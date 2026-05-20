import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:main_build/Controllers/user_provider.dart';
import 'package:main_build/data/supabase_service.dart';
import 'package:main_build/Views/SharedWidgets/toggle-Unit.dart';
import 'package:main_build/Theme/theme_scope.dart';
import 'athlete_page.dart';
import 'trend_detail_page.dart';
import 'package:main_build/theme/app_theme.dart';

// ─────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────
class MuscleData {
  final String id;
  final int recoveryScore;
  final int developmentStatus;

  const MuscleData({
    required this.id,
    required this.recoveryScore,
    required this.developmentStatus,
  });
}

// By default the app shows the anatomy silhouette without any
// synthetic per-muscle colour overlays. These lists are intentionally
// empty so the anatomy displays a neutral outline. They can be
// populated later with real exercise-driven data via
// `setMuscleData(front, back)` or by passing lists into `AnatomyView`.
List<MuscleData> _frontMuscles = [];
List<MuscleData> _backMuscles = [];

/// Replace the current muscle overlay data (used when colouring the SVG).
/// Call with real muscle data when available; pass `null` to leave a side
/// unchanged.
void setMuscleData(List<MuscleData>? front, List<MuscleData>? back) {
  if (front != null) _frontMuscles = front;
  if (back != null) _backMuscles = back;
}

// ─────────────────────────────────────────────
// Color helpers
// ─────────────────────────────────────────────
String _colorToHex(Color c) =>
    '#${(c.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

Color _recoveryColor(int score) {
  final t = score.clamp(0, 100) / 100.0;
  if (t <= 0.5) {
    return Color.lerp(const Color(0xFF68F868), Colors.yellow, t * 2)!;
  }
  return Color.lerp(Colors.yellow, Colors.red, (t - 0.5) * 2)!;
}

Color _developmentColor(int d) {
  final t = d.clamp(0, 100) / 100.0;
  if (t <= 0.5) {
    return Color.lerp(const Color(0xFF81D4FA), const Color(0xFF68F868), t * 2)!;
  }
  return Color.lerp(const Color(0xFF68F868), Colors.red, (t - 0.5) * 2)!;
}

