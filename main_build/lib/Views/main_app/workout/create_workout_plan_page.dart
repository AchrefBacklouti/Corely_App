import 'package:flutter/material.dart';
import 'package:main_build/Models/exercise.dart';
import 'package:main_build/Theme/app_theme.dart';
import 'package:main_build/Views/main_app/workout/widgets/filter_widgets.dart';
import 'package:main_build/data/exercise_cache_service.dart';

class CreateWorkoutPlanPage extends StatefulWidget {
  const CreateWorkoutPlanPage({super.key});

  @override
  State<CreateWorkoutPlanPage> createState() => _CreateWorkoutPlanPageState();
}

class _CreateWorkoutPlanPageState extends State<CreateWorkoutPlanPage> {
  late Future<List<Exercise>> _exercisesFuture;
  String _search = '';
  String _bodyPartFilter = 'all';
  String _equipmentFilter = 'all';
  List<Exercise>? _cachedExercises;

  @override
  void initState() {
    super.initState();
    _exercisesFuture = _fetchExercises();
  }

  Future<List<Exercise>> _fetchExercises({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedExercises != null) {
      return _cachedExercises!;
    }

    final exercises = await ExerciseCacheService.getExercises(
      forceRefresh: forceRefresh,
    );
    _cachedExercises = exercises;
    return exercises;
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
        title: Text(
          "Create Workout Plan",
          style: TextStyle(color: palette.textPrimary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add exercises",
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (value) =>
                  setState(() => _search = value.toLowerCase()),
              style: TextStyle(color: palette.textPrimary),
              decoration: InputDecoration(
                hintText: "Search exercises or equipment",
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
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _exercisesFuture = _fetchExercises(forceRefresh: true);
                  });
                },
                icon: Icon(Icons.wifi, color: palette.accent),
                label: Text(
                  "Fetch from API",
                  style: TextStyle(color: palette.accent),
                ),
                style: TextButton.styleFrom(foregroundColor: palette.accent),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Exercise>>(
                future: _exercisesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Unable to load exercises",
                        style: TextStyle(color: palette.textSecondary),
                      ),
                    );
                  }
                  final exercises = snapshot.data ?? [];
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

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final ex = filtered[index];
                      return GestureDetector(
                        onTap: () {
                          _showExerciseDetails(context, ex);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: palette.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: palette.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(14),
                                    topRight: Radius.circular(14),
                                  ),
                                  child: Container(
                                    color: palette.surfaceRaised,
                                    child: ex.gifUrl != null
                                        ? Image.network(
                                            ex.gifUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Center(
                                                  child: Icon(
                                                    Icons.fitness_center,
                                                    color: palette.accent,
                                                    size: 36,
                                                  ),
                                                ),
                                          )
                                        : Center(
                                            child: Icon(
                                              Icons.fitness_center,
                                              color: palette.accent,
                                              size: 36,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ex.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: palette.textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      ex.target,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: palette.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
      ),
    );
  }

  void _showExerciseDetails(BuildContext context, Exercise exercise) {
    final theme = Theme.of(context);
    final palette =
        theme.extension<CorelyColors>() ??
        (theme.brightness == Brightness.dark
            ? AppTheme.darkColors
            : AppTheme.lightColors);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: palette.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          exercise.name,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close, color: palette.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (exercise.gifUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        exercise.gifUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: palette.surfaceRaised,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.fitness_center,
                              color: palette.accent,
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: palette.surfaceRaised,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.fitness_center,
                          color: palette.accent,
                          size: 48,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 20),
                  if (exercise.instructions.isNotEmpty) ...[
                    Text(
                      "Instructions",
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 16,
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
                                    style: TextStyle(
                                      color: palette.textSecondary,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      step,
                                      style: TextStyle(
                                        color: palette.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, exercise);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.accent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Add to Plan",
                        style: TextStyle(
                          color: palette.background,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailPill(BuildContext context, String text) {
    final theme = Theme.of(context);
    final palette =
        theme.extension<CorelyColors>() ??
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
        style: TextStyle(color: palette.textSecondary, fontSize: 13),
      ),
    );
  }
}
