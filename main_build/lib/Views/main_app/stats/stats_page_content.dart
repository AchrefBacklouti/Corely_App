import 'package:flutter/material.dart';
import 'package:main_build/Theme/app_theme.dart';

class StatsPageContent extends StatelessWidget {
  const StatsPageContent({super.key});

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
