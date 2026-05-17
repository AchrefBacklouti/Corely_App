import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:main_build/data/supabase_service.dart';
import 'package:main_build/data/workout_plans.dart';

class LocalPlanService {
  static const String _customPlansBoxName = 'custom_plans';

  /// Incremented every time a plan is saved. Listeners (e.g. WorkoutPageContent)
  /// use this to refresh without needing a direct callback reference.
  static final plansChanged = ValueNotifier<int>(0);

  static Future<void> init() async {
    await Hive.openBox<Map>(_customPlansBoxName);
  }

  static Future<void> updatePlan(int index, WorkoutPlan updated) async {
    final box = Hive.box<Map>(_customPlansBoxName);
    if (index < 0 || index >= box.length) return;

    final existing = Map<String, dynamic>.from(box.getAt(index) as Map);
    final updatedMap = {
      ...existing,
      'title': updated.title,
      'duration': updated.duration,
      'exercises': updated.exercises,
      'imageAsset': updated.imageAsset,
      'imagePath': updated.imagePath,
      'difficulty': updated.difficulty,
      'dayExercises': updated.dayExercises,
      'dayNames': updated.dayNames,
      'selectedDays': updated.selectedDays,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await box.putAt(index, updatedMap);

    final supabaseId = existing['supabaseId'] as String?;
    if (supabaseId != null) {
      SupabaseService.updateUserPlan(supabaseId, updated);
    }
  }

  static const _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

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

  static Future<void> savePlan(
    WorkoutPlan plan, {
    String source = 'custom',
    String? aiRawText,
  }) async {
    final box = Hive.box<Map>(_customPlansBoxName);
    final custom = _resolveCustomFields(plan);
    final planMap = <String, dynamic>{
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
      'source': source,
      'createdAt': DateTime.now().toIso8601String(),
      'supabaseId': null,
    };
    final hiveKey = await box.add(planMap);
    plansChanged.value++;

    // Sync to Supabase in background; store returned ID back in Hive.
    SupabaseService.saveUserPlan(
      plan,
      source: source,
      aiRawText: aiRawText,
    ).then((supabaseId) async {
      if (supabaseId != null) {
        final current = Map<String, dynamic>.from(box.get(hiveKey) as Map);
        current['supabaseId'] = supabaseId;
        await box.put(hiveKey, current);
      }
    });
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
    final entry = box.getAt(index);
    if (entry != null) {
      final supabaseId =
          (Map<String, dynamic>.from(entry))['supabaseId'] as String?;
      if (supabaseId != null) {
        SupabaseService.deleteUserPlan(supabaseId);
      }
    }
    await box.deleteAt(index);
  }

  static Future<void> clearAllPlans() async {
    final box = Hive.box<Map>(_customPlansBoxName);
    await box.clear();
  }
}
