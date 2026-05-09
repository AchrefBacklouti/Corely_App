import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// Scope enum
// ─────────────────────────────────────────────
enum GraphScope { month, threeMonths, sixMonths, year }

extension GraphScopeLabel on GraphScope {
  String get label => switch (this) {
    GraphScope.month => '1M',
    GraphScope.threeMonths => '3M',
    GraphScope.sixMonths => '6M',
    GraphScope.year => '1Y',
  };

  String get fullLabel => switch (this) {
    GraphScope.month => 'This Month',
    GraphScope.threeMonths => '3 Months',
    GraphScope.sixMonths => '6 Months',
    GraphScope.year => 'This Year',
  };
}

// ─────────────────────────────────────────────
// Exercise filter (Strength page only)
// ─────────────────────────────────────────────
class StrengthExercise {
  final String key;
  final String label;
  final Color color;
  const StrengthExercise({
    required this.key,
    required this.label,
    required this.color,
  });
}

const List<StrengthExercise> kStrengthExercises = [
  StrengthExercise(key: 'Overall', label: 'Overall', color: Color(0xFF80CBC4)),
  StrengthExercise(key: 'Bench', label: 'Bench', color: Color(0xFFc9a6f5)),
  StrengthExercise(key: 'Squat', label: 'Squat', color: Color(0xFF68c87a)),
  StrengthExercise(
    key: 'Deadlift',
    label: 'Deadlift',
    color: Color(0xFFf5a623),
  ),
];

StrengthExercise exerciseByKey(String key) => kStrengthExercises.firstWhere(
  (e) => e.key == key,
  orElse: () => kStrengthExercises.first,
);

// ─────────────────────────────────────────────
// Data model & generator
// ─────────────────────────────────────────────
class TrendDataPoint {
  final DateTime date;
  final double value;
  const TrendDataPoint({required this.date, required this.value});
}

List<TrendDataPoint> _generateData({
  required String metric,
  required int daysBack,
}) {
  final now = DateTime.now();
  final points = <TrendDataPoint>[];

  // (base kg, gain-per-day, noise amplitude) — realistic per lift
  final (double base, double step, double noise) = switch (metric) {
    'Bench' => (80.0, 0.06, 2.5),
    'Squat' => (120.0, 0.09, 3.0),
    'Deadlift' => (140.0, 0.10, 3.5),
    'Overall' => (113.0, 0.08, 2.0),
    'Strength' => (113.0, 0.08, 2.0),
    'Bodyweight' => (84.0, -0.025, 0.4),
    _ => (50.0, 0.10, 2.0),
  };

  final stepDays = (daysBack / 30).ceil().clamp(1, 7);
  for (int i = daysBack; i >= 0; i -= stepDays) {
    final day = now.subtract(Duration(days: i));
    final progress = (daysBack - i) / daysBack;
    final seed = (day.day * 13 + day.month * 7) % 10 - 5;
    final value = base + step * progress * daysBack + seed * noise / 5;
    points.add(
      TrendDataPoint(
        date: day,
        value: value.clamp(base - 5, base + step * daysBack + 10),
      ),
    );
  }
  return points;
}

List<TrendDataPoint> dataForScope(String metric, GraphScope scope) {
  final days = switch (scope) {
    GraphScope.month => 30,
    GraphScope.threeMonths => 90,
    GraphScope.sixMonths => 180,
    GraphScope.year => 365,
  };
  return _generateData(metric: metric, daysBack: days);
}

// ─────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────
class TrendDetailPage extends StatefulWidget {
  final String title;
  final String unit;
  final Color accentColor;
  final IconData icon;

  const TrendDetailPage({
    super.key,
    required this.title,
    required this.unit,
    required this.accentColor,
    required this.icon,
  });

  @override
  State<TrendDetailPage> createState() => _TrendDetailPageState();
}

