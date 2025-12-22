import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:main_build/Views/main_app/settings_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),

      // ----------------------------
      // SAFE AREA + TOP BAR
      // ----------------------------
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),

            // ----------------------------
            // PAGE CONTENT (switches)
            // ----------------------------
            Expanded(
              child: IndexedStack(
                index: _index,
                children: const [
                  HomePageContent(),
                  WorkoutPageContent(),
                  StatsPageContent(),
                  NutritionPageContent(),
                ],
              ),
            ),
          ],
        ),
      ),

      // ----------------------------
      // BOTTOM NAV BAR
      // ----------------------------
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // -----------------------------------------
  // TOP BAR (Shared Across All Pages)
  // -----------------------------------------

  // -----------------------------------------
  // BOTTOM NAVIGATION BAR
  // -----------------------------------------
  Widget _buildBottomNav() {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFF191B1F),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(icon: Icons.home_filled, index: 0),
          _navItem(icon: Icons.fitness_center, index: 1),
          _navItem(icon: Icons.show_chart, index: 2),
          _navItem(icon: Icons.apple, index: 3),
        ],
      ),
    );
  }

  Widget _navItem({required IconData icon, required int index}) {
    final bool isActive = _index == index;

    return GestureDetector(
      onTap: () => setState(() => _index = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 20 : 0,
          vertical: 10,
        ),
        decoration: isActive
            ? BoxDecoration(
                color: const Color(0xFF0E0E0E),
                borderRadius: BorderRadius.circular(18),
              )
            : null,
        child: Icon(
          icon,
          size: isActive ? 28 : 24,
          color: isActive ? Colors.white : Colors.white70,
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////
// PAGE 1 — HOME PAGE CONTENT
//////////////////////////////////////////////////////
class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 24),
          _GreetingText(),
          SizedBox(height: 18),
          _StatsSection(),
          SizedBox(height: 12),
          _TodayFocus(),
          SizedBox(height: 18),
          _StartWorkoutButton(),
          SizedBox(height: 24),
          Divider(color: Colors.white, thickness: 2),
          SizedBox(height: 14),
          _StreakCard(),
          SizedBox(height: 24),
          Divider(color: Colors.white, thickness: 2),
          SizedBox(height: 14),
          _QuickAccess(),
          SizedBox(height: 24),
          StepsCard(steps: 5000),
          SizedBox(height: 22),
          _TipOfTheDayCard(
            tipText:
                "Remember to log your calories today for accurate progress tracking!",
          ),
          SizedBox(height: 26),
          _AchievementsSection(),
          SizedBox(height: 80),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Stats:",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 30,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              Text(
                "🔥 calories: ",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Livvic',
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
              ),
              Text(
                "1980 kcal   ",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Livvic',
                  fontWeight: FontWeight.w200,
                  fontSize: 20,
                ),
              ),
              Text(
                "🏋 workouts this week: ",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Livvic',
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
              ),
              Text(
                '3/5   ',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Livvic',
                  fontWeight: FontWeight.w200,
                  fontSize: 20,
                ),
              ),

              Text(
                '⏱️Recovery: ',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Livvic',
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
              ),
              Text(
                '82%   ',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Livvic',
                  fontWeight: FontWeight.w200,
                  fontSize: 20,
                ),
              ),
              Text(
                '📈Progress: ',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Livvic',
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
              ),
              Text(
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
    return Row(
      children: const [
        Text(
          "Today’s focus : ",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Livvic',
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          "chest/triceps",
          style: TextStyle(
            color: Colors.white,
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
          shadowColor: Colors.white,
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "⚡ 12 Day streak!!!",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Livvic',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "you're unstoppable, keep it up !",
            style: TextStyle(
              color: Colors.white70,
              fontFamily: 'Livvic',
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Access:",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Livvic',
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _quickAccessItem("🍎", "Log meal"),
            _quickAccessItem("🧘‍♂️", "Recovery"),
            _quickAccessItem("📋", "My plan"),
          ],
        ),
      ],
    );
  }
}

