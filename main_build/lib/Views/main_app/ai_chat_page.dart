import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:main_build/Theme/app_theme.dart';
import 'package:main_build/data/local_plan_service.dart';
import 'package:main_build/data/workout_plans.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_Message> _messages = [
    _Message(
      text:
          "Hi! I'm Corely AI, your personal fitness assistant. How can I help you today?",
      isBot: true,
    ),
  ];
  bool _isTyping = false;
  final Set<int> _savedPlanIndices = {};

  static const _apiKey = 'AIzaSyBZf6JIMQCj30NbGExIgv6zIdVZkUMR6gA';
  static const _systemPrompt =
      'You are Corely AI, a personal gym trainer and fitness buddy. '
      'You talk like a knowledgeable friend at the gym — casual, motivating, and straight to the point. '
      'You ONLY answer questions about: gym workouts and training programs, exercise form and technique, '
      'nutrition and diet for fitness goals, recovery, sleep, and injury prevention, and workout suggestions. '
      'If someone asks about anything outside those topics, redirect them with something like: '
      '"Ha, that\'s outside my lane bro! I\'m your gym buddy — ask me about gains, nutrition, or recovery." '
      'Keep replies concise and practical. Use gym lingo naturally. Address the user like a training partner.';

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    _doSend();
  }

  Future<void> _doSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Message(text: text, isBot: false));
      _isTyping = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final reply = await _callGemini();
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(_Message(text: reply, isBot: true));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(_Message(
          text: "DEBUG ERROR: $e",
          isBot: true,
        ));
      });
    }
    _scrollToBottom();
  }

  Future<String> _callGemini() async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent',
    );

    // Gemini requires the first turn to be 'user' — skip the static greeting.
    final firstUserIdx = _messages.indexWhere((m) => !m.isBot);
    final contents = _messages.skip(firstUserIdx).map((m) {
      return {
        'role': m.isBot ? 'model' : 'user',
        'parts': [
          {'text': m.text},
        ],
      };
    }).toList();

    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': _systemPrompt},
        ],
      },
      'contents': contents,
    });

    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'X-goog-api-key': _apiKey,
          },
          body: body,
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = json['candidates'] as List<dynamic>;
    final content = candidates[0]['content'] as Map<String, dynamic>;
    final parts = content['parts'] as List<dynamic>;
    return parts[0]['text'] as String;
  }

  Future<void> _saveAsPlan(int messageIndex) async {
    final text = _messages[messageIndex].text;
    final nameController = TextEditingController(text: 'AI Plan');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save as workout plan'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Plan name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final plan = WorkoutPlan(
      title: nameController.text.trim().isEmpty
          ? 'AI Plan'
          : nameController.text.trim(),
      duration: 'AI suggested',
      exercises: 'See AI chat',
      difficulty: 2,
    );
    await LocalPlanService.savePlan(
      plan,
      source: 'ai_generated',
      aiRawText: text,
    );
    if (!mounted) return;
    setState(() => _savedPlanIndices.add(messageIndex));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plan saved! Check My Plans in the Workout tab.')),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

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
              child: Image.asset('assets/img/bot_4712038.png'),
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
                  'Your fitness assistant',
                  style: TextStyle(fontSize: 11, color: c.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length) {
                  return _TypingIndicator(c: c);
                }
                final msg = _messages[i];
                return _MessageBubble(
                  message: msg,
                  c: c,
                  isSaved: _savedPlanIndices.contains(i),
                  onSave: msg.looksLikeWorkoutPlan
                      ? () => _saveAsPlan(i)
                      : null,
                );
              },
            ),
          ),
          _InputBar(controller: _controller, onSend: _send, c: c),
        ],
      ),
    );
  }
}

// ─── Data ────────────────────────────────────────

class _Message {
  final String text;
  final bool isBot;

  const _Message({required this.text, required this.isBot});

  bool get looksLikeWorkoutPlan {
    if (!isBot) return false;
    final lower = text.toLowerCase();
    final hasDays = lower.contains('day 1') || lower.contains('day 2') ||
        lower.contains('day one') || lower.contains('day two');
    final hasExerciseTerms =
        lower.contains('sets') && lower.contains('reps');
    final hasWorkoutTerms = lower.contains('workout') ||
        lower.contains('program') ||
        lower.contains('routine') ||
        lower.contains('training');
    return (hasDays || hasExerciseTerms) && hasWorkoutTerms;
  }
}

// ─── Message Bubble ──────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.c,
    this.onSave,
    this.isSaved = false,
  });

  final _Message message;
  final CorelyColors c;
  final VoidCallback? onSave;
  final bool isSaved;

  @override
  Widget build(BuildContext context) {
    final isBot = message.isBot;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isBot) ...[
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.accent, AppTheme.accent_2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(4),
              child: Image.asset('assets/img/bot_4712038.png'),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isBot
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isBot ? c.surface : AppTheme.accent,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isBot ? 4 : 16),
                      bottomRight: Radius.circular(isBot ? 16 : 4),
                    ),
                    border: isBot ? Border.all(color: c.border) : null,
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isBot ? c.textPrimary : Colors.black,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                if (onSave != null) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: isSaved ? null : onSave,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSaved
                              ? Icons.check_circle_rounded
                              : Icons.bookmark_add_outlined,
                          size: 14,
                          color: isSaved
                              ? Colors.green
                              : c.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isSaved ? 'Saved' : 'Save as plan',
                          style: TextStyle(
                            fontSize: 12,
                            color: isSaved ? Colors.green : c.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Typing Indicator ────────────────────────────

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator({required this.c});

  final CorelyColors c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppTheme.accent, AppTheme.accent_2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(4),
            child: Image.asset('assets/img/bot_4712038.png'),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: c.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AnimatedDot(c: c, delayMs: 0),
                const SizedBox(width: 5),
                _AnimatedDot(c: c, delayMs: 200),
                const SizedBox(width: 5),
                _AnimatedDot(c: c, delayMs: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedDot extends StatefulWidget {
  const _AnimatedDot({required this.c, required this.delayMs});

  final CorelyColors c;
  final int delayMs;

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _opacity = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _anim.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.c.textMuted,
        ),
      ),
    );
  }
}

// ─── Input Bar ───────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.c,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final CorelyColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: c.background,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: TextStyle(color: c.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Ask anything about fitness...',
                  hintStyle: TextStyle(color: c.textMuted, fontSize: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: c.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide:
                        const BorderSide(color: AppTheme.accent, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  fillColor: c.inputFill,
                  filled: true,
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onSend,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppTheme.accent, AppTheme.accent_2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x662979FF),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
