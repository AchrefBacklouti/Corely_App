import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:main_build/Views/SharedWidgets/toggle-Unit.dart';
import 'athlete_page.dart';
import 'trend_detail_page.dart';
// Import your theme so we can use context.colors
import 'package:main_build/theme/app_theme.dart'; // adjust path as needed

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

// ─────────────────────────────────────────────
// Sample data
// ─────────────────────────────────────────────
const List<MuscleData> _frontMuscles = [
  MuscleData(id: 'pec_left', recoveryScore: 100, developmentStatus: 90),
  MuscleData(id: 'pec_right', recoveryScore: 100, developmentStatus: 100),
  MuscleData(id: 'shoulder_left', recoveryScore: 50, developmentStatus: 100),
  MuscleData(id: 'shoulder_right', recoveryScore: 0, developmentStatus: 70),
  MuscleData(id: 'brachialis_left', recoveryScore: 0, developmentStatus: 50),
  MuscleData(id: 'bi_longhead_left', recoveryScore: 0, developmentStatus: 50),
  MuscleData(id: 'bi_shorthead_left', recoveryScore: 0, developmentStatus: 50),
  MuscleData(id: 'brachialis_right', recoveryScore: 0, developmentStatus: 50),
  MuscleData(id: 'bi_longhead_right', recoveryScore: 0, developmentStatus: 50),
  MuscleData(id: 'bi_shorthead_right', recoveryScore: 0, developmentStatus: 50),
  MuscleData(id: 'abs_low', recoveryScore: 100, developmentStatus: 30),
  MuscleData(id: 'abs_up', recoveryScore: 100, developmentStatus: 50),
  MuscleData(id: 'obliques_left', recoveryScore: 0, developmentStatus: 80),
  MuscleData(id: 'obliques_right', recoveryScore: 0, developmentStatus: 80),
  MuscleData(
    id: 'top_forearm_right',
    recoveryScore: 100,
    developmentStatus: 60,
  ),
  MuscleData(id: 'top_forearm_left', recoveryScore: 100, developmentStatus: 70),
  MuscleData(id: 'extensors_right', recoveryScore: 50, developmentStatus: 50),
  MuscleData(id: 'extensors_left', recoveryScore: 50, developmentStatus: 50),
  MuscleData(id: 'flexors_right', recoveryScore: 50, developmentStatus: 60),
  MuscleData(id: 'flexors_left', recoveryScore: 50, developmentStatus: 90),
  MuscleData(
    id: 'vastus_medialis_left',
    recoveryScore: 50,
    developmentStatus: 100,
  ),
  MuscleData(
    id: 'vastus_medialis_right',
    recoveryScore: 50,
    developmentStatus: 100,
  ),
  MuscleData(id: 'abductor_right', recoveryScore: 50, developmentStatus: 60),
  MuscleData(id: 'abductor_left', recoveryScore: 50, developmentStatus: 80),
  MuscleData(id: 'satorius_left', recoveryScore: 50, developmentStatus: 90),
  MuscleData(id: 'satorius_right', recoveryScore: 50, developmentStatus: 80),
  MuscleData(
    id: 'vastus_literalis_left',
    recoveryScore: 50,
    developmentStatus: 20,
  ),
  MuscleData(
    id: 'vastus_literalis_right',
    recoveryScore: 50,
    developmentStatus: 20,
  ),
  MuscleData(id: 'femoris_left', recoveryScore: 50, developmentStatus: 60),
  MuscleData(id: 'femoris_right', recoveryScore: 50, developmentStatus: 60),
  MuscleData(id: 'tensor_left', recoveryScore: 50, developmentStatus: 10),
  MuscleData(id: 'tensor_right', recoveryScore: 50, developmentStatus: 10),
  MuscleData(id: 'calf_right_left', recoveryScore: 50, developmentStatus: 0),
  MuscleData(id: 'calf_left_right', recoveryScore: 50, developmentStatus: 0),
  MuscleData(id: 'calf_left_left', recoveryScore: 50, developmentStatus: 0),
  MuscleData(id: 'calf_right_right', recoveryScore: 50, developmentStatus: 0),
];