Widget _quickAccessItem(String emoji, String label) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 24)),
      ),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(color: Colors.white70)),
    ],
  );
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

  double _currentProgress = 0.0; // stores last progress value

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
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2B47),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Steps label box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),

              child: const Text(
                "Steps :",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Icon + steps number
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/shoe.png',
                  width: 40,
                  height: 40,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Text(
                  '${widget.steps}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Livvic',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Animated progress bar
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 14,
                    color: const Color.fromARGB(255, 23, 27, 33),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _animation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            Text(
              "can you reach ${widget.goal}?",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF243350), // dark navy
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "AI Tip of the Day:",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            tipText,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Unlocked Achievements:",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        Center(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 48,
            ),
          ),
        ),
      ],
    );
  }
}

//////////////////////////////////////////////////////
// PAGE 2 — WORKOUT PAGE CONTENT
//////////////////////////////////////////////////////
class WorkoutPageContent extends StatelessWidget {
  const WorkoutPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --------------------------------------------------
          // TOP BAR
          // --------------------------------------------------

          // --------------------------------------------------
          // WORKOUT SPLIT TITLE
          // --------------------------------------------------
          Row(
            children: [
              const Text(
                "Workout split :",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Livvic',
                ),
              ),
              SizedBox(width: 5),
              Text(
                'upper/lower',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w200,
                  fontFamily: 'Livvic',
                ),
              ),
              SizedBox(width: 25),
              const Icon(Icons.more_horiz, color: Colors.yellow, size: 26),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Text(
                "Upper day",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Livvic',
                ),
              ),
              const SizedBox(width: 10),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.restart_alt, color: Colors.black),
                    const Text(
                      "modify",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),
            ],
          ),

          const SizedBox(height: 12),
          const Text(
            "x Exercises - x muscles",
            style: TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 18),

          // --------------------------------------------------
          // TAGS
          // --------------------------------------------------
          Row(
            children: [
              _tag("1 hr"),
              const SizedBox(width: 12),
              _tag("Large gym"),
            ],
          ),

          const SizedBox(height: 26),

          // --------------------------------------------------
          // EXERCISE LIST
          // --------------------------------------------------
          _exerciseItem(
            iconPath: "assets/ex_icons/decline.png",
            title: "Decline Bench Press",
            details: "4 Sets • 10–12 Reps • 15 kg • RPE 8–9",
          ),
          _exerciseItem(
            iconPath: "assets/ex_icons/preacher.png",
            title: "Barbell Preacher Curl",
            details: "4 Sets • 9 Reps • 15 kg • RPE 10",
          ),
          _exerciseItem(
            iconPath: "assets/ex_icons/concentration.png",
            title: "Concentration Curl",
            details: "4 Sets • 10–12 Reps • 15 kg • RPE 10",
          ),

          const SizedBox(height: 20),

          // --------------------------------------------------
          // ADD EXERCISE BUTTON
          // --------------------------------------------------
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF191B1F),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add, color: Colors.white, size: 28),
                  SizedBox(width: 10),
                  Text(
                    "Add Exercise",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // --------------------------------------------------
          // STRENGTH PLANS
          // --------------------------------------------------
          const Text(
            "Discover Strength Plans:",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),
          _plansRow(),

          const SizedBox(height: 30),

          // --------------------------------------------------
          // HYPERTROPHY PLANS
          // --------------------------------------------------
          const Text(
            "Discover hypertrophy Plans:",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),
          _plansRow(),

          const SizedBox(height: 120), // bottom padding
        ],
      ),
    );
  }

  // --------------------------------------------------
  // TAG WIDGET
  // --------------------------------------------------
  Widget _tag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Livvic',
              fontWeight: FontWeight.w400,
            ),
          ),
          Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // EXERCISE ITEM
  // --------------------------------------------------
  Widget _exerciseItem({
    required String iconPath,
    required String title,
    required String details,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF191B1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.orange.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fitness_center, color: Colors.white),
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  details,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // HORIZONTAL PLANS SCROLLER
  // --------------------------------------------------
  Widget _plansRow() {
    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _planCard("assets/plans/candito.png", "Candito 5/3/1"),
          const SizedBox(width: 14),
          _planCard("assets/plans/wendler.png", "Classic 5/3/1"),
          const SizedBox(width: 14),
          _planCard("assets/plans/gsb.png", "GSB Plan"),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // PLAN CARD
  // --------------------------------------------------
  Widget _planCard(String imagePath, String title) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////
// PAGE 3 — STATS PAGE CONTENT
//////////////////////////////////////////////////////
class StatsPageContent extends StatelessWidget {
  const StatsPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----------------------------------------------
          // BODYWEIGHT PROGRESS
          // ----------------------------------------------
          const Text(
            "Bodyweight Progress:",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _graphPlaceholder("Log your BodyWeight to track the progress"),

          const SizedBox(height: 28),

          // ----------------------------------------------
          // WEIGHT PROGRESS
          // ----------------------------------------------
          const Text(
            "Weight Progress:",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _graphPlaceholder("Start your first workout to track the progress"),

          const SizedBox(height: 32),

          // ----------------------------------------------
          // RECOVERY OVERVIEW
          // ----------------------------------------------
          const Text(
            "Recovery Overview:",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),
          const Text(
            "see which muscles are ready to train again today",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),

          const Text(
            "percentage : 82%",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),

          const SizedBox(height: 16),

          Row(
            children: const [
              _legendDot(color: Colors.red),
              SizedBox(width: 6),
              Text("sore", style: TextStyle(color: Colors.white70)),
              SizedBox(width: 20),
              _legendDot(color: Colors.green),
              SizedBox(width: 6),
              Text("recovered", style: TextStyle(color: Colors.white70)),
              SizedBox(width: 20),
              _legendDot(color: Colors.yellow),
              SizedBox(width: 6),
              Text("almost recovered", style: TextStyle(color: Colors.white70)),
            ],
          ),

          const SizedBox(height: 20),

          // ----------------------------------------------
          // ANATOMY IMAGES (front + back)
          // ----------------------------------------------
          Center(
            child: Image.asset(
              "assets/anatomy/front.png", // ADD THIS IMAGE
              height: 260,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Image.asset(
              "assets/anatomy/back.png", // ADD THIS IMAGE
              height: 260,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 40),

          // ----------------------------------------------
          // FITNESS OVERVIEW TEXT
          // ----------------------------------------------
          const Center(
            child: Text(
              "Fitness Overview",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Text(
            "This helps you compare muscle development to improve your training plan.",
            style: TextStyle(color: Colors.white70, height: 1.4),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // ----------------------------------------------
          // DEVELOPMENT SCALE
          // ----------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Underdeveloped", style: TextStyle(color: Colors.white70)),
              Text("Overdeveloped", style: TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 8),

          Container(
            height: 16,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [
                  Color(0xff4aa3ff),
                  Color(0xff00ff62),
                  Color(0xffff6f00),
                  Color(0xffff2f2f),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          // ----------------------------------------------
          // LAST TRAINING SUMMARY
          // ----------------------------------------------
          const Text(
            "Achraf’s Last Training :  Yesterday (lower body)",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 6),
          const Text(
            "Goal : Recomposition",
            style: TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 32),

          // ----------------------------------------------
          // MUSCLE BALANCE SCORE
          // ----------------------------------------------
          const Center(
            child: Text(
              "Muscle Balance Score:",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          _scoreBar(0.69),

          const SizedBox(height: 12),
          const Center(
            child: Text(
              "69%",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),

          const SizedBox(height: 12),
          const Center(
            child: Text(
              "You're in the Developing Balance range",
              style: TextStyle(color: Colors.white70),
            ),
          ),

          const SizedBox(height: 20),
          const Center(
            child: Text(
              "Best Score Yet: 74% (+5%)",
              style: TextStyle(color: Colors.white),
            ),
          ),

          const SizedBox(height: 40),

          // ----------------------------------------------
          // INSIGHT CARD
          // ----------------------------------------------
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xff1F2A33),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "Forearms and calves lag behind upper body.\n"
                    "+Add direct grip and calf training twice weekly.",
                    style: TextStyle(color: Colors.white70, height: 1.4),
                  ),
                ),
                const SizedBox(width: 12),
                Image.asset("assets/assistant.png", width: 60),
              ],
            ),
          ),

          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////
// COMPONENTS
///////////////////////////////////////////////////////////

Widget _graphPlaceholder(String label) {
  return Container(
    height: 180,
    decoration: BoxDecoration(
      color: const Color(0xFF202020),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.yellow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}

class _legendDot extends StatelessWidget {
  final Color color;
  const _legendDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

Widget _scoreBar(double value) {
  return Container(
    height: 20,
    decoration: BoxDecoration(
      color: Colors.white12,
      borderRadius: BorderRadius.circular(20),
    ),
    child: FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: value,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.greenAccent,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
  );
}

//////////////////////////////////////////////////////
// PAGE 4 — NUTRITION PAGE CONTENT
//////////////////////////////////////////////////////
class NutritionPageContent extends StatelessWidget {
  const NutritionPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --------------------------------------------------
          // TITLE
          // --------------------------------------------------
          const Center(
            child: Text(
              "Nutrition Overview :",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 6),

          const Center(
            child: Text(
              "Fuel your recovery and performance\nToday's intake balance and macro summary",
              style: TextStyle(color: Colors.white70, height: 1.3),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 22),

          // --------------------------------------------------
          // DONUT MACRO CHART + MACRO DETAILS
          // --------------------------------------------------
          _MacroCard(),

          const SizedBox(height: 24),

          // --------------------------------------------------
          // ACTION BUTTONS
          // --------------------------------------------------
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Log Meal",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1B1F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Add Meal",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // --------------------------------------------------
          // RECIPES TITLE
          // --------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Discover delicious recipes:",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.more_horiz, color: Colors.white70),
            ],
          ),

          const SizedBox(height: 18),

          // --------------------------------------------------
          // HORIZONTAL RECIPE SCROLLER
          // --------------------------------------------------
          _RecipesRow(),

          const SizedBox(height: 24),

          // --------------------------------------------------
          // BROWSE BUTTON
          // --------------------------------------------------
          Center(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Browse",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  const _MacroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Macro donut chart + dropdown
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------------------------
              // DONUT CHART PLACEHOLDER
              // -------------------------
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 18),
                ),
                child: const Center(
                  child: Text(
                    "30%\n135 g",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      height: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // -------------------------
              // MACRO DETAILS
              // -------------------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // UNIT DROPDOWN
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D3E57),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text("Gram", style: TextStyle(color: Colors.white)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_drop_down, color: Colors.white),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      "Goal :\n2700 Kcal",
                      textAlign: TextAlign.right,
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Eaten :\n1800 Kcal",
                      textAlign: TextAlign.right,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Text(
            "Tab color to see Detail",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),

          const SizedBox(height: 12),

          // -------------------------
          // MACRO LEGEND
          // -------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _macroLegend(color: Color(0xff3e5bdb), label: "Protein"),
              _macroLegend(color: Color(0xfff6e75a), label: "Carbs"),
              _macroLegend(color: Color(0xfff06a77), label: "Fats"),
            ],
          ),
        ],
      ),
    );
  }
}

class _macroLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _macroLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

class _RecipesRow extends StatelessWidget {
  const _RecipesRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          _recipeCard(
            image: "assets/recipes/chicken.png",
            title: "Grilled chicken bowl",
            calories: "420 Kcal",
          ),
          SizedBox(width: 14),
          _recipeCard(
            image: "assets/recipes/mixedfry.png",
            title: "Mixed fry up",
            calories: "600 Kcal",
          ),
          SizedBox(width: 14),
          _recipeCard(
            image: "assets/recipes/pancakes.png",
            title: "Protein pancakes",
            calories: "750 Kcal",
          ),
          SizedBox(width: 14),
          _recipeCard(
            image: "assets/recipes/fettuccine.png",
            title: "Fettuccine",
            calories: "850 Kcal",
          ),
        ],
      ),
    );
  }
}

class _recipeCard extends StatelessWidget {
  final String image;
  final String title;
  final String calories;

  const _recipeCard({
    required this.image,
    required this.title,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B1F),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // CALORIES
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              calories,
              style: const TextStyle(
                color: Colors.yellow,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 4),

          // TITLE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              title,
              maxLines: 2,
              style: const TextStyle(color: Colors.white, height: 1.1),
            ),
          ),

          const SizedBox(height: 4),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "click to check it out",
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const SizedBox(width: 20),
            Image.asset('assets/logo.png', width: 75),
          ],
        ),

        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white12,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: SvgPicture.asset(
                "assets/icons/settings.svg",
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
                width: 40,
                height: 40,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
