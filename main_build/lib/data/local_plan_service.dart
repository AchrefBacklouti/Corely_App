import 'package:hive_flutter/hive_flutter.dart';
import 'package:main_build/data/workout_plans.dart';

class LocalPlanService {
  static const String _customPlansBoxName = 'custom_plans';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(_customPlansBoxName);
  }

  static Future<void> savePlan(WorkoutPlan plan) async {
    final box = Hive.box<Map>(_customPlansBoxName);
    final planMap = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': plan.title,
      'duration': plan.duration,
      'exercises': plan.exercises,
      'imageAsset': plan.imageAsset,
      'imagePath': plan.imagePath,
      'difficulty': plan.difficulty,
      'dayExercises': plan.dayExercises,
      'dayNames': plan.dayNames,
      'selectedDays': plan.selectedDays,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await box.add(planMap);
  }

  static Future<List<WorkoutPlan>> getCustomPlans() async {
    final box = Hive.box<Map>(_customPlansBoxName);
    final plans = <WorkoutPlan>[];
    for (final item in box.values) {
      plans.add(WorkoutPlan.fromJson(Map<String, dynamic>.from(item)));
    }
    return plans;
  }

  static Future<void> deletePlan(int index) async {
    final box = Hive.box<Map>(_customPlansBoxName);
    await box.deleteAt(index);
  }

  static Future<void> clearAllPlans() async {
    final box = Hive.box<Map>(_customPlansBoxName);
    await box.clear();
  }
}
