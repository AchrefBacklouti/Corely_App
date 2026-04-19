import 'package:flutter/material.dart';

// ─── Design Tokens (same as shell) ───────────────────────────────────────────
class _C {
  static const bg          = Color(0xFF0A0A0C);
  static const surface     = Color(0xFF111116);
  static const border      = Color(0xFF1E1E24);
  static const accent      = Color(0xFFC8FF00);
  static const accentDim   = Color(0xFF4A5A00);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSub     = Color(0xFFAAAAAA);
  static const textMuted   = Color(0xFF555555);
  static const blue        = Color(0xFF3A8CFF);
  static const orange      = Color(0xFFFF8C42);
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
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: _C.textMuted,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Good morning,",
          style: TextStyle(
            color: _C.textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.4,
          ),
        ),
        SizedBox(height: 2),
        Text(
          "Achraf 💪",
          style: TextStyle(
            color: _C.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            height: 1.2,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Ready to crush today's goals?",
          style: TextStyle(
            color: _C.textSub,
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
    return IntrinsicHeight(
      child: Row(
        children: [
          // Streak card — accent
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _C.accent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("⚡", style: TextStyle(fontSize: 22)),
                  SizedBox(height: 6),
                  Text(
                    "12 Days",
                    style: TextStyle(
                      color: _C.bg,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    "Current streak",
                    style: TextStyle(color: _C.accentDim, fontSize: 12),
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
                color: _C.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _C.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("🎯", style: TextStyle(fontSize: 22)),
                  SizedBox(height: 6),
                  Text(
                    "Today's Focus",
                    style: TextStyle(color: _C.textMuted, fontSize: 11),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Chest / Triceps",
                    style: TextStyle(
                      color: _C.textPrimary,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Daily Steps",
                style: TextStyle(
                  color: _C.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "${widget.steps.toString()} / ${widget.goal}",
                style: const TextStyle(color: _C.textMuted, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, _) => _buildRing(_animation.value),
          ),
          const SizedBox(height: 16),
          const Text(
            "Stay moving to reach your goal!",
            style: TextStyle(color: _C.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildRing(double progress) {
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
            backgroundColor: _C.border,
            valueColor: const AlwaysStoppedAnimation<Color>(_C.accent),
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "$pct%",
              style: const TextStyle(
                color: _C.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              "$stepsDone steps",
              style: const TextStyle(color: _C.textMuted, fontSize: 13),
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
    return Row(
      children: const [
        Expanded(child: _AchievementCard(title: "10K Steps",    progress: 0.8, color: _C.accent)),
        SizedBox(width: 10),
        Expanded(child: _AchievementCard(title: "Consistency",  progress: 0.6, color: _C.blue)),
        SizedBox(width: 10),
        Expanded(child: _AchievementCard(title: "Strength",     progress: 0.4, color: _C.orange)),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
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
                  backgroundColor: _C.border,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                "${(progress * 100).toStringAsFixed(0)}%",
                style: const TextStyle(
                  color: _C.textPrimary,
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
            style: const TextStyle(
              color: _C.textSub,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _C.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text("💡", style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "TIP OF THE DAY",
                  style: TextStyle(
                    color: _C.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tipText,
                  style: const TextStyle(
                    color: _C.textSub,
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