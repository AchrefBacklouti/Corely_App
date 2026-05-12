import 'package:flutter/material.dart';
import 'package:main_build/Models/exercise.dart';
import 'package:main_build/Theme/app_theme.dart';
import 'package:main_build/data/local_plan_service.dart';
import 'package:main_build/data/workout_plans.dart';
import 'package:main_build/data/plan_share_service.dart';
import 'package:main_build/Views/main_app/workout/edit_day_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditPlanPage extends StatefulWidget {
  final WorkoutPlan? existingPlan;
  final int? planIndex;
  final List<WorkoutDay>? prefillDays;

  const EditPlanPage({
    super.key,
    this.existingPlan,
    this.planIndex,
    this.prefillDays,
  });

  @override
  State<EditPlanPage> createState() => _EditPlanPageState();
}

class _EditPlanPageState extends State<EditPlanPage> {
  final TextEditingController _nameController = TextEditingController();
  int _days = 3;
  int _currentDayIndex = 0;
  late List<List<Exercise>> _dayExercises;
  late Set<String> _selectedDays;
  late List<TextEditingController> _dayNameControllers;
  String? _imagePath;
  static const List<String> weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDays = {};
    _dayNameControllers = [];

    if (widget.existingPlan != null) {
      _nameController.text = widget.existingPlan!.title;
      _imagePath = widget.existingPlan!.imagePath;
      final durationInMinutes =
          int.tryParse(widget.existingPlan!.duration.split(' ').first) ?? 15;
      _days = (durationInMinutes / 5).ceil().clamp(1, 7);

      if (widget.existingPlan!.selectedDays.isNotEmpty) {
        _selectedDays = Set.from(widget.existingPlan!.selectedDays);
      } else {
        _selectedDays = Set.from(weekdays.take(_days));
      }

      for (var day in _selectedDays) {
        final dayIndex = weekdays.indexOf(day);
        final customName = dayIndex < widget.existingPlan!.dayNames.length
            ? widget.existingPlan!.dayNames[dayIndex]
            : day;
        _dayNameControllers.add(TextEditingController(text: customName));
      }

      _dayExercises = List.generate(_selectedDays.length, (dayIndex) {
        if (dayIndex < widget.existingPlan!.dayExercises.length) {
          final dayData = widget.existingPlan!.dayExercises[dayIndex];
          if (dayData is List) {
            return dayData
                .map(
                  (e) => Exercise.fromJson(
                    Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
                  ),
                )
                .toList();
          }
        }
        return <Exercise>[];
      });
    } else if (widget.prefillDays != null && widget.prefillDays!.isNotEmpty) {
      final prefill = widget.prefillDays!;
      final count = prefill.length.clamp(1, weekdays.length);
      _selectedDays = {};
      _dayExercises = [];
      for (int i = 0; i < count; i++) {
        _selectedDays.add(weekdays[i]);
        _dayNameControllers.add(TextEditingController(text: prefill[i].label));
        _dayExercises.add(prefill[i].exercises.map(_stubExercise).toList());
      }
      _imagePath = null;
    } else {
      _selectedDays = Set.from(weekdays.take(3));
      for (int i = 0; i < 3; i++) {
        _dayNameControllers.add(TextEditingController(text: weekdays[i]));
      }
      _dayExercises = List.generate(_selectedDays.length, (_) => []);
      _imagePath = null;
    }
  }

  static Exercise _stubExercise(String name) => Exercise(
    id: name.hashCode.toString(),
    name: name,
    bodyPart: 'general',
    target: 'General',
    equipment: 'body only',
  );

  @override
  void dispose() {
    _nameController.dispose();
    for (var controller in _dayNameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _editDay(int dayIndex) async {
    final List<Exercise>? selected = await Navigator.push<List<Exercise>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditDayPage(
          dayIndex: dayIndex + 1,
          currentExercises: _dayExercises[dayIndex],
        ),
      ),
    );
    if (selected != null && mounted) {
      setState(() {
        _dayExercises[dayIndex] = selected;
      });
    }
  }

  void _showImportDialog(BuildContext context) {
    final shareCodeController = TextEditingController();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final palette =
        theme.extension<CorelyColors>() ??
        (theme.brightness == Brightness.dark
            ? AppTheme.darkColors
            : AppTheme.lightColors);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: palette.surface,
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: palette.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: palette.accent.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Icon(
                      Icons.download_rounded,
                      color: palette.accent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Import Plan',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Paste the share code you received:',
                style: TextStyle(color: palette.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: shareCodeController,
                style: TextStyle(color: palette.textPrimary, fontSize: 13),
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Paste share code here...',
                  hintStyle: TextStyle(color: palette.textMuted),
                  filled: true,
                  fillColor: palette.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: palette.surfaceRaised,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: palette.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        final dialogContext = context;
                        final code = shareCodeController.text.trim();
                        if (code.isEmpty) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a share code'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        try {
                          final importedPlan = PlanShareService.decodeShareCode(
                            code,
                          );
                          if (importedPlan == null) {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('Failed to decode share code'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          Navigator.pop(dialogContext);
                          setState(() {
                            _nameController.text = importedPlan.title;
                            _selectedDays = Set.from(
                              importedPlan.selectedDays.isNotEmpty
                                  ? importedPlan.selectedDays
                                  : weekdays.take(3),
                            );
                            _dayNameControllers.clear();
                            for (var i = 0; i < _selectedDays.length; i++) {
                              final dayName = i < importedPlan.dayNames.length
                                  ? importedPlan.dayNames[i]
                                  : '';
                              _dayNameControllers.add(
                                TextEditingController(text: dayName),
                              );
                            }
                            _dayExercises = [];
                            for (final dayExerciseList
                                in importedPlan.dayExercises) {
                              if (dayExerciseList is List) {
                                _dayExercises.add(
                                  dayExerciseList
                                      .map(
                                        (e) => Exercise.fromJson(
                                          Map<String, dynamic>.from(
                                            e as Map<dynamic, dynamic>,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                );
                              } else {
                                _dayExercises.add([]);
                              }
                            }
                          });
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                'Plan "${importedPlan.title}" imported successfully!',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                'Invalid share code: ${e.toString()}',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: palette.accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Import',
                        style: TextStyle(
                          color: palette.background,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette =
        theme.extension<CorelyColors>() ??
        (theme.brightness == Brightness.dark
            ? AppTheme.darkColors
            : AppTheme.lightColors);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: palette.border),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: palette.textPrimary,
              size: 14,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existingPlan != null ? 'EDITING' : 'NEW',
              style: TextStyle(
                color: palette.accent,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
            ),
            Text(
              widget.existingPlan != null ? 'EDIT PLAN' : 'CREATE PLAN',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                height: 1,
              ),
            ),
          ],
        ),
        actions: [
          if (widget.existingPlan == null)
            Container(
              margin: const EdgeInsets.only(right: 16),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: palette.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: palette.accent.withValues(alpha: 0.45),
                ),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.download_rounded,
                  color: palette.accent,
                  size: 18,
                ),
                tooltip: 'Import Plan',
                onPressed: () => _showImportDialog(context),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Plan name ──────────────────────────────────────
            _sectionLabel(context, 'Plan name'),
            Container(
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: palette.border),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(Icons.edit_rounded, color: palette.textMuted, size: 15),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. Push / Pull / Legs',
                        hintStyle: TextStyle(color: palette.textMuted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Cover photo ────────────────────────────────────
            _sectionLabel(context, 'Cover photo'),
            Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: palette.border),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: _imagePath != null
                      ? Image.file(File(_imagePath!), fit: BoxFit.cover)
                      : Icon(
                          Icons.image_outlined,
                          color: palette.textMuted,
                          size: 26,
                        ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final xfile = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 85,
                        );
                        if (xfile != null) {
                          setState(() => _imagePath = xfile.path);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: palette.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _imagePath == null ? 'Add photo' : 'Change photo',
                          style: TextStyle(
                            color: palette.background,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (_imagePath != null) ...[
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => setState(() => _imagePath = null),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            'Remove',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Workout days ───────────────────────────────────
            _sectionLabel(context, 'Workout days'),
            Row(
              children: weekdays.map((day) {
                final isSelected = _selectedDays.contains(day);
                final abbr = day.substring(0, 3);
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedDays.remove(day);
                          final dayIndex = weekdays.indexOf(day);
                          int ci = 0;
                          for (final sd in _selectedDays.toList()) {
                            if (weekdays.indexOf(sd) >= dayIndex) break;
                            ci++;
                          }
                          if (ci < _dayNameControllers.length) {
                            _dayNameControllers[ci].dispose();
                            _dayNameControllers.removeAt(ci);
                          }
                          if (ci < _dayExercises.length) {
                            _dayExercises.removeAt(ci);
                          }
                        } else {
                          _selectedDays.add(day);
                          _dayNameControllers.add(
                            TextEditingController(text: day),
                          );
                          _dayExercises.add([]);
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? palette.accent.withValues(alpha: 0.12)
                            : palette.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? palette.accent.withValues(alpha: 0.45)
                              : palette.border,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            abbr.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: isSelected
                                  ? palette.accent
                                  : palette.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? palette.accent
                                  : Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            _sectionLabel(context, 'Day exercises'),
            const SizedBox(height: 8),

            // ── Day Navigation with Arrows ─────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left Arrow
                GestureDetector(
                  onTap: _currentDayIndex > 0
                      ? () => setState(() => _currentDayIndex--)
                      : null,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _currentDayIndex > 0
                          ? palette.accent
                          : palette.surfaceRaised,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: _currentDayIndex > 0
                          ? palette.background
                          : palette.textMuted,
                      size: 18,
                    ),
                  ),
                ),

                // Day Name
                Expanded(
                  child: Center(
                    child: Text(
                      _selectedDays.isNotEmpty
                          ? _selectedDays.toList()[_currentDayIndex]
                          : 'No days',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // Right Arrow
                GestureDetector(
                  onTap: _currentDayIndex < _selectedDays.length - 1
                      ? () => setState(() => _currentDayIndex++)
                      : null,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _currentDayIndex < _selectedDays.length - 1
                          ? palette.accent
                          : palette.surfaceRaised,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: _currentDayIndex < _selectedDays.length - 1
                          ? palette.background
                          : palette.textMuted,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Current Day Card ────────────────────────────────
            Expanded(
              child: _selectedDays.isEmpty
                  ? Center(
                      child: Text(
                        'Select workout days to add exercises',
                        style: TextStyle(
                          color: palette.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        // Day Header
                        Container(
                          decoration: BoxDecoration(
                            color: palette.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: palette.border),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: palette.accent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${_currentDayIndex + 1}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: palette.background,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedDays.toList()[_currentDayIndex],
                                      style: TextStyle(
                                        color: palette.textMuted,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${_dayExercises[_currentDayIndex].length} exercise${_dayExercises[_currentDayIndex].length != 1 ? 's' : ''}',
                                      style: TextStyle(
                                        color: palette.accent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  controller:
                                      _dayNameControllers[_currentDayIndex],
                                  style: TextStyle(
                                    color: palette.textPrimary,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    hintText: _selectedDays
                                        .toList()[_currentDayIndex],
                                    hintStyle: TextStyle(
                                      color: palette.textMuted,
                                      fontSize: 12,
                                    ),
                                    filled: true,
                                    fillColor: palette.inputFill,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Large Add Button
                        Expanded(
                          child: _dayExercises[_currentDayIndex].isEmpty
                              ? GestureDetector(
                                  onTap: () => _editDay(_currentDayIndex),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: palette.textMuted,
                                              width: 2,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.add,
                                            color: palette.textMuted,
                                            size: 40,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Add exercises for this day',
                                          style: TextStyle(
                                            color: palette.textMuted,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Column(
                                  children: [
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount:
                                            _dayExercises[_currentDayIndex]
                                                .length,
                                        itemBuilder: (context, idx) {
                                          final exercise =
                                              _dayExercises[_currentDayIndex][idx];
                                          return Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: palette.surfaceRaised,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: palette.border,
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  exercise.name,
                                                  style: TextStyle(
                                                    color: palette.textPrimary,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${exercise.target} • ${exercise.equipment}',
                                                  style: TextStyle(
                                                    color: palette.textMuted,
                                                    fontSize: 11,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    GestureDetector(
                                      onTap: () => _editDay(_currentDayIndex),
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: palette.accent,
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          color: palette.accent,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 12),

            // ── Save button ────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (_nameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a plan name'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  if (_selectedDays.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select at least one workout day'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  int totalExercises = 0;
                  for (final de in _dayExercises) {
                    totalExercises += de.length;
                  }
                  if (totalExercises == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please add at least one exercise'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  final difficulty = (totalExercises / 5).ceil().clamp(1, 5);
                  final exercisesList = totalExercises == 1
                      ? '1 exercise'
                      : '$totalExercises exercises';
                  final dayExercisesJson = _dayExercises
                      .map((dl) => dl.map((e) => e.toJson()).toList())
                      .toList();
                  final dayNames = _dayNameControllers
                      .map((c) => c.text)
                      .toList();
                  final plan = WorkoutPlan(
                    title: _nameController.text,
                    duration: '${_selectedDays.length * 5} mins',
                    exercises: exercisesList,
                    imageAsset: 'assets/img/logo_light.png',
                    imagePath: _imagePath,
                    difficulty: difficulty,
                    dayExercises: dayExercisesJson,
                    dayNames: dayNames,
                    selectedDays: _selectedDays.toList(),
                  );
                  if (widget.existingPlan != null && widget.planIndex != null) {
                    await LocalPlanService.deletePlan(widget.planIndex!);
                    await LocalPlanService.savePlan(plan);
                  } else {
                    await LocalPlanService.savePlan(plan);
                  }
                  if (mounted) {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context, true);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          widget.existingPlan != null
                              ? '${_nameController.text} updated successfully!'
                              : '${_nameController.text} saved successfully!',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.existingPlan != null ? 'UPDATE PLAN' : 'SAVE PLAN',
                      style: TextStyle(
                        color: palette.background,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: palette.surfaceRaised,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.arrow_outward_rounded,
                        color: palette.textPrimary,
                        size: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    final theme = Theme.of(context);
    final palette =
        theme.extension<CorelyColors>() ??
        (theme.brightness == Brightness.dark
            ? AppTheme.darkColors
            : AppTheme.lightColors);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: palette.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