const List<MuscleData> _backMuscles = [
  MuscleData(id: 'traps', recoveryScore: 50, developmentStatus: 100),
  MuscleData(id: 'lats_right', recoveryScore: 50, developmentStatus: 50),
  MuscleData(id: 'lats_left', recoveryScore: 50, developmentStatus: 50),
  MuscleData(id: 'tri_long_right', recoveryScore: 50, developmentStatus: 0),
  MuscleData(
    id: 'tri_med_head_right',
    recoveryScore: 100,
    developmentStatus: 20,
  ),
  MuscleData(
    id: 'tri_long_head_left',
    recoveryScore: 100,
    developmentStatus: 10,
  ),
  MuscleData(
    id: 'tri_med_head_left',
    recoveryScore: 100,
    developmentStatus: 60,
  ),
  MuscleData(id: 'rhom_2 l', recoveryScore: 50, developmentStatus: 50),
  MuscleData(id: 'rhom_1 l', recoveryScore: 50, developmentStatus: 40),
  MuscleData(id: 'rhom_3 l', recoveryScore: 50, developmentStatus: 30),
  MuscleData(id: 'rhom_3 r', recoveryScore: 50, developmentStatus: 20),
  MuscleData(id: 'rhom_2 r', recoveryScore: 50, developmentStatus: 20),
  MuscleData(id: 'rhom_1 r', recoveryScore: 50, developmentStatus: 20),
  MuscleData(id: 'side_delts_right', recoveryScore: 50, developmentStatus: 90),
  MuscleData(id: 'side_delts_left', recoveryScore: 50, developmentStatus: 90),
  MuscleData(id: 'extensorsi_right', recoveryScore: 50, developmentStatus: 50),
  MuscleData(id: 'extensorsi_left', recoveryScore: 50, developmentStatus: 50),
  MuscleData(id: 'extensor_right', recoveryScore: 50, developmentStatus: 50),
  MuscleData(id: 'top_right', recoveryScore: 50, developmentStatus: 60),
  MuscleData(id: 'extensors_right', recoveryScore: 50, developmentStatus: 60),
  MuscleData(
    id: 'finger_extensors_right',
    recoveryScore: 50,
    developmentStatus: 40,
  ),
  MuscleData(id: 'extensors_right_2', recoveryScore: 50, developmentStatus: 40),
  MuscleData(id: 'extesorsi_left', recoveryScore: 50, developmentStatus: 40),
  MuscleData(id: 'top_left', recoveryScore: 50, developmentStatus: 40),
  MuscleData(id: 'extensors_left', recoveryScore: 50, developmentStatus: 40),
  MuscleData(
    id: 'finger_extensors_left',
    recoveryScore: 100,
    developmentStatus: 50,
  ),
  MuscleData(id: 'forearms_2', recoveryScore: 50, developmentStatus: 50),
  MuscleData(id: 'glutes_right', recoveryScore: 0, developmentStatus: 90),
  MuscleData(id: 'glutes_left', recoveryScore: 0, developmentStatus: 90),
  MuscleData(id: 'tendon_left', recoveryScore: 0, developmentStatus: 20),
  MuscleData(id: 'tendon_right', recoveryScore: 0, developmentStatus: 50),
  MuscleData(id: 'hams_down_left', recoveryScore: 0, developmentStatus: 30),
  MuscleData(id: 'hams_down_right', recoveryScore: 0, developmentStatus: 40),
  MuscleData(id: 'semite_left', recoveryScore: 0, developmentStatus: 10),
  MuscleData(id: 'semite_right', recoveryScore: 0, developmentStatus: 10),
  MuscleData(id: 'semime_left', recoveryScore: 0, developmentStatus: 16),
  MuscleData(id: 'semime_right', recoveryScore: 0, developmentStatus: 16),
  MuscleData(id: 'adductor_left', recoveryScore: 0, developmentStatus: 20),
  MuscleData(id: 'adductor_right', recoveryScore: 0, developmentStatus: 20),
  MuscleData(id: 'hams_sem_left ', recoveryScore: 0, developmentStatus: 90),
  MuscleData(id: 'hams_sem_right ', recoveryScore: 0, developmentStatus: 90),
  MuscleData(id: 'ilio_left', recoveryScore: 0, developmentStatus: 50),
  MuscleData(id: 'ilio_right', recoveryScore: 0, developmentStatus: 50),
  MuscleData(
    id: 'calf_back_right_right',
    recoveryScore: 0,
    developmentStatus: 20,
  ),
  MuscleData(
    id: 'calf_back_left_left',
    recoveryScore: 0,
    developmentStatus: 20,
  ),
  MuscleData(
    id: 'calf_back_right_left',
    recoveryScore: 0,
    developmentStatus: 10,
  ),
  MuscleData(
    id: 'calf_back_left_right',
    recoveryScore: 0,
    developmentStatus: 10,
  ),
];

