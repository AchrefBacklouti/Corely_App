import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:main_build/Views/main_app/workout/edit_plan_page.dart';
import 'package:main_build/Views/main_app/workout/play_plan_page.dart';
import 'package:main_build/data/workout_plans.dart';
import 'package:main_build/data/data_service.dart';
import 'package:main_build/data/local_plan_service.dart';
import 'package:main_build/data/plan_share_service.dart';
import 'dart:io';

class WorkoutPageContent extends StatefulWidget {
  const WorkoutPageContent({super.key});

  @override
  State<WorkoutPageContent> createState() => _WorkoutPageContentState();
}

class _WorkoutPageContentState extends State<WorkoutPageContent> {
  bool _showCustom = true;
  bool _squareLayout = false;
  List<WorkoutPlan> _customPlans = [];
  List<WorkoutPlan> _suggestedPlans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final custom = await DataService.getCustomWorkoutPlans();
    final suggested = await DataService.getSuggestedWorkoutPlans();
    setState(() {
      _customPlans = custom;
      _suggestedPlans = suggested;
      _isLoading = false;
    });
  }

  void _showPlanMenu(BuildContext context, WorkoutPlan plan, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1D23),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              plan.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.play_arrow, color: Colors.yellow),
              title: const Text(
                'Play',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PlayPlanPage(plan: plan)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.yellow),
              title: const Text(
                'Edit',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        EditPlanPage(existingPlan: plan, planIndex: index),
                  ),
                );
                if (result == true && mounted) {
                  _loadData();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.blue),
              title: const Text(
                'Share',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                _showShareDialog(context, plan);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1A1D23),
                    title: const Text(
                      'Delete Plan?',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: Text(
                      'Are you sure you want to delete "${plan.title}"?',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && mounted) {
                  await LocalPlanService.deletePlan(index);
                  _loadData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${plan.title} deleted'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showShareDialog(BuildContext context, WorkoutPlan plan) {
    final shareCode = PlanShareService.generateShareCode(plan);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1D23),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Share Plan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            // Share Code Display with Copy Button
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1115),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        shareCode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: shareCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Share code copied to clipboard!'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy, color: Colors.yellow),
                    tooltip: 'Copy Code',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Plan shared successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Row(
            children: [
              _TabButton(
                label: "Custom",
                isActive: _showCustom,
                onTap: () => setState(() => _showCustom = true),
              ),
              const SizedBox(width: 12),
              _TabButton(
                label: "Suggested",
                isActive: !_showCustom,
                onTap: () => setState(() => _showCustom = false),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  _squareLayout ? Icons.view_agenda_outlined : Icons.grid_view,
                  color: Colors.yellow,
                ),
                tooltip: _squareLayout ? "Rectangular cards" : "Square cards",
                onPressed: () => setState(() => _squareLayout = !_squareLayout),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
            child: _showCustom
                ? _CustomPlansSection(
                    plans: _customPlans,
                    theme: theme,
                    squareLayout: _squareLayout,
                    onAdd: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditPlanPage()),
                      );
                      // Refresh plans if one was saved
                      if (result == true) {
                        _loadData();
                      }
                    },
                    onPlanTap: (plan, index) {
                      _showPlanMenu(context, plan, index);
                    },
                  )
                : _SuggestedSection(
                    plans: _suggestedPlans,
                    squareLayout: _squareLayout,
                  ),
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white12 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? Colors.yellow : Colors.white24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CustomPlansSection extends StatelessWidget {
  final List<WorkoutPlan> plans;
  final ThemeData theme;
  final bool squareLayout;
  final VoidCallback onAdd;
  final Function(WorkoutPlan, int) onPlanTap;

  const _CustomPlansSection({
    required this.plans,
    required this.theme,
    required this.squareLayout,
    required this.onAdd,
    required this.onPlanTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Custom plans",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        if (squareLayout)
          LayoutBuilder(
            builder: (context, constraints) {
              final spacing = 12.0;
              final cardWidth = (constraints.maxWidth - spacing) / 2;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (var i = 0; i < plans.length; i++)
                    SizedBox(
                      width: cardWidth,
                      child: _WorkoutCard(
                        title: plans[i].title,
                        duration: plans[i].duration,
                        exercises: plans[i].exercises,
                        imageAsset: plans[i].imageAsset,
                        imagePath: plans[i].imagePath,
                        squareLayout: true,
                        color: theme.colorScheme.primary.withOpacity(0.08),
                        onTap: () => onPlanTap(plans[i], i),
                        tileWidth: cardWidth,
                      ),
                    ),
                ],
              );
            },
          )
        else ...[
          for (var i = 0; i < plans.length; i++) ...[
            _WorkoutCard(
              title: plans[i].title,
              duration: plans[i].duration,
              exercises: plans[i].exercises,
              imageAsset: plans[i].imageAsset,
              imagePath: plans[i].imagePath,
              squareLayout: false,
              color: theme.colorScheme.primary.withOpacity(0.08),
              onTap: () => onPlanTap(plans[i], i),
            ),
            const SizedBox(height: 12),
          ],
        ],
        const SizedBox(height: 14),
        _AddPlanCard(onTap: onAdd),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _SuggestedSection extends StatelessWidget {
  final List<WorkoutPlan> plans;
  final bool squareLayout;

  const _SuggestedSection({required this.plans, required this.squareLayout});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Suggestions",
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 12),
        if (squareLayout)
          LayoutBuilder(
            builder: (context, constraints) {
              final spacing = 12.0;
              final cardWidth = (constraints.maxWidth - spacing) / 2;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final plan in plans)
                    SizedBox(
                      width: cardWidth,
                      child: _SuggestedCard(
                        title: plan.title,
                        description: "${plan.duration} · ${plan.exercises}",
                        color: Colors.white.withOpacity(0.04),
                        imageAsset: plan.imageAsset,
                        squareLayout: true,
                        tileWidth: cardWidth,
                        difficulty: plan.difficulty,
                        plan: plan,
                        onAddPlan: () async {
                          await LocalPlanService.savePlan(plan);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${plan.title} added to your custom plans!',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                ],
              );
            },
          )
        else ...[
          for (final plan in plans) ...[
            _SuggestedCard(
              title: plan.title,
              description: "${plan.duration} · ${plan.exercises}",
              color: Colors.white.withOpacity(0.04),
              imageAsset: plan.imageAsset,
              squareLayout: false,
              difficulty: plan.difficulty,
              plan: plan,
              onAddPlan: () async {
                await LocalPlanService.savePlan(plan);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${plan.title} added to your custom plans!',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
          ],
        ],
        const SizedBox(height: 80),
      ],
    );
  }
}

