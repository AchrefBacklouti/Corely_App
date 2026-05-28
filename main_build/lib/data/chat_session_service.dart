import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime lastActive;
  final List<Map<String, dynamic>> messages;

  const ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.lastActive,
    required this.messages,
  });

  ChatSession copyWith({
    String? title,
    DateTime? lastActive,
    List<Map<String, dynamic>>? messages,
  }) => ChatSession(
    id: id,
    title: title ?? this.title,
    createdAt: createdAt,
    lastActive: lastActive ?? this.lastActive,
    messages: messages ?? this.messages,
  );

  factory ChatSession.fromJson(Map<String, dynamic> j) => ChatSession(
    id: j['id'] as String,
    title: j['title'] as String? ?? 'Chat',
    createdAt: DateTime.parse(j['createdAt'] as String),
    lastActive: DateTime.parse(j['lastActive'] as String),
    messages: (j['messages'] as List? ?? [])
        .map((m) => Map<String, dynamic>.from(m as Map))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'lastActive': lastActive.toIso8601String(),
    'messages': messages,
  };

  // Generate a title from the first user message
  static String titleFrom(List<Map<String, dynamic>> messages) {
    try {
      final first = messages.firstWhere((m) => m['isBot'] == false);
      final t = (first['text'] as String? ?? '').trim();
      if (t.isEmpty) return 'New chat';
      return t.length > 45 ? '${t.substring(0, 45)}…' : t;
    } catch (_) {
      return 'New chat';
    }
  }
}

// ─── Service ──────────────────────────────────────────────────────────────────

class ChatSessionService {
  static const _box = 'chat_sessions';
  static const _sessionsKey = 'sessions';
  static const _activeIdKey = 'active_id';
  static const _lastActivityKey = 'last_activity';
  static const _inactiveThreshold = Duration(minutes: 30);

  static Future<Box<String>> _openBox() => Hive.openBox<String>(_box);

  // ── Read ────────────────────────────────────────────────────────────────────

  static Future<List<ChatSession>> getSessions() async {
    final box = await _openBox();
    final raw = box.get(_sessionsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((j) => ChatSession.fromJson(Map<String, dynamic>.from(j as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<ChatSession?> getSessionById(String id) async {
    final sessions = await getSessions();
    try {
      return sessions.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  static Future<ChatSession?> getActiveSession() async {
    final id = await getActiveId();
    if (id == null) return null;
    return getSessionById(id);
  }

  static Future<String?> getActiveId() async {
    final box = await _openBox();
    return box.get(_activeIdKey);
  }

  /// True when the user should see the session picker (no activity in 30 min,
  /// or no sessions exist at all).
  static Future<bool> shouldShowPicker() async {
    final sessions = await getSessions();
    if (sessions.isEmpty) return false; // first launch → go straight to new chat
    final box = await _openBox();
    final raw = box.get(_lastActivityKey);
    if (raw == null) return true;
    final last = DateTime.tryParse(raw);
    if (last == null) return true;
    return DateTime.now().difference(last) >= _inactiveThreshold;
  }

  // ── Write ───────────────────────────────────────────────────────────────────

  static Future<void> _saveSessions(List<ChatSession> sessions) async {
    final box = await _openBox();
    await box.put(
      _sessionsKey,
      jsonEncode(sessions.map((s) => s.toJson()).toList()),
    );
  }

  static Future<ChatSession> createSession() async {
    final now = DateTime.now();
    final session = ChatSession(
      id: now.millisecondsSinceEpoch.toString(),
      title: 'New chat',
      createdAt: now,
      lastActive: now,
      messages: [],
    );
    final sessions = await getSessions();
    sessions.insert(0, session);
    await _saveSessions(sessions);
    await setActiveId(session.id);
    await _touchLastActivity();
    return session;
  }

  static Future<void> updateSession(
    String id,
    List<Map<String, dynamic>> messages,
  ) async {
    final sessions = await getSessions();
    final idx = sessions.indexWhere((s) => s.id == id);
    if (idx == -1) return;
    sessions[idx] = sessions[idx].copyWith(
      title: ChatSession.titleFrom(messages),
      lastActive: DateTime.now(),
      messages: messages,
    );
    sessions.sort((a, b) => b.lastActive.compareTo(a.lastActive));
    await _saveSessions(sessions);
    await _touchLastActivity();
  }

  static Future<void> setActiveId(String? id) async {
    final box = await _openBox();
    if (id == null) {
      await box.delete(_activeIdKey);
    } else {
      await box.put(_activeIdKey, id);
    }
  }

  static Future<void> deleteSession(String id) async {
    final sessions = await getSessions();
    sessions.removeWhere((s) => s.id == id);
    await _saveSessions(sessions);
    final activeId = await getActiveId();
    if (activeId == id) await setActiveId(null);
  }

  static Future<void> _touchLastActivity() async {
    final box = await _openBox();
    await box.put(_lastActivityKey, DateTime.now().toIso8601String());
  }
}
