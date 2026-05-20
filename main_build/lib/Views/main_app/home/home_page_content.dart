import 'package:flutter/material.dart';
import 'package:main_build/Controllers/user_provider.dart';
import 'package:main_build/Theme/app_theme.dart';
import 'package:main_build/data/supabase_service.dart';

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
    return AnimatedBuilder(
      animation: UserProvider.instance,
      builder: (context, _) {
        final profile = UserProvider.instance.userProfile;
        final displayName = profile?.fullName.isNotEmpty == true
            ? profile!.fullName
            : 'User';
        final focusText = profile?.goal ?? 'Set your goal in profile';

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              _GreetingText(name: displayName),
              const SizedBox(height: 20),
              _StreakAndFocusRow(focusText: focusText),
              const SizedBox(height: 20),
              const _SectionLabel('Daily Steps'),
              const SizedBox(height: 10),
              DailyStepsSection(userId: profile?.userId),
              const SizedBox(height: 20),
              const _SectionLabel('Achievements'),
              const SizedBox(height: 10),
              const _AchievementsSection(),
              const SizedBox(height: 20),
              const _TipOfTheDayCard(),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}

class DailyStepsSection extends StatefulWidget {
  const DailyStepsSection({super.key, required this.userId});

  final String? userId;

  @override
  State<DailyStepsSection> createState() => _DailyStepsSectionState();
}

class _DailyStepsSectionState extends State<DailyStepsSection> {
  late Future<int?> _stepsFuture;

  @override
  void initState() {
    super.initState();
    _stepsFuture = _loadSteps();
  }

  @override
  void didUpdateWidget(covariant DailyStepsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _stepsFuture = _loadSteps();
    }
  }

  Future<int?> _loadSteps() async {
    final userId = widget.userId;
    if (userId == null || userId.isEmpty) {
      return null;
    }
    return SupabaseService.getLocalDailySteps(userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: _stepsFuture,
      builder: (context, snapshot) {
        return StepsCard(steps: snapshot.data);
      },
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
  const _GreetingText({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final palette = _palette(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good morning,',
          style: TextStyle(
            color: palette.textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$name 💪',
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

// ─── Streak + Focus Card ──────────────────────────────────────────────────────
class _StreakAndFocusRow extends StatelessWidget {
  const _StreakAndFocusRow({required this.focusText});

  final String focusText;

  @override
  Widget build(BuildContext context) {
    final palette = _palette(context);
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: palette.surfaceRaised,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT STREAK',
                  style: TextStyle(
                    color: palette.textMuted,
                    fontSize: 10,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '—',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: palette.surfaceRaised,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FOCUS',
                  style: TextStyle(
                    color: palette.textMuted,
                    fontSize: 10,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  focusText,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Steps Card ───────────────────────────────────────────────────────────────
class StepsCard extends StatefulWidget {
  final int? steps;
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
    final steps = widget.steps ?? 0;
    final target = (steps / widget.goal).clamp(0.0, 1.0);
    _animation = Tween<double>(
      begin: _currentProgress,
      end: target,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
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
        color: palette.surfaceRaised,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Steps',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                widget.steps == null
                    ? 'No step data yet'
                    : '${widget.steps} / ${widget.goal}',
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
            widget.steps == null
                ? 'Connect step tracking later to show real progress.'
                : 'Stay moving to reach your goal!',
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildRing(BuildContext context, double progress) {
    final palette = _palette(context);
    final stepsDone = (progress * widget.goal).round();

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 128,
          width: 128,
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
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$stepsDone steps',
              style: TextStyle(color: palette.textMuted, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Achievements ─────────────────────────────────────────────────────────────
class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection();

  @override
  Widget build(BuildContext context) {
    final palette = _palette(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No achievements yet',
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your real progress will appear here as you train and track data.',
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tip of the Day ───────────────────────────────────────────────────────────
class _TipOfTheDayCard extends StatelessWidget {
  const _TipOfTheDayCard();

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
              color: palette.accentSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('💡', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TIP OF THE DAY',
                  style: TextStyle(
                    color: palette.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Real tips will appear here once your progress data is tracked on the phone.',
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