// ─────────────────────────────────────────────
// SVG colour injection
// ─────────────────────────────────────────────
Future<String> _buildColoredSvg(
  String assetPath,
  List<MuscleData> muscles,
  bool isRecovery, {
  required Color bgColor,
  required Color outlineColor,
}) async {
  String svg = await rootBundle.loadString(assetPath);

  final bgHex = _colorToHex(bgColor);
  final outlineHex = _colorToHex(outlineColor);

  // Step 1 — blank every white/black stroke & fill → background colour
  // Handles both SVG attribute form (stroke="white") and CSS style form (stroke:white)
  svg = svg
      .replaceAll('stroke="white"', 'stroke="$bgHex"')
      .replaceAll('stroke="#FFFFFF"', 'stroke="$bgHex"')
      .replaceAll('stroke="#ffffff"', 'stroke="$bgHex"')
      .replaceAll('stroke="#000000"', 'stroke="$bgHex"')
      .replaceAll('stroke="black"', 'stroke="$bgHex"')
      .replaceAll('stroke="#000"', 'stroke="$bgHex"')
      .replaceAll('fill="white"', 'fill="$bgHex"')
      .replaceAll('fill="#FFFFFF"', 'fill="$bgHex"')
      .replaceAll('fill="#ffffff"', 'fill="$bgHex"')
      .replaceAll('fill="#D9D9D9"', 'fill="$bgHex"')
      // CSS style="" variants
      .replaceAll('stroke:white', 'stroke:$bgHex')
      .replaceAll('stroke:#FFFFFF', 'stroke:$bgHex')
      .replaceAll('stroke:#ffffff', 'stroke:$bgHex')
      .replaceAll('stroke:#000000', 'stroke:$bgHex')
      .replaceAll('stroke:black', 'stroke:$bgHex')
      .replaceAll('stroke:#000', 'stroke:$bgHex')
      .replaceAll('fill:white', 'fill:$bgHex')
      .replaceAll('fill:#FFFFFF', 'fill:$bgHex')
      .replaceAll('fill:#ffffff', 'fill:$bgHex')
      .replaceAll('fill:#D9D9D9', 'fill:$bgHex');

  // Step 2 — restore humanoid silhouette strokes → outlineColour (textPrimary)
  // face.svg uses id="front_outline"; back.svg uses id="back_ouline" (SVG typo)
  // Handles <path>, self-closing <g>, and <g>…</g> with stroke as attribute OR in style=""
  String applyOutline(String s) => s
      .replaceAll(
        RegExp(r'\bstroke="[^"]*"', caseSensitive: false),
        'stroke="$outlineHex"',
      )
      .replaceAllMapped(
        RegExp(r'\bstroke:([^;}" ]+)', caseSensitive: false),
        (_) => 'stroke:$outlineHex',
      );

  for (final outlineId in ['front_outline', 'back_ouline']) {
    final eid = RegExp.escape(outlineId);

    // Self-closing <path id="outlineId" … />
    svg = svg.replaceAllMapped(
      RegExp(
        r'(<path\b)([^>]*\bid="' + eid + r'"[^>]*?)(/>)',
        caseSensitive: false,
      ),
      (m) => '${m[1]}${applyOutline(m[2]!)}${m[3]}',
    );

    // Non-self-closing <path id="outlineId" …> … </path>
    svg = svg.replaceAllMapped(
      RegExp(
        r'(<path\b)([^>]*\bid="' + eid + r'"[^>]*?)>(.*?)(</path>)',
        caseSensitive: false,
        dotAll: true,
      ),
      (m) => '${m[1]}${applyOutline(m[2]!)}>${m[3]}${m[4]}',
    );

    // <g id="outlineId" …> … </g> — fix opening tag attrs + all child strokes
    svg = svg.replaceAllMapped(
      RegExp(
        r'(<g\b)([^>]*\bid="' + eid + r'"[^>]*)(>)(.*?)(</g>)',
        caseSensitive: false,
        dotAll: true,
      ),
      (m) =>
          '${m[1]}${applyOutline(m[2]!)}${m[3]}${applyOutline(m[4]!)}${m[5]}',
    );
  }

  // Step 3 — per-muscle colour injection
  for (final m in muscles) {
    final color = isRecovery
        ? _recoveryColor(m.recoveryScore)
        : _developmentColor(m.developmentStatus);
    final hex = _colorToHex(color);
    const opacity = '0.88';
    final eid = RegExp.escape(m.id);

    svg = svg.replaceAllMapped(
      RegExp(
        r'<g\s+id="' + eid + r'"[^>]*>(.*?)</g>',
        dotAll: true,
        caseSensitive: false,
      ),
      (match) {
        var content = match.group(1) ?? '';
        content = content
            .replaceAll(
              RegExp('fill="$bgHex"', caseSensitive: false),
              'fill="$hex"',
            )
            .replaceAll(
              RegExp('stroke="$bgHex"', caseSensitive: false),
              'stroke="$hex"',
            )
            .replaceAll(RegExp(r'\bopacity="[^"]*"'), 'opacity="$opacity"');
        return '<g id="${m.id}">$content</g>';
      },
    );

    svg = svg.replaceAllMapped(
      RegExp(
        r'<(path|ellipse|circle|rect)\s+id="' + eid + r'"([^>]*)(/?)>',
        caseSensitive: false,
      ),
      (match) {
        final tag = match.group(1)!;
        var attrs = match.group(2) ?? '';
        final self = match.group(3) ?? '';
        attrs = attrs
            .replaceAll(RegExp(r'\s*\bfill="[^"]*"'), '')
            .replaceAll(RegExp(r'\s*\bstroke="[^"]*"'), '')
            .replaceAll(RegExp(r'\s*\bopacity="[^"]*"'), '');
        return '<$tag id="${m.id}" fill="$hex" stroke="$hex" opacity="$opacity"$attrs$self>';
      },
    );
  }

  return svg;
}

// ─────────────────────────────────────────────
// SVG cache
//
// Stores the colours used during the last build alongside the SVG strings.
// isReady() returns false if the colours have changed, which causes
// prewarm() to invalidate and rebuild the affected slots.
// ─────────────────────────────────────────────
class _SvgCache {
  static String? frontRecoveryDark,
      backRecoveryDark,
      frontBalanceDark,
      backBalanceDark;
  static String? frontRecoveryLight,
      backRecoveryLight,
      frontBalanceLight,
      backBalanceLight;

  // Colours that were used when each brightness slot was last built.
  static int? _darkBg, _darkOutline;
  static int? _lightBg, _lightOutline;

