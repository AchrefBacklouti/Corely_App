// ─────────────────────────────────────────────────────────────────────────────
// Drop-in replacement for the bottom-sheet + new helper pages.
// Replace the _PlanDetailSheet class (and everything below it) in
// workout_page.dart with this file's contents.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:main_build/Theme/app_theme.dart';
import 'package:main_build/Views/main_app/workout/edit_plan_page.dart';
import 'package:main_build/data/local_plan_service.dart';
import 'package:main_build/data/data_service.dart';
import 'package:main_build/data/workout_plans.dart';

// ─────────────────────────────────────────────
// Plan detail bottom sheet
// ─────────────────────────────────────────────
class PlanDetailSheet extends StatefulWidget {
  const PlanDetailSheet({super.key, required this.plan, required this.onPlanAdded});
  final WorkoutPlan plan;
  final VoidCallback onPlanAdded;

  @override
  State<PlanDetailSheet> createState() => _PlanDetailSheetState();
}

class _PlanDetailSheetState extends State<PlanDetailSheet> {
  final Set<int> _selectedDays = {};
  bool _selectingDays = false;

  // ── Copy whole plan ──────────────────────────────────────────────────────
  Future<void> _copyAll() async {
    await LocalPlanService.savePlan(widget.plan);
    widget.onPlanAdded();
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.plan.title} added to your plans!')),
      );
    }
  }

  // ── "Copy Days" button pressed ───────────────────────────────────────────
  Future<void> _onCopyDaysConfirmed() async {
    final days = widget.plan.days;
    if (days == null || _selectedDays.isEmpty) return;

    final selectedDayObjects = _selectedDays.map((i) => days[i]).toList();

    // Show the two-choice overlay
    if (!mounted) return;
    final choice = await _showCopyChoiceDialog(context);
    if (choice == null || !mounted) return;

    if (choice == _CopyChoice.createPlan) {
      // ── Path 1: open EditPlanPage pre-loaded with the copied days ─────────
      Navigator.pop(context); // close bottom sheet first
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditPlanPage(prefillDays: selectedDayObjects),
        ),
      );
      if (result == true) widget.onPlanAdded();
    } else {
      // ── Path 2: add to existing plan ──────────────────────────────────────
      final customPlans = await DataService.getCustomWorkoutPlans();

      if (!mounted) return;

      if (customPlans.isEmpty) {
        // No custom plans → auto-create one and open EditPlanPage
        Navigator.pop(context);
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditPlanPage(prefillDays: selectedDayObjects),
          ),
        );
        if (result == true) widget.onPlanAdded();
      } else {
        // Has custom plans → let user pick one
        Navigator.pop(context);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _AddToExistingPlanPage(
              plans: customPlans,
              daysToAdd: selectedDayObjects,
              onDone: widget.onPlanAdded,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final plan = widget.plan;
    final days = plan.days ?? [];
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      height: screenH * 0.88,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          // ── Handle ───────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header image ─────────────────────
          if (plan.imageAsset != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(plan.imageAsset!, fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [c.surface, c.surface.withValues(alpha: 0)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Scrollable body ──────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + difficulty
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          plan.title,
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      _DifficultyIcons(level: plan.difficulty),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${plan.duration}  ·  ${plan.exercises}',
                    style: TextStyle(color: c.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 14),

                  if (plan.description != null) ...[
                    Text(
                      plan.description!,
                      style: TextStyle(
                        color: c.textSecondary,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Days breakdown
                  if (days.isNotEmpty) ...[
                    Row(
                      children: [
                        Text(
                          'Workout Days',
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        if (_selectingDays)
                          TextButton(
                            onPressed: () => setState(() {
                              _selectingDays = false;
                              _selectedDays.clear();
                            }),
                            child: const Text('Cancel'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(days.length, (i) {
                      final day = days[i];
                      final selected = _selectedDays.contains(i);
                      return Stack(
                        children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: selected ? c.accentSoft : c.surfaceRaised,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected ? c.accent : c.border,
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Theme(
                            data: Theme.of(
                              context,
                            ).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 2,
                              ),
                              childrenPadding: const EdgeInsets.fromLTRB(
                                14,
                                0,
                                14,
                                12,
                              ),
                              leading: _selectingDays
                                  ? AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: selected
                                            ? c.accent
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: selected ? c.accent : c.border,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: selected
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.black,
                                              size: 14,
                                            )
                                          : null,
                                    )
                                  : null,
                              title: Text(
                                day.label,
                                style: TextStyle(
                                  color: c.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              iconColor: c.textMuted,
                              collapsedIconColor: c.textMuted,
                              children: day.exercises
                                  .map(
                                    (ex) => Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 5,
                                            height: 5,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: c.accent,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              ex,
                                              style: TextStyle(
                                                color: c.textSecondary,
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
                          ),
                        ),
                        if (_selectingDays)
                          Positioned.fill(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => setState(() {
                                selected
                                    ? _selectedDays.remove(i)
                                    : _selectedDays.add(i);
                              }),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),

          // ── Action buttons ───────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: c.surface,
              border: Border(top: BorderSide(color: c.border)),
            ),
            child: _selectingDays
                ? Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _selectedDays.isEmpty
                              ? null
                              : _onCopyDaysConfirmed,
                          child: Text(
                            'Copy ${_selectedDays.isEmpty ? '' : '${_selectedDays.length} '}Day${_selectedDays.length == 1 ? '' : 's'}',
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              setState(() => _selectingDays = true),
                          child: const Text('Copy Days'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _copyAll,
                          child: const Text('Copy Plan'),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Copy-choice dialog  (Create Plan / Add to Existing)
// ─────────────────────────────────────────────
enum _CopyChoice { createPlan, addToExisting }

Future<_CopyChoice?> _showCopyChoiceDialog(BuildContext context) {
  final c = context.colors;

  return showGeneralDialog<_CopyChoice>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.65),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, _, __) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: c.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: c.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Where to add?',
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose how you want to use the copied days',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: c.textMuted,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Option 1: Create new plan ──
                  _ChoiceCard(
                    icon: Icons.add_circle_outline_rounded,
                    title: 'Create Plan',
                    subtitle: 'Start a new plan with the selected days',
                    onTap: () => Navigator.pop(ctx, _CopyChoice.createPlan),
                    color: c.accent,
                  ),
                  const SizedBox(height: 12),

                  // ── Option 2: Add to existing ──
                  _ChoiceCard(
                    icon: Icons.playlist_add_rounded,
                    title: 'Add to Existing Plan',
                    subtitle: 'Insert the days into one of your custom plans',
                    onTap: () => Navigator.pop(ctx, _CopyChoice.addToExisting),
                    color: Colors.blueAccent,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (_, anim, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.88,
          end: 1.0,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
        child: child,
      ),
    ),
  );
}

// Small card used in the choice dialog
class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: c.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: c.textMuted, size: 14),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AddToExistingPlanPage
// Shows the user's custom plans → they pick one → editing view opens →
// they tap the day slot where the copied days should land → confirmation popup.
// ─────────────────────────────────────────────────────────────────────────────
class _AddToExistingPlanPage extends StatefulWidget {
  const _AddToExistingPlanPage({
    required this.plans,
    required this.daysToAdd,
    required this.onDone,
  });

  final List<WorkoutPlan> plans;
  final List<WorkoutDay> daysToAdd;
  final VoidCallback onDone;

  @override
  State<_AddToExistingPlanPage> createState() => _AddToExistingPlanPageState();
}

class _AddToExistingPlanPageState extends State<_AddToExistingPlanPage> {
  int? _selectedPlanIndex;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        title: Text(
          'Choose a Plan',
          style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700),
        ),
        iconTheme: IconThemeData(color: c.textPrimary),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Text(
              'Select the plan you want to add the copied days to',
              style: TextStyle(color: c.textSecondary, fontSize: 14),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.plans.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final plan = widget.plans[i];
                final isSelected = _selectedPlanIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedPlanIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? c.accentSoft : c.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? c.accent : c.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: c.surfaceRaised,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.fitness_center,
                            color: isSelected ? c.accent : c.textMuted,
                            size: 22,
                          ),
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
                              const SizedBox(height: 3),
                              Text(
                                '${plan.days?.length ?? 0} days  ·  ${plan.exercises}',
                                style: TextStyle(
                                  color: c.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? c.accent : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? c.accent : c.border,
                              width: 1.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.black,
                                  size: 13,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedPlanIndex == null
                    ? null
                    : () async {
                        final plan = widget.plans[_selectedPlanIndex!];
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _DaySlotPickerPage(
                              plan: plan,
                              planIndex: _selectedPlanIndex!,
                              daysToAdd: widget.daysToAdd,
                              onDone: () {
                                widget.onDone();
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DaySlotPickerPage
// Shows the chosen plan's days as tappable slots.
// Tapping a slot shows a confirmation dialog; on "Yes" the copied days are
// merged into that slot and saved.
// ─────────────────────────────────────────────────────────────────────────────
class _DaySlotPickerPage extends StatefulWidget {
  const _DaySlotPickerPage({
    required this.plan,
    required this.planIndex,
    required this.daysToAdd,
    required this.onDone,
  });

  final WorkoutPlan plan;
  final int planIndex;
  final List<WorkoutDay> daysToAdd;
  final VoidCallback onDone;

  @override
  State<_DaySlotPickerPage> createState() => _DaySlotPickerPageState();
}

class _DaySlotPickerPageState extends State<_DaySlotPickerPage> {
  late List<WorkoutDay> _days;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _days = List<WorkoutDay>.from(widget.plan.days ?? []);
  }

  Future<void> _onSlotTapped(int slotIndex) async {
    final c = context.colors;
    final slot = _days[slotIndex];

    // ── Confirmation dialog ────────────────────────────────────────────────
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Add to "${slot.label}"?',
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'The ${widget.daysToAdd.length} copied day${widget.daysToAdd.length == 1 ? '' : 's'} will be merged into this day slot.',
          style: TextStyle(color: c.textSecondary, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('No', style: TextStyle(color: c.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: c.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Yes',
              style: TextStyle(
                color: c.background,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // ── Merge exercises into the chosen slot ───────────────────────────────
    setState(() {
      final allExercises = [
        ...slot.exercises,
        for (final d in widget.daysToAdd) ...d.exercises,
      ];
      _days[slotIndex] = WorkoutDay(label: slot.label, exercises: allExercises);
    });

    // Save immediately
    setState(() => _saving = true);
    final updated = widget.plan.copyWith(days: _days);
    await LocalPlanService.updatePlan(widget.planIndex, updated);
    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Days added to "${slot.label}" in ${widget.plan.title}!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        title: Text(
          widget.plan.title,
          style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700),
        ),
        iconTheme: IconThemeData(color: c.textPrimary),
        actions: [
          if (_saving)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: c.accent,
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: widget.onDone,
              child: Text('Done', style: TextStyle(color: c.accent)),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Text(
              'Tap the day you want to add the copied exercises to',
              style: TextStyle(color: c.textSecondary, fontSize: 14),
            ),
          ),

          // ── Badge showing what will be added ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: c.accentSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.accent.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  Icon(Icons.content_copy_rounded, color: c.accent, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${widget.daysToAdd.length} day${widget.daysToAdd.length == 1 ? '' : 's'} ready to be merged  '
                      '(${widget.daysToAdd.expand((d) => d.exercises).length} exercises)',
                      style: TextStyle(
                        color: c.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Day slots ──────────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _days.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final day = _days[i];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _onSlotTapped(i),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: c.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: c.accentSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  color: c.accent,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  day.label,
                                  style: TextStyle(
                                    color: c.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${day.exercises.length} exercise${day.exercises.length == 1 ? '' : 's'}',
                                  style: TextStyle(
                                    color: c.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
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
                              'Add here',
                              style: TextStyle(
                                color: c.accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Keep these unchanged — they are still needed
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
