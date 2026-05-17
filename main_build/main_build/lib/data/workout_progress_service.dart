import 'package:hive_flutter/hive_flutter.dart';

class WorkoutProgressService {
  static const String _boxName = 'workout_progress';

  static Future<void> init() async {
    await Hive.openBox<Map>(_boxName);
  }

  static String planKey({
    required String title,
    required String duration,
    required int daysCount,
  }) {
    return '${title.trim()}|${duration.trim()}|$daysCount';
  }

  static Map<int, Map<String, Map<String, String>>> getPlanProgress(
    String key,
  ) {
    final box = Hive.box<Map>(_boxName);
    final raw = box.get(key);
    if (raw == null) return {};

    final result = <int, Map<String, Map<String, String>>>{};

    for (final entry in raw.entries) {
      final dayIndex = int.tryParse(entry.key.toString());
      if (dayIndex == null || entry.value is! Map) continue;

      final dayMap = <String, Map<String, String>>{};
      final exercisesRaw = Map.from(entry.value as Map);

      for (final exerciseEntry in exercisesRaw.entries) {
        if (exerciseEntry.value is! Map) continue;
        final fields = <String, String>{};
        final fieldsRaw = Map.from(exerciseEntry.value as Map);

        for (final fieldEntry in fieldsRaw.entries) {
          fields[fieldEntry.key.toString()] =
              fieldEntry.value?.toString() ?? '';
        }

        dayMap[exerciseEntry.key.toString()] = fields;
      }

      result[dayIndex] = dayMap;
    }

    return result;
  }

  static Future<void> savePlanProgress(
    String key,
    Map<int, Map<String, Map<String, String>>> progress,
  ) async {
    final box = Hive.box<Map>(_boxName);

    final serialized = <String, Map<String, Map<String, String>>>{};
    for (final dayEntry in progress.entries) {
      serialized[dayEntry.key.toString()] = dayEntry.value;
    }

    await box.put(key, serialized);
  }
}
