import 'package:flutter/material.dart';

//////////////////////////////////////////////////////
// PAGE 1 — HOME PAGE CONTENT
//////////////////////////////////////////////////////
class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const _GreetingText(),
          const SizedBox(height: 18),
          const _StatsSection(),
          const SizedBox(height: 12),
          const _TodayFocus(),
          const SizedBox(height: 18),
          const _StartWorkoutButton(),
          const SizedBox(height: 24),
          Divider(
            color: isDarkMode ? Colors.white : Colors.black,
            thickness: 2,
          ),
          const SizedBox(height: 14),
          const _StreakCard(),
          const SizedBox(height: 24),
          Divider(
            color: isDarkMode ? Colors.white : Colors.black,
            thickness: 2,
          ),
          const SizedBox(height: 14),
          const _QuickAccess(),
          const SizedBox(height: 24),
          const StepsCard(steps: 5000),
          const SizedBox(height: 22),
          const _TipOfTheDayCard(
            tipText:
                "Remember to log your calories today for accurate progress tracking!",
          ),
          const SizedBox(height: 26),
          const _AchievementsSection(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////
// COMPONENTS
//////////////////////////////////////////////////////////

class _GreetingText extends StatelessWidget {
  const _GreetingText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Welcome back, Achraf💪 Ready\nto crush today’s goals?",
      style: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Stats:",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 30,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              const Text(
                "🔥 calories: ",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Livvic',
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
              ),
              const Text(
                "1980 kcal   ",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Livvic',
                  fontWeight: FontWeight.w200,
                  fontSize: 20,
                ),
              ),
              const Text(
                "🏋 workouts this week: ",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Livvic',
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
              ),
              const Text(
                '3/5   ',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Livvic',
                  fontWeight: FontWeight.w200,
                  fontSize: 20,
                ),
              ),
              const Text(
                '⏱️Recovery: ',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Livvic',
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
              ),
              const Text(
                '82%   ',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Livvic',
                  fontWeight: FontWeight.w200,
                  fontSize: 20,
                ),
              ),
              const Text(
                '📈Progress: ',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Livvic',
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
              ),
              const Text(
                '6%   ',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Livvic',
                  fontWeight: FontWeight.w200,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TodayFocus extends StatelessWidget {
  const _TodayFocus();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Text(
          "Today’s focus : ",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 20,
            fontFamily: 'Livvic',
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          "chest/triceps",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 20,
            fontFamily: 'Livvic',
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

class _StartWorkoutButton extends StatelessWidget {
  const _StartWorkoutButton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () {},
        child: const Text(
          "start workout",
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'RedRose',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2B47),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              final isDarkMode =
                  Theme.of(context).brightness == Brightness.dark;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "⚡ 12 Day streak!!!",
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontFamily: 'Livvic',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "you're unstoppable, keep it up !",
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontFamily: 'Livvic',
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickAccess extends StatelessWidget {
  const _QuickAccess();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Access:",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 20,
            fontFamily: 'Livvic',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _quickAccessItem("🍎", "Log meal"),
            _quickAccessItem("🧘‍♂️", "Recovery"),
            _quickAccessItem("📋", "My plan"),
          ],
        ),
      ],
    );
  }
}

class _quickAccessItem extends StatelessWidget {
  final String emoji;
  final String label;

  const _quickAccessItem(this.emoji, this.label);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white12 : Colors.black12,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
        ),
      ],
    );
  }
}

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
      duration: const Duration(milliseconds: 800),
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
    final targetProgress = (widget.steps / widget.goal).clamp(0.0, 1.0);

    _animation = Tween<double>(
      begin: _currentProgress,
      end: targetProgress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _currentProgress = targetProgress;
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2B47),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Daily Steps",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return _buildProgressRing(context, _animation.value);
              },
            ),
            const SizedBox(height: 12),
            const Text(
              "Stay moving to reach your goal!",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRing(BuildContext context, double progress) {
    final percentage = (progress * 100).toStringAsFixed(0);
    final stepsCount = (progress * widget.goal).round();

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 140,
          width: 140,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 12,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "$percentage%",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "$stepsCount steps",
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _TipOfTheDayCard extends StatelessWidget {
  final String tipText;

  const _TipOfTheDayCard({required this.tipText});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white12 : Colors.black12,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        tipText,
        style: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.black54,
          fontFamily: 'Livvic',
          fontSize: 16,
        ),
      ),
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Achievements",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            _AchievementCard(title: "10K Steps", progress: 0.8),
            _AchievementCard(title: "Consistency", progress: 0.6),
            _AchievementCard(title: "Strength", progress: 0.4),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final String title;
  final double progress;

  const _AchievementCard({required this.title, required this.progress});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 70,
              width: 70,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
              ),
            ),
            Text(
              "${(progress * 100).toStringAsFixed(0)}%",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black54,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
