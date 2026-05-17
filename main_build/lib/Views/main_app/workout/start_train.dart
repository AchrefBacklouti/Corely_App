import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:main_build/Theme/app_theme.dart';

CorelyColors _workoutPalette(BuildContext context) {
  final theme = Theme.of(context);
  return theme.extension<CorelyColors>() ??
      (theme.brightness == Brightness.dark
          ? AppTheme.darkColors
          : AppTheme.lightColors);
}

class StartTrainPage extends StatefulWidget {
  final String planTitle;
  final String dayName;
  final int dayNumber;
  final List<Map<String, dynamic>> exercises;
  final Map<String, Map<String, String>> initialInputs;

  const StartTrainPage({
    super.key,
    required this.planTitle,
    required this.dayName,
    required this.dayNumber,
    required this.exercises,
    required this.initialInputs,
  });

  @override
  State<StartTrainPage> createState() => _StartTrainPageState();
}

class _StartTrainPageState extends State<StartTrainPage> {
  int _currentExercise = 0;
  int _sessionSeconds = 0;
  Timer? _sessionTimer;
  int _repIdSeed = 0;

  // exerciseName -> {reps, kg}
  late final Map<String, Map<String, String>> _inputs;

  // exerciseIndex -> list of reps for that exercise
  final Map<int, List<_RepLine>> _repLinesByExercise = {};

