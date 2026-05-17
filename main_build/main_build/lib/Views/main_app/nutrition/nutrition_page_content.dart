import 'package:flutter/material.dart';
import '../../../Theme/app_theme.dart';

class NutritionPageContent extends StatelessWidget {
  const NutritionPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF05070D), Color(0xFF0B0F1A), Color(0xFF121826)],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            const SizedBox(height: 30),

            _buildStatsRow(),

            const SizedBox(height: 32),

            const Text(
              "Workout Meals",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _buildMealsList(),

            const SizedBox(height: 32),

            const Text(
              "Hydration",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            const _HydrationCard(),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "NUTRITION SECTION",
          style: TextStyle(
            color: Colors.orange[400],
            fontSize: 12,
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
            children: [
              TextSpan(text: "Fuel Your\n"),
              TextSpan(
                text: "Workout",
                style: TextStyle(color: Colors.orange),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          "Discover healthy meals designed to boost your energy, improve recovery, and support your fitness goals.",
          style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
        ),

        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            elevation: 10,
            shadowColor: Colors.orange,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Text(
            "Explore Plans",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Column(
      children: [
        Row(
          children: const [
            Expanded(
              child: _StatCard(title: "Daily Calories", value: "2,450"),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _StatCard(title: "Protein Goal", value: "145g"),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(title: "Water Intake", value: "3.2L"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMealsList() {
    return Column(
      children: meals.map((meal) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _MealCard(meal: meal),
        );
      }).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1F2E), Color(0xFF111522)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class Meal {
  final String name;
  final int calories;
  final String protein;
  final String carbs;
  final String fats;
  final String level;
  final String image;

  const Meal({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.level,
    required this.image,
  });
}

const List<Meal> meals = [
  Meal(
    name: "Mass Gainer Bowl",
    calories: 720,
    protein: "52g",
    carbs: "68g",
    fats: "18g",
    level: "Bulking",
    image:
        "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=1200&auto=format&fit=crop",
  ),
  Meal(
    name: "Shredded Chicken",
    calories: 430,
    protein: "46g",
    carbs: "15g",
    fats: "10g",
    level: "Cutting",
    image:
        "https://images.unsplash.com/photo-1546793665-c74683f339c1?q=80&w=1200&auto=format&fit=crop",
  ),
  Meal(
    name: "Power Oats",
    calories: 510,
    protein: "30g",
    carbs: "58g",
    fats: "12g",
    level: "Energy",
    image:
        "https://images.unsplash.com/photo-1517673400267-0251440c45dc?q=80&w=1200&auto=format&fit=crop",
  ),
];

class _MealCard extends StatelessWidget {
  final Meal meal;

  const _MealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1F2E), Color(0xFF111522)],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.orange.withOpacity(0.15), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.12),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 220,
                width: double.infinity,
                child: Hero(
                  tag: meal.name,
                  child: Image.network(meal.image, fit: BoxFit.cover),
                ),
              ),

              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.orange.withOpacity(0.2)),
                  ),
                  child: Text(
                    meal.level,
                    style: TextStyle(
                      color: Colors.orange[400],
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        meal.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "${meal.calories} kcal",
                        style: TextStyle(
                          color: Colors.orange[400],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _MacroBox(label: "PROTEIN", value: meal.protein),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MacroBox(label: "CARBS", value: meal.carbs),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MacroBox(label: "FATS", value: meal.fats),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      elevation: 10,
                      shadowColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      "Add To Meal Plan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

class _MacroBox extends StatelessWidget {
  final String label;
  final String value;

  const _MacroBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D111B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _HydrationCard extends StatelessWidget {
  const _HydrationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1F2E), Color(0xFF111522)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.water_drop, color: Colors.blue),
              SizedBox(width: 10),
              Text(
                "Water Intake",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: 0.7,
              minHeight: 10,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            "2.1L / 3.0L",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
