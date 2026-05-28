import 'package:flutter/material.dart';
import 'package:main_build/Theme/app_theme.dart';
import 'package:main_build/Views/main_app/ai_chat_page.dart';
import 'package:main_build/data/chat_session_service.dart';

class ChatHistoryPage extends StatefulWidget {
  final String? gender;
  final int? age;
  final double? weight;
  final String? weightUnit;
  final String? heightDisplay;
  final String? goal;
  final int? trainingDays;

  const ChatHistoryPage({
    super.key,
    this.gender,
    this.age,
    this.weight,
    this.weightUnit,
    this.heightDisplay,
    this.goal,
    this.trainingDays,
  });

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  List<ChatSession> _sessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sessions = await ChatSessionService.getSessions();
    if (!mounted) return;
    setState(() {
      _sessions = sessions;
      _loading = false;
    });
  }

  Future<void> _newConversation() async {
    final session = await ChatSessionService.createSession();
    if (!mounted) return;
    _openSession(session.id);
  }

  void _openSession(String id) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AiChatPage(
          sessionId: id,
          gender: widget.gender,
          age: widget.age,
          weight: widget.weight,
          weightUnit: widget.weightUnit,
          heightDisplay: widget.heightDisplay,
          goal: widget.goal,
          trainingDays: widget.trainingDays,
        ),
      ),
    );
  }

  Future<void> _deleteSession(String id) async {
    await ChatSessionService.deleteSession(id);
    if (!mounted) return;
    setState(() => _sessions.removeWhere((s) => s.id == id));
  }

  Map<String, List<ChatSession>> _groupSessions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final groups = <String, List<ChatSession>>{
      'Today': [],
      'Yesterday': [],
      'This week': [],
      'Older': [],
    };

    for (final s in _sessions) {
      final d = DateTime(
        s.lastActive.year,
        s.lastActive.month,
        s.lastActive.day,
      );
      if (!d.isBefore(today)) {
        groups['Today']!.add(s);
      } else if (!d.isBefore(yesterday)) {
        groups['Yesterday']!.add(s);
      } else if (!d.isBefore(weekAgo)) {
        groups['This week']!.add(s);
      } else {
        groups['Older']!.add(s);
      }
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final groups = _groupSessions();

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.accent, AppTheme.accent_2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(6),
              child: Image.asset('assets/img/bot.png'),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Corely AI',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Chat history',
                  style: TextStyle(fontSize: 11, color: c.textMuted),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: _newConversation,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.accent),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
          ? _EmptyState(onNewChat: _newConversation)
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (final entry in groups.entries)
                  if (entry.value.isNotEmpty) ...[
                    _GroupHeader(label: entry.key, c: c),
                    for (final session in entry.value)
                      _SessionTile(
                        session: session,
                        c: c,
                        onTap: () => _openSession(session.id),
                        onDelete: () => _deleteSession(session.id),
                      ),
                  ],
              ],
            ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onNewChat;
  const _EmptyState({required this.onNewChat});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 64,
            color: c.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Start chatting with Corely AI',
            style: TextStyle(color: c.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onNewChat,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New conversation'),
          ),
        ],
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _GroupHeader extends StatelessWidget {
  final String label;
  final CorelyColors c;
  const _GroupHeader({required this.label, required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: c.textMuted,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

// ─── Session tile ─────────────────────────────────────────────────────────────

class _SessionTile extends StatelessWidget {
  final ChatSession session;
  final CorelyColors c;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SessionTile({
    required this.session,
    required this.c,
    required this.onTap,
    required this.onDelete,
  });

  String _relativeTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${t.day}/${t.month}/${t.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade800,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: c.surface,
            shape: BoxShape.circle,
            border: Border.all(color: c.border),
          ),
          child: Icon(
            Icons.chat_bubble_outline_rounded,
            size: 18,
            color: c.textMuted,
          ),
        ),
        title: Text(
          session.title,
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _relativeTime(session.lastActive),
          style: TextStyle(color: c.textMuted, fontSize: 12),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: c.textMuted, size: 20),
      ),
    );
  }
}
