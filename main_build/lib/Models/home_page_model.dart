import 'nutrition_page_model.dart';
import 'workout_page_model.dart';

class HomeSummaryModel {
  final int stepsToday;
  final double caloriesBurnedToday;
  final DailyNutrition? todayNutrition;
  final WorkoutDay? todayWorkout;
  final int streakCount; // training streak
  final double bodyWeightToday;

  HomeSummaryModel({
    required this.stepsToday,
    required this.caloriesBurnedToday,
    this.todayNutrition,
    this.todayWorkout,
    required this.streakCount,
    required this.bodyWeightToday,
  });
}