class _AddPlanCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddPlanCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
          color: isDarkMode ? Colors.white10 : Colors.black12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add, color: Colors.yellow),
            SizedBox(width: 8),
            Text(
              "Add another plan",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final String title;
  final String duration;
  final String exercises;
  final String? imageAsset;
  final String? imagePath;
  final bool squareLayout;
  final double? tileWidth;
  final Color color;
  final VoidCallback onTap;

  const _WorkoutCard({
    required this.title,
    required this.duration,
    required this.exercises,
    required this.imageAsset,
    required this.imagePath,
    required this.squareLayout,
    this.tileWidth,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (squareLayout) {
      return InkWell(
        onTap: onTap,
        child: Container(
          width: tileWidth ?? double.infinity,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                if (imagePath != null && File(imagePath!).existsSync())
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(File(imagePath!), fit: BoxFit.cover),
                    ),
                  )
                else if (imageAsset != null)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(imageAsset!, fit: BoxFit.cover),
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.55),
                        Colors.black.withOpacity(0.15),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  bottom: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$duration · $exercises",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white12 : Colors.black12,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.hardEdge,
              child: (imagePath != null && File(imagePath!).existsSync())
                  ? Image.file(File(imagePath!), fit: BoxFit.cover)
                  : (imageAsset != null
                        ? Image.asset(imageAsset!, fit: BoxFit.cover)
                        : const Icon(
                            Icons.fitness_center,
                            color: Colors.yellow,
                          )),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "$duration · $exercises",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestedCard extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final String? imageAsset;
  final bool squareLayout;
  final double? tileWidth;
  final int difficulty;
  final WorkoutPlan? plan; // Added to support adding to custom
  final VoidCallback? onAddPlan; // Added callback for adding plan

  const _SuggestedCard({
    required this.title,
    required this.description,
    required this.color,
    required this.imageAsset,
    required this.squareLayout,
    this.tileWidth,
    required this.difficulty,
    this.plan,
    this.onAddPlan,
  });

  @override
  Widget build(BuildContext context) {
    if (squareLayout) {
      return Container(
        width: tileWidth ?? double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              if (imageAsset != null)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(imageAsset!, fit: BoxFit.cover),
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.55),
                      Colors.black.withOpacity(0.15),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                bottom: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DifficultyIcons(level: difficulty),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black45,
                    foregroundColor: Colors.yellow,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: onAddPlan,
                  child: const Text(
                    "Add",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: Colors.orange),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 6),
                _DifficultyIcons(level: difficulty),
              ],
            ),
          ),
          TextButton(
            onPressed: onAddPlan,
            child: const Text(
              "Add",
              style: TextStyle(
                color: Colors.yellow,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyIcons extends StatelessWidget {
  final int level;

  const _DifficultyIcons({required this.level});

  @override
  Widget build(BuildContext context) {
    final clamped = level.clamp(1, 4);
    return Row(
      children: List.generate(4, (index) {
        final isActive = index < clamped;
        return Icon(
          Icons.flash_on,
          size: 16,
          color: isActive ? Colors.yellow : Colors.white30,
        );
      }),
    );
  }
}
