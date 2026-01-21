import 'package:flutter/material.dart';

class NutritionPageContent extends StatelessWidget {
  const NutritionPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MacroCard(
                label: "Calories",
                value: "1,980",
                subtitle: "of 2,400 kcal",
                progress: 0.82,
                color: Colors.orange,
              ),
              _MacroCard(
                label: "Protein",
                value: "132g",
                subtitle: "of 160g",
                progress: 0.82,
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MacroCard(
                label: "Carbs",
                value: "210g",
                subtitle: "of 280g",
                progress: 0.75,
                color: Colors.blue,
              ),
              _MacroCard(
                label: "Fats",
                value: "62g",
                subtitle: "of 70g",
                progress: 0.88,
                color: Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "Today’s meals",
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const _MealRow(
            title: "Breakfast",
            calories: "420 kcal",
            description: "Oats, berries, protein shake",
          ),
          const SizedBox(height: 10),
          const _MealRow(
            title: "Lunch",
            calories: "680 kcal",
            description: "Chicken, rice, veggies",
          ),
          const SizedBox(height: 10),
          const _MealRow(
            title: "Snack",
            calories: "180 kcal",
            description: "Greek yogurt, nuts",
          ),
          const SizedBox(height: 10),
          const _MealRow(
            title: "Dinner",
            calories: "620 kcal",
            description: "Salmon, sweet potato, broccoli",
          ),
          const SizedBox(height: 26),
          Text(
            "Hydration",
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _HydrationCard(isDarkMode: isDarkMode),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final double progress;
  final Color color;

  const _MacroCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.42,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2B47),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white12,
            color: color,
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  final String title;
  final String calories;
  final String description;

  const _MealRow({
    required this.title,
    required this.calories,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2B47),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.restaurant_menu,
              color: Colors.yellow,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            calories,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HydrationCard extends StatelessWidget {
  final bool isDarkMode;

  const _HydrationCard({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2B47),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white12 : Colors.black12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.water_drop,
              color: Colors.lightBlueAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Water intake",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "1.6 L of 3.0 L",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                "53%",
                style: TextStyle(
                  color: Colors.lightBlueAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Keep sipping",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
