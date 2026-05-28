import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:main_build/Theme/app_theme.dart';
import 'package:main_build/Views/main_app/workout/plan_detail_sheet.dart';
import 'package:main_build/data/local_plan_service.dart';
import 'package:main_build/data/supabase_service.dart';
import 'package:main_build/data/workout_plans.dart';

// ─── Message type ─────────────────────────────────────────────────────────────

enum _MessageType { text, planCard, recommendationChoice }

// ─── Page ─────────────────────────────────────────────────────────────────────

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
    const _Message(
      text:
          "Hi! I'm Corely AI, your personal fitness assistant. How can I help you today?",
      isBot: true,
    ),
  ];
  bool _isTyping = false;
  final Set<int> _savedPlanIndices = {};

  // ── Recommendation flow state ────────────────────────────────────────────
  bool _awaitingRecommendationChoice = false;
  WorkoutPlan? _pendingModificationPlan;
  List<WorkoutPlan> _recommendationPlans = [];
  int _recommendationIndex = 0;

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
    final profile =
        'User profile — Gender: ${w.gender}, Age: ${w.age} yrs, '
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

  // ── Persistence ──────────────────────────────────────────────────────────

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
          ..addAll(
            list.map(
              (m) => _Message(
                text: m['text'] as String,
                isBot: m['isBot'] as bool,
              ),
            ),
          );
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (_) {}
  }

  Future<void> _saveMessages() async {
    final box = await Hive.openBox<String>(_hiveBox);
    final serializable = _messages
        .map((m) {
          if (m.type == _MessageType.planCard) {
            return {
              'text': m.plan != null ? '[Recommended: ${m.plan!.title}]' : '',
              'isBot': true,
            };
          }
          return {'text': m.text, 'isBot': m.isBot};
        })
        .where((m) => (m['text'] as String).isNotEmpty)
        .toList();
    await box.put(_hiveKey, jsonEncode(serializable));
  }

  // ── Send logic ───────────────────────────────────────────────────────────

  void _send() => _doSend();

  Future<void> _doSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_Message(text: text, isBot: false));
      _controller.clear();
      // Typing while a choice is pending cancels the flow
      if (_awaitingRecommendationChoice) _awaitingRecommendationChoice = false;
    });
    _scrollToBottom();
    _saveMessages();

    // ── Pending modification ───────────────────────────────────────────────
    if (_pendingModificationPlan != null) {
      final plan = _pendingModificationPlan!;
      _pendingModificationPlan = null;
      setState(() => _isTyping = true);
      try {
        final reply = await _callGemini(extra: _buildModificationContext(plan));
        if (!mounted) return;
        setState(() {
          _isTyping = false;
          _messages.add(_Message(text: reply, isBot: true));
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isTyping = false;
          _messages.add(
            _Message(
              text:
                  "Corely AI is busy right now — give it a sec and try again 💪",
              isBot: true,
            ),
          );
        });
      }
      _scrollToBottom();
      _saveMessages();
      return;
    }

    // ── Workout generation intent → recommendation flow ────────────────────
    if (_isWorkoutGenerationRequest(text)) {
      await _triggerRecommendationFlow();
      return;
    }

    // ── Normal Gemini call ─────────────────────────────────────────────────
    setState(() => _isTyping = true);
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
        _messages.add(
          _Message(
            text:
                "Corely AI is busy right now — give it a sec and try again 💪",
            isBot: true,
          ),
        );
      });
    }
    _scrollToBottom();
    _saveMessages();
  }

  // ── Gemini API ───────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _buildContents() {
    final firstUserIdx = _messages.indexWhere((m) => !m.isBot);
    if (firstUserIdx == -1) return [];
    return _messages
        .skip(firstUserIdx)
        .map((m) {
          String t = m.text;
          if (m.type == _MessageType.planCard) {
            t = m.plan != null ? '[Plan shown to user: ${m.plan!.title}]' : '';
          }
          return {
            'role': m.isBot ? 'model' : 'user',
            'parts': [
              {'text': t},
            ],
          };
        })
        .where(
          (m) => ((m['parts'] as List)[0] as Map)['text'].toString().isNotEmpty,
        )
        .toList();
  }

  Future<String> _callGemini({String? extra}) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent',
    );
    final systemText = extra != null
        ? '$_systemPrompt\n\n$extra'
        : _systemPrompt;
    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': systemText},
        ],
      },
      'contents': _buildContents(),
    });

    // Retry up to 3 times on 503 (model overloaded) with back-off
    http.Response? lastResponse;
    for (var attempt = 0; attempt < 3; attempt++) {
      if (attempt > 0) {
        await Future.delayed(Duration(seconds: attempt * 2));
      }
      lastResponse = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'X-goog-api-key': _apiKey,
            },
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      if (lastResponse.statusCode == 200) {
        final json = jsonDecode(lastResponse.body) as Map<String, dynamic>;
        final candidates = json['candidates'] as List<dynamic>;
        final content = candidates[0]['content'] as Map<String, dynamic>;
        final parts = content['parts'] as List<dynamic>;
        return parts[0]['text'] as String;
      }
      if (lastResponse.statusCode != 503) break;
    }
    throw Exception('HTTP ${lastResponse?.statusCode}');
  }

  // ── Recommendation flow ──────────────────────────────────────────────────

  bool _isWorkoutGenerationRequest(String text) {
    final lower = text.toLowerCase();
    final hasVerb = RegExp(
      r'generat|creat|make\s+me|give\s+me|build|design|write\s+me|suggest|recommend|come\s+up\s+with',
    ).hasMatch(lower);
    final hasNoun = RegExp(
      r'workout|training\s+plan|exercise\s+plan|program|routine|schedule',
    ).hasMatch(lower);
    return hasVerb && hasNoun;
  }

  List<WorkoutPlan> _rankPlans(List<WorkoutPlan> plans) {
    final goal = (widget.goal ?? '').toLowerCase();
    final days = widget.trainingDays ?? 3;
    final expLevel = days <= 3
        ? 1
        : days <= 4
        ? 2
        : days <= 5
        ? 3
        : 4;

    int score(WorkoutPlan p) {
      int s = 0;
      if (p.category == PlanCategory.cardio &&
          RegExp(r'weight|fat|cardio|endur|run').hasMatch(goal)) {
        s += 3;
      }
      if (p.category == PlanCategory.hypertrophy &&
          RegExp(r'muscle|size|bulk|hyper|aesthet').hasMatch(goal)) {
        s += 3;
      }
      if (p.category == PlanCategory.strength &&
          RegExp(r'strength|strong|power|lift').hasMatch(goal)) {
        s += 3;
      }
      if (p.category == PlanCategory.calisthenics &&
          RegExp(r'calisthenic|bodyweight|home').hasMatch(goal)) {
        s += 3;
      }
      s -= (p.difficulty - expLevel).abs();
      return s;
    }

    return [...plans]..sort((a, b) => score(b).compareTo(score(a)));
  }

  Future<void> _triggerRecommendationFlow() async {
    setState(() {
      _awaitingRecommendationChoice = true;
      _messages.add(
        const _Message(
          text:
              "I can generate a fully custom plan, or recommend one from our curated library that matches your profile. Which do you prefer?",
          isBot: true,
          type: _MessageType.recommendationChoice,
        ),
      );
    });
    _scrollToBottom();
    _saveMessages();
  }

  Future<void> _onChooseFromLibrary() async {
    setState(() {
      _awaitingRecommendationChoice = false;
      _isTyping = true;
    });
    try {
      final plans = await SupabaseService.getSuggestedPlans();
      if (!mounted) return;
      if (plans.isEmpty) {
        setState(() {
          _isTyping = false;
          _messages.add(
            const _Message(
              text:
                  "Couldn't load the library right now — generating a custom plan for you instead!",
              isBot: true,
            ),
          );
        });
        _scrollToBottom();
        await _callGeminiAndRespond();
        return;
      }
      _recommendationPlans = _rankPlans(plans);
      _recommendationIndex = 0;
      _showRecommendationCard(0);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(
          const _Message(
            text:
                "Ran into an issue loading the library — generating a custom plan for you!",
            isBot: true,
          ),
        );
      });
      _scrollToBottom();
      await _callGeminiAndRespond();
    }
  }

  void _showRecommendationCard(int index) {
    final plan = _recommendationPlans[index];
    setState(() {
      _isTyping = false;
      _messages.add(
        _Message(
          text: index == 0
              ? "Here's a plan that fits your profile 💪"
              : "Here's another one from the library:",
          isBot: true,
        ),
      );
      _messages.add(
        _Message(
          text: '',
          isBot: true,
          type: _MessageType.planCard,
          plan: plan,
        ),
      );
    });
    _scrollToBottom();
    _saveMessages();
  }

  Future<void> _onChooseCustomGenerate() async {
    setState(() => _awaitingRecommendationChoice = false);
    await _callGeminiAndRespond();
  }

  Future<void> _callGeminiAndRespond() async {
    setState(() => _isTyping = true);
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
        _messages.add(
          _Message(
            text:
                "Corely AI is busy right now — give it a sec and try again 💪",
            isBot: true,
          ),
        );
      });
    }
    _scrollToBottom();
    _saveMessages();
  }

  void _onShowAnother() {
    if (_recommendationPlans.isEmpty) return;
    _recommendationIndex =
        (_recommendationIndex + 1) % _recommendationPlans.length;
    _showRecommendationCard(_recommendationIndex);
  }

  Future<void> _onAddPlanFromRecommendation(WorkoutPlan plan) async {
    await LocalPlanService.savePlan(plan, source: 'suggested');
    if (!mounted) return;
    setState(() {
      _messages.add(
        _Message(
          text: '"${plan.title}" added to your plans! Check the Workout tab 🎉',
          isBot: true,
        ),
      );
    });
    _scrollToBottom();
    _saveMessages();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${plan.title} added to your plans!')),
    );
  }

  void _onModifyPlan(WorkoutPlan plan) {
    _pendingModificationPlan = plan;
    setState(() {
      _messages.add(_Message(text: 'Modify "${plan.title}"', isBot: false));
      _messages.add(
        const _Message(
          text:
              'Sure! Tell me what you want to change — e.g. "make it 4 days", "add more cardio", "swap chest for back".',
          isBot: true,
        ),
      );
    });
    _scrollToBottom();
    _saveMessages();
  }

  void _previewPlan(WorkoutPlan plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlanDetailSheet(
        plan: plan,
        onPlanAdded: () {
          Navigator.pop(context);
          _onAddPlanFromRecommendation(plan);
        },
      ),
    );
  }

  String _buildModificationContext(WorkoutPlan plan) {
    final buf = StringBuffer();
    buf.writeln(
      'The user wants to modify the following existing workout plan:',
    );
    buf.writeln('Title: ${plan.title}');
    buf.writeln('Duration: ${plan.duration}');
    if (plan.description != null)
      buf.writeln('Description: ${plan.description}');
    if (plan.days != null) {
      for (final d in plan.days!) {
        buf.writeln('${d.label}: ${d.exercises.join(", ")}');
      }
    }
    buf.writeln('');
    buf.writeln(
      'Generate a modified version per the user\'s request. '
      'Start your response with [WORKOUT_PLAN] and use [EX: Name | sets | reps] for every exercise.',
    );
    return buf.toString();
  }

  // ── Save AI-generated plan ───────────────────────────────────────────────

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
      const SnackBar(
        content: Text('Plan saved! Check My Plans in the Workout tab.'),
      ),
    );
  }

  // ── Workout parser ───────────────────────────────────────────────────────

  ({
    List<List<Map<String, dynamic>>> dayExercises,
    List<String> dayNames,
    List<String> selectedDays,
    String summary,
    String duration,
  })
  _parseAiWorkout(String text) {
    final dayNames = <String>[];
    final allDayExercises = <List<Map<String, dynamic>>>[];
    List<Map<String, dynamic>>? current;

    final dayRe = RegExp(
      r'^(?:day\s*\d+|session\s+[a-z]|week\s*\d+|workout\s+[ab])',
      caseSensitive: false,
    );
    final setsRepsRe = RegExp(
      r'(\d+)\s*(?:sets?\s*)?[x×]\s*(\d+(?:[–\-]\d+)?)'
      r'|'
      r'(\d+)\s*sets?\s*(?:(?:of|,)\s*)?(\d+(?:[–\-]\d+)?)\s*(?:reps?)?',
      caseSensitive: false,
    );
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

      if (current == null) {
        final hasBullet = RegExp(r'^[-*•]').hasMatch(raw.trim());
        if (!hasBullet && !setsRepsRe.hasMatch(line)) continue;
        current = [];
        dayNames.add('Day 1');
      }

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

      final m = setsRepsRe.firstMatch(ex);
      if (m != null) {
        final sRaw = m.group(1) ?? m.group(3);
        final rRaw = m.group(2) ?? m.group(4);
        final s = int.tryParse(sRaw ?? '');
        if (s != null && s >= 1 && s <= 12 && rRaw != null) {
          sets = s;
          reps = rRaw;
        }
        ex = ex
            .substring(0, m.start)
            .replaceAll(RegExp(r'[:\-–,\s]+$'), '')
            .trim();
      } else {
        final repsFirst = RegExp(
          r'(\d+(?:[–\-]\d+)?)\s*reps?\s*,?\s*(\d+)\s*sets?',
          caseSensitive: false,
        ).firstMatch(ex);
        if (repsFirst != null) {
          reps = repsFirst.group(1) ?? '10';
          sets = int.tryParse(repsFirst.group(2) ?? '') ?? 3;
          ex = ex
              .substring(0, repsFirst.start)
              .replaceAll(RegExp(r'[:\-–,\s]+$'), '')
              .trim();
        } else {
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
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final count = dayNames.length.clamp(0, 7);
    final total = allDayExercises.fold(0, (s, d) => s + d.length);

    return (
      dayExercises: allDayExercises,
      dayNames: dayNames,
      selectedDays: List<String>.from(weekdays.take(count)),
      summary: total > 0 ? '$total exercises' : 'AI suggested',
      duration: count > 1 ? '$count-day plan' : 'AI suggested',
    );
  }

  // ── Scroll ───────────────────────────────────────────────────────────────

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

  // ── Build ────────────────────────────────────────────────────────────────

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
                if (i == _messages.length) return _TypingIndicator(c: c);
                final msg = _messages[i];

                if (msg.type == _MessageType.planCard && msg.plan != null) {
                  return _PlanCardBubble(
                    plan: msg.plan!,
                    c: c,
                    onPreview: () => _previewPlan(msg.plan!),
                    onAdd: () => _onAddPlanFromRecommendation(msg.plan!),
                    onModify: () => _onModifyPlan(msg.plan!),
                    onShowAnother: _onShowAnother,
                  );
                }

                if (msg.type == _MessageType.recommendationChoice) {
                  return _RecommendationChoiceBubble(
                    text: msg.text,
                    c: c,
                    enabled: _awaitingRecommendationChoice,
                    onLibrary: _onChooseFromLibrary,
                    onCustom: _onChooseCustomGenerate,
                  );
                }

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

// ─── Data ─────────────────────────────────────────────────────────────────────

class _Message {
  final String text;
  final bool isBot;
  final _MessageType type;
  final WorkoutPlan? plan;

  const _Message({
    required this.text,
    required this.isBot,
    this.type = _MessageType.text,
    this.plan,
  });

  String get displayText =>
      text.replaceFirst(RegExp(r'^\[WORKOUT_PLAN\]\s*\n?'), '').trim();

  bool get looksLikeWorkoutPlan {
    if (!isBot || type != _MessageType.text) return false;
    if (text.contains('[WORKOUT_PLAN]')) return true;
    final lower = text.toLowerCase();
    final hasDays =
        lower.contains('day 1') ||
        lower.contains('day 2') ||
        lower.contains('day 3') ||
        lower.contains('day one') ||
        lower.contains('day two') ||
        lower.contains('day three');
    final hasExerciseTerms =
        (lower.contains('sets') || lower.contains('set')) &&
        (lower.contains('reps') || lower.contains('rep'));
    final hasWorkoutTerms =
        lower.contains('workout') ||
        lower.contains('program') ||
        lower.contains('routine') ||
        lower.contains('training plan') ||
        lower.contains('exercise plan');
    return (hasDays && hasExerciseTerms) ||
        (hasExerciseTerms && hasWorkoutTerms);
  }
}

// ─── Text message bubble ──────────────────────────────────────────────────────

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
        mainAxisAlignment: isBot
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
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
              child: Image.asset('assets/img/bot.png'),
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
                    horizontal: 14,
                    vertical: 10,
                  ),
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
                          color: isSaved ? Colors.green : c.textMuted,
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

// ─── Recommendation choice bubble ─────────────────────────────────────────────

class _RecommendationChoiceBubble extends StatelessWidget {
  const _RecommendationChoiceBubble({
    required this.text,
    required this.c,
    required this.enabled,
    required this.onLibrary,
    required this.onCustom,
  });

  final String text;
  final CorelyColors c;
  final bool enabled;
  final VoidCallback onLibrary;
  final VoidCallback onCustom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _BotAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: c.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  if (enabled) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onLibrary,
                            icon: const Icon(
                              Icons.library_books_outlined,
                              size: 14,
                            ),
                            label: const Text('From Library'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onCustom,
                            icon: const Icon(Icons.auto_awesome, size: 14),
                            label: const Text('Generate'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 6),
                    Text(
                      'Choice made',
                      style: TextStyle(color: c.textMuted, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Plan card bubble ─────────────────────────────────────────────────────────

class _PlanCardBubble extends StatelessWidget {
  const _PlanCardBubble({
    required this.plan,
    required this.c,
    required this.onPreview,
    required this.onAdd,
    required this.onModify,
    required this.onShowAnother,
  });

  final WorkoutPlan plan;
  final CorelyColors c;
  final VoidCallback onPreview;
  final VoidCallback onAdd;
  final VoidCallback onModify;
  final VoidCallback onShowAnother;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _BotAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: c.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + difficulty
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          plan.title,
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          4,
                          (i) => Icon(
                            Icons.flash_on,
                            size: 14,
                            color: i < plan.difficulty.clamp(1, 4)
                                ? AppTheme.accent
                                : c.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${plan.duration}  ·  ${plan.exercises}',
                    style: TextStyle(color: c.textMuted, fontSize: 12),
                  ),
                  if (plan.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      plan.description!,
                      style: TextStyle(
                        color: c.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Row 1: Preview + Add
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onPreview,
                          icon: const Icon(Icons.visibility_outlined, size: 14),
                          label: const Text('Preview'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onAdd,
                          icon: const Icon(Icons.add, size: 14),
                          label: const Text('Add Plan'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Row 2: Modify + Show another
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onModify,
                          icon: const Icon(Icons.edit_outlined, size: 14),
                          label: const Text('Modify'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onShowAnother,
                          icon: const Icon(Icons.refresh, size: 14),
                          label: const Text('Another'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared bot avatar ────────────────────────────────────────────────────────

class _BotAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Image.asset('assets/img/bot.png'),
    );
  }
}

// ─── Typing indicator ─────────────────────────────────────────────────────────

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
          _BotAvatar(),
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
    _opacity = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
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

// ─── Input bar ────────────────────────────────────────────────────────────────

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
                    borderSide: const BorderSide(
                      color: AppTheme.accent,
                      width: 1.5,
                    ),
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