  /// Returns true only when all four slots exist AND were built with the
  /// exact same colours the caller is now requesting.
  static bool isReady({
    required bool isDark,
    required Color bgColor,
    required Color outlineColor,
  }) {
    if (isDark) {
      return frontRecoveryDark != null &&
          backRecoveryDark != null &&
          frontBalanceDark != null &&
          backBalanceDark != null &&
          _darkBg == bgColor.value &&
          _darkOutline == outlineColor.value;
    } else {
      return frontRecoveryLight != null &&
          backRecoveryLight != null &&
          frontBalanceLight != null &&
          backBalanceLight != null &&
          _lightBg == bgColor.value &&
          _lightOutline == outlineColor.value;
    }
  }

  static void _invalidate(bool isDark) {
    if (isDark) {
      frontRecoveryDark = backRecoveryDark = frontBalanceDark =
          backBalanceDark = null;
      _darkBg = _darkOutline = null;
    } else {
      frontRecoveryLight = backRecoveryLight = frontBalanceLight =
          backBalanceLight = null;
      _lightBg = _lightOutline = null;
    }
  }

  static Future<void> prewarm({
    required bool isDark,
    required Color bgColor,
    required Color outlineColor,
  }) async {
    // Colours changed → discard stale strings before rebuilding.
    if (isDark) {
      if (_darkBg != bgColor.value || _darkOutline != outlineColor.value) {
        _invalidate(true);
      }
    } else {
      if (_lightBg != bgColor.value || _lightOutline != outlineColor.value) {
        _invalidate(false);
      }
    }

    Future<String> get(
      String? cached,
      String path,
      List<MuscleData> muscles,
      bool recovery,
    ) => cached != null
        ? Future.value(cached)
        : _buildColoredSvg(
            path,
            muscles,
            recovery,
            bgColor: bgColor,
            outlineColor: outlineColor,
          );

    if (isDark) {
      final r = await Future.wait([
        get(
          frontRecoveryDark,
          'assets/img/anatomy/face.svg',
          _frontMuscles,
          true,
        ),
        get(
          backRecoveryDark,
          'assets/img/anatomy/back.svg',
          _backMuscles,
          true,
        ),
        get(
          frontBalanceDark,
          'assets/img/anatomy/face.svg',
          _frontMuscles,
          false,
        ),
        get(
          backBalanceDark,
          'assets/img/anatomy/back.svg',
          _backMuscles,
          false,
        ),
      ]);
      frontRecoveryDark = r[0];
      backRecoveryDark = r[1];
      frontBalanceDark = r[2];
      backBalanceDark = r[3];
      _darkBg = bgColor.value;
      _darkOutline = outlineColor.value;
    } else {
      final r = await Future.wait([
        get(
          frontRecoveryLight,
          'assets/img/anatomy/face_light.svg',
          _frontMuscles,
          true,
        ),
        get(
          backRecoveryLight,
          'assets/img/anatomy/back_light.svg',
          _backMuscles,
          true,
        ),
        get(
          frontBalanceLight,
          'assets/img/anatomy/face_light.svg',
          _frontMuscles,
          false,
        ),
        get(
          backBalanceLight,
          'assets/img/anatomy/back_light.svg',
          _backMuscles,
          false,
        ),
      ]);
      frontRecoveryLight = r[0];
      backRecoveryLight = r[1];
      frontBalanceLight = r[2];
      backBalanceLight = r[3];
      _lightBg = bgColor.value;
      _lightOutline = outlineColor.value;
    }
  }

  static String? front(bool isRecovery, bool isDark) => isDark
      ? (isRecovery ? frontRecoveryDark : frontBalanceDark)
      : (isRecovery ? frontRecoveryLight : frontBalanceLight);

  static String? back(bool isRecovery, bool isDark) => isDark
      ? (isRecovery ? backRecoveryDark : backBalanceDark)
      : (isRecovery ? backRecoveryLight : backBalanceLight);
}

// ─────────────────────────────────────────────
// View mode
// ─────────────────────────────────────────────
enum AnatomyViewMode { both, frontOnly, backOnly }

// ─────────────────────────────────────────────
// AnatomyView widget
// ─────────────────────────────────────────────
class AnatomyView extends StatefulWidget {
  final bool isRecovery;
  final AnatomyViewMode viewMode;
  final ValueChanged<AnatomyViewMode> onViewModeChanged;
  final List<MuscleData>? frontMuscles;
  final List<MuscleData>? backMuscles;

