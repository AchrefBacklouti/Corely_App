class FoodItem {
  final String id;
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fats;
  final String servingSize;
  final String image;
  final String source; // 'openfoodfacts' etc

  const FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.servingSize,
    required this.image,
    required this.source,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fats: (json['fats'] as num?)?.toDouble() ?? 0.0,
      servingSize: json['serving_size'] ?? '100g',
      image: json['image'] ?? '',
      source: json['source'] ?? 'openfoodfacts',
    );
  }
}

// Meal categories for filtering
const List<MealCategory> mealCategories = [
  MealCategory(id: 'breakfast', name: 'Breakfast', icon: '🍳'),
  MealCategory(id: 'lunch', name: 'Lunch', icon: '🍱'),
  MealCategory(id: 'dinner', name: 'Dinner', icon: '🍽️'),
  MealCategory(id: 'snack', name: 'Snack', icon: '🥤'),
  MealCategory(id: 'smoothie', name: 'Smoothie', icon: '🥤'),
];

class MealCategory {
  final String id;
  final String name;
  final String icon;

  const MealCategory({
    required this.id,
    required this.name,
    required this.icon,
  });
}
