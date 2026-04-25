import 'package:flutter/material.dart';
import 'package:main_build/Views/SharedWidgets/toggle-Unit.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StatsPageContent extends StatefulWidget {
  const StatsPageContent({super.key});

  @override
  State<StatsPageContent> createState() => _StatsPageContentState();
}

class _StatsPageContentState extends State<StatsPageContent> {
  String selectedUnit = "Recovery";
  TextStyle _legendTextStyles(Color textColor) {
    return TextStyle(
      color: textColor, // Matches label color to the gradient ends for clarity
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );
  }

  Widget _buildDevelopmentLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        children: [
          // 1. The Gradient Bar
          // 2. The Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Underdeveloped',
                style: _legendTextStyles(const Color(0xFF81D4FA)),
              ),
              Text('Overdeveloped', style: _legendTextStyles(Colors.red)),
            ],
          ),
          Container(
            height: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF81D4FA), // Light Blue
                  Color.fromARGB(255, 104, 248, 104), // Light Green (Middle)
                  Colors.red, // Red
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildGradientRecoveryLegend() {
    // Constants for standard colors and alignment
    const red = Colors.red;
    const yellow = Colors.yellow;
    const green = Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        children: [
          // 1. The Gradient Bar
          Container(
            height: 12, // The "weight" of the bar
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6), // Completely rounded ends
              gradient: const LinearGradient(
                // Gradient starts at the far left and ends at the far right
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                // The definitive colors we want in the bar
                colors: [red, yellow, green],
                // Specific locations (0.0 to 1.0) for the colors to lock in.
                // We lock yellow exactly in the middle (0.5).
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          const SizedBox(height: 10), // Space between the bar and labels
          // 2. The Labels (spaced to match the gradient points)
          Row(
            // mainAxisAlignment is redundant if everything is aligned manually,
            // but good for context. We want 'Space Between' the edges.
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Label: Aligns with 0.0 (Red)
              Text('Sore', style: _legendTextStyle()),

              // Middle Label: Needs to be centered at 0.5 (Yellow)
              // We use 'Expanded' and 'Center' to hold the middle ground.
              Expanded(
                child: Center(
                  child: Text('Needs Recovery', style: _legendTextStyle()),
                ),
              ),

              // Right Label: Aligns with 1.0 (Green)
              Text('Fully Healed', style: _legendTextStyle()),
            ],
          ),
        ],
      ),
    );
  }

  // Helper for consistent label styling
  TextStyle _legendTextStyle() {
    return const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w400, // Slightly lighter weight for contrast
    );
  }

  Widget _buildAnatomyImage() {
    return Row(
      children: [
        // Front Anatomy
        Expanded(child: _buildSingleAnatomySvg('assets/img/anatomy/face.svg')),
        const SizedBox(width: 16), // Space between images
        // Back Anatomy
        Expanded(child: _buildSingleAnatomySvg('assets/img/anatomy/back.svg')),
      ],
    );
  }

  Widget _buildSingleAnatomySvg(String assetPath) {
    return SvgPicture.asset(
      assetPath,
      // Removed package: 'main_build' as it's likely causing your "Asset not found"
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      placeholderBuilder: (context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final palette =
        theme.extension<CorelyColors>() ??
        (isDarkMode ? AppTheme.darkColors : AppTheme.lightColors);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _StatCard(
                title: "Workouts",
                value: "22",
                subtitle: "+3 this week",
              ),
              _StatCard(
                title: "Calories",
                value: "14.2K",
                subtitle: "avg 560/day",
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _StatCard(title: "Steps", value: "76K", subtitle: "+8% vs last"),
              _StatCard(title: "Sleep", value: "7.3h", subtitle: "avg last 7d"),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "Fitness Overview",
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          // human diagramm placeholder
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UnitToggle(
                leftLabel: "Recovery",
                rightLabel: "Balance",
                value: selectedUnit,
                onChanged: (value) => setState(() => selectedUnit = value),
                useMaxWidth: true,
              ),
            ],
          ),
          if (selectedUnit == "Recovery") ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Removed 'const' from here
                const SizedBox(height: 10),
                const Text(
                  "Recovery Overview:",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "See which muscles are ready to train again today.",
                  style: TextStyle(color: Colors.white70, fontSize: 17),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Percentage: 82%",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildGradientRecoveryLegend(),
                _buildAnatomyImage(),
              ],
            ),
          ] else ...[
            SizedBox(height: 10),
            Text(
              "Balance Overview:",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "This would help you compare the development of different muscle groups to improve your training plan.",
              style: TextStyle(color: Colors.white70, fontSize: 17),
            ),
            _buildDevelopmentLegend(),
            _buildAnatomyImage(),
            SizedBox(height: 12),
            Text(
              "Balance Score: 78",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "Good balance • Keep it up!",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            "Trends",
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _TrendCard(
            title: "Strength",
            trend: "+8% last month",
            color: Colors.greenAccent.withValues(alpha: 0.12),
            icon: Icons.trending_up,
            palette: palette,
          ),
          const SizedBox(height: 12),
          _TrendCard(
            title: "VO₂ Max",
            trend: "Steady",
            color: Colors.blueAccent.withValues(alpha: 0.12),
            icon: Icons.show_chart,
            palette: palette,
          ),
          const SizedBox(height: 12),
          _TrendCard(
            title: "Bodyweight",
            trend: "-1.2 kg over 4 weeks",
            color: Colors.orangeAccent.withValues(alpha: 0.12),
            icon: Icons.monitor_weight,
            palette: palette,
          ),
          const SizedBox(height: 28),
          const _ProgressList(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final palette =
        theme.extension<CorelyColors>() ??
        (isDarkMode ? AppTheme.darkColors : AppTheme.lightColors);

    return Container(
      width: MediaQuery.of(context).size.width * 0.42,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: palette.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: palette.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final String title;
  final String trend;
  final Color color;
  final IconData icon;
  final CorelyColors palette;

  const _TrendCard({
    required this.title,
    required this.trend,
    required this.color,
    required this.icon,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: palette.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: palette.textPrimary, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                trend,
                style: TextStyle(color: palette.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressList extends StatelessWidget {
  const _ProgressList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette =
        theme.extension<CorelyColors>() ??
        (theme.brightness == Brightness.dark
            ? AppTheme.darkColors
            : AppTheme.lightColors);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _ProgressRow(label: "Bench press", value: "+5 kg", trend: "Up"),
        SizedBox(height: 10),
        _ProgressRow(label: "Squat", value: "+7 kg", trend: "Up"),
        SizedBox(height: 10),
        _ProgressRow(label: "Deadlift", value: "+4 kg", trend: "Up"),
        SizedBox(height: 10),
        _ProgressRow(label: "Pull-ups", value: "+3 reps", trend: "Steady"),
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final String value;
  final String trend;

  const _ProgressRow({
    required this.label,
    required this.value,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette =
        theme.extension<CorelyColors>() ??
        (theme.brightness == Brightness.dark
            ? AppTheme.darkColors
            : AppTheme.lightColors);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: palette.textPrimary,
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
              trend == "Up" ? Icons.arrow_upward : Icons.remove,
              color: trend == "Up" ? Colors.greenAccent : Colors.orangeAccent,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              trend,
              style: TextStyle(color: palette.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}
