import 'package:flutter/material.dart';
import 'package:main_build/Models/exercise.dart';
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
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF0F1115),
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
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          color: Colors.yellow,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  exercise.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _detailPill('Body Part: ${exercise.bodyPart}'),
                    _detailPill('Target: ${exercise.target}'),
                    _detailPill('Equipment: ${exercise.equipment}'),
                    if ((exercise.force ?? '').isNotEmpty)
                      _detailPill('Force: ${exercise.force}'),
                    if ((exercise.level ?? '').isNotEmpty)
                      _detailPill('Level: ${exercise.level}'),
                    if ((exercise.mechanic ?? '').isNotEmpty)
                      _detailPill('Mechanic: ${exercise.mechanic}'),
                    if (exercise.secondaryMuscles.isNotEmpty)
                      _detailPill(
                        'Secondary: ${exercise.secondaryMuscles.join(', ')}',
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (exercise.instructions.isNotEmpty) ...[
                  const Text(
                    "Instructions",
                    style: TextStyle(
                      color: Colors.white,
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
                                const Text(
                                  '\u2022 ',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                Expanded(
                                  child: Text(
                                    step,
                                    style: const TextStyle(
                                      color: Colors.white70,
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
                    child: const Text(
                      'Close',
                      style: TextStyle(color: Colors.yellow),
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

  Widget _detailPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
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
          'Day ${widget.dayIndex}',
          style: const TextStyle(color: Colors.white),
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
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search exercises",
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.yellow),
                    filled: true,
                    fillColor: const Color(0xFF1A1D23),
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
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.yellow),
                        SizedBox(height: 16),
                        Text(
                          'Loading exercises...',
                          style: TextStyle(color: Colors.white70),
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
                        const Text(
                          "Unable to load exercises",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white54,
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
                            backgroundColor: Colors.yellow,
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: Color(0xFF0F1115)),
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
                        const Icon(
                          Icons.fitness_center,
                          color: Colors.white24,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No exercises available",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Check your internet connection",
                          style: TextStyle(color: Colors.white54),
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
                            backgroundColor: Colors.yellow,
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: Color(0xFF0F1115)),
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
                  return const Center(
                    child: Text(
                      "No exercises found",
                      style: TextStyle(color: Colors.white70),
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
                          color: const Color(0xFF1A1D23),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.yellow : Colors.white12,
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
                              activeColor: Colors.yellow,
                              checkColor: const Color(0xFF0F1115),
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
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: exercise.gifUrl != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          exercise.gifUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Center(
                                                child: Icon(
                                                  Icons.fitness_center,
                                                  color: Colors.yellow,
                                                  size: 28,
                                                ),
                                              ),
                                        ),
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.fitness_center,
                                          color: Colors.yellow,
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
                                    style: const TextStyle(
                                      color: Colors.white,
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
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const Text(
                                        ' • ',
                                        style: TextStyle(color: Colors.white54),
                                      ),
                                      Text(
                                        exercise.equipment,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white70,
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
                  backgroundColor: Colors.white12,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.white,
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
                  backgroundColor: Colors.yellow,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Add ${_selectedIds.length}',
                  style: const TextStyle(
                    color: Color(0xFF0F1115),
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
