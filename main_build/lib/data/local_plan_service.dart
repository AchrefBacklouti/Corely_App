import 'package:hive_flutter/hive_flutter.dart';
import 'package:main_build/data/workout_plans.dart';

class LocalPlanService {
  static const String _customPlansBoxName = 'custom_plans';

  static Future<void> init() async {
    await Hive.openBox<Map>(_customPlansBoxName);
  }

  static Future<void> updatePlan(int index, WorkoutPlan updated) async {
    final box = Hive.box<Map>(_customPlansBoxName);
    if (index < 0 || index >= box.length) return;

    final updatedMap = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': updated.title,
      'duration': updated.duration,
      'exercises': updated.exercises,
      'imageAsset': updated.imageAsset,
      'imagePath': updated.imagePath,
      'difficulty': updated.difficulty,
      'dayExercises': updated.dayExercises,
      'dayNames': updated.dayNames,
      'selectedDays': updated.selectedDays,
      'createdAt': DateTime.now().toIso8601String(),
    };

    await box.putAt(index, updatedMap);
  }

  static const _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  // Converts a suggested-plan WorkoutDay (string exercises) into the
  // dayExercises / dayNames / selectedDays format used by EditPlanPage.
  static Map<String, dynamic> _resolveCustomFields(WorkoutPlan plan) {
    if (plan.dayExercises.isNotEmpty ||
        plan.days == null ||
        plan.days!.isEmpty) {
      return {
        'dayExercises': plan.dayExercises,
        'dayNames': plan.dayNames,
        'selectedDays': plan.selectedDays,
      };
    }
    final days = plan.days!;
    final count = days.length.clamp(0, 7);
    return {
      'dayExercises': days.take(count).map((d) {
        return d.exercises
            .map((name) => {
                  'id': name.hashCode.toString(),
                  'name': name,
                  'bodyPart': 'general',
                  'target': 'General',
                  'equipment': 'body only',
                })
            .toList();
      }).toList(),
      'dayNames': days.take(count).map((d) => d.label).toList(),
      'selectedDays': _weekdays.take(count).toList(),
    };
  }

  static Future<void> savePlan(WorkoutPlan plan) async {
    final box = Hive.box<Map>(_customPlansBoxName);
    final custom = _resolveCustomFields(plan);
    final planMap = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': plan.title,
      'duration': plan.duration,
      'exercises': plan.exercises,
      'imageAsset': plan.imageAsset,
      'imagePath': plan.imagePath,
      'difficulty': plan.difficulty,
      'dayExercises': custom['dayExercises'],
      'dayNames': custom['dayNames'],
      'selectedDays': custom['selectedDays'],
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
