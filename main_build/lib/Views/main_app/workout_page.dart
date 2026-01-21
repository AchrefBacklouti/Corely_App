import 'package:flutter/material.dart';
import 'package:main_build/Theme/app_theme.dart';
import 'workout/create_workout_plan_page.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppTheme.darkBackground
          : AppTheme.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // TOP BAR
              // --------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Corely💪",
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: isDarkMode
                            ? Colors.white
                            : Colors.black,
                        child: Icon(
                          Icons.person,
                          color: isDarkMode ? Colors.black : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.settings,
                        color: isDarkMode ? Colors.white : Colors.black,
                        size: 26,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // --------------------------------------------------
              // TABS
              // --------------------------------------------------
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF191B1F),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.white70,
                  tabs: const [
                    Tab(text: "Custom"),
                    Tab(text: "Suggestions"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --------------------------------------------------
              // TAB CONTENT
              // --------------------------------------------------
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_customPlansSection(), _suggestionsSection()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================================================
  // CUSTOM PLANS
  // ==================================================
  Widget _customPlansSection() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 0.85,
      children: [
        _planCard("assets/img/plans/candito.png", "Candito 5/3/1"),
        _planCard("assets/img/plans/upperlower.png", "Upper / Lower"),

        // ADD NEW PLAN
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateWorkoutPlanPage()),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add, color: Colors.white, size: 42),
                SizedBox(height: 12),
                Text(
                  "Add New Plan",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================================================
  // SUGGESTIONS
  // ==================================================
  Widget _suggestionsSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Discover Strength Plans",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _plansRow(),

          const SizedBox(height: 26),

          const Text(
            "Discover Hypertrophy Plans",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _plansRow(),
        ],
      ),
    );
  }

  // ==================================================
  // PLAN ROW
  // ==================================================
  Widget _plansRow() {
    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _planCard("assets/img/plans/candito.png", "Candito 5/3/1"),
          const SizedBox(width: 14),
          _planCard("assets/img/plans/wendler.png", "Classic 5/3/1"),
          const SizedBox(width: 14),
          _planCard("assets/img/plans/gsb.png", "GSB Program"),
        ],
      ),
    );
  }

  // ==================================================
  // PLAN CARD
  // ==================================================
  Widget _planCard(String imagePath, String title) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
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
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
