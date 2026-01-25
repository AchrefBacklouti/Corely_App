import 'dart:convert';
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
    final data = await loadAccountData();
    final suggestedPlans = data['workouts']['suggestedPlans'] as List;
    return suggestedPlans.map((plan) => WorkoutPlan.fromJson(plan)).toList();
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
