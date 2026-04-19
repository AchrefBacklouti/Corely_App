import 'package:flutter/material.dart';
import 'package:main_build/Models/exercise.dart';
import 'package:main_build/Theme/app_theme.dart';
import 'package:main_build/Views/main_app/workout/widgets/filter_widgets.dart';
import 'package:main_build/data/exercise_cache_service.dart';

class EditDayPage extends StatefulWidget {
  final int dayIndex;
  final List<Exercise> currentExercises;

  const EditDayPage({
    super.key,
    required this.dayIndex,
    required this.currentExercises,
  });

  @override
  State<EditDayPage> createState() => _EditDayPageState();
}

class _EditDayPageState extends State<EditDayPage> {
  late Future<List<Exercise>> _exercisesFuture;
  String _search = '';
  String _bodyPartFilter = 'all';
  String _equipmentFilter = 'all';
  List<Exercise>? _cachedExercises;
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.currentExercises.map((e) => e.id));
    _exercisesFuture = _fetchExercises();
  }

  Future<List<Exercise>> _fetchExercises({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedExercises != null) {
      debugPrint(
        'EditDayPage: Using cached ${_cachedExercises!.length} exercises',
      );
      return _cachedExercises!;
    }

    debugPrint('EditDayPage: Loading exercises from cache/API');
    final exercises = await ExerciseCacheService.getExercises(
      forceRefresh: forceRefresh,
    );
    _cachedExercises = exercises;
    debugPrint(
      'EditDayPage: Successfully loaded ${exercises.length} exercises',
    );
    return exercises;
  }

  void _toggleSelection(String exerciseId) {
    setState(() {
      if (_selectedIds.contains(exerciseId)) {
        _selectedIds.remove(exerciseId);
      } else {
        _selectedIds.add(exerciseId);
      }
    });
  }

  void _showExerciseDetails(BuildContext context, Exercise exercise) {
    final theme = Theme.of(context);
    final palette = theme.extension<CorelyColors>() ??
        (theme.brightness == Brightness.dark
            ? AppTheme.darkColors
            : AppTheme.lightColors);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: palette.surface,
        insetPadding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (exercise.gifUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      exercise.gifUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 180,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: palette.surfaceRaised,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.fitness_center,
                          color: palette.accent,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  exercise.name,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _detailPill(context, 'Body Part: ${exercise.bodyPart}'),
                    _detailPill(context, 'Target: ${exercise.target}'),
                    _detailPill(context, 'Equipment: ${exercise.equipment}'),
                    if ((exercise.force ?? '').isNotEmpty)
                      _detailPill(context, 'Force: ${exercise.force}'),
                    if ((exercise.level ?? '').isNotEmpty)
                      _detailPill(context, 'Level: ${exercise.level}'),
                    if ((exercise.mechanic ?? '').isNotEmpty)
                      _detailPill(context, 'Mechanic: ${exercise.mechanic}'),
                    if (exercise.secondaryMuscles.isNotEmpty)
                      _detailPill(
                        context,
                        'Secondary: ${exercise.secondaryMuscles.join(', ')}',
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (exercise.instructions.isNotEmpty) ...[
                  Text(
                    "Instructions",
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: exercise.instructions
                        .map(
                          (step) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '\u2022 ',
                                  style: TextStyle(color: palette.textSecondary),
                                ),
                                Expanded(
                                  child: Text(
                                    step,
                                    style: TextStyle(
                                      color: palette.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Close',
                      style: TextStyle(color: palette.accent),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailPill(BuildContext context, String text) {
    final theme = Theme.of(context);
    final palette = theme.extension<CorelyColors>() ??
        (theme.brightness == Brightness.dark
            ? AppTheme.darkColors
            : AppTheme.lightColors);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: palette.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Text(
        text,
        style: TextStyle(color: palette.textSecondary, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<CorelyColors>() ??
        (theme.brightness == Brightness.dark
            ? AppTheme.darkColors
            : AppTheme.lightColors);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        title: Text(
          'Day ${widget.dayIndex}',
          style: TextStyle(color: palette.textPrimary),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (value) =>
                      setState(() => _search = value.toLowerCase()),
                  style: TextStyle(color: palette.textPrimary),
                  decoration: InputDecoration(
                    hintText: "Search exercises",
                    hintStyle: TextStyle(color: palette.textMuted),
                    prefixIcon: Icon(Icons.search, color: palette.accent),
                    filled: true,
                    fillColor: palette.inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Filters(
                  onBodyPartChanged: (value) =>
                      setState(() => _bodyPartFilter = value),
                  onEquipmentChanged: (value) =>
                      setState(() => _equipmentFilter = value),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Exercise>>(
              future: _exercisesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: palette.accent),
                        SizedBox(height: 16),
                        Text(
                          'Loading exercises...',
                          style: TextStyle(color: palette.textSecondary),
                        ),
                      ],
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Unable to load exercises",
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: palette.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _exercisesFuture = _fetchExercises(
                                forceRefresh: true,
                              );
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: palette.accent,
                          ),
                          child: Text(
                            'Retry',
                            style: TextStyle(color: palette.background),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final exercises = snapshot.data ?? [];

                if (exercises.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          color: palette.textMuted,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No exercises available",
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Check your internet connection",
                          style: TextStyle(color: palette.textMuted),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _exercisesFuture = _fetchExercises(
                                forceRefresh: true,
                              );
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: palette.accent,
                          ),
                          child: Text(
                            'Retry',
                            style: TextStyle(color: palette.background),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final filtered = exercises.where((e) {
                  final haystack =
                      '${e.name} ${e.equipment} ${e.bodyPart} ${e.target}'
                          .toLowerCase();
                  final matchesSearch = _search.isEmpty
                      ? true
                      : haystack.contains(_search);
                  final matchesBody = _bodyPartFilter == 'all'
                      ? true
                      : e.bodyPart.toLowerCase() == _bodyPartFilter;
                  final matchesEquip = _equipmentFilter == 'all'
                      ? true
                      : e.equipment.toLowerCase() == _equipmentFilter;
                  return matchesSearch && matchesBody && matchesEquip;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      "No exercises found",
                      style: TextStyle(color: palette.textSecondary),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final exercise = filtered[index];
                    final isSelected = _selectedIds.contains(exercise.id);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: palette.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? palette.accent : palette.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Checkbox
                            Checkbox(
                              value: isSelected,
                              onChanged: (_) {
                                _toggleSelection(exercise.id);
                              },
                              activeColor: palette.accent,
                              checkColor: palette.background,
                            ),
                            // Exercise image/icon
                            GestureDetector(
                              onTap: () =>
                                  _showExerciseDetails(context, exercise),
                              child: Container(
                                width: 60,
                                height: 60,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: palette.surfaceRaised,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: exercise.gifUrl != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          exercise.gifUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Center(
                                                child: Icon(
                                                  Icons.fitness_center,
                                                  color: palette.accent,
                                                  size: 28,
                                                ),
                                              ),
                                        ),
                                      )
                                    : Center(
                                        child: Icon(
                                          Icons.fitness_center,
                                          color: palette.accent,
                                          size: 28,
                                        ),
                                      ),
                              ),
                            ),
                            // Exercise info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: palette.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        exercise.target,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: palette.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        ' • ',
                                        style: TextStyle(color: palette.textMuted),
                                      ),
                                      Text(
                                        exercise.equipment,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: palette.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.surfaceRaised,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_cachedExercises == null) {
                    Navigator.pop(context);
                    return;
                  }
                  final selectedExercises = _cachedExercises!
                      .where((e) => _selectedIds.contains(e.id))
                      .toList();
                  Navigator.pop(context, selectedExercises);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.accent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Add ${_selectedIds.length}',
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
      ),
    );
  }
}
