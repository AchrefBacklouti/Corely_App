import 'package:flutter/material.dart';
import 'package:main_build/Views/main_app/workout/create_workout_plan_page.dart';
import 'package:main_build/data/workout_plans.dart';
import 'package:main_build/data/data_service.dart';

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
                    onAdd: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateWorkoutPlanPage(),
                        ),
                      );
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

  const _CustomPlansSection({
    required this.plans,
    required this.theme,
    required this.squareLayout,
    required this.onAdd,
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
                  for (final plan in plans)
                    SizedBox(
                      width: cardWidth,
                      child: _WorkoutCard(
                        title: plan.title,
                        duration: plan.duration,
                        exercises: plan.exercises,
                        imageAsset: plan.imageAsset,
                        squareLayout: true,
                        color: theme.colorScheme.primary.withOpacity(0.08),
                        onTap: () {},
                        tileWidth: cardWidth,
                      ),
                    ),
                ],
              );
            },
          )
        else ...[
          for (final plan in plans) ...[
            _WorkoutCard(
              title: plan.title,
              duration: plan.duration,
              exercises: plan.exercises,
              imageAsset: plan.imageAsset,
              squareLayout: false,
              color: theme.colorScheme.primary.withOpacity(0.08),
              onTap: () {},
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Suggestions",
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
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
  final bool squareLayout;
  final double? tileWidth;
  final Color color;
  final VoidCallback onTap;

  const _WorkoutCard({
    required this.title,
    required this.duration,
    required this.exercises,
    required this.imageAsset,
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
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white12 : Colors.black12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.fitness_center, color: Colors.yellow),
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

  const _SuggestedCard({
    required this.title,
    required this.description,
    required this.color,
    required this.imageAsset,
    required this.squareLayout,
    this.tileWidth,
    required this.difficulty,
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
                  onPressed: () {},
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
            onPressed: () {},
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
