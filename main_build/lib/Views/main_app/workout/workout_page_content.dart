import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:main_build/Theme/app_theme.dart';
import 'package:main_build/Views/main_app/workout/edit_plan_page.dart';
import 'package:main_build/Views/main_app/workout/play_plan_page.dart';
import 'package:main_build/Views/main_app/workout/plan_detail_sheet.dart'; // ← import the shared sheet
import 'package:main_build/data/workout_plans.dart';
import 'package:main_build/data/data_service.dart';
import 'package:main_build/data/supabase_service.dart';
import 'package:main_build/data/exercise_cache_service.dart';
import 'package:main_build/data/local_plan_service.dart';
import 'package:main_build/data/plan_share_service.dart';
import 'dart:io';

// ─────────────────────────────────────────────
// Main page
// ─────────────────────────────────────────────
class WorkoutPageContent extends StatefulWidget {
  const WorkoutPageContent({super.key});

  @override
  State<WorkoutPageContent> createState() => _WorkoutPageContentState();
}

class _WorkoutPageContentState extends State<WorkoutPageContent> {
  bool _showCustom = false;
  bool _squareLayout = true;
  List<WorkoutPlan> _customPlans = [];
  List<WorkoutPlan> _suggestedPlans = kSuggestedPlans;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadData();
    _syncExercisesIfStale();
    LocalPlanService.plansChanged.addListener(_onPlansChanged);
  }

  void _onPlansChanged() {
    if (mounted) _loadData();
  }

  @override
  void dispose() {
    LocalPlanService.plansChanged.removeListener(_onPlansChanged);
    super.dispose();
  }

  Future<void> _syncExercisesIfStale() async {
    try {
      await ExerciseCacheService.refreshIfStale();
    } catch (_) {
      // Keep workout tab resilient; sync failures should not block UI.
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final results = await Future.wait([
        DataService.getCustomWorkoutPlans(),
        SupabaseService.getSuggestedPlans(), // Updated to fetch from Supabase
      ]);
      if (!mounted) return;
      debugPrint('Supabase suggested plans count: ${results[1].length}');
      setState(() {
        _customPlans = results[0];
        if (results[1].isNotEmpty) _suggestedPlans = results[1];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint('WorkoutPage._loadData: $e');
      setState(() {
        _isLoading = false;
        _loadError = 'Unable to load training plans right now.';
      });
    }
  }

  void _showPlanMenu(BuildContext pageContext, WorkoutPlan plan, int index) {
    final c = pageContext.colors;

    showGeneralDialog<void>(
      context: pageContext,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(
        pageContext,
      ).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, _, __) {
        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: c.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.54),
                        blurRadius: 30,
                        offset: const Offset(0, 18),
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
                          color: c.border,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        plan.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Choose an action',
                        style: TextStyle(color: c.textMuted, fontSize: 13),
                      ),
                      const SizedBox(height: 22),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          _CircleAction(
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
                          _CircleAction(
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
                              if (result == true && mounted) await _loadData();
                            },
                          ),
                          _CircleAction(
                            icon: Icons.share_rounded,
                            label: 'Share',
                            color: Colors.blueAccent,
                            onTap: () {
                              Navigator.pop(dialogContext);
                              _showShareDialog(pageContext, plan);
                            },
                          ),
                          _CircleAction(
                            icon: Icons.delete_rounded,
                            label: 'Delete',
                            color: Colors.redAccent,
                            onTap: () async {
                              Navigator.pop(dialogContext);
                              final confirm = await showDialog<bool>(
                                context: pageContext,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: c.surface,
                                  title: Text(
                                    'Delete Plan?',
                                    style: TextStyle(color: c.textPrimary),
                                  ),
                                  content: Text(
                                    'Are you sure you want to delete "${plan.title}"?',
                                    style: TextStyle(color: c.textSecondary),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.redAccent,
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
      transitionBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          ),
          child: child,
        ),
      ),
    );
  }

  void _showShareDialog(BuildContext context, WorkoutPlan plan) {
    final c = context.colors;
    final shareCode = PlanShareService.generateShareCode(plan);

    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Share Plan',
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        shareCode,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 12,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: shareCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share code copied!')),
                      );
                    },
                    icon: Icon(Icons.copy, color: c.accent),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Plan shared successfully')),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: c.accent));
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
                style: TextStyle(color: c.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
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
                label: 'Custom',
                isActive: _showCustom,
                onTap: () => setState(() => _showCustom = true),
              ),
              const SizedBox(width: 12),
              _TabButton(
                label: 'Suggested',
                isActive: !_showCustom,
                onTap: () => setState(() => _showCustom = false),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  _squareLayout ? Icons.view_agenda_outlined : Icons.grid_view,
                  color: c.accent,
                ),
                tooltip: _squareLayout ? 'List cards' : 'Grid cards',
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
                    squareLayout: _squareLayout,
                    onAdd: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditPlanPage()),
                      );
                      if (result == true) _loadData();
                    },
                    onPlanTap: _showPlanMenu,
                  )
                : _SuggestedSection(
                    plans: _suggestedPlans,
                    squareLayout: _squareLayout,
                    onPlanAdded: _loadData,
                  ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Circle action button (plan menu)
// ─────────────────────────────────────────────
class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
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
                color: c.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tab button
// ─────────────────────────────────────────────
class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? c.surfaceRaised : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? c.accent : c.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Custom plans section
// ─────────────────────────────────────────────
class _CustomPlansSection extends StatelessWidget {
  const _CustomPlansSection({
    required this.plans,
    required this.squareLayout,
    required this.onAdd,
    required this.onPlanTap,
  });
  final List<WorkoutPlan> plans;
  final bool squareLayout;
  final VoidCallback onAdd;
  final void Function(BuildContext, WorkoutPlan, int) onPlanTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custom plans',
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        if (squareLayout)
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 12.0;
              final cardWidth = (constraints.maxWidth - spacing) / 2;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (var i = 0; i < plans.length; i++)
                    SizedBox(
                      width: cardWidth,
                      child: _WorkoutCard(
                        plan: plans[i],
                        squareLayout: true,
                        tileWidth: cardWidth,
                        onTap: () => onPlanTap(context, plans[i], i),
                      ),
                    ),
                ],
              );
            },
          )
        else ...[
          for (var i = 0; i < plans.length; i++) ...[
            _WorkoutCard(
              plan: plans[i],
              squareLayout: false,
              onTap: () => onPlanTap(context, plans[i], i),
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

// ─────────────────────────────────────────────
// Suggested section
// ─────────────────────────────────────────────
class _SuggestedSection extends StatefulWidget {
  const _SuggestedSection({
    required this.plans,
    required this.squareLayout,
    required this.onPlanAdded,
  });
  final List<WorkoutPlan> plans;
  final bool squareLayout;
  final VoidCallback onPlanAdded;

  @override
  State<_SuggestedSection> createState() => _SuggestedSectionState();
}

class _SuggestedSectionState extends State<_SuggestedSection> {
  final Map<PlanCategory, String> _queries = {
    for (final cat in PlanCategory.values) cat: '',
  };
  final Map<PlanCategory, bool> _searchOpen = {
    for (final cat in PlanCategory.values) cat: false,
  };
  final Map<PlanCategory, TextEditingController> _controllers = {
    for (final cat in PlanCategory.values) cat: TextEditingController(),
  };

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<WorkoutPlan> _plansFor(PlanCategory cat) {
    final q = _queries[cat]!.toLowerCase();
    final all = widget.plans.where((p) => p.category == cat).toList();
    if (q.isEmpty) return all;
    return all
        .where(
          (p) =>
              p.title.toLowerCase().contains(q) ||
              (p.description?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  static const _catMeta = {
    PlanCategory.strength: (label: 'Strength', icon: Icons.fitness_center),
    PlanCategory.hypertrophy: (
      label: 'Hypertrophy',
      icon: Icons.accessibility_new_rounded,
    ),
    PlanCategory.cardio: (label: 'Cardio', icon: Icons.directions_run),
    PlanCategory.calisthenics: (
      label: 'Calisthenics',
      icon: Icons.self_improvement_rounded,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final cat in PlanCategory.values) ...[
          _CategorySection(
            category: cat,
            meta: _catMeta[cat]!,
            plans: _plansFor(cat),
            squareLayout: widget.squareLayout,
            searchOpen: _searchOpen[cat]!,
            controller: _controllers[cat]!,
            onSearchToggle: () => setState(() {
              _searchOpen[cat] = !_searchOpen[cat]!;
              if (!_searchOpen[cat]!) {
                _controllers[cat]!.clear();
                _queries[cat] = '';
              }
            }),
            onQueryChanged: (q) => setState(() => _queries[cat] = q),
            onPlanAdded: widget.onPlanAdded,
          ),
          const SizedBox(height: 32),
        ],
        const SizedBox(height: 60),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Single category block
// ─────────────────────────────────────────────
class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.meta,
    required this.plans,
    required this.squareLayout,
    required this.searchOpen,
    required this.controller,
    required this.onSearchToggle,
    required this.onQueryChanged,
    required this.onPlanAdded,
  });

  final PlanCategory category;
  final ({String label, IconData icon}) meta;
  final List<WorkoutPlan> plans;
  final bool squareLayout;
  final bool searchOpen;
  final TextEditingController controller;
  final VoidCallback onSearchToggle;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onPlanAdded;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: c.accentSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(meta.icon, color: c.accent, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              meta.label,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onSearchToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: searchOpen ? c.accentSoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: searchOpen ? c.accent : c.border),
                ),
                child: Icon(
                  searchOpen ? Icons.search_off : Icons.search,
                  color: searchOpen ? c.accent : c.textMuted,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: searchOpen
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextField(
                    controller: controller,
                    onChanged: onQueryChanged,
                    autofocus: true,
                    style: TextStyle(color: c.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search ${meta.label.toLowerCase()} plans…',
                      prefixIcon: Icon(
                        Icons.search,
                        color: c.textMuted,
                        size: 18,
                      ),
                      suffixIcon: controller.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: c.textMuted,
                                size: 16,
                              ),
                              onPressed: () {
                                controller.clear();
                                onQueryChanged('');
                              },
                            )
                          : null,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 14),
        if (plans.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No plans match your search.',
              style: TextStyle(color: c.textMuted, fontSize: 13),
            ),
          )
        else if (squareLayout)
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 12.0;
              final cardWidth = (constraints.maxWidth - spacing) / 2;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final plan in plans)
                    SizedBox(
                      width: cardWidth,
                      child: _SuggestedCard(
                        plan: plan,
                        squareLayout: true,
                        tileWidth: cardWidth,
                        onTap: () =>
                            _showPlanDetail(context, plan, onPlanAdded),
                        onAddPlan: () => _addPlan(context, plan, onPlanAdded),
                      ),
                    ),
                ],
              );
            },
          )
        else ...[
          for (final plan in plans) ...[
            _SuggestedCard(
              plan: plan,
              squareLayout: false,
              onTap: () => _showPlanDetail(context, plan, onPlanAdded),
              onAddPlan: () => _addPlan(context, plan, onPlanAdded),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }

  static Future<void> _addPlan(
    BuildContext context,
    WorkoutPlan plan,
    VoidCallback onDone,
  ) async {
    await LocalPlanService.savePlan(plan);
    onDone();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${plan.title} added to your plans!')),
      );
    }
  }

  // ← Now uses PlanDetailSheet from doc 2, which has the full copy-days flow
  static void _showPlanDetail(
    BuildContext context,
    WorkoutPlan plan,
    VoidCallback onPlanAdded,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlanDetailSheet(plan: plan, onPlanAdded: onPlanAdded),
    );
  }
}