// ─────────────────────────────────────────────
// Color helpers
// ─────────────────────────────────────────────
String _colorToHex(Color c) =>
    '#${(c.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

Color _recoveryColor(int score) {
  final normalized = score.clamp(0, 100) / 100.0;
  if (normalized <= 0.5) {
    return Color.lerp(const Color(0xFF68F868), Colors.yellow, normalized * 2)!;
  }
  return Color.lerp(Colors.yellow, Colors.red, (normalized - 0.5) * 2)!;
}

Color _developmentColor(int d) {
  final normalized = d.clamp(0, 100) / 100.0;
  if (normalized <= 0.5) {
    return Color.lerp(
      const Color(0xFF81D4FA),
      const Color(0xFF68F868),
      normalized * 2,
    )!;
  }
  return Color.lerp(
    const Color(0xFF68F868),
    Colors.red,
    (normalized - 0.5) * 2,
  )!;
}

String _muscleIdPattern(String muscleId) {
  final parts = muscleId
      .split(RegExp(r'[_\-\s]+'))
      .where((part) => part.isNotEmpty)
      .map(RegExp.escape)
      .toList();
  return parts.join(r'[_\-\s]+');
}

// ─────────────────────────────────────────────
// SVG colour injection
// Now accepts an optional outlineColor for the figure silhouette/outline
// ─────────────────────────────────────────────
Future<String> _buildColoredSvg(
  String assetPath,
  List<MuscleData> muscles,
  bool isRecovery, {
  Color outlineColor = Colors.white,
}) async {
  String svg = await rootBundle.loadString(assetPath);

  // Replace the base figure outline/stroke color (typically black or white in SVG)
  // This targets the outermost silhouette paths that use stroke for the body outline.
  // We replace the SVG-level stroke/fill used for the figure outline.
  final outlineHex = _colorToHex(outlineColor);
  // Replace base figure outline: any path with stroke="#000000" or stroke="black"
  svg = svg.replaceAll('stroke="#000000"', 'stroke="$outlineHex"');
  svg = svg.replaceAll('stroke="black"', 'stroke="$outlineHex"');
  svg = svg.replaceAll('stroke="#000"', 'stroke="$outlineHex"');

  final Map<String, Color> muscleColors = {};
  for (final m in muscles) {
    final color = isRecovery
        ? _recoveryColor(m.recoveryScore)
        : _developmentColor(m.developmentStatus);
    muscleColors[m.id] = color;
  }

  for (final entry in muscleColors.entries) {
    final muscleId = entry.key;
    final color = entry.value;
    final hex = _colorToHex(color);
    const opacity = '0.9';
    final searchPattern = _muscleIdPattern(muscleId);

    final groupPattern = RegExp(
      r'<g\s+id="([^"]*' + searchPattern + r'[^"]*)"[^>]*>(.*?)</g>',
      dotAll: true,
      caseSensitive: false,
    );

    svg = svg.replaceAllMapped(groupPattern, (match) {
      var groupContent = match.group(2) ?? '';
      final groupId = match.group(1) ?? '';

      groupContent = groupContent.replaceAll(
        RegExp(r'\bfill="white"', caseSensitive: false),
        'fill="$hex"',
      );
      groupContent = groupContent.replaceAll(
        RegExp(r'\bstroke="white"', caseSensitive: false),
        'stroke="$hex"',
      );
      groupContent = groupContent.replaceAll(
        RegExp(r'\bfill="#D9D9D9"', caseSensitive: false),
        'fill="$hex"',
      );
      groupContent = groupContent.replaceAll(
        RegExp(r'fill="$hex"(?!\s+opacity)', caseSensitive: false),
        'fill="$hex" opacity="$opacity"',
      );

      return '<g id="$groupId">$groupContent</g>';
    });

    final pathPattern = RegExp(
      r'<(path|ellipse|circle|rect)\s+id="([^"]*' +
          searchPattern +
          r'[^"]*)"([^>]*)>',
      caseSensitive: false,
    );

    svg = svg.replaceAllMapped(pathPattern, (match) {
      final tag = match.group(1) ?? 'path';
      final id = match.group(2) ?? '';
      var attrs = match.group(3) ?? '';

      attrs = attrs.replaceAll(RegExp(r'\s*\bfill="[^"]*"'), '');
      attrs = attrs.replaceAll(RegExp(r'\s*\bstroke="[^"]*"'), '');
      attrs = attrs.replaceAll(RegExp(r'\s*\bopacity="[^"]*"'), '');

      return '<$tag id="$id" fill="$hex" stroke="$hex" opacity="$opacity"$attrs>';
    });
  }

  return svg;
}