  const AnatomyView({
    super.key,
    required this.isRecovery,
    required this.viewMode,
    required this.onViewModeChanged,
    this.frontMuscles,
    this.backMuscles,
  });

  @override
  State<AnatomyView> createState() => _AnatomyViewState();
}

class _AnatomyViewState extends State<AnatomyView> {
  // Track the colours we last launched a build with so we never
  // fire two concurrent builds for the same colours.
  int? _pendingBg;
  int? _pendingOutline;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureWarmed();
  }

  @override
  void didUpdateWidget(AnatomyView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureWarmed();
  }

  void _ensureWarmed() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = context.colors.background; // invisible strokes
    final outlineColor = context.colors.textPrimary; // silhouette stroke

    // If caller supplied muscle lists use them for this build.
    if (widget.frontMuscles != null) _frontMuscles = widget.frontMuscles!;
    if (widget.backMuscles != null) _backMuscles = widget.backMuscles!;

    // Already ready with these exact colours — nothing to do.
    if (_SvgCache.isReady(
      isDark: isDark,
      bgColor: bgColor,
      outlineColor: outlineColor,
    )) {
      return;
    }

    // A build is already in flight for these colours — don't double-dispatch.
    if (_pendingBg == bgColor.value && _pendingOutline == outlineColor.value) {
      return;
    }

    _pendingBg = bgColor.value;
    _pendingOutline = outlineColor.value;

    _SvgCache.prewarm(
      isDark: isDark,
      bgColor: bgColor,
      outlineColor: outlineColor,
    ).then((_) {
      // Clear the pending markers so a future theme change can trigger again.
      _pendingBg = null;
      _pendingOutline = null;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final frontSvg = _SvgCache.front(widget.isRecovery, isDark);
    final backSvg = _SvgCache.back(widget.isRecovery, isDark);

    if (frontSvg == null || backSvg == null) {
      return SizedBox(
        height: 260,
        child: Center(
          child: CircularProgressIndicator(color: context.colors.accent),
        ),
      );
    }

    return Column(
      children: [
        _ViewModeSelector(
          current: widget.viewMode,
          onChanged: widget.onViewModeChanged,
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          child: _buildFigures(frontSvg, backSvg),
        ),
      ],
    );
  }

  Widget _buildFigures(String frontSvg, String backSvg) {
    switch (widget.viewMode) {
      case AnatomyViewMode.both:
        return Row(
          key: const ValueKey('both'),
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 195 / 285,
                child: SvgPicture.string(frontSvg),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AspectRatio(
                aspectRatio: 191 / 281,
                child: SvgPicture.string(backSvg),
              ),
            ),
          ],
        );
      case AnatomyViewMode.frontOnly:
        return Center(
          key: const ValueKey('front'),
          child: SizedBox(
            width: 220,
            child: AspectRatio(
              aspectRatio: 195 / 285,
              child: SvgPicture.string(frontSvg),
            ),
          ),
        );
      case AnatomyViewMode.backOnly:
        return Center(
          key: const ValueKey('back'),
          child: SizedBox(
            width: 220,
            child: AspectRatio(
              aspectRatio: 191 / 281,
              child: SvgPicture.string(backSvg),
            ),
          ),
        );
    }
  }
}

// ─────────────────────────────────────────────
// View-mode selector
// ─────────────────────────────────────────────
class _ViewModeSelector extends StatelessWidget {
  final AnatomyViewMode current;
  final ValueChanged<AnatomyViewMode> onChanged;
  const _ViewModeSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _ModeBtn(
          icon: Icons.view_column_rounded,
          label: 'Both',
          active: current == AnatomyViewMode.both,
          onTap: () => onChanged(AnatomyViewMode.both),
        ),
        const SizedBox(width: 6),
        _ModeBtn(
          icon: Icons.person_rounded,
          label: 'Front',
          active: current == AnatomyViewMode.frontOnly,
          onTap: () => onChanged(AnatomyViewMode.frontOnly),
        ),
        const SizedBox(width: 6),
        _ModeBtn(
          icon: Icons.accessibility_new_rounded,
          label: 'Back',
          active: current == AnatomyViewMode.backOnly,
          onTap: () => onChanged(AnatomyViewMode.backOnly),
        ),
      ],
    );
  }
}

class _ModeBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ModeBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? c.accentSoft : c.surfaceRaised,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? c.accent.withOpacity(0.5) : c.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: active ? c.accent : c.textMuted),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: active ? c.accent : c.textMuted,
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Stats page
// ─────────────────────────────────────────────
class StatsPageContent extends StatefulWidget {
  const StatsPageContent({super.key});
  @override
  State<StatsPageContent> createState() => _StatsPageContentState();
}