// ─────────────────────────────────────────────
// Suggested plan card
// ─────────────────────────────────────────────
class _SuggestedCard extends StatelessWidget {
  const _SuggestedCard({
    required this.plan,
    required this.squareLayout,
    this.tileWidth,
    required this.onTap,
    required this.onAddPlan,
  });

  final WorkoutPlan plan;
  final bool squareLayout;
  final double? tileWidth;
  final VoidCallback onTap;
  final VoidCallback onAddPlan;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (squareLayout) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: tileWidth ?? double.infinity,
          decoration: BoxDecoration(
            color: c.surfaceRaised,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.border),
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                if (plan.imageAsset != null)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(plan.imageAsset!, fit: BoxFit.cover),
                    ),
                  )
                else if (plan.imagePath != null &&
                    File(plan.imagePath!).existsSync())
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(plan.imagePath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/placeholder.png',
                        fit: BoxFit.cover,
                      ),
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
                        plan.title,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${plan.duration} · ${plan.exercises}',
                        style: TextStyle(color: c.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: onAddPlan,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Add',
                        style: TextStyle(
                          color: c.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surfaceRaised,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            if (plan.imageAsset != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.asset(plan.imageAsset!, fit: BoxFit.cover),
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: c.accentSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.fitness_center, color: c.accent),
              ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.title,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${plan.duration} · ${plan.exercises}',
                    style: TextStyle(color: c.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  _DifficultyIcons(level: plan.difficulty),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                GestureDetector(
                  onTap: onAddPlan,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: c.accentSoft,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: c.accent.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      'Add',
                      style: TextStyle(
                        color: c.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Icon(Icons.chevron_right, color: c.textMuted, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Add plan card
// ─────────────────────────────────────────────
class _AddPlanCard extends StatelessWidget {
  const _AddPlanCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
          color: c.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: c.accent),
            const SizedBox(width: 8),
            Text(
              'Add another plan',
              style: TextStyle(
                color: c.textPrimary,
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

// ─────────────────────────────────────────────
// Custom workout card
// ─────────────────────────────────────────────
class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({
    required this.plan,
    required this.squareLayout,
    this.tileWidth,
    required this.onTap,
  });
  final WorkoutPlan plan;
  final bool squareLayout;
  final double? tileWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = c.accent.withValues(alpha: 0.08);

    if (squareLayout) {
      return InkWell(
        onTap: onTap,
        child: Container(
          width: tileWidth ?? double.infinity,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.border),
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                if (plan.imagePath != null &&
                    File(plan.imagePath!).existsSync())
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(plan.imagePath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else if (plan.imageAsset != null)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(plan.imageAsset!, fit: BoxFit.cover),
                    ),
                  )
                else
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/placeholder.png',
                        fit: BoxFit.cover,
                      ),
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
                        plan.title,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${plan.duration} · ${plan.exercises}',
                        style: TextStyle(color: c.textSecondary, fontSize: 13),
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
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: c.surfaceRaised,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.hardEdge,
              child:
                  (plan.imagePath != null && File(plan.imagePath!).existsSync())
                  ? Image.file(File(plan.imagePath!), fit: BoxFit.cover)
                  : (plan.imageAsset != null
                        ? Image.asset(plan.imageAsset!, fit: BoxFit.cover)
                        : Icon(Icons.fitness_center, color: c.accent)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.title,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${plan.duration} · ${plan.exercises}',
                    style: TextStyle(color: c.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: c.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Difficulty icons
// ─────────────────────────────────────────────
class _DifficultyIcons extends StatelessWidget {
  const _DifficultyIcons({required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        4,
        (i) => Icon(
          Icons.flash_on,
          size: 16,
          color: i < level.clamp(1, 4) ? c.accent : c.textMuted,
        ),
      ),
    );
  }
}
