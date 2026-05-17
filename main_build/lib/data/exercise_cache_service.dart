import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:main_build/Models/exercise.dart';

class ExerciseCacheService {
  static const String _exercisesBoxName = 'exercises_cache';
  static const String _exercisesKey = 'exercises_data';
  static const String _lastUpdateKey = 'last_update';
  static const String _cacheVersionKey = 'cache_version';
  static const String _cacheSourceKey = 'cache_source';
  static const String _visibleExerciseIdsKey = 'visible_exercise_ids';
  static const String _adminPinKey = 'admin_pin';
  static const int _cacheVersion = 3;
  static const String _cacheSource = 'wger';
  static const String _defaultAdminPin = '2468';
  static const String _wgerBaseUrl = 'https://wger.de/api/v2';
  static const int _pageSize = 200;
  static const Duration _defaultCacheTtl = Duration(days: 7);

  static Future<void> init() async {
    await Hive.openBox(_exercisesBoxName);
  }

  /// Get exercises from cache or fetch from API
  static Future<List<Exercise>> getExercises({
    bool forceRefresh = false,
    int? limit,
    bool onlyWithImage = false,
    bool onlyWithTarget = false,
    bool ignoreVisibilityFilter = false,
  }) async {
    final box = Hive.box(_exercisesBoxName);
    final visibleIds = ignoreVisibilityFilter
        ? null
        : _readVisibleExerciseIds(box);

    if (!forceRefresh) {
      final cached = _loadFromCache(box);
      if (cached.isNotEmpty) {
        return _applyListFilters(
          cached,
          limit: limit,
          onlyWithImage: onlyWithImage,
          onlyWithTarget: onlyWithTarget,
          visibleIds: visibleIds,
        );
      }
    }

    try {
      final normalized = await _fetchFromWger();
      if (normalized.isNotEmpty) {
        await _saveToCache(box, normalized);
        final parsed = normalized.map(Exercise.fromJson).toList();
        return _applyListFilters(
          parsed,
          limit: limit,
          onlyWithImage: onlyWithImage,
          onlyWithTarget: onlyWithTarget,
          visibleIds: visibleIds,
        );
      }
    } catch (e) {
      print('Error fetching exercises from wger: $e');
    }

    final cachedFallback = _loadFromCache(box, allowLegacy: true);
    if (cachedFallback.isNotEmpty) {
      return _applyListFilters(
        cachedFallback,
        limit: limit,
        onlyWithImage: onlyWithImage,
        onlyWithTarget: onlyWithTarget,
        visibleIds: visibleIds,
      );
    }

    return [];
  }

  /// Check if exercises are cached
  static bool hasCachedExercises() {
    final box = Hive.box(_exercisesBoxName);
    return box.containsKey(_exercisesKey);
  }

  /// Returns true when local cache exists but is older than [ttl].
  static bool isCacheStale({Duration ttl = _defaultCacheTtl}) {
    if (!hasCachedExercises()) return true;
    final lastUpdate = getLastUpdateTime();
    if (lastUpdate == null) return true;
    return DateTime.now().difference(lastUpdate) > ttl;
  }

