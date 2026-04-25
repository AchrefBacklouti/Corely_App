import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:main_build/Views/SharedWidgets/toggle-Unit.dart';
import 'athlete_page.dart'; // <-- add this import
import 'trend_detail_page.dart'; // <-- add this import

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
  MuscleData(id: 'forearm_left', recoveryScore: 0, developmentStatus: 70),
  MuscleData(id: 'forearm_right', recoveryScore: 0, developmentStatus: 20),
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
// ─────────────────────────────────────────────
Future<String> _buildColoredSvg(
  String assetPath,
  List<MuscleData> muscles,
  bool isRecovery,
) async {
  String svg = await rootBundle.loadString(assetPath);

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
// SVG cache — load once per session, switch instantly
// ─────────────────────────────────────────────
class _SvgCache {
  static String? frontRecovery;
  static String? backRecovery;
  static String? frontBalance;
  static String? backBalance;

  static bool get recoveryReady =>
      frontRecovery != null && backRecovery != null;
  static bool get balanceReady => frontBalance != null && backBalance != null;

  /// Pre-builds all four SVG strings in one async call.
  static Future<void> prewarm() async {
    final results = await Future.wait([
      if (frontRecovery == null)
        _buildColoredSvg('assets/img/anatomy/face.svg', _frontMuscles, true)
      else
        Future.value(frontRecovery!),
      if (backRecovery == null)
        _buildColoredSvg('assets/img/anatomy/back.svg', _backMuscles, true)
      else
        Future.value(backRecovery!),
      if (frontBalance == null)
        _buildColoredSvg('assets/img/anatomy/face.svg', _frontMuscles, false)
      else
        Future.value(frontBalance!),
      if (backBalance == null)
        _buildColoredSvg('assets/img/anatomy/back.svg', _backMuscles, false)
      else
        Future.value(backBalance!),
    ]);
    frontRecovery = results[0];
    backRecovery = results[1];
    frontBalance = results[2];
    backBalance = results[3];
  }

  static String? front(bool isRecovery) =>
      isRecovery ? frontRecovery : frontBalance;
  static String? back(bool isRecovery) =>
      isRecovery ? backRecovery : backBalance;
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
  // Tracks whether the prewarm future has resolved.
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    // If already cached (e.g. second build), mark ready immediately.
    if (_SvgCache.recoveryReady && _SvgCache.balanceReady) {
      _ready = true;
    } else {
      _SvgCache.prewarm().then((_) {
        if (mounted) setState(() => _ready = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const SizedBox(
        height: 260,
        child: Center(child: CircularProgressIndicator(color: Colors.white38)),
      );
    }

    final frontSvg = _SvgCache.front(widget.isRecovery)!;
    final backSvg = _SvgCache.back(widget.isRecovery)!;

    return Column(
      children: [
        // ── View mode selector ───────────────
        _ViewModeSelector(
          current: widget.viewMode,
          onChanged: widget.onViewModeChanged,
        ),
        const SizedBox(height: 14),
        // ── Figure(s) ────────────────────────
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
// View-mode icon toggle row
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2e2a42) : const Color(0xFF1a1726),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active
                ? const Color(0xFF7b5ea7).withOpacity(0.7)
                : const Color(0xFF2a2733),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: active ? const Color(0xFFc9a6f5) : const Color(0xFF6a6080),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: active
                    ? const Color(0xFFc9a6f5)
                    : const Color(0xFF6a6080),
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

  // ── Navigate to trend detail graph ──────────────
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

  // ── Navigate to athlete profile on avatar tap ──
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

  // ── Hunter status card with tappable avatar ──
  Widget _buildHunterCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1f1b2e),
        border: Border.all(color: const Color(0xFF2e2a3e)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTag('Hunter Status'),
              const SizedBox(height: 6),
              const Text(
                'Ash',
                style: TextStyle(
                  color: Color(0xFFe8e0f5),
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const Text(
                'Rookie Athlete',
                style: TextStyle(color: Color(0xFF7a6e90), fontSize: 12),
              ),
              const SizedBox(height: 8),
              _RankBadge('S-RANK'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'LV. 107',
                    style: TextStyle(color: Color(0xFF7a6e90), fontSize: 12),
                  ),
                  Text(
                    '4455 / 5,900 XP',
                    style: TextStyle(color: Color(0xFF9a8eb0), fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(
                  value: 0.74,
                  minHeight: 5,
                  backgroundColor: Color(0xFF2a2538),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9070c0)),
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
                  border: Border.all(color: const Color(0xFF7b5ea7), width: 2),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3d2f5a), Color(0xFF1f1b2e)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: Color(0xFFc9a6f5),
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

  Widget _recoveryLegend() => Padding(
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
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recovered',
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
            Text(
              'Halfway',
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
            Text('Sore', style: TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ],
    ),
  );

  Widget _balanceLegend() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Underdeveloped',
              style: TextStyle(
                color: Color(0xFF81D4FA),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Overdeveloped',
              style: TextStyle(
                color: Colors.red,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hunter status card sits at top, full-width with side padding
          _buildHunterCard(),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                const Text(
                  'Fitness Overview',
                  style: TextStyle(
                    color: Colors.white,
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
                  const Text(
                    'Recovery Overview:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'See which muscles are ready to train again today.',
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                  _recoveryLegend(),
                ] else ...[
                  const Text(
                    'Balance Overview:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Compare muscle group development to optimise your training plan.',
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                  _balanceLegend(),
                ],

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
                      color: const Color(0xFF1C2B47),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Balance Score',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '78',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
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
                                color: Colors.white54,
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
                const Text(
                  'Trends',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _TrendCard(
                  title: 'Strength',
                  trend: '+8% last month',
                  color: Colors.greenAccent.withOpacity(0.15),
                  icon: Icons.trending_up,
                  unit: 'kg',
                  accentColor: Colors.greenAccent,
                  onTap: () => _openTrendDetail(
                    title: 'Strength',
                    unit: 'kg',
                    accentColor: Colors.greenAccent,
                    icon: Icons.trending_up,
                  ),
                ),

                const SizedBox(height: 12),
                _TrendCard(
                  title: 'Bodyweight',
                  trend: '-1.2 kg over 4 weeks',
                  color: Colors.orangeAccent.withOpacity(0.15),
                  icon: Icons.monitor_weight,
                  unit: 'kg',
                  accentColor: Colors.orangeAccent,
                  onTap: () => _openTrendDetail(
                    title: 'Bodyweight',
                    unit: 'kg',
                    accentColor: Colors.orangeAccent,
                    icon: Icons.monitor_weight,
                  ),
                ),
                const SizedBox(height: 28),
                const _ProgressList(),
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
// Small shared widgets
// ─────────────────────────────────────────────
class _SectionTag extends StatelessWidget {
  final String text;
  const _SectionTag(this.text);

  @override
  Widget build(BuildContext context) => Text(
    '[ ${text.toUpperCase()} ]',
    style: const TextStyle(
      color: Color(0xFF4a4460),
      fontSize: 9,
      letterSpacing: 2,
      fontFamily: 'monospace',
    ),
  );
}

class _RankBadge extends StatelessWidget {
  final String label;
  const _RankBadge(this.label);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: const Color(0xFF7b5ea7),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Color(0xFFe8d8ff),
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    ),
  );
}

class _TrendCard extends StatelessWidget {
  final String title, trend, unit;
  final Color color, accentColor;
  final IconData icon;
  final VoidCallback? onTap;

  const _TrendCard({
    required this.title,
    required this.trend,
    required this.color,
    required this.icon,
    this.unit = '',
    this.accentColor = Colors.white,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: onTap != null
            ? Border.all(color: accentColor.withOpacity(0.2))
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  trend,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.chevron_right,
              color: accentColor.withOpacity(0.6),
              size: 20,
            ),
        ],
      ),
    ),
  );
}

class _ProgressList extends StatelessWidget {
  const _ProgressList();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _ProgressRow(label: 'Bench press', value: '+5 kg', trend: 'Up'),
      SizedBox(height: 10),
      _ProgressRow(label: 'Squat', value: '+7 kg', trend: 'Up'),
      SizedBox(height: 10),
      _ProgressRow(label: 'Deadlift', value: '+4 kg', trend: 'Up'),
      SizedBox(height: 10),
      _ProgressRow(label: 'Pull-ups', value: '+3 reps', trend: 'Steady'),
    ],
  );
}

class _ProgressRow extends StatelessWidget {
  final String label, value, trend;
  const _ProgressRow({
    required this.label,
    required this.value,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      Text(
        value,
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      Row(
        children: [
          Icon(
            trend == 'Up' ? Icons.arrow_upward : Icons.remove,
            color: trend == 'Up' ? Colors.greenAccent : Colors.orangeAccent,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            trend,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    ],
  );
}
