import 'dart:io';

import 'package:flutter/material.dart';
import 'package:main_build/Theme/app_theme.dart';
import 'package:main_build/Views/main_app/workout/start_train.dart';
import 'package:main_build/data/workout_plans.dart';
import 'package:main_build/data/workout_progress_service.dart';

class PlayPlanPage extends StatefulWidget {
  final WorkoutPlan plan;

  const PlayPlanPage({super.key, required this.plan});

  @override
  State<PlayPlanPage> createState() => _PlayPlanPageState();
}

class _PlayPlanPageState extends State<PlayPlanPage> {
  late final PageController _pageController;
  int _currentDay = 0;

  // dayIndex -> exerciseName -> {reps, kg}
  final Map<int, Map<String, Map<String, String>>> _exerciseInputs = {};

  late final List<Map<String, dynamic>> _resolvedDays;
  late final String _planProgressKey;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _resolvedDays = _buildResolvedDays();
    _planProgressKey = WorkoutProgressService.planKey(
      title: widget.plan.title,
      duration: widget.plan.duration,
      daysCount: _resolvedDays.length,
    );
    _loadSavedProgress();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _buildResolvedDays() {
    final List<Map<String, dynamic>> days = [];

    if (widget.plan.dayExercises.isNotEmpty) {
      for (
        var dayIndex = 0;
        dayIndex < widget.plan.dayExercises.length;
        dayIndex++
      ) {
        final dayName = dayIndex < widget.plan.dayNames.length
            ? widget.plan.dayNames[dayIndex]
            : 'Day ${dayIndex + 1}';

        final rawExercises = widget.plan.dayExercises[dayIndex];
        final List<Map<String, dynamic>> exercises = [];

        if (rawExercises is List) {
          for (final raw in rawExercises) {
            if (raw is Map) {
              exercises.add(Map<String, dynamic>.from(raw));
            }
          }
        }

        days.add({'name': dayName, 'exercises': exercises});
      }
      return days;
    }

    final durationInMinutes =
        int.tryParse(widget.plan.duration.split(' ').first) ?? 15;
    final fallbackDaysCount = (durationInMinutes / 5).ceil().clamp(1, 7);

    for (var dayIndex = 0; dayIndex < fallbackDaysCount; dayIndex++) {
      days.add({
        'name': 'Day ${dayIndex + 1}',
        'exercises': <Map<String, dynamic>>[
          {
            'name': 'Main Exercise ${dayIndex + 1}',
            'sets': '3',
            'reps': '8-12',
            'rest': '90 sec',
          },
          {
            'name': 'Accessory Exercise ${dayIndex + 1}',
            'sets': '3',
            'reps': '10-12',
            'rest': '60 sec',
          },
        ],
      });
    }

    return days;
  }

  void _goToDay(int newIndex) {
    if (newIndex < 0 || newIndex >= _resolvedDays.length) return;
    _pageController.animateToPage(
      newIndex,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  String _getInputValue(
    int dayIndex,
    String exerciseName,
    String field,
    String fallback,
  ) {
    final value = _exerciseInputs[dayIndex]?[exerciseName]?[field];
    if (value == null || value.trim().isEmpty) return fallback;
    return value;
  }

  void _setInputValue(
    int dayIndex,
    String exerciseName,
    String field,
    String value,
  ) {
    final dayMap = _exerciseInputs.putIfAbsent(dayIndex, () => {});
    final exerciseMap = dayMap.putIfAbsent(exerciseName, () => {});
    exerciseMap[field] = value;
  }

  void _loadSavedProgress() {
    final saved = WorkoutProgressService.getPlanProgress(_planProgressKey);
    if (saved.isEmpty) return;

    if (!mounted) return;
    setState(() {
      _exerciseInputs
        ..clear()
        ..addAll(saved);
    });
  }

  Future<void> _persistProgress() async {
    try {
      await WorkoutProgressService.savePlanProgress(
        _planProgressKey,
        _exerciseInputs,
      );
    } catch (error) {
      debugPrint('Failed to save workout progress: $error');
    }
  }

  Future<void> _editExerciseWeight(
    int dayIndex,
    String exerciseName,
    String currentValue,
  ) async {
    final currentReps = _getInputValue(dayIndex, exerciseName, 'reps', '1');

    final updated = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return _WorkoutEditDialog(
          initialKg: currentValue.isEmpty ? '1' : currentValue,
          initialReps: currentReps.isEmpty ? '1' : currentReps,
        );
      },
    );
    if (!mounted || updated == null) return;

    final kgValue = updated['kg']?.trim();
    final repsValue = updated['reps']?.trim();

    setState(() {
      _setInputValue(
        dayIndex,
        exerciseName,
        'kg',
        (kgValue == null || kgValue.isEmpty) ? '1' : kgValue,
      );
      _setInputValue(
        dayIndex,
        exerciseName,
        'reps',
        (repsValue == null || repsValue.isEmpty) ? '1' : repsValue,
      );
    });

    if (!mounted) return;
    try {
      await _persistProgress();
    } catch (_) {
      // Persistence failures are non-fatal; the UI state is already updated.
    }
  }

