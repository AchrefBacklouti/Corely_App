import 'package:flutter/material.dart';
import 'package:main_build/Theme/app_theme.dart';
import 'package:main_build/Views/SharedWidgets/build_piker.dart';
import 'package:main_build/Views/SharedWidgets/toggle-Unit.dart';
import 'package:main_build/Views/on_boarding/user_summary.dart';

class CorelyOnboardingFlow extends StatefulWidget {
  const CorelyOnboardingFlow({super.key});

  @override
  State<CorelyOnboardingFlow> createState() => _CorelyOnboardingFlowState();
}

class _CorelyOnboardingFlowState extends State<CorelyOnboardingFlow> {
  int _currentStep = 0;

  // user data
  String? gender;
  String? age;
  String selectedWeight = '190';
  String selectedUnitWeight = 'lbs';
  String selectedHeightUnit = 'cm';
  String selectedHeightFt = '5';
  String selectedHeightIn = '9';
  String selectedHeightCm = '175';
  String selectedGoal = 'Build more muscle';
  String selectedTrainingDays = '5';

  // controllers for pickers
  late FixedExtentScrollController ageController;
  late FixedExtentScrollController weightController;
  late FixedExtentScrollController heightFtController;
  late FixedExtentScrollController heightInController;
  late FixedExtentScrollController heightCmController;
  late FixedExtentScrollController goalController;
  late FixedExtentScrollController trainingDaysController;

  // data
  final List<String> ages = List.generate(68, (i) => (13 + i).toString());
  final List<String> weightsKg = List.generate(171, (i) => (30 + i).toString());
  final List<String> weightsLbs = List.generate(
    376,
    (i) => (65 + i).toString(),
  );
  final List<String> ftHeights = List.generate(5, (i) => (3 + i).toString());
  final List<String> inHeights = List.generate(12, (i) => i.toString());
  final List<String> cmHeights = List.generate(
    121,
    (i) => (i + 120).toString(),
  );
  final List<String> goals = [
    'Build more muscle',
    'Lose fat',
    'Recomposition',
    'Build strength',
  ];
  final List<String> trainingDays = ['2', '3', '4', '5', '6', '7'];

  double get progress => (_currentStep + 1) / 6;

