import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:main_build/Theme/app_theme.dart';
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
  bool _showCustom = false;
  bool _squareLayout = true;
  List<WorkoutPlan> _customPlans = [];
  List<WorkoutPlan> _suggestedPlans = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final results = await Future.wait([
        DataService.getCustomWorkoutPlans(),
        DataService.getSuggestedWorkoutPlans(),
      ]);

      if (!mounted) return;
      setState(() {
        _customPlans = results[0];
        _suggestedPlans = results[1];
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Unable to load training plans right now.';
      });
    }
  }

  void _showPlanMenu(BuildContext pageContext, WorkoutPlan plan, int index) {
    final theme = Theme.of(pageContext);
    final palette =
        theme.extension<CorelyColors>() ??
        (theme.brightness == Brightness.dark
            ? AppTheme.darkColors
            : AppTheme.lightColors);

    showGeneralDialog<void>(
      context: pageContext,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(
        pageContext,
      ).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: palette.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.54),
                        blurRadius: 30,
                        offset: Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 54,
                        height: 5,
                        decoration: BoxDecoration(
                          color: palette.border,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        plan.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Choose an action',
                        style: TextStyle(
                          color: palette.textMuted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          _CircleMenuAction(
                            icon: Icons.play_arrow_rounded,
                            label: 'Play',
                            color: Colors.greenAccent,
                            onTap: () {
                              Navigator.pop(dialogContext);
                              Navigator.push(
                                pageContext,
                                MaterialPageRoute(
                                  builder: (_) => PlayPlanPage(plan: plan),
                                ),
                              );
                            },
                          ),
                          _CircleMenuAction(
                            icon: Icons.edit_rounded,
                            label: 'Edit',
                            color: Colors.yellow,
                            onTap: () async {
                              Navigator.pop(dialogContext);
                              final result = await Navigator.push(
                                pageContext,
                                MaterialPageRoute(
                                  builder: (_) => EditPlanPage(
                                    existingPlan: plan,
                                    planIndex: index,
                                  ),
                                ),
                              );
                              if (result == true && mounted) {
                                await _loadData();
                              }
                            },
                          ),
                          _CircleMenuAction(
                            icon: Icons.share_rounded,
                            label: 'Share',
                            color: Colors.blueAccent,
                            onTap: () {
                              Navigator.pop(dialogContext);
                              _showShareDialog(pageContext, plan);
                            },
                          ),
                          _CircleMenuAction(
                            icon: Icons.delete_rounded,
                            label: 'Delete',
                            color: Colors.redAccent,
                            onTap: () async {
                              Navigator.pop(dialogContext);
                              final confirm = await showDialog<bool>(
                                context: pageContext,
                                builder: (confirmContext) => AlertDialog(
                                  backgroundColor: palette.surface,
                                  title: Text(
                                    'Delete Plan?',
                                    style: TextStyle(
                                      color: palette.textPrimary,
                                    ),
                                  ),
                                  content: Text(
                                    'Are you sure you want to delete "${plan.title}"?',
                                    style: TextStyle(
                                      color: palette.textSecondary,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(confirmContext, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(confirmContext, true),
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
                                await _loadData();
                                if (mounted) {
                                  ScaffoldMessenger.of(
                                    pageContext,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text('${plan.title} deleted'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        final scale = Tween<double>(begin: 0.92, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        );

        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(scale: scale, child: child),
        );
      },
    );
  }

  Widget _CircleMenuAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final palette =
        theme.extension<CorelyColors>() ??
        (theme.brightness == Brightness.dark
            ? AppTheme.darkColors
            : AppTheme.lightColors);

    return SizedBox(
      width: 108,
      child: InkResponse(
        onTap: onTap,
        radius: 44,
        splashColor: color.withValues(alpha: 0.2),
        highlightColor: color.withValues(alpha: 0.08),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.14),
                border: Border.all(
                  color: color.withValues(alpha: 0.45),
                  width: 1.2,
                ),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showShareDialog(BuildContext context, WorkoutPlan plan) {
    final shareCode = PlanShareService.generateShareCode(plan);
    final theme = Theme.of(context);
    final palette =
        theme.extension<CorelyColors>() ??
        (theme.brightness == Brightness.dark
            ? AppTheme.darkColors
            : AppTheme.lightColors);

    showModalBottomSheet(
      context: context,
      backgroundColor: palette.surface,
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
                color: palette.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Share Plan',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            // Share Code Display with Copy Button
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: palette.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: palette.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        shareCode,
                        style: TextStyle(
                          color: palette.textPrimary,
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
                    icon: Icon(Icons.copy, color: palette.accent),
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
                      backgroundColor: palette.accent,
                      foregroundColor: palette.background,
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
    final isDarkMode = theme.brightness == Brightness.dark;
    final palette =
        theme.extension<CorelyColors>() ??
        (isDarkMode ? AppTheme.darkColors : AppTheme.lightColors);

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: palette.accent));
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _loadError!,
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: palette.background,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
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
                  color: palette.accent,
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final palette =
        theme.extension<CorelyColors>() ??
        (isDarkMode ? AppTheme.darkColors : AppTheme.lightColors);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? palette.surfaceRaised : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? palette.accent : palette.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: palette.textPrimary,
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
    final palette =
        Theme.of(context).extension<CorelyColors>() ??
        (Theme.of(context).brightness == Brightness.dark
            ? AppTheme.darkColors
            : AppTheme.lightColors);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Custom plans",
          style: TextStyle(
            color: palette.textPrimary,
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
                        color: palette.accent.withValues(alpha: 0.08),
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
              color: palette.accent.withValues(alpha: 0.08),
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
    final palette =
        Theme.of(context).extension<CorelyColors>() ??
        (Theme.of(context).brightness == Brightness.dark
            ? AppTheme.darkColors
            : AppTheme.lightColors);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Suggestions",
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: palette.textPrimary),
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
                        color: palette.surfaceRaised,
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
              color: palette.surfaceRaised,
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final palette =
        theme.extension<CorelyColors>() ??
        (isDarkMode ? AppTheme.darkColors : AppTheme.lightColors);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: palette.border),
          color: palette.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: palette.accent),
            const SizedBox(width: 8),
            Text(
              "Add another plan",
              style: TextStyle(
                color: palette.textPrimary,
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
    final palette =
        Theme.of(context).extension<CorelyColors>() ??
        (Theme.of(context).brightness == Brightness.dark
            ? AppTheme.darkColors
            : AppTheme.lightColors);

    if (squareLayout) {
      return InkWell(
        onTap: onTap,
        child: Container(
          width: tileWidth ?? double.infinity,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.border),
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
                        Colors.black.withValues(alpha: 0.55),
                        Colors.black.withValues(alpha: 0.15),
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
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$duration · $exercises",
                        style: TextStyle(
                          color: palette.textSecondary,
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
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: palette.surfaceRaised,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.hardEdge,
              child: (imagePath != null && File(imagePath!).existsSync())
                  ? Image.file(File(imagePath!), fit: BoxFit.cover)
                  : (imageAsset != null
                        ? Image.asset(imageAsset!, fit: BoxFit.cover)
                        : const Icon(
                            Icons.fitness_center,
                            color: AppTheme.accent,
                          )),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "$duration · $exercises",
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: palette.textSecondary,
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
    final palette =
        Theme.of(context).extension<CorelyColors>() ??
        (Theme.of(context).brightness == Brightness.dark
            ? AppTheme.darkColors
            : AppTheme.lightColors);

    if (squareLayout) {
      return Container(
        width: tileWidth ?? double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.border),
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
                      Colors.black.withValues(alpha: 0.55),
                      Colors.black.withValues(alpha: 0.15),
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
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: palette.textSecondary,
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
                    backgroundColor: Colors.black.withValues(alpha: 0.45),
                    foregroundColor: palette.accent,
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
          Icon(Icons.local_fire_department, color: palette.accent),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: palette.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 6),
                _DifficultyIcons(level: difficulty),
              ],
            ),
          ),
          TextButton(
            onPressed: onAddPlan,
            child: Text(
              "Add",
              style: TextStyle(
                color: palette.accent,
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
    final palette =
        Theme.of(context).extension<CorelyColors>() ??
        (Theme.of(context).brightness == Brightness.dark
            ? AppTheme.darkColors
            : AppTheme.lightColors);

    final clamped = level.clamp(1, 4);
    return Row(
      children: List.generate(4, (index) {
        final isActive = index < clamped;
        return Icon(
          Icons.flash_on,
          size: 16,
          color: isActive ? palette.accent : palette.textMuted,
        );
      }),
    );
  }
}
