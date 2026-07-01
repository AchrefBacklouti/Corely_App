import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../Models/food_item_model.dart';

// ─── AddMealPage ──────────────────────────────────────────────────────────────

class AddMealPage extends StatefulWidget {
  final String initialMealType;
  const AddMealPage({super.key, this.initialMealType = 'lunch'});

  @override
  State<AddMealPage> createState() => _AddMealPageState();
}

class _AddMealPageState extends State<AddMealPage>
    with TickerProviderStateMixin {
  late final TextEditingController _searchCtrl;
  late final ScrollController _mealScrollCtrl;
  late final TabController _tabCtrl;

  String _mealType = 'lunch';
  List<FoodItem> _best = [];
  List<FoodItem> _more = [];
  bool _loading = false;
  bool _searched = false;

  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _mealType = widget.initialMealType;
    _searchCtrl = TextEditingController();
    _mealScrollCtrl = ScrollController();
    _tabCtrl = TabController(length: 4, vsync: this);
    _initSpeech();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locale ??= Localizations.localeOf(context);
  }

  // Returns "&lc=en&cc=gb" style params for the OpenFoodFacts API.
  String get _offLocaleParams {
    final lang = _locale?.languageCode ?? 'en';
    final cc = _locale?.countryCode?.toLowerCase();
    return '&lc=$lang${cc != null && cc.isNotEmpty ? '&cc=$cc' : ''}';
  }

  // Picks the most readable name: prefers the locale-specific field
  // (e.g. product_name_en) before falling back to the generic product_name.
  String _localName(Map<String, dynamic> p) {
    final lang = _locale?.languageCode ?? 'en';
    final specific = p['product_name_$lang']?.toString().trim() ?? '';
    if (specific.isNotEmpty) return specific;
    return (p['product_name'] ?? '').toString().trim();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (_) {
        if (mounted) setState(() => _isListening = false);
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _mealScrollCtrl.dispose();
    _tabCtrl.dispose();
    _speech.stop();
    super.dispose();
  }

  // ── Text search ─────────────────────────────────────────────────────────────
  Future<void> _search(String query) async {
    query = query.trim();
    if (query.isEmpty) {
      setState(() {
        _best = [];
        _more = [];
        _searched = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _searched = true;
    });
    try {
      final uri = Uri.parse(
        'https://world.openfoodfacts.org/cgi/search.pl'
        '?search_terms=${Uri.encodeComponent(query)}'
        '$_offLocaleParams'
        '&search_simple=1&action=process&json=1&page_size=25',
      );
      final res = await http
          .get(uri, headers: {'User-Agent': 'CorelyApp/1.0'})
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final raw = json.decode(res.body) as Map<String, dynamic>;
        final items = ((raw['products'] as List<dynamic>?) ?? [])
            .map((p) => (p as Map<String, dynamic>))
            .where((p) => _localName(p).isNotEmpty)
            .map((p) {
              final n = p['nutriments'] as Map<String, dynamic>? ?? {};
              return FoodItem(
                id: (p['id'] ?? p['code'] ?? '').toString(),
                name: _localName(p),
                calories: (n['energy-kcal_100g'] as num?)?.toInt() ?? 0,
                protein: (n['proteins_100g'] as num?)?.toDouble() ?? 0,
                carbs: (n['carbohydrates_100g'] as num?)?.toDouble() ?? 0,
                fats: (n['fat_100g'] as num?)?.toDouble() ?? 0,
                servingSize: p['serving_size']?.toString() ?? '100g',
                image: (p['image_url'] ?? p['image_small_url'] ?? '')
                    .toString(),
                source: 'openfoodfacts',
              );
            })
            .toList();
        if (!mounted) return;
        setState(() {
          _best = items.take(3).toList();
          _more = items.skip(3).toList();
          _loading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _loading = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // ── Barcode lookup ───────────────────────────────────────────────────────────
  Future<void> _lookupBarcode(String barcode) async {
    setState(() {
      _loading = true;
      _searched = true;
    });
    try {
      final uri = Uri.parse(
        'https://world.openfoodfacts.org/api/v0/product/$barcode.json'
        '?${_offLocaleParams.replaceFirst('&', '')}',
      );
      final res = await http
          .get(uri, headers: {'User-Agent': 'CorelyApp/1.0'})
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final raw = json.decode(res.body) as Map<String, dynamic>;
        if ((raw['status'] as int?) == 1) {
          final p = raw['product'] as Map<String, dynamic>;
          final n = p['nutriments'] as Map<String, dynamic>? ?? {};
          final item = FoodItem(
            id: barcode,
            name: _localName(p).isNotEmpty ? _localName(p) : 'Unknown Product',
            calories: (n['energy-kcal_100g'] as num?)?.toInt() ?? 0,
            protein: (n['proteins_100g'] as num?)?.toDouble() ?? 0,
            carbs: (n['carbohydrates_100g'] as num?)?.toDouble() ?? 0,
            fats: (n['fat_100g'] as num?)?.toDouble() ?? 0,
            servingSize: p['serving_size']?.toString() ?? '100g',
            image: (p['image_url'] ?? p['image_small_url'] ?? '').toString(),
            source: 'openfoodfacts',
          );
          if (!mounted) return;
          setState(() {
            _best = [item];
            _more = [];
            _loading = false;
            _searchCtrl.text = item.name;
          });
        } else {
          if (!mounted) return;
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product not found in database'),
              backgroundColor: Color(0xFF1C2130),
            ),
          );
        }
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // ── Barcode scanner ──────────────────────────────────────────────────────────
  Future<void> _openBarcodeScanner() async {
    final String? barcode = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _BarcodeScannerSheet(),
    );
    if (barcode != null && mounted) {
      _lookupBarcode(barcode);
    }
  }

  // ── Voice input ──────────────────────────────────────────────────────────────
  Future<void> _toggleVoice() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition not available on this device'),
          backgroundColor: Color(0xFF1C2130),
        ),
      );
      return;
    }
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      _search(_searchCtrl.text);
    } else {
      setState(() => _isListening = true);
      try {
        await _speech.listen(
          onResult: (result) {
            setState(() => _searchCtrl.text = result.recognizedWords);
            if (result.finalResult && result.recognizedWords.isNotEmpty) {
              _speech.stop();
              setState(() => _isListening = false);
              _search(result.recognizedWords);
            }
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          listenOptions: SpeechListenOptions(
            partialResults: true,
            cancelOnError: true,
          ),
        );
      } catch (_) {
        setState(() => _isListening = false);
      }
    }
  }

  void _selectMealType(int index) {
    setState(() => _mealType = mealCategories[index].id);
    final offset = (index * 105.0) - 50;
    _mealScrollCtrl.animateTo(
      offset.clamp(0.0, double.infinity),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _openDetail(FoodItem food) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoodDetailPage(food: food, mealType: _mealType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mealName = mealCategories
        .firstWhere((c) => c.id == _mealType, orElse: () => mealCategories[1])
        .name;
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: _buildAppBar(mealName),
      body: Column(
        children: [
          _buildMealScroller(),
          _buildSearchBar(),
          _buildTabBar(),
          Divider(height: 1, color: Colors.white.withOpacity(0.06)),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  AppBar _buildAppBar(String mealName) {
    return AppBar(
      backgroundColor: const Color(0xFF0D1117),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            mealName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.white54, size: 20),
        ],
      ),
      centerTitle: true,
      actions: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.4)),
            ),
            child: const Icon(Icons.check, color: Colors.blue, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildMealScroller() {
    return Container(
      height: 66,
      color: const Color(0xFF111622),
      child: ListView.builder(
        controller: _mealScrollCtrl,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: mealCategories.length,
        itemBuilder: (_, i) {
          final cat = mealCategories[i];
          final sel = _mealType == cat.id;
          return GestureDetector(
            onTap: () => _selectMealType(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? Colors.blue : const Color(0xFF1C2130),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sel ? Colors.blue : Colors.white.withOpacity(0.08),
                ),
                boxShadow: sel
                    ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.28),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale: sel ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 280),
                    child: Text(cat.icon, style: const TextStyle(fontSize: 15)),
                  ),
                  const SizedBox(width: 6),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 280),
                    style: TextStyle(
                      color: sel ? Colors.white : Colors.white60,
                      fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    child: Text(cat.name),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Search bar with voice + barcode icons ────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              onChanged: (v) {
                setState(() {});
                _search(v);
              },
              decoration: InputDecoration(
                hintText: _isListening ? 'Listening...' : 'Search for food...',
                hintStyle: TextStyle(
                  color: _isListening
                      ? Colors.blue.withOpacity(0.7)
                      : Colors.white.withOpacity(0.35),
                  fontSize: 15,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white38,
                  size: 22,
                ),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.white.withOpacity(0.4),
                          size: 18,
                        ),
                        onPressed: () {
                          _searchCtrl.clear();
                          _search('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1C2130),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _inputActionBtn(
            icon: _isListening ? Icons.mic : Icons.mic_none,
            color: _isListening ? Colors.blue : Colors.white54,
            active: _isListening,
            onTap: _toggleVoice,
            tooltip: 'Voice search',
          ),
          const SizedBox(width: 6),
          _inputActionBtn(
            icon: Icons.qr_code_scanner,
            color: Colors.white54,
            active: false,
            onTap: _openBarcodeScanner,
            tooltip: 'Scan barcode',
          ),
        ],
      ),
    );
  }

  Widget _inputActionBtn({
    required IconData icon,
    required Color color,
    required bool active,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: active
                ? Colors.blue.withOpacity(0.15)
                : const Color(0xFF1C2130),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active
                  ? Colors.blue.withOpacity(0.5)
                  : Colors.white.withOpacity(0.08),
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabCtrl,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white38,
      indicatorColor: Colors.blue,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      tabs: const [
        Tab(text: 'All'),
        Tab(text: 'My Meals'),
        Tab(text: 'My Recipes'),
        Tab(text: 'My Foods'),
      ],
    );
  }

  Widget _buildResults() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 2),
      );
    }
    if (!_searched) {
      return _buildSearchMascot();
    }
    if (_best.isEmpty && _more.isEmpty) {
      return _emptyState(Icons.search_off, 'No results found');
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        if (_best.isNotEmpty) ...[
          _sectionHeader('Best Match'),
          const SizedBox(height: 10),
          ..._best.map((f) => _FoodRow(food: f, onTap: () => _openDetail(f))),
        ],
        if (_more.isNotEmpty) ...[
          const SizedBox(height: 20),
          _sectionHeader('More Results'),
          const SizedBox(height: 10),
          ..._more.map((f) => _FoodRow(food: f, onTap: () => _openDetail(f))),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Show more results...',
                style: TextStyle(color: Colors.blue, fontSize: 13),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSearchMascot() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/img/search.png', width: 160, fit: BoxFit.contain),
          const SizedBox(height: 22),
          const Text(
            'Search for food',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Type a name, scan a barcode,\nor use your voice',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.38),
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(IconData icon, String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 44, color: Colors.white.withOpacity(0.14)),
          const SizedBox(height: 12),
          Text(
            msg,
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2130),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, size: 11, color: Colors.green[400]),
              const SizedBox(width: 4),
              const Text(
                'Only',
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── _FoodRow ─────────────────────────────────────────────────────────────────

class _FoodRow extends StatelessWidget {
  final FoodItem food;
  final VoidCallback onTap;
  const _FoodRow({required this.food, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: const Color(0xFF1C2130),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.blue.withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.verified, size: 14, color: Colors.green[400]),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${food.calories} cal, ${food.servingSize}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(Icons.add, color: Colors.blue, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── _BarcodeScannerSheet ─────────────────────────────────────────────────────

class _BarcodeScannerSheet extends StatefulWidget {
  const _BarcodeScannerSheet();

  @override
  State<_BarcodeScannerSheet> createState() => _BarcodeScannerSheetState();
}

class _BarcodeScannerSheetState extends State<_BarcodeScannerSheet> {
  final MobileScannerController _ctrl = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Color(0xFF0D1117),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Scan Barcode',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Point camera at the product barcode',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    MobileScanner(
                      controller: _ctrl,
                      onDetect: (capture) {
                        if (_scanned) return;
                        for (final barcode in capture.barcodes) {
                          if (barcode.rawValue != null) {
                            _scanned = true;
                            Navigator.pop(context, barcode.rawValue);
                            break;
                          }
                        }
                      },
                    ),
                    // scan frame
                    Container(
                      width: 220,
                      height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                    ),
                    // corner accents
                    ..._cornerAccents(),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => _ctrl.toggleTorch(),
                icon: const Icon(Icons.flashlight_on, color: Colors.white54),
                tooltip: 'Toggle flashlight',
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white38, size: 16),
                label: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white38, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  List<Widget> _cornerAccents() {
    const size = 18.0;
    const thick = 3.0;
    const color = Colors.blue;
    final corners = [
      [Alignment.topLeft, const BorderRadius.only(topLeft: Radius.circular(4))],
      [
        Alignment.topRight,
        const BorderRadius.only(topRight: Radius.circular(4)),
      ],
      [
        Alignment.bottomLeft,
        const BorderRadius.only(bottomLeft: Radius.circular(4)),
      ],
      [
        Alignment.bottomRight,
        const BorderRadius.only(bottomRight: Radius.circular(4)),
      ],
    ];
    return corners.map((c) {
      final align = c[0] as Alignment;
      final radius = c[1] as BorderRadius;
      final isLeft = align.x < 0;
      final isTop = align.y < 0;
      return Positioned(
        left: isLeft
            ? (MediaQuery.of(context).size.width / 2 - 110 - 24 + 0)
            : null,
        right: !isLeft
            ? (MediaQuery.of(context).size.width / 2 - 110 - 24 + 0)
            : null,
        top: isTop ? 0 : null,
        bottom: !isTop ? 0 : null,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border(
              top: isTop
                  ? const BorderSide(color: color, width: thick)
                  : BorderSide.none,
              bottom: !isTop
                  ? const BorderSide(color: color, width: thick)
                  : BorderSide.none,
              left: isLeft
                  ? const BorderSide(color: color, width: thick)
                  : BorderSide.none,
              right: !isLeft
                  ? const BorderSide(color: color, width: thick)
                  : BorderSide.none,
            ),
          ),
        ),
      );
    }).toList();
  }
}

// ─── FoodDetailPage ───────────────────────────────────────────────────────────

class FoodDetailPage extends StatefulWidget {
  final FoodItem food;
  final String mealType;
  const FoodDetailPage({super.key, required this.food, required this.mealType});

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  double _servings = 1.0;
  late String _mealType;
  final List<DateTime> _days = [DateTime.now()];

  @override
  void initState() {
    super.initState();
    _mealType = widget.mealType;
  }

  double get _cal => widget.food.calories * _servings;
  double get _pro => widget.food.protein * _servings;
  double get _carb => widget.food.carbs * _servings;
  double get _fat => widget.food.fats * _servings;

  void _toggleDay(DateTime day) {
    setState(() {
      final idx = _days.indexWhere(
        (d) => d.year == day.year && d.month == day.month && d.day == day.day,
      );
      if (idx >= 0) {
        _days.removeAt(idx);
      } else {
        _days.add(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Food',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => Navigator.pop(context, {
              'food': widget.food,
              'servings': _servings,
              'mealType': _mealType,
              'days': _days,
            }),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFoodHeader(),
            const SizedBox(height: 24),
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildDayPicker(),
            const SizedBox(height: 28),
            _buildNutritionRing(),
            const SizedBox(height: 24),
            _buildDailyGoals(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.verified, color: Colors.green[400], size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            widget.food.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C2130),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          _infoRow('Serving Size', widget.food.servingSize),
          _divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Number of Servings',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      _servings % 1 == 0
                          ? _servings.toInt().toString()
                          : _servings.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                    activeTrackColor: Colors.blue,
                    inactiveTrackColor: Colors.white.withOpacity(0.12),
                    thumbColor: Colors.blue,
                    overlayColor: Colors.blue.withOpacity(0.12),
                  ),
                  child: Slider(
                    value: _servings,
                    min: 0.25,
                    max: 5,
                    divisions: 19,
                    onChanged: (v) => setState(() => _servings = v),
                  ),
                ),
              ],
            ),
          ),
          _divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Text(
                  'Meal',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const Spacer(),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _mealType,
                    dropdownColor: const Color(0xFF1C2130),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white38,
                    ),
                    onChanged: (v) {
                      if (v != null) setState(() => _mealType = v);
                    },
                    items: mealCategories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Divider(height: 1, color: Colors.white.withOpacity(0.05));

  Widget _buildDayPicker() {
    final today = DateTime.now();
    const dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Add to Multiple Days',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.help_outline,
              size: 14,
              color: Colors.white.withOpacity(0.35),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(7, (i) {
              final day = today.add(Duration(days: i));
              final sel = _days.any(
                (d) =>
                    d.year == day.year &&
                    d.month == day.month &&
                    d.day == day.day,
              );
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => _toggleDay(day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 44,
                    height: 54,
                    decoration: BoxDecoration(
                      color: sel ? Colors.blue : const Color(0xFF1C2130),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: sel
                            ? Colors.blue
                            : Colors.white.withOpacity(0.07),
                      ),
                      boxShadow: sel
                          ? [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 6,
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayLabels[day.weekday % 7],
                          style: TextStyle(
                            color: sel ? Colors.white : Colors.white54,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${day.day}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionRing() {
    final total = _pro * 4 + _carb * 4 + _fat * 9;
    final carbPct = total > 0 ? _carb * 4 / total : 0.0;
    final fatPct = total > 0 ? _fat * 9 / total : 0.0;
    final proPct = total > 0 ? _pro * 4 / total : 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2130),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 10,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.06),
                  ),
                ),
                CircularProgressIndicator(
                  value: (_cal / 2000).clamp(0.0, 1.0),
                  strokeWidth: 10,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _cal.toInt().toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'cal',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [
                _macroRow(
                  'Carbs',
                  carbPct,
                  Colors.blue,
                  '${_carb.toStringAsFixed(1)}g',
                ),
                const SizedBox(height: 14),
                _macroRow(
                  'Fat',
                  fatPct,
                  Colors.yellow[700]!,
                  '${_fat.toStringAsFixed(1)}g',
                ),
                const SizedBox(height: 14),
                _macroRow(
                  'Protein',
                  proPct,
                  Colors.orange,
                  '${_pro.toStringAsFixed(1)}g',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _macroRow(String label, double pct, Color color, String val) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Text(
          '${(pct * 100).toInt()}%',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const Spacer(),
        Text(val, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildDailyGoals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Percent of Daily Goals',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _goalBar('Calories', (_cal / 2000).clamp(0.0, 1.0), Colors.orange),
        const SizedBox(height: 10),
        _goalBar('Carbs', (_carb / 250).clamp(0.0, 1.0), Colors.blue),
        const SizedBox(height: 10),
        _goalBar('Fat', (_fat / 65).clamp(0.0, 1.0), Colors.yellow[700]!),
        const SizedBox(height: 10),
        _goalBar('Protein', (_pro / 50).clamp(0.0, 1.0), Colors.orange),
      ],
    );
  }

  Widget _goalBar(String label, double pct, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
            Text(
              '${(pct * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: Colors.white.withOpacity(0.07),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