  void _next() {
    if (_currentStep < 5) {
      setState(() => _currentStep++);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserSummary(
          gender: gender ?? 'male',
          age: int.parse(age ?? '21'),
          weight: double.parse(selectedWeight),
          height: int.parse(selectedHeightCm),
          goal: selectedGoal,
          trainingDays: int.parse(selectedTrainingDays),
          weightUnit: selectedUnitWeight,
          heightUnit: selectedHeightUnit,
        ),
      ),
    );
  }

  void _back() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  @override
  void initState() {
    super.initState();
    ageController = FixedExtentScrollController(
      initialItem: ages.indexOf(age ?? '21'),
    );
    weightController = FixedExtentScrollController(
      initialItem: weightsKg.indexOf(selectedWeight),
    );
    heightFtController = FixedExtentScrollController(
      initialItem: ftHeights.indexOf(selectedHeightFt),
    );
    heightInController = FixedExtentScrollController(
      initialItem: inHeights.indexOf(selectedHeightIn),
    );
    heightCmController = FixedExtentScrollController(
      initialItem: cmHeights.indexOf(selectedHeightCm),
    );
    goalController = FixedExtentScrollController(
      initialItem: goals.indexOf(selectedGoal),
    );
    trainingDaysController = FixedExtentScrollController(
      initialItem: trainingDays.indexOf(selectedTrainingDays),
    );
  }

  @override
  void dispose() {
    ageController.dispose();
    weightController.dispose();
    heightFtController.dispose();
    heightInController.dispose();
    heightCmController.dispose();
    goalController.dispose();
    trainingDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use the theme extension for all colours — auto-switches dark/light.
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            if (_currentStep > 0)
              IconButton(
                icon: Icon(Icons.arrow_back, color: c.textPrimary, size: 28),
                onPressed: _back,
              )
            else
              const SizedBox(width: 56),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  color: AppTheme.accent,
                  backgroundColor: c.border,
                  minHeight: 20,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: Text(
                'Tell us more about you',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: _buildStep(context),
              ),
            ),
            const SizedBox(height: 20),
            _buildBottomButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── Step router ───────────────────────────────
  Widget _buildStep(BuildContext context) {
    return switch (_currentStep) {
      0 => _genderStep(),
      1 => _ageStep(),
      2 => _weightStep(),
      3 => _heightStep(),
      4 => _goalStep(),
      5 => _trainingStep(),
      _ => const SizedBox(),
    };
  }

  // ── Gender ────────────────────────────────────
  Widget _genderStep() {
    final c = context.colors;
    return Column(
      key: const ValueKey('gender'),
      children: [
        const SizedBox(height: 10),
        Text(
          "Let's start simple — what's your gender?",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: c.textSecondary,
            fontSize: 20,
            fontFamily: 'LindenHill',
          ),
        ),
        const SizedBox(height: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _genderButton('female', Icons.female),
            const SizedBox(height: 15),
            _genderButton('male', Icons.male),
          ],
        ),
      ],
    );
  }

  Widget _genderButton(String label, IconData icon) {
    final c = context.colors;
    final isSelected = gender == label;

    return GestureDetector(
      onTap: () => setState(() => gender = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          // Selected → accent; unselected → surface card colour
          color: isSelected ? AppTheme.accent : c.surfaceRaised,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppTheme.accent : c.border,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 120,
              color: isSelected ? Colors.black : c.textPrimary,
              shadows: const [
                Shadow(
                  offset: Offset(2, 2),
                  blurRadius: 4,
                  color: Colors.black45,
                ),
              ],
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : c.textSecondary,
                fontFamily: 'Livvic',
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Age ───────────────────────────────────────
  Widget _ageStep() {
    final c = context.colors;
    final ageValue = age ?? '21';
    final ageIndex = ages.indexOf(ageValue);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ageController.hasClients) return;
      if (ageController.selectedItem != ageIndex)
        ageController.jumpToItem(ageIndex);
    });

    return Column(
      key: const ValueKey('age'),
      children: [
        Text(
          "Cool — how old are you?",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: c.textSecondary,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: _pickerStack(
            buildPicker(
              ages,
              ageValue,
              Theme.of(context).brightness == Brightness.dark,
              (val) => setState(() => age = val),
              fontSize: 36,
              selectedHeight: 260,
              controller: ageController,
            ),
          ),
        ),
      ],
    );
  }

  // ── Weight ────────────────────────────────────
  Widget _weightStep() {
    final c = context.colors;
    final weights = selectedUnitWeight == 'kg' ? weightsKg : weightsLbs;
    final weightIndex = weights.indexOf(selectedWeight);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!weightController.hasClients) return;
      if (weightController.selectedItem != weightIndex) {
        weightController.jumpToItem(weightIndex);
      }
    });

    return Column(
      key: const ValueKey('weight'),
      children: [
        Text(
          "Almost done 💪 — what's your current weight?",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: c.textSecondary,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            UnitToggle(
              leftLabel: 'lbs',
              rightLabel: 'kg',
              value: selectedUnitWeight,
              onChanged: (val) {
                if (selectedUnitWeight == val) return;
                final numeric = double.tryParse(selectedWeight) ?? 0;
                final converted = val == 'kg'
                    ? (numeric / 2.20462).round().toString()
                    : (numeric * 2.20462).round().toString();
                final newList = val == 'kg' ? weightsKg : weightsLbs;
                weightController.jumpToItem(newList.indexOf(converted));
                setState(() {
                  selectedWeight = converted;
                  selectedUnitWeight = val;
                });
              },
            ),
          ],
        ),
        Expanded(
          child: _pickerStack(
            buildPicker(
              weights,
              selectedWeight,
              Theme.of(context).brightness == Brightness.dark,
              (val) => setState(() => selectedWeight = val),
              fontSize: 36,
              selectedHeight: 280,
              controller: weightController,
            ),
          ),
        ),
      ],
    );
  }

  // ── Height ────────────────────────────────────
  Widget _heightStep() {
    final c = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectedHeightUnit == 'cm') {
        if (!heightCmController.hasClients) return;
        final i = cmHeights.indexOf(selectedHeightCm);
        if (heightCmController.selectedItem != i)
          heightCmController.jumpToItem(i);
      } else {
        if (heightFtController.hasClients) {
          final i = ftHeights.indexOf(selectedHeightFt);
          if (heightFtController.selectedItem != i)
            heightFtController.jumpToItem(i);
        }
        if (heightInController.hasClients) {
          final i = inHeights.indexOf(selectedHeightIn);
          if (heightInController.selectedItem != i)
            heightInController.jumpToItem(i);
        }
      }
    });

    return Column(
      key: const ValueKey('height'),
      children: [
        Text(
          "And how tall are you?",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: c.textSecondary,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            UnitToggle(
              leftLabel: 'in',
              rightLabel: 'cm',
              value: selectedHeightUnit,
              onChanged: (val) {
                if (selectedHeightUnit == val) return;
                if (val == 'cm') {
                  final cm =
                      (int.parse(selectedHeightFt) * 30.48 +
                              int.parse(selectedHeightIn) * 2.54)
                          .round()
                          .toString();
                  heightCmController.jumpToItem(cmHeights.indexOf(cm));
                  setState(() {
                    selectedHeightCm = cm;
                    selectedHeightUnit = val;
                  });
                } else {
                  final cmVal = double.parse(selectedHeightCm);
                  final ft = (cmVal / 30.48).floor().toString();
                  final inch = ((cmVal - int.parse(ft) * 30.48) / 2.54)
                      .round()
                      .toString();
                  heightFtController.jumpToItem(ftHeights.indexOf(ft));
                  heightInController.jumpToItem(inHeights.indexOf(inch));
                  setState(() {
                    selectedHeightFt = ft;
                    selectedHeightIn = inch;
                    selectedHeightUnit = val;
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: selectedHeightUnit == 'cm'
              ? _pickerStack(
                  buildPicker(
                    cmHeights,
                    selectedHeightCm,
                    isDark,
                    (val) => setState(() => selectedHeightCm = val),
                    fontSize: 20,
                    selectedHeight: 280,
                    controller: heightCmController,
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: _pickerStack(
                        buildPicker(
                          ftHeights,
                          selectedHeightFt,
                          isDark,
                          (val) => setState(() => selectedHeightFt = val),
                          fontSize: 28,
                          selectedHeight: 240,
                          controller: heightFtController,
                        ),
                        horizontalMargin: 20,
                        barHeight: 4,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _pickerStack(
                        buildPicker(
                          inHeights,
                          selectedHeightIn,
                          isDark,
                          (val) => setState(() => selectedHeightIn = val),
                          fontSize: 28,
                          selectedHeight: 240,
                          controller: heightInController,
                        ),
                        horizontalMargin: 20,
                        barHeight: 4,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  // ── Goal ──────────────────────────────────────
  Widget _goalStep() {
    final c = context.colors;
    return Column(
      key: const ValueKey('goal'),
      children: [
        Text(
          "What's your main goal right now?",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: c.textSecondary,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 30),
        ...goals.map((goal) {
          final selected = selectedGoal == goal;
          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: GestureDetector(
              onTap: () => setState(() => selectedGoal = goal),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      border: Border.all(color: c.textPrimary, width: 2),
                      color: selected ? AppTheme.accent : Colors.transparent,
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.black, size: 18)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    goal,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: selected ? AppTheme.accent : c.textPrimary,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Training days ─────────────────────────────
  Widget _trainingStep() {
    final c = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trainingIndex = trainingDays.indexOf(selectedTrainingDays);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!trainingDaysController.hasClients) return;
      if (trainingDaysController.selectedItem != trainingIndex) {
        trainingDaysController.jumpToItem(trainingIndex);
      }
    });

    return Column(
      key: const ValueKey('training'),
      children: [
        Text(
          "Finally, let's find your perfect rhythm 💪\nHow many days a week do you want to train?",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: c.textSecondary,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          height: 350,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _pickerStack(
                  buildPicker(
                    trainingDays,
                    selectedTrainingDays,
                    isDark,
                    (val) => setState(() => selectedTrainingDays = val),
                    fontSize: 32,
                    selectedHeight: 240,
                    controller: trainingDaysController,
                  ),
                  horizontalMargin: 60,
                  barHeight: 4,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Days/week',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: c.textPrimary,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Text(
          _getTrainingMessage(selectedTrainingDays),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: c.textSecondary,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ── Shared picker scaffold ─────────────────────
  // Wraps any picker in the two yellow selection bars so we don't
  // repeat that Stack boilerplate six times.
  Widget _pickerStack(
    Widget picker, {
    double horizontalMargin = 60,
    double barHeight = 9,
    double horizontalPadding = 40,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Top bar
        Align(
          alignment: const Alignment(0, -0.15),
          child: Container(
            height: barHeight,
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppTheme
                  .accent, // uses the theme accent, not hardcoded yellow
            ),
          ),
        ),
        // Bottom bar
        Align(
          alignment: const Alignment(0, 0.15),
          child: Container(
            height: barHeight,
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppTheme.accent,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: picker,
        ),
      ],
    );
  }

  // ── Continue / Finish button ───────────────────
  Widget _buildBottomButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _next,
      // Inherits ElevatedButtonThemeData from AppTheme._build;
      // override only the shape/padding that differs from the default.
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      ),
      child: Text(
        _currentStep == 5 ? 'Finish' : 'Select',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _getTrainingMessage(String days) {
    return switch (days) {
      '2' =>
        "Perfect start! Two focused sessions are enough to build momentum 💪",
      '3' => "Three days a week? That's a smart, sustainable routine 🔥",
      '4' =>
        "Nice! Four sessions give a great balance of intensity and recovery ⚖️",
      '5' => "Five days — now we're getting serious! Let's push your limits 💥",
      '6' => "Six days? You're in beast mode 😤 — recovery will be key here.",
      '7' =>
        "Every day?! That's elite dedication 🏆 — Corely will help you stay balanced.",
      _ => "Choose what fits your life — Corely adapts to you.",
    };
  }
}
