import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:main_build/data/workout_plans.dart';

class SupabaseService {
  static const _url = 'https://colmjvbhmkqaanjaenaa.supabase.co';
  static const _anonKey = 'sb_publishable_CzAtiousn9waTH7VXdVf_w_D5XdA86_';

  static const _configBox = 'app_config';
  static const _deviceIdKey = 'device_id';

  static SupabaseClient get _db => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(url: _url, anonKey: _anonKey);
    await Hive.openBox(_configBox);
  }

  // Stable per-device identifier (no auth required)
  static String get deviceId {
    final box = Hive.box(_configBox);
    var id = box.get(_deviceIdKey) as String?;
    if (id == null) {
      id = _makeId();
      box.put(_deviceIdKey, id);
    }
    return id;
  }

  static String _makeId() {
    final t = DateTime.now().microsecondsSinceEpoch;
    final chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final buf = StringBuffer();
    var n = t;
    for (var i = 0; i < 20; i++) {
      buf.write(chars[n.abs() % chars.length]);
      n = (n * 6364136223846793 + 1442695040888963) ^ (n >> 33);
    }
    return buf.toString();
  }

  // ── Suggested Plans (read from Supabase, fallback to local) ──────────────

  static Future<List<WorkoutPlan>> getSuggestedPlans() async {
    try {
      final rows = await _db
          .from('workout_plans')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      return (rows as List)
          .map((r) => _planFromRow(Map<String, dynamic>.from(r as Map)))
          .toList();
    } catch (e) {
      debugPrint('SupabaseService.getSuggestedPlans: $e');
      return [];
    }
  }

  // ── User Saved Plans ─────────────────────────────────────────────────────

  static Future<String?> saveUserPlan(
    WorkoutPlan plan, {
    String source = 'custom',
    String? aiRawText,
  }) async {
    try {
      final row = await _db
          .from('user_saved_plans')
          .insert({
            'device_id': deviceId,
            'title': plan.title,
            'duration': plan.duration,
            'exercises': plan.exercises,
            'image_asset': plan.imageAsset,
            'image_path': plan.imagePath,
            'difficulty': plan.difficulty,
            'day_exercises': plan.dayExercises,
            'day_names': plan.dayNames,
            'selected_days': plan.selectedDays,
            'source': source,
            if (aiRawText != null) 'ai_raw_text': aiRawText,
          })
          .select('id')
          .single();

      return row['id'] as String?;
    } catch (e) {
      debugPrint('SupabaseService.saveUserPlan: $e');
      return null;
    }
  }

  static Future<void> updateUserPlan(
      String supabaseId, WorkoutPlan plan) async {
    try {
      await _db
          .from('user_saved_plans')
          .update({
            'title': plan.title,
            'duration': plan.duration,
            'exercises': plan.exercises,
            'image_asset': plan.imageAsset,
            'image_path': plan.imagePath,
            'difficulty': plan.difficulty,
            'day_exercises': plan.dayExercises,
            'day_names': plan.dayNames,
            'selected_days': plan.selectedDays,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', supabaseId)
          .eq('device_id', deviceId);
    } catch (e) {
      debugPrint('SupabaseService.updateUserPlan: $e');
    }
  }

  static Future<void> deleteUserPlan(String supabaseId) async {
    try {
      await _db
          .from('user_saved_plans')
          .delete()
          .eq('id', supabaseId)
          .eq('device_id', deviceId);
    } catch (e) {
      debugPrint('SupabaseService.deleteUserPlan: $e');
    }
  }

  static Future<List<WorkoutPlan>> getUserPlans() async {
    try {
      final rows = await _db
          .from('user_saved_plans')
          .select()
          .eq('device_id', deviceId)
          .order('created_at', ascending: false);

      return (rows as List)
          .map((r) => _planFromRow(Map<String, dynamic>.from(r as Map)))
          .toList();
    } catch (e) {
      debugPrint('SupabaseService.getUserPlans: $e');
      return [];
    }
  }

  // ── Helper ───────────────────────────────────────────────────────────────

  static WorkoutPlan _planFromRow(Map<String, dynamic> r) {
    PlanCategory? category;
    final catRaw = r['category'] as String?;
    if (catRaw != null) {
      category = PlanCategory.values.firstWhere(
        (e) => e.name == catRaw,
        orElse: () => PlanCategory.strength,
      );
    }

    List<WorkoutDay>? days;
    final rawDays = r['days'];
    if (rawDays is List && rawDays.isNotEmpty) {
      days = rawDays
          .whereType<Map>()
          .map((d) => WorkoutDay.fromJson(Map<String, dynamic>.from(d)))
          .toList();
    }

    return WorkoutPlan(
      title: r['title'] as String? ?? '',
      duration: r['duration'] as String? ?? '',
      exercises: r['exercises'] as String? ?? '',
      imageAsset: r['image_asset'] as String?,
      imagePath: r['image_path'] as String?,
      difficulty: (r['difficulty'] as int?) ?? 2,
      category: category,
      description: r['description'] as String?,
      days: days,
      dayExercises: (r['day_exercises'] as List?) ?? [],
      dayNames: (r['day_names'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      selectedDays: (r['selected_days'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