  @override
  void initState() {
    super.initState();
    _inputs = {
      for (final entry in widget.initialInputs.entries)
        entry.key: {
          'reps': entry.value['reps'] ?? '',
          'kg': entry.value['kg'] ?? '',
        },
    };
    _initializeRepLines();
    _startSessionTimer();
    _syncControllersForCurrentExercise();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  Map<String, dynamic> get _exercise {
    return widget.exercises[_currentExercise];
  }

  String get _exerciseName {
    return (_exercise['name']?.toString() ?? 'Exercise').trim();
  }

  String get _exerciseDescription {
    final raw =
        _exercise['description'] ??
        _exercise['instructions'] ??
        _exercise['instruction'] ??
        _exercise['notes'];

    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }

    if (raw is List && raw.isNotEmpty) {
      return raw
          .where((e) => e != null)
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .join('\n');
    }

    return 'No description available for this exercise yet.';
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _sessionSeconds += 1;
      });
    });
  }

  int _parseRepCount(String text) {
    final matches = RegExp(r'\d+').allMatches(text).toList();
    if (matches.isEmpty) return 8;
    final number = int.tryParse(matches.last.group(0) ?? '8') ?? 8;
    return number.clamp(1, 50);
  }

  void _initializeRepLines() {
    for (var i = 0; i < widget.exercises.length; i++) {
      final exercise = widget.exercises[i];
      final name = (exercise['name']?.toString() ?? 'Exercise').trim();
      final savedReps = _inputs[name]?['reps'] ?? '';
      final savedKg = _inputs[name]?['kg'] ?? '';
      final fallbackReps = exercise['reps']?.toString() ?? '8';
      final count = _parseRepCount(
        savedReps.isNotEmpty ? savedReps : fallbackReps,
      );
      final defaultKg = (savedKg.isNotEmpty ? savedKg : '10').trim();

      _repLinesByExercise[i] = List.generate(
        count,
        (_) => _RepLine(id: _repIdSeed++, checked: false, kg: defaultKg),
      );
    }
  }

  List<_RepLine> _currentRepLines() {
    return _repLinesByExercise.putIfAbsent(
      _currentExercise,
      () => [_RepLine(id: _repIdSeed++, checked: false, kg: '10')],
    );
  }

  void _syncControllersForCurrentExercise() {
    // No-op: KG values are edited inline per row and first rep acts as master.
  }

  void _saveCurrentExerciseInputs() {
    final lines = _currentRepLines();
    final defaultKg = lines.isNotEmpty ? lines.first.kg : '10';

    _inputs[_exerciseName] = {'reps': lines.length.toString(), 'kg': defaultKg};
  }

  String _formatTimer(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  void _goToExercise(int index) {
    if (index < 0 || index >= widget.exercises.length) return;

    _saveCurrentExerciseInputs();

    setState(() {
      _currentExercise = index;
    });

    _syncControllersForCurrentExercise();
  }

  int get _currentTarget => _currentRepLines().length;
  int get _currentCompleted =>
      _currentRepLines().where((line) => line.checked).length;
  bool get _isCurrentExerciseDone =>
      _currentTarget > 0 && _currentRepLines().every((line) => line.checked);

  void _checkNextRep() {
    _saveCurrentExerciseInputs();
    final lines = _currentRepLines();
    final nextIndex = lines.indexWhere((line) => !line.checked);
    if (nextIndex == -1) return;

    setState(() {
      lines[nextIndex] = lines[nextIndex].copyWith(checked: true);
    });
  }

  void _toggleRepCheck(int index, bool checked) {
    final lines = _currentRepLines();
    if (index < 0 || index >= lines.length) return;

    setState(() {
      lines[index] = lines[index].copyWith(checked: checked);
    });
  }

  void _addRepLine() {
    final lines = _currentRepLines();
    final kg = lines.isNotEmpty ? lines.first.kg : '10';

    setState(() {
      lines.add(_RepLine(id: _repIdSeed++, checked: false, kg: kg));
    });
    _saveCurrentExerciseInputs();
  }

  void _removeRepLine(int index) {
    final lines = _currentRepLines();
    if (lines.length <= 1 || index < 0 || index >= lines.length) return;

    setState(() {
      lines.removeAt(index);
    });
    _saveCurrentExerciseInputs();
  }

  Future<void> _completeCurrentExercise() async {
    final total = widget.exercises.length;

    if (_currentExercise == total - 1) {
      final shouldContinue = await _showCompletionSummary();
      if (!shouldContinue || !mounted) return;
      await _askToSaveAndExit(completed: true);
      return;
    }

    _goToExercise(_currentExercise + 1);
  }

  int _parseRepsValue(String text) {
    final matched = RegExp(r'\d+').firstMatch(text)?.group(0);
    return int.tryParse(matched ?? '') ?? 0;
  }

  double _parseKgValue(String text) {
    final normalized = text.replaceAll(',', '.');
    final matched = RegExp(r'\d+(?:\.\d+)?').firstMatch(normalized)?.group(0);
    return double.tryParse(matched ?? '') ?? 0;
  }

  Future<bool> _showCompletionSummary() async {
    _saveCurrentExerciseInputs();

    final summaries = <_ExerciseSummary>[];
    var improvedCount = 0;

    for (final exercise in widget.exercises) {
      final name = (exercise['name']?.toString() ?? 'Exercise').trim();
      final beforeRaw = widget.initialInputs[name] ?? const <String, String>{};
      final afterRaw = _inputs[name] ?? const <String, String>{};

      final beforeReps = _parseRepsValue(beforeRaw['reps'] ?? '0');
      final afterReps = _parseRepsValue(afterRaw['reps'] ?? '0');
      final beforeKg = _parseKgValue(beforeRaw['kg'] ?? '0');
      final afterKg = _parseKgValue(afterRaw['kg'] ?? '0');

      final repsImproved = afterReps > beforeReps;
      final kgImproved = afterKg > beforeKg;
      final improved = repsImproved && kgImproved;
      if (improved) improvedCount += 1;

      summaries.add(
        _ExerciseSummary(
          name: name,
          beforeReps: beforeReps,
          afterReps: afterReps,
          beforeKg: beforeKg,
          afterKg: afterKg,
          improved: improved,
        ),
      );
    }

    final totalReps = _repLinesByExercise.values.fold<int>(
      0,
      (sum, lines) => sum + lines.where((line) => line.checked).length,
    );
    final palette = _workoutPalette(context);

    final proceed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: palette.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.54),
                blurRadius: 16,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Congratulations!',
                style: TextStyle(
                  color: palette.accent,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You finished this training session.',
                style: TextStyle(color: palette.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SummaryPill(
                    label: 'Time',
                    value: _formatTimer(_sessionSeconds),
                  ),
                  _SummaryPill(
                    label: 'Exercises',
                    value: summaries.length.toString(),
                  ),
                  _SummaryPill(
                    label: 'Checked Reps',
                    value: totalReps.toString(),
                  ),
                  _SummaryPill(
                    label: 'Improved',
                    value: '$improvedCount/${summaries.length}',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'What You Did And Improved',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: summaries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final item = summaries[i];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: palette.surfaceRaised,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: palette.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: palette.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: item.improved
                                      ? Colors.green.withValues(alpha: 0.2)
                                      : palette.surface,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  item.improved
                                      ? 'Strong Improvement'
                                      : 'Keep Pushing',
                                  style: TextStyle(
                                    color: item.improved
                                        ? Colors.greenAccent
                                        : palette.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _MetricChip(
                                label: 'Reps',
                                increased: item.repsImproved,
                                decreased: item.repsDecreased,
                              ),
                              const SizedBox(width: 8),
                              _MetricChip(
                                label: 'KG',
                                increased: item.kgImproved,
                                decreased: item.kgDecreased,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Reps: ${item.beforeReps} -> ${item.afterReps}',
                                  style: TextStyle(
                                    color: palette.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'KG: ${item.beforeKg.toStringAsFixed(item.beforeKg % 1 == 0 ? 0 : 1)} -> ${item.afterKg.toStringAsFixed(item.afterKg % 1 == 0 ? 0 : 1)}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: palette.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(sheetContext, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.accent,
                    foregroundColor: palette.background,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        );
      },
    );

    return proceed == true;
  }

  Future<void> _showExerciseInfo() async {
    final imageAsset = _exercise['imageAsset']?.toString();
    final imagePath = _exercise['imagePath']?.toString();
    final imageUrl =
        _exercise['imageUrl']?.toString() ?? _exercise['gifUrl']?.toString();
    final palette = _workoutPalette(context);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.82,
          ),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: palette.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.54),
                blurRadius: 18,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 250,
                        child: _ExerciseImage(
                          imageAsset: imageAsset,
                          imagePath: imagePath,
                          imageUrl: imageUrl,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _exerciseName,
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _exerciseDescription,
                            style: TextStyle(
                              color: palette.textSecondary,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: InkWell(
                  onTap: () => Navigator.pop(sheetContext),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                      border: Border.all(color: palette.border),
                    ),
                    child: Icon(
                      Icons.close,
                      color: palette.textPrimary,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _askToSaveAndExit({required bool completed}) async {
    _saveCurrentExerciseInputs();
    final palette = _workoutPalette(context);

    final decision = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: palette.surface,
          title: Text(
            completed ? 'Workout Complete' : 'Exit Training',
            style: TextStyle(color: palette.textPrimary),
          ),
          content: Text(
            completed
                ? 'Do you want to update your reps and kg changes?'
                : 'Do you want to save your current reps and kg changes before leaving?',
            style: TextStyle(color: palette.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'discard'),
              child: const Text(
                'No',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, 'save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.accent,
                foregroundColor: palette.background,
              ),
              child: const Text('Yes, Save'),
            ),
          ],
        );
      },
    );

    if (!mounted || decision == null || decision == 'cancel') {
      return false;
    }

    if (decision == 'save') {
      Navigator.pop(context, {
        'save': true,
        'completed': completed,
        'inputs': _inputs,
        'durationSeconds': _sessionSeconds,
      });
    } else {
      Navigator.pop(context, {'save': false, 'completed': completed});
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.exercises.length;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final palette =
        theme.extension<CorelyColors>() ??
        (isDarkMode ? AppTheme.darkColors : AppTheme.lightColors);
    final imageAsset = _exercise['imageAsset']?.toString();
    final imagePath = _exercise['imagePath']?.toString();
    final imageUrl =
        _exercise['imageUrl']?.toString() ?? _exercise['gifUrl']?.toString();
    final setsText = _exercise['sets']?.toString() ?? '-';
    final restText = _exercise['rest']?.toString() ?? '-';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _askToSaveAndExit(completed: false);
      },
      child: Scaffold(
        backgroundColor: palette.background,
        appBar: AppBar(
          backgroundColor: palette.background,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.close, color: palette.textPrimary),
            onPressed: () => _askToSaveAndExit(completed: false),
          ),
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: palette.surfaceRaised,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: palette.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer, color: palette.accent, size: 14),
                const SizedBox(width: 6),
                Text(
                  _formatTimer(_sessionSeconds),
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: palette.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: palette.accent.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Text(
                      'Exercise ${_currentExercise + 1}/$total',
                      style: TextStyle(
                        color: palette.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${widget.dayName} • Day ${widget.dayNumber}',
                    style: TextStyle(color: palette.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _showExerciseInfo,
                child: Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: palette.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _ExerciseImage(
                        imageAsset: imageAsset,
                        imagePath: imagePath,
                        imageUrl: imageUrl,
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 220),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _exerciseName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: _currentTarget,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, repIndex) {
                    final repLine = _currentRepLines()[repIndex];
                    return Dismissible(
                      key: ValueKey('rep-$_currentExercise-${repLine.id}'),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) async => _currentTarget > 1,
                      onDismissed: (_) => _removeRepLine(repIndex),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 14),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: palette.surfaceRaised,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: palette.border),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _toggleRepCheck(repIndex, !repLine.checked);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: repLine.checked
                                      ? Colors.green
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: repLine.checked
                                        ? Colors.green
                                        : Colors.white38,
                                    width: 1.6,
                                  ),
                                ),
                                child: repLine.checked
                                    ? const Icon(
                                        Icons.check,
                                        size: 15,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Rep ${repIndex + 1}',
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontSize: 14,
                                fontWeight: repLine.checked
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: 86,
                                maxWidth: 118,
                              ),
                              child: _InlineKgField(
                                key: ValueKey(
                                  'kg-$_currentExercise-${repLine.id}',
                                ),
                                initialValue: repLine.kg,
                                onChanged: (value) {
                                  final lines = _currentRepLines();
                                  if (repIndex < 0 ||
                                      repIndex >= lines.length) {
                                    return;
                                  }
                                  final nextKg = value.isEmpty
                                      ? lines[repIndex].kg
                                      : value;
                                  setState(() {
                                    if (repIndex == 0) {
                                      for (var i = 0; i < lines.length; i++) {
                                        lines[i] = lines[i].copyWith(
                                          kg: nextKg,
                                        );
                                      }
                                    } else {
                                      lines[repIndex] = lines[repIndex]
                                          .copyWith(kg: nextKg);
                                    }
                                  });
                                  _saveCurrentExerciseInputs();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: _addRepLine,
                  icon: Icon(Icons.add_circle_outline, color: palette.accent),
                  label: Text(
                    '+ Add Rep',
                    style: TextStyle(color: palette.accent),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _BottomActionButton(
                      onPressed: _currentExercise == 0
                          ? null
                          : () => _goToExercise(_currentExercise - 1),
                      icon: Icons.chevron_left,
                      label: 'Previous',
                      highlighted: false,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _BottomActionButton(
                      onPressed: () async {
                        if (_isCurrentExerciseDone) {
                          await _completeCurrentExercise();
                        } else {
                          _checkNextRep();
                        }
                      },
                      icon: !_isCurrentExerciseDone
                          ? Icons.check
                          : _currentExercise == total - 1
                          ? Icons.task_alt
                          : Icons.chevron_right,
                      label: !_isCurrentExerciseDone
                          ? 'Check ${_currentCompleted + 1}/$_currentTarget'
                          : _currentExercise == total - 1
                          ? 'Done'
                          : 'Next',
                      highlighted: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RepLine {
  final int id;
  final bool checked;
  final String kg;

  const _RepLine({required this.id, required this.checked, required this.kg});

  _RepLine copyWith({bool? checked, String? kg}) {
    return _RepLine(
      id: id,
      checked: checked ?? this.checked,
      kg: kg ?? this.kg,
    );
  }
}

class _ExerciseImage extends StatelessWidget {
  final String? imageAsset;
  final String? imagePath;
  final String? imageUrl;

  const _ExerciseImage({
    required this.imageAsset,
    required this.imagePath,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath != null && imagePath!.isNotEmpty) {
      return Image.file(
        File(imagePath!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imageFallback(),
      );
    }

    if (imageUrl != null && imageUrl!.startsWith('http')) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imageFallback(),
      );
    }

    if (imageAsset != null && imageAsset!.isNotEmpty) {
      return Image.asset(
        imageAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imageFallback(),
      );
    }

    return _imageFallback();
  }

  Widget _imageFallback() {
    final palette = AppTheme.darkColors;
    return Container(
      color: palette.surface,
      alignment: Alignment.center,
      child: Icon(
        Icons.fitness_center_rounded,
        color: palette.textMuted,
        size: 64,
      ),
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool highlighted;

  const _BottomActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _workoutPalette(context);
    final enabled = onPressed != null;
    final background = highlighted
        ? palette.accent.withValues(alpha: enabled ? 1 : 0.5)
        : Colors.transparent;
    final foreground = highlighted ? palette.background : palette.textPrimary;

    return SizedBox(
      height: 42,
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: background,
          foregroundColor: enabled ? foreground : palette.textMuted,
          side: BorderSide(
            color: highlighted ? palette.accent : palette.textMuted,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final palette = _workoutPalette(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: palette.surfaceRaised,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: palette.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final bool increased;
  final bool decreased;

  const _MetricChip({
    required this.label,
    required this.increased,
    required this.decreased,
  });

  @override
  Widget build(BuildContext context) {
    final color = increased
        ? Colors.greenAccent
        : decreased
        ? Colors.orangeAccent
        : Colors.white70;
    final text = increased
        ? '$label Up'
        : decreased
        ? '$label Down'
        : '$label Same';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ExerciseSummary {
  final String name;
  final int beforeReps;
  final int afterReps;
  final double beforeKg;
  final double afterKg;
  final bool improved;

  const _ExerciseSummary({
    required this.name,
    required this.beforeReps,
    required this.afterReps,
    required this.beforeKg,
    required this.afterKg,
    required this.improved,
  });

  bool get repsImproved => afterReps > beforeReps;
  bool get repsDecreased => afterReps < beforeReps;
  bool get kgImproved => afterKg > beforeKg;
  bool get kgDecreased => afterKg < beforeKg;
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final palette = _workoutPalette(context);
    return Row(
      children: [
        Text(label, style: TextStyle(color: palette.textMuted, fontSize: 13)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TrainInput extends StatelessWidget {
  final String label;
  final String hintText;
  final TextInputType keyboardType;
  final TextEditingController controller;

  const _TrainInput({
    required this.label,
    required this.hintText,
    required this.keyboardType,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _workoutPalette(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: palette.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: palette.textPrimary),
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            hintStyle: TextStyle(color: palette.textMuted),
            filled: true,
            fillColor: palette.inputFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: palette.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: palette.accent),
            ),
          ),
        ),
      ],
    );
  }
}

class _InlineKgField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const _InlineKgField({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_InlineKgField> createState() => _InlineKgFieldState();
}

class _InlineKgFieldState extends State<_InlineKgField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _InlineKgField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue &&
        _controller.text != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = _workoutPalette(context);
    return TextField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (value) => widget.onChanged(value.trim()),
      textAlign: TextAlign.center,
      style: TextStyle(
        color: palette.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'KG',
        hintStyle: TextStyle(color: palette.textMuted, fontSize: 12),
        suffixText: 'KG',
        suffixStyle: TextStyle(color: palette.textMuted, fontSize: 11),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        filled: true,
        fillColor: palette.inputFill,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: palette.accent),
        ),
      ),
    );
  }
}
