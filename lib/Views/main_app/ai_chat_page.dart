import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:main_build/Theme/app_theme.dart';
import 'package:main_build/data/local_plan_service.dart';
import 'package:main_build/data/workout_plans.dart';

class AiChatPage extends StatefulWidget {
  final String? gender;
  final int? age;
  final double? weight;
  final String? weightUnit;
  final String? heightDisplay;
  final String? goal;
  final int? trainingDays;

  const AiChatPage({
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
  static const _baseSystemPrompt =
      'You are Corely AI, a personal gym trainer and fitness buddy. '
      'You talk like a knowledgeable friend at the gym — casual, motivating, and straight to the point. '
      'You ONLY answer questions about: gym workouts and training programs, exercise form and technique, '
      'nutrition and diet for fitness goals, recovery, sleep, and injury prevention, and workout suggestions. '
      'If someone asks about anything outside those topics, redirect them with something like: '
      '"Ha, that\'s outside my lane bro! I\'m your gym buddy — ask me about gains, nutrition, or recovery." '
      'Keep replies concise and practical. Use gym lingo naturally. Address the user like a training partner. '
      'IMPORTANT: Whenever you provide a full workout plan (a structured response that includes specific days, '
      'exercises, sets and reps), you MUST begin your entire response with the exact text "[WORKOUT_PLAN]" '
      'on its own line. Do not use this tag for general advice, single exercise tips, or nutrition info — '
      'only for complete, ready-to-follow workout plans. '
      'EXERCISE FORMAT: In every workout plan, list each exercise on its own line using EXACTLY this format: '
      '[EX: Exercise Name | sets | reps] '
      'Example: [EX: Barbell Squat | 4 | 8-12] — no other format is allowed for exercise entries.';

  String get _systemPrompt {
    final w = widget;
    if (w.gender == null) return _baseSystemPrompt;
    final profile = 'User profile — Gender: ${w.gender}, Age: ${w.age} yrs, '
        'Weight: ${w.weight?.toStringAsFixed(1)} ${w.weightUnit}, '
        'Height: ${w.heightDisplay}, Goal: ${w.goal}, '
        'Training frequency: ${w.trainingDays} days/week. '
        'Always tailor plans and advice specifically to this user.';
    return '$_baseSystemPrompt\n\n$profile';
  }

  static const _hiveBox = 'ai_chat';
  static const _hiveKey = 'messages';

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final box = await Hive.openBox<String>(_hiveBox);
    final raw = box.get(_hiveKey);
    if (raw == null || !mounted) return;
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      if (list.isEmpty) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(list.map((m) => _Message(
                text: m['text'] as String,
                isBot: m['isBot'] as bool,
              )));
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (_) {}
  }

  Future<void> _saveMessages() async {
    final box = await Hive.openBox<String>(_hiveBox);
    await box.put(
      _hiveKey,
      jsonEncode(_messages.map((m) => {'text': m.text, 'isBot': m.isBot}).toList()),
    );
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
    _saveMessages();

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
    _saveMessages();
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

    final parsed = _parseAiWorkout(text);
    final plan = WorkoutPlan(
      title: nameController.text.trim().isEmpty
          ? 'AI Plan'
          : nameController.text.trim(),
      duration: parsed.duration,
      exercises: parsed.summary,
      difficulty: 2,
      dayExercises: parsed.dayExercises,
      dayNames: parsed.dayNames,
      selectedDays: parsed.selectedDays,
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

  ({
    List<List<Map<String, dynamic>>> dayExercises,
    List<String> dayNames,
    List<String> selectedDays,
    String summary,
    String duration,
  }) _parseAiWorkout(String text) {
    final dayNames = <String>[];
    final allDayExercises = <List<Map<String, dynamic>>>[];
    List<Map<String, dynamic>>? current;

    // Matches day-level headers like "Day 1", "Day 1 – Push", "Session A", "Week 2"
    final dayRe = RegExp(
      r'^(?:day\s*\d+|session\s+[a-z]|week\s*\d+|workout\s+[ab])',
      caseSensitive: false,
    );
    // Matches sets × reps in two forms:
    //   Form A: "3x10", "3 sets x 10", "3 × 10", "3 sets × 10-12"
    //   Form B: "3 sets of 10", "3 sets, 10", "3 sets 10 reps"
    final setsRepsRe = RegExp(
      r'(\d+)\s*(?:sets?\s*)?[x×]\s*(\d+(?:[–\-]\d+)?)'
      r'|'
      r'(\d+)\s*sets?\s*(?:(?:of|,)\s*)?(\d+(?:[–\-]\d+)?)\s*(?:reps?)?',
      caseSensitive: false,
    );

    // Matches the structured tag the AI is instructed to use for every exercise
    final exTagRe = RegExp(
      r'\[EX:\s*(.+?)\s*\|\s*(\d+)\s*\|\s*([\d\-–]+)\]',
      caseSensitive: false,
    );

    for (var raw in text.split('\n')) {
      final line = raw.replaceAll(RegExp(r'[*#_`]'), '').trim();
      if (line.isEmpty) continue;

      if (dayRe.hasMatch(line)) {
        if (current != null) allDayExercises.add(current);
        current = [];
        var name = line.replaceAll(RegExp(r':\s*$'), '').trim();
        if (name.length > 45) name = name.substring(0, 45);
        dayNames.add(name);
        continue;
      }

      // Priority: structured [EX: Name | sets | reps] tag
      final tagMatch = exTagRe.firstMatch(line);
      if (tagMatch != null) {
        if (current == null) {
          current = [];
          dayNames.add('Day 1');
        }
        final exName = tagMatch.group(1)!.trim();
        final sets = int.tryParse(tagMatch.group(2) ?? '') ?? 3;
        final reps = tagMatch.group(3) ?? '10';
        current.add({
          'id': exName.hashCode.toString(),
          'name': exName,
          'bodyPart': 'general',
          'target': 'General',
          'equipment': 'body only',
          'sets': sets,
          'reps': reps,
        });
        continue;
      }

      // Auto-start Day 1 if exercise lines appear before any day header
      if (current == null) {
        final hasBullet = RegExp(r'^[-*•]').hasMatch(raw.trim());
        if (!hasBullet && !setsRepsRe.hasMatch(line)) continue;
        current = [];
        dayNames.add('Day 1');
      }

      // Strip leading bullet / number markers
      var ex = line.replaceFirst(RegExp(r'^[-*•\d]+[.):]?\s*'), '').trim();
      if (ex.isEmpty) continue;

      final lower = ex.toLowerCase();
      if (lower.startsWith('rest') ||
          lower.startsWith('note') ||
          lower.startsWith('tip') ||
          lower.startsWith('optional')) {
        continue;
      }

      int sets = 3;
      String reps = '10';

      // Form A/B: sets-first — "3x10", "3 sets x 10", "3 sets of 10", "3 sets, 10"
      final m = setsRepsRe.firstMatch(ex);
      if (m != null) {
        final sRaw = m.group(1) ?? m.group(3);
        final rRaw = m.group(2) ?? m.group(4);
        final s = int.tryParse(sRaw ?? '');
        if (s != null && s >= 1 && s <= 12 && rRaw != null) {
          sets = s;
          reps = rRaw;
        }
        ex = ex.substring(0, m.start)
            .replaceAll(RegExp(r'[:\-–,\s]+$'), '')
            .trim();
      } else {
        // Form C: reps-first — "8 reps 5 sets", "8 reps, 5 sets"
        final repsFirst = RegExp(
          r'(\d+(?:[–\-]\d+)?)\s*reps?\s*,?\s*(\d+)\s*sets?',
          caseSensitive: false,
        ).firstMatch(ex);
        if (repsFirst != null) {
          reps = repsFirst.group(1) ?? '10';
          sets = int.tryParse(repsFirst.group(2) ?? '') ?? 3;
          ex = ex.substring(0, repsFirst.start)
              .replaceAll(RegExp(r'[:\-–,\s]+$'), '')
              .trim();
        } else {
          // No sets/reps found at all — skip sub-headers (lines that end with ':')
          // but keep plain exercise names like "Squats" (saved with 3×10 default)
          final stripped = ex.replaceAll(RegExp(r'[:\s]+$'), '');
          if (ex.endsWith(':') || stripped != ex && stripped.isEmpty) continue;
          ex = stripped;
        }
      }

      if (ex.isEmpty) continue;

      current.add({
        'id': ex.hashCode.toString(),
        'name': ex,
        'bodyPart': 'general',
        'target': 'General',
        'equipment': 'body only',
        'sets': sets,
        'reps': reps,
      });
    }

    if (current != null) allDayExercises.add(current);

    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    final count = dayNames.length.clamp(0, 7);
    final selected = List<String>.from(weekdays.take(count));
    final total = allDayExercises.fold(0, (s, d) => s + d.length);

    return (
      dayExercises: allDayExercises,
      dayNames: dayNames,
      selectedDays: selected,
      summary: total > 0 ? '$total exercises' : 'AI suggested',
      duration: count > 1 ? '$count-day plan' : 'AI suggested',
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

  // Strip the internal tag before showing in the bubble
  String get displayText =>
      text.replaceFirst(RegExp(r'^\[WORKOUT_PLAN\]\s*\n?'), '').trim();

  bool get looksLikeWorkoutPlan {
    if (!isBot) return false;
    // Primary: AI explicitly tagged this response as a workout plan
    if (text.contains('[WORKOUT_PLAN]')) return true;
    // Fallback: keyword heuristic for edge cases the tag misses
    final lower = text.toLowerCase();
    final hasDays = lower.contains('day 1') || lower.contains('day 2') ||
        lower.contains('day 3') || lower.contains('day one') ||
        lower.contains('day two') || lower.contains('day three');
    final hasExerciseTerms =
        (lower.contains('sets') || lower.contains('set')) &&
        (lower.contains('reps') || lower.contains('rep'));
    final hasWorkoutTerms = lower.contains('workout') ||
        lower.contains('program') ||
        lower.contains('routine') ||
        lower.contains('training plan') ||
        lower.contains('exercise plan');
    return (hasDays && hasExerciseTerms) ||
        (hasExerciseTerms && hasWorkoutTerms);
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
                    message.displayText,
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
