import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:main_build/Models/exercise.dart';
import 'package:main_build/Theme/app_theme.dart';
import 'package:main_build/data/exercise_cache_service.dart';

class ExerciseVisibilityPage extends StatefulWidget {
  const ExerciseVisibilityPage({super.key});

  @override
  State<ExerciseVisibilityPage> createState() => _ExerciseVisibilityPageState();
}

class _ExerciseVisibilityPageState extends State<ExerciseVisibilityPage> {
  List<Exercise> _allExercises = const [];
  Set<String> _visibleIds = <String>{};
  String _search = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait<dynamic>([
        ExerciseCacheService.getExercises(
          limit: 800,
          ignoreVisibilityFilter: true,
        ),
        ExerciseCacheService.getVisibleExerciseIds(),
      ]);
      if (!mounted) return;
      setState(() {
        _allExercises = (results[0] as List<Exercise>);
        _visibleIds = (results[1] as Set<String>);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _saveSelection() async {
    await ExerciseCacheService.setVisibleExerciseIds(_visibleIds);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _showAll() async {
    await ExerciseCacheService.clearVisibleExerciseIds();
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  List<Exercise> get _selectedExercises =>
      _orderedExercises.where((e) => _visibleIds.contains(e.id)).toList();

  List<Exercise> get _orderedExercises {
    final list = [..._allExercises];
    list.sort((a, b) {
      final aHasImage = (a.gifUrl ?? '').trim().isNotEmpty;
      final bHasImage = (b.gifUrl ?? '').trim().isNotEmpty;
      if (aHasImage == bHasImage) return a.name.compareTo(b.name);
      return aHasImage ? -1 : 1;
    });
    return list;
  }

  String _buildExportText({required bool selectedOnly}) {
    final list = selectedOnly ? _selectedExercises : _orderedExercises;
    final buffer = StringBuffer();
    for (final ex in list) {
      buffer.writeln('${ex.id} | ${ex.name}');
    }
    return buffer.toString().trim();
  }

  Future<void> _showExportDialog({required bool selectedOnly}) async {
    final theme = Theme.of(context);
    final palette =
        theme.extension<CorelyColors>() ??
        (theme.brightness == Brightness.dark
            ? AppTheme.darkColors
            : AppTheme.lightColors);

    final text = _buildExportText(selectedOnly: selectedOnly);
    if (text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No items to export yet.')));
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: palette.surface,
          title: Text(
            selectedOnly ? 'Selected Exercises' : 'All Exercises',
            style: TextStyle(color: palette.textPrimary),
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: SelectableText(
                text,
                style: TextStyle(color: palette.textSecondary, fontSize: 13),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Close', style: TextStyle(color: palette.textMuted)),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: text));
                if (!mounted) return;
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard.')),
                );
              },
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Copy'),
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.accent,
                foregroundColor: palette.background,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changeAdminPin() async {
    final theme = Theme.of(context);
    final palette =
        theme.extension<CorelyColors>() ??
        (theme.brightness == Brightness.dark
            ? AppTheme.darkColors
            : AppTheme.lightColors);

    final pinController = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: palette.surface,
          title: Text(
            'Change Admin PIN',
            style: TextStyle(color: palette.textPrimary),
          ),
          content: TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            style: TextStyle(color: palette.textPrimary),
            decoration: InputDecoration(
              hintText: 'New PIN',
              hintStyle: TextStyle(color: palette.textMuted),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('Cancel', style: TextStyle(color: palette.textMuted)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.accent,
                foregroundColor: palette.background,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (saved == true && pinController.text.trim().isNotEmpty) {
      await ExerciseCacheService.setAdminPin(pinController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Admin PIN updated.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette =
        theme.extension<CorelyColors>() ??
        (theme.brightness == Brightness.dark
            ? AppTheme.darkColors
            : AppTheme.lightColors);

    final filtered = _orderedExercises.where((e) {
      if (_search.isEmpty) return true;
      final text = '${e.name} ${e.bodyPart} ${e.target} ${e.equipment}'
          .toLowerCase();
      return text.contains(_search);
    }).toList();

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        title: Text(
          'Visible Exercises',
          style: TextStyle(color: palette.textPrimary),
        ),
        actions: [
          IconButton(
            onPressed: () => _showExportDialog(selectedOnly: true),
            icon: Icon(Icons.list_alt, color: palette.accent),
            tooltip: 'Copy selected list',
          ),
          IconButton(
            onPressed: _showAll,
            icon: Icon(Icons.visibility, color: palette.accent),
            tooltip: 'Show all',
          ),
          IconButton(
            onPressed: _changeAdminPin,
            icon: Icon(Icons.lock_reset, color: palette.accent),
            tooltip: 'Change admin PIN',
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: palette.accent))
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  _error!,
                  style: TextStyle(color: palette.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: (value) =>
                        setState(() => _search = value.toLowerCase()),
                    style: TextStyle(color: palette.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search exercise list',
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
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'Selected: ${_visibleIds.length}',
                        style: TextStyle(color: palette.textSecondary),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _showExportDialog(selectedOnly: false),
                        child: Text(
                          'Copy all',
                          style: TextStyle(color: palette.accent),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _visibleIds = filtered.map((e) => e.id).toSet();
                          });
                        },
                        child: Text(
                          'Select filtered',
                          style: TextStyle(color: palette.accent),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _visibleIds.clear();
                          });
                        },
                        child: Text(
                          'Clear',
                          style: TextStyle(color: palette.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No exercises match your search',
                            style: TextStyle(color: palette.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final ex = filtered[index];
                            final selected = _visibleIds.contains(ex.id);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: palette.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected
                                      ? palette.accent
                                      : palette.border,
                                ),
                              ),
                              child: CheckboxListTile(
                                value: selected,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      _visibleIds.add(ex.id);
                                    } else {
                                      _visibleIds.remove(ex.id);
                                    }
                                  });
                                },
                                title: Text(
                                  ex.name,
                                  style: TextStyle(color: palette.textPrimary),
                                ),
                                subtitle: Text(
                                  '${ex.bodyPart} • ${ex.target}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: palette.textSecondary,
                                  ),
                                ),
                                secondary: ex.gifUrl != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          ex.gifUrl!,
                                          width: 44,
                                          height: 44,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Icon(
                                            Icons.fitness_center,
                                            color: palette.accent,
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.fitness_center,
                                        color: palette.accent,
                                      ),
                                activeColor: palette.accent,
                                checkColor: palette.background,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _showAll,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: palette.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Show All',
                    style: TextStyle(color: palette.textPrimary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Save List',
                    style: TextStyle(
                      color: palette.background,
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
  }
}