  /// Lightweight sync for tab opens: keep UI fast and only refresh if stale.
  static Future<void> refreshIfStale({Duration ttl = _defaultCacheTtl}) async {
    if (!isCacheStale(ttl: ttl)) return;
    await getExercises(forceRefresh: true);
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

  static Future<Set<String>> getVisibleExerciseIds() async {
    final box = Hive.box(_exercisesBoxName);
    return _readVisibleExerciseIds(box) ?? <String>{};
  }

  static Future<void> setVisibleExerciseIds(Set<String> ids) async {
    final box = Hive.box(_exercisesBoxName);
    await box.put(_visibleExerciseIdsKey, ids.toList(growable: false));
  }

  static Future<void> clearVisibleExerciseIds() async {
    final box = Hive.box(_exercisesBoxName);
    await box.delete(_visibleExerciseIdsKey);
  }

  static Future<bool> verifyAdminPin(String pin) async {
    final box = Hive.box(_exercisesBoxName);
    final stored = (box.get(_adminPinKey) as String?) ?? _defaultAdminPin;
    return pin.trim() == stored.trim();
  }

  static Future<void> setAdminPin(String pin) async {
    final box = Hive.box(_exercisesBoxName);
    await box.put(_adminPinKey, pin.trim());
  }

  static List<Exercise> _loadFromCache(
    Box<dynamic> box, {
    bool allowLegacy = false,
  }) {
    if (!box.containsKey(_exercisesKey)) {
      return const [];
    }

    final cacheVersion = box.get(_cacheVersionKey) as int?;
    final cacheSource = box.get(_cacheSourceKey) as String?;
    final cachedData = box.get(_exercisesKey) as String?;

    if (cachedData == null || cachedData.isEmpty) {
      return const [];
    }

    if (!allowLegacy &&
        (cacheVersion != _cacheVersion || cacheSource != _cacheSource)) {
      return const [];
    }

    try {
      final decoded = json.decode(cachedData);
      if (decoded is List) {
        // Legacy support for previously cached list payloads.
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(Exercise.fromJson)
            .toList();
      }
      if (decoded is Map<String, dynamic>) {
        final list = decoded['exercises'];
        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map(Exercise.fromJson)
              .toList();
        }
      }
    } catch (e) {
      print('Error loading cached exercises: $e');
    }

    return const [];
  }

  static Future<void> _saveToCache(
    Box<dynamic> box,
    List<Map<String, dynamic>> normalized,
  ) async {
    final payload = json.encode({
      'source': _cacheSource,
      'version': _cacheVersion,
      'exercises': normalized,
    });
    await box.put(_exercisesKey, payload);
    await box.put(_lastUpdateKey, DateTime.now().toIso8601String());
    await box.put(_cacheVersionKey, _cacheVersion);
    await box.put(_cacheSourceKey, _cacheSource);
  }

  static Future<List<Map<String, dynamic>>> _fetchFromWger() async {
    final allItems = <Map<String, dynamic>>[];
    var nextUrl = '$_wgerBaseUrl/exerciseinfo/?language=2&limit=$_pageSize';
    var pagesFetched = 0;
    const maxPages = 20;

    while (nextUrl.isNotEmpty && pagesFetched < maxPages) {
      http.Response response;
      try {
        response = await http.get(Uri.parse(nextUrl));
      } catch (e) {
        if (allItems.isNotEmpty) {
          print('wger request error after partial success: $e');
          break;
        }
        rethrow;
      }

      if (response.statusCode != 200) {
        if (allItems.isNotEmpty) {
          print(
            'wger request failed (${response.statusCode}), using partial list',
          );
          break;
        }
        throw Exception('wger request failed (${response.statusCode})');
      }

      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) {
        break;
      }

      final results = decoded['results'];
      if (results is List) {
        for (final item in results) {
          if (item is Map<String, dynamic>) {
            final mapped = _toLegacyExerciseJson(item);
            if ((mapped['name'] as String).isNotEmpty) {
              allItems.add(mapped);
            }
          }
        }
      }

      final next = decoded['next'];
      if (next is String && next.isNotEmpty) {
        nextUrl = next;
      } else {
        nextUrl = '';
      }
      pagesFetched++;
    }

