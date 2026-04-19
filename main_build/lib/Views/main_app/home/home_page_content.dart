import 'package:flutter/material.dart';
import 'package:main_build/Theme/app_theme.dart';

CorelyColors _palette(BuildContext context) {
  final theme = Theme.of(context);
  return theme.extension<CorelyColors>() ??
      (theme.brightness == Brightness.dark
          ? AppTheme.darkColors
          : AppTheme.lightColors);
}

//////////////////////////////////////////////////////
// PAGE 1 — HOME PAGE CONTENT
//////////////////////////////////////////////////////
class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          const _GreetingText(),
          const SizedBox(height: 20),
          const _StreakAndFocusRow(),
          const SizedBox(height: 20),
          const _SectionLabel("Daily Steps"),
          const SizedBox(height: 10),
          const StepsCard(steps: 5000),
          const SizedBox(height: 20),
          const _SectionLabel("Achievements"),
          const SizedBox(height: 10),
          const _AchievementsSection(),
          const SizedBox(height: 20),
          const _TipOfTheDayCard(
            tipText:
                "Log your calories today for accurate progress tracking. Consistency is the key to results.",
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = _palette(context);
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: palette.textMuted,
        letterSpacing: 1.8,
      ),
    );
  }
}

// ─── Greeting ─────────────────────────────────────────────────────────────────
class _GreetingText extends StatelessWidget {
  const _GreetingText();

  @override
  Widget build(BuildContext context) {
    final palette = _palette(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Good morning,",
          style: TextStyle(
            color: palette.textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "Achraf 💪",
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Ready to crush today's goals?",
          style: TextStyle(
            color: palette.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

// ─── Streak + Today's Focus (side by side) ────────────────────────────────────
class _StreakAndFocusRow extends StatelessWidget {
  const _StreakAndFocusRow();

  @override
  Widget build(BuildContext context) {
    final palette = _palette(context);
    return IntrinsicHeight(
      child: Row(
        children: [
          // Streak card — accent
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: palette.accent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("⚡", style: TextStyle(fontSize: 22)),
                  const SizedBox(height: 6),
                  Text(
                    "12 Days",
                    style: TextStyle(
                      color: palette.background,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    "Current streak",
                    style: TextStyle(color: palette.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Today's focus card — dark
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: palette.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("🎯", style: TextStyle(fontSize: 22)),
                  const SizedBox(height: 6),
                  Text(
                    "Today's Focus",
                    style: TextStyle(color: palette.textMuted, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Chest / Triceps",
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Steps Card ───────────────────────────────────────────────────────────────
class StepsCard extends StatefulWidget {
  final int steps;
  final int goal;

  const StepsCard({super.key, required this.steps, this.goal = 10000});

  @override
  State<StepsCard> createState() => _StepsCardState();
}

class _StepsCardState extends State<StepsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _setupAnimation();
  }

  @override
  void didUpdateWidget(covariant StepsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.steps != widget.steps || oldWidget.goal != widget.goal) {
      _setupAnimation();
    }
  }

  void _setupAnimation() {
    final target = (widget.steps / widget.goal).clamp(0.0, 1.0);
    _animation = Tween<double>(begin: _currentProgress, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _currentProgress = target;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Daily Steps",
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "${widget.steps.toString()} / ${widget.goal}",
                style: TextStyle(color: palette.textMuted, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, _) => _buildRing(context, _animation.value),
          ),
          const SizedBox(height: 16),
          Text(
            "Stay moving to reach your goal!",
            style: TextStyle(color: palette.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildRing(BuildContext context, double progress) {
    final palette = _palette(context);
    final pct = (progress * 100).toStringAsFixed(0);
    final stepsDone = (progress * widget.goal).round();

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 130,
          width: 130,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 10,
            backgroundColor: palette.border,
            valueColor: AlwaysStoppedAnimation<Color>(palette.accent),
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "$pct%",
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              "$stepsDone steps",
              style: TextStyle(color: palette.textMuted, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Achievements Section ─────────────────────────────────────────────────────
class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection();

  @override
  Widget build(BuildContext context) {
    final palette = _palette(context);
    return Row(
      children: [
        const Expanded(child: _AchievementCard(title: "10K Steps", progress: 0.8, color: AppTheme.accent)),
        SizedBox(width: 10),
        const Expanded(child: _AchievementCard(title: "Consistency", progress: 0.6, color: Colors.blueAccent)),
        SizedBox(width: 10),
        const Expanded(child: _AchievementCard(title: "Strength", progress: 0.4, color: Colors.orangeAccent)),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final String title;
  final double progress;
  final Color color;

  const _AchievementCard({
    required this.title,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _palette(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 64,
                width: 64,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 7,
                  backgroundColor: palette.border,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                "${(progress * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tip of the Day ───────────────────────────────────────────────────────────
class _TipOfTheDayCard extends StatelessWidget {
  final String tipText;

  const _TipOfTheDayCard({required this.tipText});

  @override
  Widget build(BuildContext context) {
    final palette = _palette(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: palette.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text("💡", style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "TIP OF THE DAY",
                  style: TextStyle(
                    color: palette.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tipText,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}