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

  // ── User data (raw numeric strings) ───────────
  String? gender;
  String? age;
  String selectedBirthDay = '1';
  String selectedBirthMonth = 'January';
  String selectedBirthYear = DateTime.now().year.toString();
  String selectedWeight = '190';
  String selectedUnitWeight = 'lbs';
  String selectedHeightUnit = 'ft';
  String selectedHeightFt = '5';
  String selectedHeightIn = '9';
  String selectedHeightCm = '175';
  final Set<String> selectedGoals = {'Build more muscle'};
  String selectedTrainingDays = '5';

  // ── Raw data lists ─────────────────────────────
  final List<String> ages = List.generate(68, (i) => (13 + i).toString());
  final List<String> birthDays = List.generate(31, (i) => (i + 1).toString());
  final List<String> birthMonths = const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  late final List<String> birthYears = List.generate(
    DateTime.now().year - 1899,
    (i) => (DateTime.now().year - i).toString(),
  );
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
  final List<_GoalCardData> goalCards = const [
    _GoalCardData(
      label: 'Build more muscle',
      imagePath: 'assets/img/plans/dumbells.jpg',
      description: 'Push for size and strength',
    ),
    _GoalCardData(
      label: 'Lose fat',
      imagePath: 'assets/img/plans/cardio_1.webp',
      description: 'Burn calories and stay lean',
    ),
    _GoalCardData(
      label: 'Recomposition',
      imagePath: 'assets/img/plans/Energy.jpg',
      description: 'Build muscle while reducing fat',
    ),
    _GoalCardData(
      label: 'Build strength',
      imagePath: 'assets/img/plans/wendler.png',
      description: 'Train to lift heavier',
    ),
  ];
  final List<String> trainingDays = ['2', '3', '4', '5', '6', '7'];

  // ── Labelled lists (unit appended — shown in picker) ──
  List<String> get weightsKgLabelled => weightsKg.map((v) => '$v kg').toList();
  List<String> get weightsLbsLabelled =>
      weightsLbs.map((v) => '$v lbs').toList();
  List<String> get cmHeightsLabelled => cmHeights.map((v) => '$v cm').toList();
  List<String> get ftHeightsLabelled => ftHeights.map((v) => '$v ft').toList();
  List<String> get inHeightsLabelled => inHeights.map((v) => '$v in').toList();

  // ── Helpers ───────────────────────────────────
  // Build the labelled string for a raw value + unit suffix.
  String _label(String raw, String unit) => '$raw $unit';

  // Recover raw numeric string from a labelled picker value.
  String _raw(String labelled) => labelled.split(' ').first;

  // Safe index lookup — returns 0 if not found so the picker never crashes.
  int _idx(List<String> list, String value) {
    final i = list.indexOf(value);
    return i < 0 ? 0 : i;
  }

  // ── Scroll controllers ────────────────────────
  late FixedExtentScrollController ageController;
  late FixedExtentScrollController birthDayController;
  late FixedExtentScrollController birthMonthController;
  late FixedExtentScrollController birthYearController;
  late FixedExtentScrollController weightController;
  late FixedExtentScrollController heightFtController;
  late FixedExtentScrollController heightInController;
  late FixedExtentScrollController heightCmController;
  late FixedExtentScrollController trainingDaysController;

  double get progress => (_currentStep + 1) / 7;

  String get selectedGoalLabel {
    if (selectedGoals.isEmpty) return '';
    return selectedGoals.join(', ');
  }

  int _daysInMonth(int year, int month) {
    final firstDayNextMonth = month == 12
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);
    return firstDayNextMonth.subtract(const Duration(days: 1)).day;
  }

  int _selectedBirthMonthIndex() => birthMonths.indexOf(selectedBirthMonth) + 1;

  void _syncBirthYearFromAge() {
    final parsedAge = int.tryParse(age ?? '21') ?? 21;
    selectedBirthYear = (DateTime.now().year - parsedAge).toString();
  }

  void _clampBirthDayToMonth() {
    final monthIndex = _selectedBirthMonthIndex();
    if (monthIndex <= 0) return;
    final yearValue = int.tryParse(selectedBirthYear) ?? DateTime.now().year;
    final maxDay = _daysInMonth(yearValue, monthIndex);
    final currentDay = int.tryParse(selectedBirthDay) ?? 1;
    if (currentDay > maxDay) {
      selectedBirthDay = maxDay.toString();
      if (birthDayController.hasClients) {
        birthDayController.jumpToItem(maxDay - 1);
      }
    }
  }

  String _birthDateDisplay() =>
      '$selectedBirthDay $selectedBirthMonth $selectedBirthYear';

  String _birthDateIso() {
    final monthIndex = _selectedBirthMonthIndex();
    final yearValue = int.tryParse(selectedBirthYear) ?? DateTime.now().year;
    final dayValue = int.tryParse(selectedBirthDay) ?? 1;
    return DateTime(yearValue, monthIndex, dayValue).toIso8601String();
  }

  @override
  void initState() {
    super.initState();
    // Weight — starts on lbs
    final initWeightLabel = _label(selectedWeight, selectedUnitWeight);
    weightController = FixedExtentScrollController(
      initialItem: _idx(weightsLbsLabelled, initWeightLabel),
    );
    // Height — starts on cm
    final initCmLabel = _label(selectedHeightCm, 'cm');
    heightCmController = FixedExtentScrollController(
      initialItem: _idx(cmHeightsLabelled, initCmLabel),
    );
    heightFtController = FixedExtentScrollController(
      initialItem: _idx(ftHeightsLabelled, _label(selectedHeightFt, 'ft')),
    );
    heightInController = FixedExtentScrollController(
      initialItem: _idx(inHeightsLabelled, _label(selectedHeightIn, 'in')),
    );
    ageController = FixedExtentScrollController(
      initialItem: _idx(ages, age ?? '21'),
    );
    final initialBirthYear =
        (DateTime.now().year - (int.tryParse(age ?? '21') ?? 21)).toString();
    selectedBirthYear = initialBirthYear;
    birthDayController = FixedExtentScrollController(
      initialItem: _idx(birthDays, selectedBirthDay),
    );
    birthMonthController = FixedExtentScrollController(
      initialItem: _idx(birthMonths, selectedBirthMonth),
    );
    birthYearController = FixedExtentScrollController(
      initialItem: _idx(birthYears, selectedBirthYear),
    );
    trainingDaysController = FixedExtentScrollController(
      initialItem: _idx(trainingDays, selectedTrainingDays),
    );
  }

  @override
  void dispose() {
    ageController.dispose();
    birthDayController.dispose();
    birthMonthController.dispose();
    birthYearController.dispose();
    weightController.dispose();
    heightFtController.dispose();
    heightInController.dispose();
    heightCmController.dispose();
    trainingDaysController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep < 6) {
      if (_currentStep == 3) {
        // Leaving weight step: sync height unit to match the chosen weight unit.
        setState(() {
          selectedHeightUnit = selectedUnitWeight == 'kg' ? 'cm' : 'ft';
          _currentStep++;
        });
      } else {
        setState(() => _currentStep++);
      }
      return;
    }
    final heightDisplay = selectedHeightUnit == 'ft'
        ? '${selectedHeightFt}ft ${selectedHeightIn}in'
        : '${selectedHeightCm}cm';
    final goalText = selectedGoalLabel.isEmpty
        ? 'Build more muscle'
        : selectedGoalLabel;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserSummary(
          gender: gender ?? 'male',
          age: int.parse(age ?? '21'),
          weight: double.parse(selectedWeight),
          heightDisplay: heightDisplay,
          goal: goalText,
          trainingDays: int.parse(selectedTrainingDays),
          weightUnit: selectedUnitWeight,
          heightUnit: selectedHeightUnit,
          birthDateDisplay: _birthDateDisplay(),
          birthDateIso: _birthDateIso(),
        ),
      ),
    );
  }

  void _back() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  @override
  Widget build(BuildContext context) {
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

  Widget _buildStep(BuildContext context) {
    return switch (_currentStep) {
      0 => _genderStep(),
      1 => _ageStep(),
      2 => _birthDateStep(),
      3 => _weightStep(),
      4 => _heightStep(),
      5 => _goalStep(),
      6 => _trainingStep(),
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ageController.hasClients) return;
      final i = _idx(ages, ageValue);
      if (ageController.selectedItem != i) ageController.jumpToItem(i);
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
              (val) => setState(() {
                age = val;
                _syncBirthYearFromAge();
                if (birthYearController.hasClients) {
                  final yearIndex = _idx(birthYears, selectedBirthYear);
                  birthYearController.jumpToItem(yearIndex);
                }
              }),
              fontSize: 36,
              selectedHeight: 260,
              controller: ageController,
            ),
          ),
        ),
      ],
    );
  }

  Widget _birthDateStep() {
    final c = context.colors;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (birthDayController.hasClients) {
        final dayIndex = _idx(birthDays, selectedBirthDay);
        if (birthDayController.selectedItem != dayIndex) {
          birthDayController.jumpToItem(dayIndex);
        }
      }
      if (birthMonthController.hasClients) {
        final monthIndex = _idx(birthMonths, selectedBirthMonth);
        if (birthMonthController.selectedItem != monthIndex) {
          birthMonthController.jumpToItem(monthIndex);
        }
      }
      if (birthYearController.hasClients) {
        final yearIndex = _idx(birthYears, selectedBirthYear);
        if (birthYearController.selectedItem != yearIndex) {
          birthYearController.jumpToItem(yearIndex);
        }
      }
    });

    return Column(
      key: const ValueKey('birth-date'),
      children: [
        Text(
          'What is your date of birth?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: c.textSecondary,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: buildPicker(
                  birthDays,
                  selectedBirthDay,
                  Theme.of(context).brightness == Brightness.dark,
                  (val) => setState(() => selectedBirthDay = val),
                  fontSize: 28,
                  selectedHeight: 260,
                  controller: birthDayController,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: buildPicker(
                  birthMonths,
                  selectedBirthMonth,
                  Theme.of(context).brightness == Brightness.dark,
                  (val) => setState(() {
                    selectedBirthMonth = val;
                    _clampBirthDayToMonth();
                  }),
                  fontSize: 18,
                  selectedHeight: 260,
                  controller: birthMonthController,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: buildPicker(
                  birthYears,
                  selectedBirthYear,
                  Theme.of(context).brightness == Brightness.dark,
                  (val) => setState(() {
                    selectedBirthYear = val;
                    _clampBirthDayToMonth();
                  }),
                  fontSize: 26,
                  selectedHeight: 260,
                  controller: birthYearController,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Weight ────────────────────────────────────
  Widget _weightStep() {
    final c = context.colors;
    final labelled = selectedUnitWeight == 'kg'
        ? weightsKgLabelled
        : weightsLbsLabelled;
    final currentLbl = _label(selectedWeight, selectedUnitWeight);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!weightController.hasClients) return;
      final i = _idx(labelled, currentLbl);
      if (weightController.selectedItem != i) weightController.jumpToItem(i);
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
                final newLabelled = val == 'kg'
                    ? weightsKgLabelled
                    : weightsLbsLabelled;
                final i = _idx(newLabelled, _label(converted, val));
                weightController.jumpToItem(i);
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
              labelled,
              currentLbl,
              Theme.of(context).brightness == Brightness.dark,
              (val) => setState(() => selectedWeight = _raw(val)),
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
        final i = _idx(cmHeightsLabelled, _label(selectedHeightCm, 'cm'));
        if (heightCmController.selectedItem != i) {
          heightCmController.jumpToItem(i);
        }
      } else {
        if (heightFtController.hasClients) {
          final i = _idx(ftHeightsLabelled, _label(selectedHeightFt, 'ft'));
          if (heightFtController.selectedItem != i) {
            heightFtController.jumpToItem(i);
          }
        }
        if (heightInController.hasClients) {
          final i = _idx(inHeightsLabelled, _label(selectedHeightIn, 'in'));
          if (heightInController.selectedItem != i) {
            heightInController.jumpToItem(i);
          }
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
              leftLabel: 'ft',
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
                  heightCmController.jumpToItem(
                    _idx(cmHeightsLabelled, _label(cm, 'cm')),
                  );
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
                  heightFtController.jumpToItem(
                    _idx(ftHeightsLabelled, _label(ft, 'ft')),
                  );
                  heightInController.jumpToItem(
                    _idx(inHeightsLabelled, _label(inch, 'in')),
                  );
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
                    cmHeightsLabelled,
                    _label(selectedHeightCm, 'cm'),
                    isDark,
                    (val) => setState(() => selectedHeightCm = _raw(val)),
                    fontSize: 28,
                    selectedHeight: 280,
                    controller: heightCmController,
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: _pickerStack(
                        buildPicker(
                          ftHeightsLabelled,
                          _label(selectedHeightFt, 'ft'),
                          isDark,
                          (val) => setState(() => selectedHeightFt = _raw(val)),
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
                          inHeightsLabelled,
                          _label(selectedHeightIn, 'in'),
                          isDark,
                          (val) => setState(() => selectedHeightIn = _raw(val)),
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
          "Pick one or more goals that matter to you right now.",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: c.textSecondary,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.only(bottom: 12),
            itemCount: goalCards.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.92,
            ),
            itemBuilder: (context, index) {
              final card = goalCards[index];
              final selected = selectedGoals.contains(card.label);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selected) {
                      selectedGoals.remove(card.label);
                    } else {
                      selectedGoals.add(card.label);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.accent.withOpacity(0.16)
                        : c.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected ? AppTheme.accent : c.border,
                      width: selected ? 2.5 : 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(selected ? 0.18 : 0.08),
                        blurRadius: selected ? 18 : 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            card.imagePath,
                            fit: BoxFit.cover,
                            color: selected
                                ? Colors.black.withOpacity(0.12)
                                : null,
                            colorBlendMode: BlendMode.darken,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(
                                  selected ? 0.42 : 0.55,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppTheme.accent
                                      : Colors.white24,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  selected ? Icons.check : Icons.add,
                                  size: 18,
                                  color: selected ? Colors.black : Colors.white,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  card.label,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  card.description,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.88),
                                    fontSize: 13,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Training days ─────────────────────────────
  Widget _trainingStep() {
    final c = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ti = _idx(trainingDays, selectedTrainingDays);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!trainingDaysController.hasClients) return;
      if (trainingDaysController.selectedItem != ti) {
        trainingDaysController.jumpToItem(ti);
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
  Widget _pickerStack(
    Widget picker, {
    double horizontalMargin = 60,
    double barHeight = 9,
    double horizontalPadding = 40,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: const Alignment(0, -0.15),
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
    final isDisabled = _currentStep == 0 && gender == null;
    return ElevatedButton(
      onPressed: isDisabled ? null : _next,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      ),
      child: Text(
        _currentStep == 6 ? 'Finish' : 'Select',
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

class _GoalCardData {
  final String label;
  final String imagePath;
  final String description;

  const _GoalCardData({
    required this.label,
    required this.imagePath,
    required this.description,
  });
}