// ─────────────────────────────────────────────
// Anatomy view mode
// ─────────────────────────────────────────────
enum AnatomyViewMode { both, frontOnly, backOnly }

// ─────────────────────────────────────────────
// SVG cache — keyed by isRecovery + isDark
// ─────────────────────────────────────────────
class _SvgCache {
  // dark variants (white outline)
  static String? frontRecoveryDark;
  static String? backRecoveryDark;
  static String? frontBalanceDark;
  static String? backBalanceDark;

  // light variants (black outline)
  static String? frontRecoveryLight;
  static String? backRecoveryLight;
  static String? frontBalanceLight;
  static String? backBalanceLight;

  static bool isReady(bool isDark) {
    return isDark
        ? (frontRecoveryDark != null &&
              backRecoveryDark != null &&
              frontBalanceDark != null &&
              backBalanceDark != null)
        : (frontRecoveryLight != null &&
              backRecoveryLight != null &&
              frontBalanceLight != null &&
              backBalanceLight != null);
  }

  static Future<void> prewarm({required bool isDark}) async {
    final outline = isDark ? Colors.white : Colors.black;

    if (isDark) {
      final results = await Future.wait([
        frontRecoveryDark == null
            ? _buildColoredSvg(
                'assets/img/anatomy/face.svg',
                _frontMuscles,
                true,
                outlineColor: outline,
              )
            : Future.value(frontRecoveryDark!),
        backRecoveryDark == null
            ? _buildColoredSvg(
                'assets/img/anatomy/back.svg',
                _backMuscles,
                true,
                outlineColor: outline,
              )
            : Future.value(backRecoveryDark!),
        frontBalanceDark == null
            ? _buildColoredSvg(
                'assets/img/anatomy/face.svg',
                _frontMuscles,
                false,
                outlineColor: outline,
              )
            : Future.value(frontBalanceDark!),
        backBalanceDark == null
            ? _buildColoredSvg(
                'assets/img/anatomy/back.svg',
                _backMuscles,
                false,
                outlineColor: outline,
              )
            : Future.value(backBalanceDark!),
      ]);
      frontRecoveryDark = results[0];
      backRecoveryDark = results[1];
      frontBalanceDark = results[2];
      backBalanceDark = results[3];
    } else {
      final results = await Future.wait([
        frontRecoveryLight == null
            ? _buildColoredSvg(
                'assets/img/anatomy/face.svg',
                _frontMuscles,
                true,
                outlineColor: outline,
              )
            : Future.value(frontRecoveryLight!),
        backRecoveryLight == null
            ? _buildColoredSvg(
                'assets/img/anatomy/back.svg',
                _backMuscles,
                true,
                outlineColor: outline,
              )
            : Future.value(backRecoveryLight!),
        frontBalanceLight == null
            ? _buildColoredSvg(
                'assets/img/anatomy/face.svg',
                _frontMuscles,
                false,
                outlineColor: outline,
              )
            : Future.value(frontBalanceLight!),
        backBalanceLight == null
            ? _buildColoredSvg(
                'assets/img/anatomy/back.svg',
                _backMuscles,
                false,
                outlineColor: outline,
              )
            : Future.value(backBalanceLight!),
      ]);
      frontRecoveryLight = results[0];
      backRecoveryLight = results[1];
      frontBalanceLight = results[2];
      backBalanceLight = results[3];
    }
  }

