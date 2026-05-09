import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:main_build/Models/exercise.dart';

class ExerciseCacheService {
  static const String _exercisesBoxName = 'exercises_cache';
  static const String _exercisesKey = 'exercises_data';
  static const String _lastUpdateKey = 'last_update';

  static Future<void> init() async {
    await Hive.openBox(_exercisesBoxName);
  }

  /// Get exercises from cache or fetch from API
  static Future<List<Exercise>> getExercises({
    bool forceRefresh = false,
  }) async {
    final box = Hive.box(_exercisesBoxName);

    // Check if we have cached exercises and not forcing refresh
    if (!forceRefresh && box.containsKey(_exercisesKey)) {
      final cachedData = box.get(_exercisesKey) as String?;
      if (cachedData != null && cachedData.isNotEmpty) {
        try {
          final List<dynamic> decoded = json.decode(cachedData);
          final exercises = decoded
              .whereType<Map<String, dynamic>>()
              .map((e) => Exercise.fromJson(e))
              .toList();
          return exercises;
        } catch (e) {
          print('Error loading cached exercises: $e');
        }
      }
    }

    // Fetch from API if no cache or force refresh
    try {
      const url =
          'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Save to cache
        await box.put(_exercisesKey, response.body);
        await box.put(_lastUpdateKey, DateTime.now().toIso8601String());

        final dynamic body = json.decode(response.body);
        final List<dynamic> results = body is List ? body : [];

        final exercises = results
            .whereType<Map<String, dynamic>>()
            .map((e) => Exercise.fromJson(e))
            .toList();

        return exercises;
      }
    } catch (e) {
      print('Error fetching exercises: $e');

      // Try to return cached data if fetch failed
      final cachedData = box.get(_exercisesKey) as String?;
      if (cachedData != null && cachedData.isNotEmpty) {
        try {
          final List<dynamic> decoded = json.decode(cachedData);
          final exercises = decoded
              .whereType<Map<String, dynamic>>()
              .map((e) => Exercise.fromJson(e))
              .toList();
          return exercises;
        } catch (e) {
          print('Error loading cached exercises after fetch failure: $e');
        }
      }
    }

    return [];
  }

  /// Check if exercises are cached
  static bool hasCachedExercises() {
    final box = Hive.box(_exercisesBoxName);
    return box.containsKey(_exercisesKey);
  }

  /// Get last update time
  static DateTime? getLastUpdateTime() {
    final box = Hive.box(_exercisesBoxName);
    final lastUpdate = box.get(_lastUpdateKey) as String?;
    if (lastUpdate != null) {
      return DateTime.tryParse(lastUpdate);
    }
    return null;
  }

  /// Clear cached exercises
  static Future<void> clearCache() async {
    final box = Hive.box(_exercisesBoxName);
    await box.clear();
  }
}