class _TrendDetailPageState extends State<TrendDetailPage>
    with SingleTickerProviderStateMixin {
  GraphScope _scope = GraphScope.month;
  String _exerciseKey = 'Overall';
  late AnimationController _animCtrl;
  late Animation<double> _anim;
  List<TrendDataPoint> _data = [];
  int? _hoverIndex;

  bool get _isStrength => widget.title == 'Strength';
  Color get _activeColor =>
      _isStrength ? exerciseByKey(_exerciseKey).color : widget.accentColor;
  String get _activeMetric => _isStrength ? _exerciseKey : widget.title;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _reload();
  }

  void _reload() {
    setState(() {
      _data = dataForScope(_activeMetric, _scope);
      _hoverIndex = null;
    });
    _animCtrl.forward(from: 0);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  double get _minVal => _data.isEmpty
      ? 0
      : _data.map((d) => d.value).reduce((a, b) => a < b ? a : b);
  double get _maxVal => _data.isEmpty
      ? 1
      : _data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
  double get _change =>
      _data.length < 2 ? 0 : _data.last.value - _data.first.value;
  String get _changeLabel {
    final c = _change;
    return '${c >= 0 ? '+' : ''}${c.toStringAsFixed(1)} ${widget.unit}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111015),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            _buildHeroStats(),
            const SizedBox(height: 14),
            if (_isStrength) ...[
              _buildExerciseSelector(),
              const SizedBox(height: 10),
            ],
            _buildScopeSelector(),
            const SizedBox(height: 20),
            Expanded(child: _buildChart()),
            _buildXAxisLabels(),
            const SizedBox(height: 20),
            _buildStatRow(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Top bar ──────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1f1b2e),
                border: Border.all(color: const Color(0xFF2e2a3e)),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFFc9a6f5),
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(widget.icon, color: _activeColor, size: 18),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _isStrength && _exerciseKey != 'Overall'
                  ? '${widget.title} · $_exerciseKey'
                  : widget.title,
              key: ValueKey(_exerciseKey),
              style: const TextStyle(
                color: Color(0xFFe8e0f5),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero numbers ─────────────────────────────
  Widget _buildHeroStats() {
    final current = _hoverIndex != null
        ? _data[_hoverIndex!].value
        : (_data.isEmpty ? 0.0 : _data.last.value);
    final isPos = _change >= 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  color: _activeColor,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
                child: Text('${current.toStringAsFixed(1)} ${widget.unit}'),
              ),
              const SizedBox(height: 4),
              Text(
                _scope.fullLabel,
                style: const TextStyle(color: Color(0xFF7a6e90), fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (isPos ? Colors.greenAccent : Colors.redAccent)
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (isPos ? Colors.greenAccent : Colors.redAccent)
                    .withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isPos ? Icons.trending_up : Icons.trending_down,
                  color: isPos ? Colors.greenAccent : Colors.redAccent,
                  size: 14,
                ),
                const SizedBox(width: 5),
                Text(
                  _changeLabel,
                  style: TextStyle(
                    color: isPos ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Exercise filter pills ─────────────────────
  Widget _buildExerciseSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: kStrengthExercises.map((ex) {
            final active = ex.key == _exerciseKey;
            return GestureDetector(
              onTap: () {
                setState(() => _exerciseKey = ex.key);
                _reload();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? ex.color.withOpacity(0.15)
                      : const Color(0xFF1a1726),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active
                        ? ex.color.withOpacity(0.7)
                        : const Color(0xFF2a2733),
                    width: active ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (active) ...[
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ex.color,
                        ),
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      ex.label,
                      style: TextStyle(
                        color: active ? ex.color : const Color(0xFF6a6080),
                        fontSize: 12,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Scope selector ───────────────────────────
  Widget _buildScopeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1726),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2a2733)),
        ),
        child: Row(
          children: GraphScope.values.map((s) {
            final active = s == _scope;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _scope = s);
                  _reload();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFF2e2a42)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    border: active
                        ? Border.all(color: _activeColor.withOpacity(0.4))
                        : null,
                  ),
                  child: Text(
                    s.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: active ? _activeColor : const Color(0xFF6a6080),
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Chart ────────────────────────────────────
  Widget _buildChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => GestureDetector(
          onTapDown: (d) => _onInteract(d.localPosition),
          onPanUpdate: (d) => _onInteract(d.localPosition),
          onPanEnd: (_) => setState(() => _hoverIndex = null),
          child: CustomPaint(
            painter: _ChartPainter(
              data: _data,
              progress: _anim.value,
              accentColor: _activeColor,
              hoverIndex: _hoverIndex,
              minVal: _minVal,
              maxVal: _maxVal,
              unit: widget.unit,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }

  void _onInteract(Offset pos) {
    if (_data.isEmpty) return;
    final width = context.size?.width ?? 300;
    final idx = ((pos.dx / (width - 40)) * (_data.length - 1)).round().clamp(
      0,
      _data.length - 1,
    );
    setState(() => _hoverIndex = idx);
  }

  // ── X-axis labels ────────────────────────────
  Widget _buildXAxisLabels() {
    if (_data.isEmpty) return const SizedBox.shrink();
    String fmt(DateTime d) {
      const m = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${m[d.month - 1]} ${d.day}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:
            [_data.first.date, _data[_data.length ~/ 2].date, _data.last.date]
                .map(
                  (d) => Text(
                    fmt(d),
                    style: const TextStyle(
                      color: Color(0xFF5a5070),
                      fontSize: 10,
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  // ── Bottom stat strip ─────────────────────────
  Widget _buildStatRow() {
    if (_data.isEmpty) return const SizedBox.shrink();
    final avg =
        _data.map((d) => d.value).reduce((a, b) => a + b) / _data.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _StatChip(
            label: 'High',
            value: '${_maxVal.toStringAsFixed(1)} ${widget.unit}',
            color: Colors.greenAccent,
          ),
          const SizedBox(width: 10),
          _StatChip(
            label: 'Low',
            value: '${_minVal.toStringAsFixed(1)} ${widget.unit}',
            color: Colors.redAccent,
          ),
          const SizedBox(width: 10),
          _StatChip(
            label: 'Avg',
            value: '${avg.toStringAsFixed(1)} ${widget.unit}',
            color: _activeColor,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Chart painter
// ─────────────────────────────────────────────
class _ChartPainter extends CustomPainter {
  final List<TrendDataPoint> data;
  final double progress;
  final Color accentColor;
  final int? hoverIndex;
  final double minVal;
  final double maxVal;
  final String unit;

  const _ChartPainter({
    required this.data,
    required this.progress,
    required this.accentColor,
    required this.hoverIndex,
    required this.minVal,
    required this.maxVal,
    required this.unit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final range = (maxVal - minVal).clamp(0.001, double.infinity);
    final pad = range * 0.1;
    final lo = minVal - pad;
    final hi = maxVal + pad;

    Offset pt(int i) {
      final x = size.width * i / (data.length - 1).clamp(1, 99999);
      final y = size.height * (1 - (data[i].value - lo) / (hi - lo));
      return Offset(x, y);
    }

    final vis = ((data.length - 1) * progress).round() + 1;

    // Grid
    final grid = Paint()
      ..color = const Color(0xFF2a2733)
      ..strokeWidth = 1;
    for (int i = 1; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    // Y labels
    const ls = TextStyle(color: Color(0xFF5a5070), fontSize: 10);
    for (int i = 0; i <= 4; i++) {
      final frac = i / 4;
      final val = lo + (hi - lo) * (1 - frac);
      final tp = TextPainter(
        text: TextSpan(text: val.toStringAsFixed(1), style: ls),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, size.height * frac - 8));
    }

    if (vis < 2) return;

    // Smooth path
    final path = Path()..moveTo(pt(0).dx, pt(0).dy);
    for (int i = 1; i < vis; i++) {
      final a = pt(i - 1), b = pt(i);
      final cx = (a.dx + b.dx) / 2;
      path.cubicTo(cx, a.dy, cx, b.dy, b.dx, b.dy);
    }

    // Fill
    final lastPt = pt(vis - 1);
    canvas.drawPath(
      Path.from(path)
        ..lineTo(lastPt.dx, size.height)
        ..lineTo(0, size.height)
        ..close(),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [accentColor.withOpacity(0.28), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    canvas.drawPath(
      path,
      Paint()
        ..color = accentColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Hover scrubber
    if (hoverIndex != null && hoverIndex! < vis) {
      final p = pt(hoverIndex!);

      // Dashed line
      final dash = Paint()
        ..color = accentColor.withOpacity(0.4)
        ..strokeWidth = 1;
      for (double y = 0; y < size.height; y += 8) {
        canvas.drawLine(
          Offset(p.dx, y),
          Offset(p.dx, (y + 4).clamp(0, size.height)),
          dash,
        );
      }

      canvas.drawCircle(p, 10, Paint()..color = accentColor.withOpacity(0.15));
      canvas.drawCircle(p, 5, Paint()..color = accentColor);
      canvas.drawCircle(p, 3, Paint()..color = Colors.white);

      // Tooltip
      final val = data[hoverIndex!].value;
      final d = data[hoverIndex!].date;
      const mo = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final lbl =
          '${mo[d.month - 1]} ${d.day}   ${val.toStringAsFixed(1)} $unit';

      final tp = TextPainter(
        text: TextSpan(
          text: lbl,
          style: TextStyle(
            color: accentColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      const pd = 8.0;
      final bw = tp.width + pd * 2;
      final bh = tp.height + pd * 2;
      final bx = (p.dx - bw / 2).clamp(0.0, size.width - bw);
      final by = p.dy - bh - 14 < 0 ? p.dy + 14 : p.dy - bh - 14;

      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(bx, by, bw, bh),
        const Radius.circular(6),
      );
      canvas.drawRRect(rr, Paint()..color = const Color(0xFF1f1b2e));
      canvas.drawRRect(
        rr,
        Paint()
          ..color = accentColor.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      tp.paint(canvas, Offset(bx + pd, by + pd));
    }
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.progress != progress ||
      old.hoverIndex != hoverIndex ||
      old.data != data ||
      old.accentColor != accentColor;
}

// ─────────────────────────────────────────────
// Stat chip
// ─────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1726),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2a2733)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF6a6080), fontSize: 10),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );
}