  static String? front(bool isRecovery, bool isDark) {
    if (isDark) {
      return isRecovery ? frontRecoveryDark : frontBalanceDark;
    } else {
      return isRecovery ? frontRecoveryLight : frontBalanceLight;
    }
  }

  static String? back(bool isRecovery, bool isDark) {
    if (isDark) {
      return isRecovery ? backRecoveryDark : backBalanceDark;
    } else {
      return isRecovery ? backRecoveryLight : backBalanceLight;
    }
  }
}

// ─────────────────────────────────────────────
// Anatomy widget
// ─────────────────────────────────────────────
class AnatomyView extends StatefulWidget {
  final bool isRecovery;
  final AnatomyViewMode viewMode;
  final ValueChanged<AnatomyViewMode> onViewModeChanged;

  const AnatomyView({
    super.key,
    required this.isRecovery,
    required this.viewMode,
    required this.onViewModeChanged,
  });

  @override
  State<AnatomyView> createState() => _AnatomyViewState();
}

class _AnatomyViewState extends State<AnatomyView> {
  // Tracks which isDark value we last started a prewarm for,
  // preventing duplicate futures on repeated didChangeDependencies calls.
  bool? _warmingFor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureWarmed();
  }

  void _ensureWarmed() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Already warmed or warming for this brightness — skip.
    if (_warmingFor == isDark && _SvgCache.isReady(isDark)) return;
    if (_SvgCache.isReady(isDark)) {
      _warmingFor = isDark;
      return;
    }
    _warmingFor = isDark;
    _SvgCache.prewarm(isDark: isDark).then((_) {
      // Trigger a rebuild so build() picks up the newly cached SVGs.
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Read nullable — null means prewarm is still in flight.
    // Never force-unwrap (!); show loader instead.
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
// View-mode icon toggle row — now themed
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
          // Active: accentSoft tint; inactive: surfaceRaised
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
// Main Stats Page
// ─────────────────────────────────────────────
class StatsPageContent extends StatefulWidget {
  const StatsPageContent({super.key});

  @override
  State<StatsPageContent> createState() => _StatsPageContentState();
}

class _StatsPageContentState extends State<StatsPageContent> {
  String _selectedUnit = 'Recovery';
  AnatomyViewMode _anatomyViewMode = AnatomyViewMode.both;

  void _openTrendDetail({
    required String title,
    required String unit,
    required Color accentColor,
    required IconData icon,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => TrendDetailPage(
          title: title,
          unit: unit,
          accentColor: accentColor,
          icon: icon,
        ),
        transitionsBuilder: (_, animation, __, child) {
          final slide =
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );
          return SlideTransition(position: slide, child: child);
        },
        transitionDuration: const Duration(milliseconds: 380),
      ),
    );
  }

  void _openAthleteProfile() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const AthleteProfilePage(
          athleteName: 'Ash',
          athleteSubtitle: 'Rookie Athlete',
          level: 107,
          currentXp: 4455,
          maxXp: 5900,
        ),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 380),
      ),
    );
  }

  // ── Hunter status card — fully themed ──────────
  Widget _buildHunterCard(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // surfaceRaised gives it clear lift above the page background
        // in both light and dark
        color: c.surfaceRaised,
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTag(textColor: c.textMuted),
              const SizedBox(height: 6),
              Text(
                'Ash',
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              Text(
                'Rookie Athlete',
                style: TextStyle(color: c.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 8),
              _RankBadge(
                label: 'S-RANK',
                accentColor: c.accent,
                accentSoft: c.accentSoft,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LV. 107',
                    style: TextStyle(color: c.textSecondary, fontSize: 12),
                  ),
                  Text(
                    '4455 / 5,900 XP',
                    style: TextStyle(color: c.textMuted, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.74,
                  minHeight: 5,
                  backgroundColor: c.border,
                  valueColor: AlwaysStoppedAnimation<Color>(c.accent),
                ),
              ),
            ],
          ),
          // ── Tappable avatar ──────────────────
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

  Widget _recoveryLegend(BuildContext context) {
    final c = context.colors;
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
                stops: [0.0, 0.5, 1.0],
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

  Widget _balanceLegend(BuildContext context) {
    final c = context.colors;
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
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHunterCard(context),
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
                  _recoveryLegend(context),
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
                  _balanceLegend(context),
                ],

                AnatomyView(
                  isRecovery: _selectedUnit == 'Recovery',
                  viewMode: _anatomyViewMode,
                  onViewModeChanged: (m) =>
                      setState(() => _anatomyViewMode = m),
                ),

                if (_selectedUnit == 'Balance') ...[
                  const SizedBox(height: 16),
                  // Balance score card — themed surface
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
                const SizedBox(height: 12),

                // Trend cards use surfaceRaised + border so they
                // always pop off the page background in both modes
                _TrendCard(
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
                  title: 'Bodyweight',
                  trend: '-1.2 kg over 4 weeks',
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
  }
}

// ─────────────────────────────────────────────
// Small shared widgets — themed
// ─────────────────────────────────────────────

class _SectionTag extends StatelessWidget {
  final Color? textColor;
  const _SectionTag({this.textColor});

  @override
  Widget build(BuildContext context) => Text(
    '[ HUNTER STATUS ]',
    style: TextStyle(
      color: textColor ?? context.colors.textMuted,
      fontSize: 9,
      letterSpacing: 2,
      fontFamily: 'monospace',
    ),
  );
}

class _RankBadge extends StatelessWidget {
  final String label;
  final Color accentColor;
  final Color accentSoft;

  const _RankBadge({
    required this.label,
    required this.accentColor,
    required this.accentSoft,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: accentSoft,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: accentColor.withOpacity(0.4)),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: accentColor,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    ),
  );
}

/// TrendCard now reads from CorelyColors — no hardcoded hex.
class _TrendCard extends StatelessWidget {
  final String title, trend, unit;
  final Color accentColor;
  final IconData icon;
  final VoidCallback? onTap;

  const _TrendCard({
    required this.title,
    required this.trend,
    required this.icon,
    this.unit = '',
    this.accentColor = Colors.blue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // surfaceRaised ensures the card pops off the page background
          // in both light (0xFFDDE6FF on 0xFFEDF2FF) and dark modes.
          // gradient is intentionally removed — it overrides color in Flutter.
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
        // Section header
        Text(
          'Recent Progress',
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        // Wrap in a card so it reads consistently with other surfaces
        Container(
          decoration: BoxDecoration(
            color: c.surface,
            border: Border.all(color: c.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: const [
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