class _StatsPageContentState extends State<StatsPageContent> {
  String _selectedUnit = 'Recovery';
  AnatomyViewMode _anatomyViewMode = AnatomyViewMode.frontOnly;

  void _openTrendDetail({
    required String title,
    required String unit,
    required Color accentColor,
    required IconData icon,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => TrendDetailPage(
          title: title,
          unit: unit,
          accentColor: accentColor,
          icon: icon,
        ),
        transitionsBuilder: (_, a, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 380),
      ),
    );
  }

  void _openAthleteProfile() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => const AthleteProfilePage(
          athleteName: 'Ash',
          athleteSubtitle: 'Rookie Athlete',
          level: 107,
          currentXp: 4455,
          maxXp: 5900,
        ),
        transitionsBuilder: (_, a, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 380),
      ),
    );
  }

  Future<void> _showAddWeightEntryDialog() async {
    final profile = UserProvider.instance.userProfile;
    if (profile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No profile loaded yet.')));
      return;
    }

    final weightCtrl = TextEditingController(
      text: profile.weight?.toStringAsFixed(1) ?? '',
    );
    DateTime selectedDate = DateTime.now();

    final shouldAdd = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Add test weight entry'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: weightCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Weight'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Date: ${selectedDate.toLocal().toString().split(' ').first}',
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: dialogContext,
                            initialDate: selectedDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setDialogState(() => selectedDate = picked);
                          }
                        },
                        child: const Text('Pick date'),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldAdd != true) return;

    final parsedWeight = double.tryParse(weightCtrl.text.trim());
    if (parsedWeight == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a valid weight.')));
      return;
    }

    await SupabaseService.addLocalWeightRecord(
      userId: profile.userId,
      weight: parsedWeight,
      weightUnit: profile.weightUnit ?? 'kg',
      recordedAt: selectedDate,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Test weight entry added.')));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ThemeScope.of(
      context,
    ); // depend directly on ThemeProvider so toggleTheme() forces rebuild
    final c = context.colors;

    return AnimatedBuilder(
      animation: UserProvider.instance,
      builder: (context, _) {
        final profile = UserProvider.instance.userProfile;
        final weightText = profile?.weight != null
            ? '${profile!.weight!.toStringAsFixed(1)} ${profile.weightUnit ?? 'kg'}'
            : 'Add your current weight';
        final goalText = profile?.goal ?? 'Set your goal in onboarding';
        final nameText = profile?.fullName.isNotEmpty == true
            ? profile!.fullName
            : 'Ash';

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHunterCard(context, nameText: nameText, goalText: goalText),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Fitness Overview',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    UnitToggle(
                      leftLabel: 'Recovery',
                      rightLabel: 'Balance',
                      value: _selectedUnit,
                      onChanged: (v) => setState(() => _selectedUnit = v),
                      useMaxWidth: true,
                    ),
                    const SizedBox(height: 16),
                    if (_selectedUnit == 'Recovery') ...[
                      Text(
                        'Recovery Overview:',
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'See which muscles are ready to train again today.',
                        style: TextStyle(color: c.textSecondary, fontSize: 14),
                      ),
                      _legend(context, isRecovery: true),
                    ] else ...[
                      Text(
                        'Balance Overview:',
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Compare muscle group development to optimise your training plan.',
                        style: TextStyle(color: c.textSecondary, fontSize: 14),
                      ),
                      _legend(context, isRecovery: false),
                    ],
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: c.surfaceRaised,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: c.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile Snapshot',
                            style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Name: $nameText',
                            style: TextStyle(
                              color: c.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Goal: $goalText',
                            style: TextStyle(
                              color: c.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Current Weight: $weightText',
                            style: TextStyle(
                              color: c.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnatomyView(
                      isRecovery: _selectedUnit == 'Recovery',
                      viewMode: _anatomyViewMode,
                      onViewModeChanged: (m) =>
                          setState(() => _anatomyViewMode = m),
                    ),
                    if (_selectedUnit == 'Balance') ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: c.surfaceRaised,
                          border: Border.all(color: c.border),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Balance Score',
                                  style: TextStyle(
                                    color: c.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '78',
                                  style: TextStyle(
                                    color: c.textPrimary,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Good balance',
                                  style: TextStyle(
                                    color: Color(0xFF68F868),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Keep it up!',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      'Trends',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: _showAddWeightEntryDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add test weight entry'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _TrendCard(
                      themeColors: c,
                      title: 'Strength',
                      trend: '+8% last month',
                      icon: Icons.trending_up,
                      unit: 'kg',
                      accentColor: const Color(0xFF4CAF50),
                      onTap: () => _openTrendDetail(
                        title: 'Strength',
                        unit: 'kg',
                        accentColor: const Color(0xFF4CAF50),
                        icon: Icons.trending_up,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _TrendCard(
                      themeColors: c,
                      title: 'Bodyweight',
                      trend: profile?.weight != null
                          ? 'Current: ${profile!.weight!.toStringAsFixed(1)} ${profile.weightUnit ?? 'kg'}'
                          : '-1.2 kg over 4 weeks',
                      icon: Icons.monitor_weight,
                      unit: 'kg',
                      accentColor: const Color(0xFFFF9800),
                      onTap: () => _openTrendDetail(
                        title: 'Bodyweight',
                        unit: 'kg',
                        accentColor: const Color(0xFFFF9800),
                        icon: Icons.monitor_weight,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _ProgressList(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHunterCard(
    BuildContext context, {
    required String nameText,
    required String goalText,
  }) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '[ HUNTER STATUS ]',
                style: TextStyle(
                  color: c.textMuted,
                  fontSize: 9,
                  letterSpacing: 2,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                nameText,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              Text(
                goalText,
                style: TextStyle(color: c.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: c.accentSoft,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: c.accent.withOpacity(0.4)),
                ),
                child: Text(
                  'USER PROFILE',
                  style: TextStyle(
                    color: c.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LIVE DATA',
                    style: TextStyle(color: c.textSecondary, fontSize: 12),
                  ),
                  Text(
                    'Synced from account',
                    style: TextStyle(color: c.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: _openAthleteProfile,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: c.accent, width: 2),
                  color: c.accentSoft,
                ),
                child: Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: c.accent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(BuildContext context, {required bool isRecovery}) {
    final c = context.colors;
    if (isRecovery) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                gradient: const LinearGradient(
                  colors: [Color(0xFF68F868), Color(0xFFFFFF00), Colors.red],
                  stops: [0, .5, 1],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recovered',
                  style: TextStyle(color: c.textSecondary, fontSize: 11),
                ),
                Text(
                  'Halfway',
                  style: TextStyle(color: c.textSecondary, fontSize: 11),
                ),
                Text(
                  'Sore',
                  style: TextStyle(color: c.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 5),
                    decoration: const BoxDecoration(
                      color: Color(0xFF81D4FA),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    'Underdeveloped',
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Overdeveloped',
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(left: 5),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              gradient: const LinearGradient(
                colors: [Color(0xFF81D4FA), Color(0xFF68F868), Colors.red],
                stops: [0, .5, 1],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────
class _TrendCard extends StatelessWidget {
  final String title, trend, unit;
  final Color accentColor;
  final IconData icon;
  final VoidCallback? onTap;
  final CorelyColors? themeColors;
  const _TrendCard({
    required this.title,
    required this.trend,
    required this.icon,
    this.unit = '',
    this.accentColor = Colors.blue,
    this.onTap,
    this.themeColors,
  });

  @override
  Widget build(BuildContext context) {
    final c = themeColors ?? context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surfaceRaised,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: onTap != null ? accentColor.withOpacity(0.4) : c.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trend,
                    style: TextStyle(color: c.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: accentColor.withOpacity(0.7),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _ProgressList extends StatelessWidget {
  const _ProgressList();
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Progress',
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: c.surface,
            border: Border.all(color: c.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _ProgressRow(label: 'Bench press', value: '+5 kg', trend: 'Up'),
              _ProgressRow(label: 'Squat', value: '+7 kg', trend: 'Up'),
              _ProgressRow(label: 'Deadlift', value: '+4 kg', trend: 'Up'),
              _ProgressRow(
                label: 'Pull-ups',
                value: '+3 reps',
                trend: 'Steady',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label, value, trend;
  const _ProgressRow({
    required this.label,
    required this.value,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isUp = trend == 'Up';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.border, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF4CAF50),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          Row(
            children: [
              Icon(
                isUp ? Icons.arrow_upward : Icons.remove,
                color: isUp ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                trend,
                style: TextStyle(color: c.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
