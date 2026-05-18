class FoodItem {
  final String name; // e.g., "Chicken Breast"
  final double calories; // total calories
  final double protein; // grams
  final double carbs; // grams
  final double fats; // grams
  final double servingSize; // in grams
  final String? imagePath; // optional picture

  FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.servingSize,
    this.imagePath,
  });
}

class Meal {
  final String mealType; // e.g., "Breakfast", "Lunch", "Dinner", "Snack"
  final List<FoodItem> foods;

  Meal({required this.mealType, required this.foods});

  double get totalCalories => foods.fold(0, (sum, item) => sum + item.calories);

  double get totalProtein => foods.fold(0, (sum, item) => sum + item.protein);

  double get totalCarbs => foods.fold(0, (sum, item) => sum + item.carbs);

  double get totalFats => foods.fold(0, (sum, item) => sum + item.fats);
}

class DailyNutrition {
  final DateTime date;
  final List<Meal> meals;
  final double calorieGoal;
  final double proteinGoal;
  final double carbGoal;
  final double fatGoal;

  DailyNutrition({
    required this.date,
    required this.meals,
    required this.calorieGoal,
    required this.proteinGoal,
    required this.carbGoal,
    required this.fatGoal,
  });

  double get totalCalories =>
      meals.fold(0, (sum, meal) => sum + meal.totalCalories);

  double get totalProtein =>
      meals.fold(0, (sum, meal) => sum + meal.totalProtein);

  double get totalCarbs => meals.fold(0, (sum, meal) => sum + meal.totalCarbs);

  double get totalFats => meals.fold(0, (sum, meal) => sum + meal.totalFats);
}