    return allItems;
  }

  static Map<String, dynamic> _toLegacyExerciseJson(Map<String, dynamic> raw) {
    final id = raw['id']?.toString() ?? '';

    final translation = _pickTranslation(raw, preferredLanguage: 2);
    final name = _readString(translation['name']).isNotEmpty
        ? _readString(translation['name'])
        : _readString(raw['name']);
    final description = _stripHtml(
      _readString(translation['description']).isNotEmpty
          ? _readString(translation['description'])
          : _readString(raw['description']),
    );

    final categoryName = _extractNamedEntity(raw['category']);
    final primary = _extractNameList(raw['muscles']);
    final secondary = _extractNameList(raw['muscles_secondary']);
    final equipmentList = _extractNameList(raw['equipment']);
    final equipment = equipmentList.isNotEmpty
        ? equipmentList.join(', ')
        : 'body only';

    String? imagePath;
    final images = raw['images'];
    if (images is List && images.isNotEmpty) {
      final first = images.first;
      if (first is Map<String, dynamic>) {
        imagePath = _readString(first['image']);
      } else if (first is String) {
        imagePath = first;
      }
    }

    final instructions = description.isEmpty
        ? <String>[]
        : description
              .split(RegExp(r'\n+'))
              .map((line) => line.trim())
              .where((line) => line.isNotEmpty)
              .toList();

    return {
      'id': id,
      'name': name,
      'category': categoryName.isEmpty ? 'strength' : categoryName,
      'primaryMuscles': primary,
      'secondaryMuscles': secondary,
      'equipment': equipment,
      'images': imagePath != null && imagePath.isNotEmpty ? [imagePath] : [],
      'instructions': instructions,
      'force': null,
      'level': null,
      'mechanic': null,
    };
  }

  static String _extractNamedEntity(dynamic value) {
    if (value is Map<String, dynamic>) {
      final name = _readString(value['name']);
      if (name.isNotEmpty) return name;
      final translated = _readString(value['name_en']);
      if (translated.isNotEmpty) return translated;
    }
    return _readString(value);
  }

  static Map<String, dynamic> _pickTranslation(
    Map<String, dynamic> raw, {
    required int preferredLanguage,
  }) {
    final translations = raw['translations'];
    if (translations is! List) return const {};

    Map<String, dynamic>? first;
    for (final item in translations) {
      if (item is! Map<String, dynamic>) continue;
      first ??= item;
      final lang = item['language'];
      if (lang is int && lang == preferredLanguage) {
        return item;
      }
    }

    return first ?? const {};
  }

  static List<String> _extractNameList(dynamic value) {
    if (value is! List) return const [];
    final names = <String>[];
    for (final item in value) {
      String name = '';
      if (item is Map<String, dynamic>) {
        name = _readString(item['name_en']);
        if (name.isEmpty) {
          name = _readString(item['name']);
        }
      } else {
        name = _readString(item);
      }
      if (name.isNotEmpty) {
        names.add(name);
      }
    }
    return names;
  }

  static String _readString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static String _stripHtml(String input) {
    if (input.isEmpty) return '';
    final withoutTags = input.replaceAll(RegExp(r'<[^>]*>'), ' ');
    final normalized = withoutTags
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    return normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static List<Exercise> _applyListFilters(
    List<Exercise> source, {
    int? limit,
    bool onlyWithImage = false,
    bool onlyWithTarget = false,
    Set<String>? visibleIds,
  }) {
    var items = source;

    items = [...items]
      ..sort((a, b) {
        final aHasImage = (a.gifUrl ?? '').trim().isNotEmpty;
        final bHasImage = (b.gifUrl ?? '').trim().isNotEmpty;
        if (aHasImage == bHasImage) return a.name.compareTo(b.name);
        return aHasImage ? -1 : 1;
      });

    if (visibleIds != null && visibleIds.isNotEmpty) {
      items = items.where((e) => visibleIds.contains(e.id)).toList();
    }

    if (onlyWithImage) {
      items = items.where((e) => (e.gifUrl ?? '').trim().isNotEmpty).toList();
    }

    if (onlyWithTarget) {
      items = items.where((e) {
        final target = e.target.trim().toLowerCase();
        return target.isNotEmpty && target != 'general';
      }).toList();
    }

    if (limit != null && limit > 0 && items.length > limit) {
      items = items.take(limit).toList();
    }

    return items;
  }

  static Set<String>? _readVisibleExerciseIds(Box<dynamic> box) {
    final raw = box.get(_visibleExerciseIdsKey);
    if (raw is! List) return null;
    return raw.map((e) => e.toString()).toSet();
  }
}
