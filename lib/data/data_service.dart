import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:main_build/data/workout_plans.dart';
import 'package:main_build/data/local_plan_service.dart';

class DataService {
  static Map<String, dynamic>? _cachedData;

  static Future<Map<String, dynamic>> loadAccountData() async {
    if (_cachedData != null) return _cachedData!;

    final jsonString = await rootBundle.loadString(
      'lib/data/sample_account.json',
    );
    _cachedData = json.decode(jsonString) as Map<String, dynamic>;
    return _cachedData!;
  }

  static Future<List<WorkoutPlan>> getCustomWorkoutPlans() async {
    // Load from local storage instead of file
    return await LocalPlanService.getCustomPlans();
  }

  static Future<List<WorkoutPlan>> getSuggestedWorkoutPlans() async {
    try {
      final data = await loadAccountData();
      final workouts = data['workouts'];
      if (workouts is! Map<String, dynamic>) return [];

      final suggestedPlans = workouts['suggestedPlans'];
      if (suggestedPlans is! List) return [];

      return suggestedPlans
          .whereType<Map>()
          .map((plan) => WorkoutPlan.fromJson(Map<String, dynamic>.from(plan)))
          .toList();
    } catch (e) {
      debugPrint('DataService: failed to load suggested workout plans: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getUserProfile() async {
    final data = await loadAccountData();
    return data['user'] as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getStats() async {
    final data = await loadAccountData();
    return data['stats'] as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getNutrition() async {
    final data = await loadAccountData();
    return data['nutrition'] as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getSettings() async {
    final data = await loadAccountData();
    return data['settings'] as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getGoals() async {
    final data = await loadAccountData();
    return data['goals'] as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getActivityFeed() async {
    final data = await loadAccountData();
    return data['activityFeed'] as List;
  }
}