  Future<void> _startTrainingForDay(int dayIndex) async {
    final day = _resolvedDays[dayIndex];
    final dayName = day['name'] as String;
    final exercises = day['exercises'] as List<Map<String, dynamic>>;

    if (exercises.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No exercises found for this day.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final currentDayInputs = _exerciseInputs[dayIndex] ?? {};

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => StartTrainPage(
          planTitle: widget.plan.title,
          dayName: dayName,
          dayNumber: dayIndex + 1,
          exercises: exercises,
          initialInputs: currentDayInputs,
        ),
      ),
    );

    if (!mounted || result == null) return;

    final shouldSave = result['save'] == true;
    if (!shouldSave) return;

    final incoming = result['inputs'];
    if (incoming is! Map) return;

    final normalized = <String, Map<String, String>>{};
    for (final entry in incoming.entries) {
      if (entry.value is! Map) continue;

      final fields = Map<String, dynamic>.from(entry.value as Map);
      normalized[entry.key.toString()] = {
        'reps': fields['reps']?.toString().trim().isNotEmpty == true
            ? fields['reps'].toString()
            : '1',
        'kg': fields['kg']?.toString().trim().isNotEmpty == true
            ? fields['kg'].toString()
            : '1',
      };
    }

    setState(() {
      _exerciseInputs[dayIndex] = normalized;
    });
    await _persistProgress();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Training changes updated.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final daysCount = _resolvedDays.length;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final palette =
        theme.extension<CorelyColors>() ??
        (isDarkMode ? AppTheme.darkColors : AppTheme.lightColors);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        title: Text(plan.title, style: TextStyle(color: palette.textPrimary)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Workout Days',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  'Day ${_currentDay + 1}/$daysCount',
                  style: TextStyle(color: palette.textMuted, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _DayArrowButton(
                  icon: Icons.chevron_left,
                  enabled: _currentDay > 0,
                  onTap: () => _goToDay(_currentDay - 1),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: Center(
                      child: Text(
                        _resolvedDays[_currentDay]['name'] as String,
                        style: TextStyle(
                          color: palette.accent,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _DayArrowButton(
                  icon: Icons.chevron_right,
                  enabled: _currentDay < daysCount - 1,
                  onTap: () => _goToDay(_currentDay + 1),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _startTrainingForDay(_currentDay),
                icon: const Icon(Icons.play_circle_fill_rounded),
                label: const Text('Start Training Mode'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.accent,
                  foregroundColor: palette.background,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: daysCount,
                onPageChanged: (index) {
                  setState(() {
                    _currentDay = index;
                  });
                },
                itemBuilder: (context, dayIndex) {
                  final day = _resolvedDays[dayIndex];
                  final exercises =
                      day['exercises'] as List<Map<String, dynamic>>;

                  return ListView.separated(
                    itemCount: exercises.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, exerciseIndex) {
                      final exercise = exercises[exerciseIndex];
                      final exerciseName =
                          (exercise['name']?.toString() ?? 'Exercise').trim();
                      final suggestedReps = exercise['reps']?.toString() ?? '';
                      final currentKg = _getInputValue(
                        dayIndex,
                        exerciseName,
                        'kg',
                        '',
                      );
                      final currentReps = _getInputValue(
                        dayIndex,
                        exerciseName,
                        'reps',
                        suggestedReps,
                      );
                      final weightLabel = currentKg.isEmpty
                          ? 'Last: -'
                          : 'Last: $currentKg kg';

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: palette.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: palette.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ExerciseThumb(
                                  imageAsset: exercise['imageAsset']
                                      ?.toString(),
                                  imagePath: exercise['imagePath']?.toString(),
                                  imageUrl:
                                      exercise['imageUrl']?.toString() ??
                                      exercise['gifUrl']?.toString(),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    exerciseName,
                                    style: TextStyle(
                                      color: palette.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                InkWell(
                                  onTap: () => _editExerciseWeight(
                                    dayIndex,
                                    exerciseName,
                                    currentKg,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: palette.surfaceRaised,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: palette.border),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          weightLabel,
                                          style: TextStyle(
                                            color: palette.textSecondary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          currentReps.isEmpty
                                              ? 'Reps: -'
                                              : 'Reps: $currentReps',
                                          style: TextStyle(
                                            color: palette.textMuted,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutEditDialog extends StatefulWidget {
  final String initialKg;
  final String initialReps;

  const _WorkoutEditDialog({
    required this.initialKg,
    required this.initialReps,
  });

  @override
  State<_WorkoutEditDialog> createState() => _WorkoutEditDialogState();
}

class _WorkoutEditDialogState extends State<_WorkoutEditDialog> {
  late final TextEditingController _kgController;
  late final TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _kgController = TextEditingController(text: widget.initialKg);
    _repsController = TextEditingController(text: widget.initialReps);
  }

  @override
  void dispose() {
    _kgController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette =
        theme.extension<CorelyColors>() ??
        (theme.brightness == Brightness.dark
            ? AppTheme.darkColors
            : AppTheme.lightColors);

    return AlertDialog(
      backgroundColor: palette.surface,
      title: Text(
        'Update Weight and Reps',
        style: TextStyle(color: palette.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _kgController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: palette.textPrimary),
            decoration: InputDecoration(
              labelText: 'KG',
              labelStyle: TextStyle(color: palette.textSecondary),
              hintText: 'e.g. 1',
              hintStyle: TextStyle(color: palette.textMuted),
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
          const SizedBox(height: 12),
          TextField(
            controller: _repsController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: palette.textPrimary),
            decoration: InputDecoration(
              labelText: 'Reps',
              labelStyle: TextStyle(color: palette.textSecondary),
              hintText: 'e.g. 1',
              hintStyle: TextStyle(color: palette.textMuted),
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {
            'kg': _kgController.text,
            'reps': _repsController.text,
          }),
          style: ElevatedButton.styleFrom(
            backgroundColor: palette.accent,
            foregroundColor: palette.background,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _DayArrowButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _DayArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette =
        theme.extension<CorelyColors>() ??
        (theme.brightness == Brightness.dark
            ? AppTheme.darkColors
            : AppTheme.lightColors);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled
              ? palette.accent.withValues(alpha: 0.16)
              : palette.surfaceRaised,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled
                ? palette.accent.withValues(alpha: 0.45)
                : palette.border,
          ),
        ),
        child: Icon(icon, color: enabled ? palette.accent : palette.textMuted),
      ),
    );
  }
}

class _ExerciseThumb extends StatelessWidget {
  final String? imageAsset;
  final String? imagePath;
  final String? imageUrl;

  const _ExerciseThumb({
    required this.imageAsset,
    required this.imagePath,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (imagePath != null && imagePath!.isNotEmpty) {
      child = Image.file(
        File(imagePath!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    } else if (imageUrl != null && imageUrl!.startsWith('http')) {
      child = Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    } else if (imageAsset != null && imageAsset!.isNotEmpty) {
      child = Image.asset(
        imageAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    } else {
      child = _fallback();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(width: 44, height: 44, child: child),
    );
  }

  Widget _fallback() {
    final palette = AppTheme.darkColors;
    return Container(
      color: palette.surface,
      alignment: Alignment.center,
      child: Icon(Icons.fitness_center, color: palette.textMuted, size: 18),
    );
  }
}
