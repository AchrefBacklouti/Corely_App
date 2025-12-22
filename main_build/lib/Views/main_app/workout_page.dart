import 'package:flutter/material.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // TOP BAR (Corely + Profile + Settings)
              // --------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Corely💪",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.settings, color: Colors.white, size: 26),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // --------------------------------------------------
              // WORKOUT SPLIT
              // --------------------------------------------------
              const Text(
                "Workout split : upper/lower",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Text(
                    "Upper day",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
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
                    child: const Text(
                      "modify",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Three-dot menu button
                  IconButton(
                    onPressed: () => _showWorkoutOptions(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    splashRadius: 22,
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Text(
                "x Exercises - x muscles",
                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 18),

              // --------------------------------------------------
              // FILTER TAGS
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF191B1F),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
              // DISCOVER STRENGTH PLANS
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
              // DISCOVER HYPERTROPHY PLANS
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

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // WORKOUT OPTIONS POPUP (THREE DOT MENU)
  // --------------------------------------------------
  void _showWorkoutOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF191B1F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Upper Day",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              _optionItem(Icons.delete, "Delete Workout"),
              _optionItem(Icons.edit, "Rename Workout"),
              _optionItem(Icons.picture_as_pdf, "Export to PDF"),
              _optionItem(Icons.refresh, "Reset to Default"),
            ],
          ),
        );
      },
    );
  }

  // Bottom sheet item
  Widget _optionItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
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
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 14),
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
