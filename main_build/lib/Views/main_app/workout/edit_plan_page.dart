import 'package:flutter/material.dart';
import 'package:main_build/Models/exercise.dart';
import 'package:main_build/data/local_plan_service.dart';
import 'package:main_build/data/workout_plans.dart';
import 'package:main_build/data/plan_share_service.dart';
import 'package:main_build/Views/main_app/workout/edit_day_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditPlanPage extends StatefulWidget {
  final WorkoutPlan? existingPlan;
  final int? planIndex;

  const EditPlanPage({super.key, this.existingPlan, this.planIndex});

  @override
  State<EditPlanPage> createState() => _EditPlanPageState();
}

class _EditPlanPageState extends State<EditPlanPage> {
  final TextEditingController _nameController = TextEditingController();
  int _days = 3;
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
      // Pre-populate with existing plan data
      _nameController.text = widget.existingPlan!.title;
      _imagePath = widget.existingPlan!.imagePath;
      // Parse duration to get days (format: "15 mins" = 3 days)
      final durationInMinutes =
          int.tryParse(widget.existingPlan!.duration.split(' ').first) ?? 15;
      _days = (durationInMinutes / 5).ceil().clamp(1, 7);

      // Load selected days if available
      if (widget.existingPlan!.selectedDays.isNotEmpty) {
        _selectedDays = Set.from(widget.existingPlan!.selectedDays);
      } else {
        // Default to first N weekdays if not specified
        _selectedDays = Set.from(weekdays.take(_days));
      }

      // Initialize day name controllers
      for (var day in _selectedDays) {
        final dayIndex = weekdays.indexOf(day);
        final customName = dayIndex < widget.existingPlan!.dayNames.length
            ? widget.existingPlan!.dayNames[dayIndex]
            : day;
        _dayNameControllers.add(TextEditingController(text: customName));
      }

      // Load exercises from stored plan data
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
    } else {
      // Default to first 3 weekdays for new plan
      _selectedDays = Set.from(weekdays.take(3));
      for (int i = 0; i < 3; i++) {
        _dayNameControllers.add(TextEditingController(text: weekdays[i]));
      }
      _dayExercises = List.generate(_selectedDays.length, (_) => []);
      _imagePath = null;
    }
  }

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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D23),
        title: const Text(
          'Import Plan',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste the share code you received:',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: shareCodeController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Paste share code here...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF0F1115),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              final code = shareCodeController.text.trim();
              if (code.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a share code'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final importedPlan = PlanShareService.decodeShareCode(code);

                if (importedPlan == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to decode share code'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.pop(context);

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
                  for (final dayExerciseList in importedPlan.dayExercises) {
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

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Plan "${importedPlan.title}" imported successfully!',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Invalid share code: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Import', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1115),
        elevation: 0,
        title: Text(
          widget.existingPlan != null ? 'Edit Plan' : 'Create Plan',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (widget.existingPlan == null)
            IconButton(
              icon: const Icon(Icons.download, color: Colors.yellow),
              tooltip: 'Import Plan',
              onPressed: () => _showImportDialog(context),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Plan name',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF1A1D23),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1D23),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: _imagePath != null
                      ? Image.file(File(_imagePath!), fit: BoxFit.cover)
                      : const Icon(Icons.image, color: Colors.white54),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final xfile = await picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 85,
                          );
                          if (xfile != null) {
                            setState(() {
                              _imagePath = xfile.path;
                            });
                          }
                        },
                        icon: const Icon(Icons.photo_library),
                        label: Text(
                          _imagePath == null ? 'Add photo' : 'Change photo',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          foregroundColor: const Color(0xFF0F1115),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (_imagePath != null)
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _imagePath = null;
                            });
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          label: const Text(
                            'Remove',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Select workout days:',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: weekdays.map((day) {
                final isSelected = _selectedDays.contains(day);
                return FilterChip(
                  selected: isSelected,
                  label: Text(day.substring(0, 3)),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: const Color(0xFF1A1D23),
                  selectedColor: const Color(0xFF6366F1),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF6366F1)
                        : Colors.white12,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDays.add(day);
                        _dayNameControllers.add(
                          TextEditingController(text: day),
                        );
                        _dayExercises.add([]);
                      } else {
                        _selectedDays.remove(day);
                        // Find the correct index to remove
                        final dayIndex = weekdays.indexOf(day);
                        int controllerIndex = 0;
                        for (final selectedDay in _selectedDays.toList()) {
                          if (weekdays.indexOf(selectedDay) >= dayIndex) break;
                          controllerIndex++;
                        }
                        if (controllerIndex < _dayNameControllers.length) {
                          _dayNameControllers[controllerIndex].dispose();
                          _dayNameControllers.removeAt(controllerIndex);
                        }
                        if (controllerIndex < _dayExercises.length) {
                          _dayExercises.removeAt(controllerIndex);
                        }
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Exercises:',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: _selectedDays.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final selectedDaysList = _selectedDays.toList();
                  final day = selectedDaysList[index];
                  final exercises = index < _dayExercises.length
                      ? _dayExercises[index]
                      : <Exercise>[];

                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1D23),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    day,
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${exercises.length} exercises',
                                    style: const TextStyle(
                                      color: Colors.yellow,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 120,
                                child: TextField(
                                  controller: _dayNameControllers[index],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    hintText: day,
                                    hintStyle: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFF0F1115),
                                    contentPadding: const EdgeInsets.all(8),
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
                        Container(
                          width: double.infinity,
                          height: 1,
                          color: Colors.white12,
                        ),
                        GestureDetector(
                          onTap: () => _editDay(index),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (exercises.isEmpty)
                                  const Text(
                                    'Tap to add exercises',
                                    style: TextStyle(color: Colors.white54),
                                  )
                                else
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: exercises
                                        .take(3)
                                        .map(
                                          (exercise) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF6366F1,
                                              ).withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: const Color(
                                                  0xFF6366F1,
                                                ).withOpacity(0.5),
                                              ),
                                            ),
                                            child: Text(
                                              exercise.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
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

                  // Calculate total exercises and determine difficulty
                  int totalExercises = 0;
                  for (final dayExercises in _dayExercises) {
                    totalExercises += dayExercises.length;
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

                  // Convert exercises to JSON for storage
                  final dayExercisesJson = _dayExercises
                      .map((dayList) => dayList.map((e) => e.toJson()).toList())
                      .toList();

                  // Get day names from controllers
                  final dayNames = _dayNameControllers
                      .map((controller) => controller.text)
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
                    // Update existing plan
                    await LocalPlanService.deletePlan(widget.planIndex!);
                    await LocalPlanService.savePlan(plan);
                  } else {
                    // Create new plan
                    await LocalPlanService.savePlan(plan);
                  }

                  if (mounted) {
                    Navigator.pop(context, true);
                    ScaffoldMessenger.of(context).showSnackBar(
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
                  backgroundColor: Colors.yellow,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  widget.existingPlan != null ? 'Update plan' : 'Save plan',
                  style: const TextStyle(
                    color: Color(0xFF0F1115),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
