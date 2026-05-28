import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:main_build/data/workout_plans.dart';
import 'package:main_build/Models/user_profile.dart';
import 'package:main_build/Models/analytics_page_model.dart';

class SupabaseService {
  static const _url = 'https://colmjvbhmkqaanjaenaa.supabase.co';
  static const _anonKey = 'sb_publishable_CzAtiousn9waTH7VXdVf_w_D5XdA86_';

  static const _configBox = 'app_config';
  static const _deviceIdKey = 'device_id';
  static const _weightBox = 'weight_history';
  static const _profileBox = 'user_profile_cache';
  static const _stepsBox = 'daily_steps_cache';
  static const _profileKey = 'current_profile';

  static SupabaseClient get _db => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(url: _url, anonKey: _anonKey);
    await Hive.openBox(_configBox);
    if (!Hive.isBoxOpen(_weightBox)) {
      await Hive.openBox(_weightBox);
    }
    if (!Hive.isBoxOpen(_profileBox)) {
      await Hive.openBox(_profileBox);
    }
    if (!Hive.isBoxOpen(_stepsBox)) {
      await Hive.openBox(_stepsBox);
    }
  }

  static String _dayKey(DateTime date) {
    final local = date.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static Future<void> saveLocalUserProfile(UserProfile profile) async {
    try {
      final box = Hive.box(_profileBox);
      final payload = profile.toJson();
      payload['saved_at'] = DateTime.now().toIso8601String();
      await box.put(_profileKey, payload);
    } catch (e) {
      debugPrint('SupabaseService.saveLocalUserProfile: $e');
    }
  }

  static Future<UserProfile?> getLocalUserProfile() async {
    try {
      final box = Hive.box(_profileBox);
      final raw = box.get(_profileKey);
      if (raw is Map) {
        final data = Map<String, dynamic>.from(raw);
        data.remove('saved_at');
        return UserProfile.fromJson(data);
      }
    } catch (e) {
      debugPrint('SupabaseService.getLocalUserProfile: $e');
    }
    return null;
  }

  static Future<bool> hasLocalUserProfile() async {
    try {
      final box = Hive.box(_profileBox);
      final raw = box.get(_profileKey);
      if (raw is Map) {
        return raw['saved_at'] != null;
      }
      return false;
    } catch (e) {
      debugPrint('SupabaseService.hasLocalUserProfile: $e');
      return false;
    }
  }

  static Future<void> clearLocalUserProfile() async {
    try {
      final box = Hive.box(_profileBox);
      await box.delete(_profileKey);
    } catch (e) {
      debugPrint('SupabaseService.clearLocalUserProfile: $e');
    }
  }

  static Future<void> addLocalWeightRecord({
    required String userId,
    required double weight,
    String weightUnit = 'kg',
    DateTime? recordedAt,
    String? note,
  }) async {
    try {
      final box = Hive.box(_weightBox);
      final list = (box.get(userId) as List?)?.cast<Map?>() ?? <Map>[];
      final entry = {
        'recorded_at': (recordedAt ?? DateTime.now()).toIso8601String(),
        'weight': weight,
        'weight_unit': weightUnit,
        if (note != null) 'note': note,
      };
      list.add(entry);
      await box.put(userId, list);
    } catch (e) {
      debugPrint('SupabaseService.addLocalWeightRecord: $e');
    }
  }

  static Future<List<BodyWeightRecord>> getLocalWeightHistory(
    String userId, {
    int limit = 500,
  }) async {
    try {
      final box = Hive.box(_weightBox);
      final list = (box.get(userId) as List?)?.cast<Map?>() ?? <Map>[];
      final rows =
          list
              .map(
                (m) => BodyWeightRecord(
                  date: DateTime.parse((m?['recorded_at'] ?? '').toString()),
                  weight: (m?['weight'] as num).toDouble(),
                ),
              )
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));
      if (rows.length > limit) return rows.sublist(rows.length - limit);
      return rows;
    } catch (e) {
      debugPrint('SupabaseService.getLocalWeightHistory: $e');
      return [];
    }
  }

  static Future<void> saveLocalDailySteps({
    required String userId,
    required int steps,
    DateTime? recordedAt,
  }) async {
    try {
      final box = Hive.box(_stepsBox);
      final date = recordedAt ?? DateTime.now();
      final key = '$userId:${_dayKey(date)}';
      await box.put(key, {
        'user_id': userId,
        'date': date.toIso8601String(),
        'steps': steps,
        'saved_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('SupabaseService.saveLocalDailySteps: $e');
    }
  }

  static Future<int?> getLocalDailySteps(
    String userId, {
    DateTime? recordedAt,
  }) async {
    try {
      final box = Hive.box(_stepsBox);
      final date = recordedAt ?? DateTime.now();
      final key = '$userId:${_dayKey(date)}';
      final raw = box.get(key);
      if (raw is Map) {
        final steps = raw['steps'];
        if (steps is int) return steps;
        if (steps is num) return steps.toInt();
        return int.tryParse(steps?.toString() ?? '');
      }
    } catch (e) {
      debugPrint('SupabaseService.getLocalDailySteps: $e');
    }
    return null;
  }

  // ── USER PROFILE MANAGEMENT ──────────────────────────────────────────────

  static Future<UserProfile?> createUserProfile(
    String userId,
    String email, {
    String? firstName,
    String? lastName,
    String? gender,
    int? age,
    double? weight,
    double? height,
    String? goal,
    int? trainingDaysPerWeek,
    String? weightUnit,
    String? heightUnit,
  }) async {
    try {
      final now = DateTime.now();
      final response = await _db.from('user_profiles').upsert({
        'user_id': userId,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'gender': gender,
        'age': age,
        'weight': weight,
        'height': height,
        'goal': goal,
        'training_days_per_week': trainingDaysPerWeek,
        'weight_unit': weightUnit,
        'height_unit': heightUnit,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      }, onConflict: 'user_id').select();

      if (response.isNotEmpty) {
        final profile = UserProfile.fromJson(
          Map<String, dynamic>.from(response[0]),
        );
        await saveLocalUserProfile(profile);
        return profile;
      }
      return null;
    } catch (e) {
      debugPrint('SupabaseService.createUserProfile: $e');
      return null;
    }
  }

  static int? _parseIntValue(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double? _parseDoubleValue(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static double? _parseHeightFromMetadata(
    Map<String, dynamic> metadata,
    String? heightUnit,
  ) {
    final rawHeight = metadata['height_display']?.toString().trim();
    if (rawHeight == null || rawHeight.isEmpty) {
      return _parseDoubleValue(metadata['height']);
    }

    final parsedUnit = heightUnit?.toLowerCase();
    if (parsedUnit == 'ft') {
      final match = RegExp(r'^(\d+(?:\.\d+)?)').firstMatch(rawHeight);
      return match == null ? null : double.tryParse(match.group(1)!);
    }

    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(rawHeight);
    return match == null ? null : double.tryParse(match.group(1)!);
  }

  static String? _readMetadataString(
    Map<String, dynamic> metadata,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = metadata[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return null;
  }

  static Future<UserProfile?> createCurrentUserProfileFromAuthMetadata() async {
    try {
      final user = _db.auth.currentUser;
      if (user == null) return null;

      final existingProfile = await getUserProfile(user.id);
      if (existingProfile != null) {
        await saveLocalUserProfile(existingProfile);
        return existingProfile;
      }

      final metadata = Map<String, dynamic>.from(user.userMetadata ?? const {});
      final created = await createUserProfile(
        user.id,
        user.email ?? '',
        firstName: _readMetadataString(metadata, const [
          'first_name',
          'firstName',
          'given_name',
          'name',
        ]),
        lastName: _readMetadataString(metadata, const [
          'last_name',
          'lastName',
          'family_name',
        ]),
        gender: _readMetadataString(metadata, const ['gender']),
        age: _parseIntValue(metadata['age']),
        weight: _parseDoubleValue(metadata['weight']),
        height: _parseHeightFromMetadata(
          metadata,
          _readMetadataString(metadata, const ['height_unit']),
        ),
        goal: _readMetadataString(metadata, const ['goal']),
        trainingDaysPerWeek: _parseIntValue(metadata['training_days_per_week']),
        weightUnit: _readMetadataString(metadata, const ['weight_unit']),
        heightUnit: _readMetadataString(metadata, const ['height_unit']),
      );

      if (created != null) {
        await saveLocalUserProfile(created);
      }
      return created;
    } catch (e) {
      debugPrint(
        'SupabaseService.createCurrentUserProfileFromAuthMetadata: $e',
      );
      return null;
    }
  }

  static Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _db
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .single();

      return UserProfile.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      debugPrint('SupabaseService.getUserProfile: $e');
      return null;
    }
  }

  static Future<UserProfile?> updateUserProfile(
    String userId, {
    String? firstName,
    String? lastName,
    String? gender,
    int? age,
    double? weight,
    double? height,
    String? goal,
    int? trainingDaysPerWeek,
    String? weightUnit,
    String? heightUnit,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (firstName != null) updateData['first_name'] = firstName;
      if (lastName != null) updateData['last_name'] = lastName;
      if (gender != null) updateData['gender'] = gender;
      if (age != null) updateData['age'] = age;
      if (weight != null) updateData['weight'] = weight;
      if (height != null) updateData['height'] = height;
      if (goal != null) updateData['goal'] = goal;
      if (trainingDaysPerWeek != null) {
        updateData['training_days_per_week'] = trainingDaysPerWeek;
      }
      if (weightUnit != null) updateData['weight_unit'] = weightUnit;
      if (heightUnit != null) updateData['height_unit'] = heightUnit;

      final response = await _db
          .from('user_profiles')
          .update(updateData)
          .eq('user_id', userId)
          .select();

      if (response.isNotEmpty) {
        final profile = UserProfile.fromJson(
          Map<String, dynamic>.from(response[0]),
        );
        await saveLocalUserProfile(profile);
        return profile;
      }
      return null;
    } catch (e) {
      debugPrint('SupabaseService.updateUserProfile: $e');
      return null;
    }
  }

  static Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final user = _db.auth.currentUser;
      if (user == null) return null;
      return getUserProfile(user.id);
    } catch (e) {
      debugPrint('SupabaseService.getCurrentUserProfile: $e');
      return null;
    }
  }

  static Future<UserProfile?> getOrCreateCurrentUserProfile() async {
    try {
      final user = _db.auth.currentUser;
      if (user == null) return null;

      final existingProfile = await getUserProfile(user.id);
      if (existingProfile != null) {
        await saveLocalUserProfile(existingProfile);
        return existingProfile;
      }

      return createCurrentUserProfileFromAuthMetadata();
    } catch (e) {
      debugPrint('SupabaseService.getOrCreateCurrentUserProfile: $e');
      return null;
    }
  }

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

  static String? _cleanAssetPath(String? value) {
    if (value == null) return null;
    final cleaned = value.trim().replaceFirst(RegExp(r'^-\s+'), '');
    return cleaned.isEmpty ? null : cleaned;
  }

  static Future<List<WorkoutPlan>> getSuggestedPlans() async {
    final rows = await _db
        .from('workout_plans')
        .select()
        .eq('is_active', true)
        .order('sort_order', ascending: true);

    return (rows as List)
        .map((r) => _planFromRow(Map<String, dynamic>.from(r as Map)))
        .toList();
  }

  /// Seed the `workout_plans` table from the local `kSuggestedPlans` list.
  /// This will upsert by `title` and set `is_active = true` and `sort_order`
  /// according to the list index. Use with caution (requires DB permissions).
  static Future<void> seedSuggestedPlansToDb({bool dryRun = false}) async {
    try {
      final List<Map<String, dynamic>> rows = [];
      for (var i = 0; i < kSuggestedPlans.length; i++) {
        final p = kSuggestedPlans[i];
        rows.add({
          'title': p.title,
          'duration': p.duration,
          'exercises': p.exercises,
          'image_asset': p.imageAsset,
          'difficulty': p.difficulty,
          'category': p.category?.name,
          'description': p.description,
          'days': p.days?.map((d) => d.toJson()).toList(),
          'day_exercises': p.dayExercises,
          'day_names': p.dayNames,
          'selected_days': p.selectedDays,
          'is_active': true,
          'sort_order': i,
        });
      }

      if (dryRun) {
        debugPrint(
          'SupabaseService.seedSuggestedPlansToDb: dryRun payload length=${rows.length}',
        );
        return;
      }

      // Upsert many rows in a single call. Use onConflict='title' so duplicates update.
      await _db.from('workout_plans').upsert(rows, onConflict: 'title');
    } catch (e) {
      debugPrint('SupabaseService.seedSuggestedPlansToDb: $e');
    }
  }

  /// Import a generic plan JSON into the user's saved plans table. Stores
  /// the original raw JSON in `ai_raw_text` for provenance.
  static Future<String?> importPlanJsonToUserSaved(
    Map<String, dynamic> json,
  ) async {
    try {
      final plan = WorkoutPlan.fromJson(json);
      final raw = jsonEncode(json);
      return await saveUserPlan(plan, source: 'shared', aiRawText: raw);
    } catch (e) {
      debugPrint('SupabaseService.importPlanJsonToUserSaved: $e');
      return null;
    }
  }

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
            'image_asset': _cleanAssetPath(plan.imageAsset),
            'image_path': _cleanAssetPath(plan.imagePath),
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
    String supabaseId,
    WorkoutPlan plan,
  ) async {
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
    List<dynamic> dayExercises = [];
    List<String> dayNames = [];

    final rawDays = r['days'];

    if (rawDays is List && rawDays.isNotEmpty) {
      // Legacy list format: [{label, exercises: ["Bench Press 4×5", ...]}, ...]
      days = rawDays
          .whereType<Map>()
          .map((d) => WorkoutDay.fromJson(Map<String, dynamic>.from(d)))
          .toList();
    } else if (rawDays is Map && rawDays.isNotEmpty) {
      // New DB format: {day_1: {name, exercises: [{name, sets, reps, rest}]}, day_2: ...}
      final sortedKeys = rawDays.keys.toList()
        ..sort((a, b) {
          final aNum = int.tryParse(
                a.toString().replaceAll(RegExp(r'\D'), ''),
              ) ??
              0;
          final bNum = int.tryParse(
                b.toString().replaceAll(RegExp(r'\D'), ''),
              ) ??
              0;
          return aNum.compareTo(bNum);
        });

      for (final key in sortedKeys) {
        final dayData = rawDays[key];
        if (dayData is! Map) continue;

        final dayName = dayData['name']?.toString() ?? key.toString();
        dayNames.add(dayName);

        final rawExercises = dayData['exercises'];
        final List<Map<String, dynamic>> exerciseMaps = [];
        final List<String> exerciseStrings = [];

        if (rawExercises is List) {
          for (final ex in rawExercises) {
            if (ex is Map) {
              final m = Map<String, dynamic>.from(ex);
              exerciseMaps.add(m);
              final name = m['name']?.toString() ?? '';
              final sets = m['sets'];
              final reps = m['reps'];
              exerciseStrings.add(
                (sets != null && reps != null) ? '$name $sets×$reps' : name,
              );
            } else {
              exerciseStrings.add(ex.toString());
            }
          }
        }

        dayExercises.add(exerciseMaps);
        days ??= [];
        days.add(WorkoutDay(label: dayName, exercises: exerciseStrings));
      }
    }

    return WorkoutPlan(
      title: r['title'] as String? ?? '',
      duration: r['duration'] as String? ?? '',
      exercises: r['exercises'] as String? ?? '',
      imageAsset: _cleanAssetPath(r['image_asset'] as String?),
      imagePath: _cleanAssetPath(r['image_path'] as String?),
      difficulty: (r['difficulty'] as int?) ?? 2,
      category: category,
      description: r['description'] as String?,
      days: days,
      credit: r['credit'] as String?,
      creditUrl: r['credit_url'] as String?,
      dayExercises: dayExercises.isNotEmpty
          ? dayExercises
          : ((r['day_exercises'] as List?) ?? []),
      dayNames: dayNames.isNotEmpty
          ? dayNames
          : ((r['day_names'] as List?)?.map((e) => e.toString()).toList() ?? []),
      selectedDays:
          (r['selected_days'] as List?)?.map((e) => e.toString()).toList() ??
          [],
    );
  }
}
