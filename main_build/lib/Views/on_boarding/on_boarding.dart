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
  String selectedWeight = '80';
  String selectedUnitWeight = 'kg';
  String selectedHeightUnit = 'cm';
  String selectedHeightFt = '5';
  String selectedHeightIn = '9';
  String selectedHeightCm = '175';
  String selectedGoal = 'Build more muscle';
  String selectedTrainingDays = '5';

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
    "Build more muscle",
    "Lose fat",
    "Recomposition",
    "Build strength",
  ];
  final List<String> trainingDays = ['2', '3', '4', '5', '6', '7'];

  double get progress => (_currentStep + 1) / 6;

  void _next() {
    if (_currentStep < 5) {
      setState(() => _currentStep++);
    } else {
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
  }

  void _back() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppTheme.darkBackground
          : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Show back button only after first step
            if (_currentStep > 0)
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: isDarkMode ? Colors.white : Colors.black,
                  size: 28,
                ),
                onPressed: _back,
              )
            else
              const SizedBox(
                width: 56,
              ), // Same width as IconButton for consistent layout
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  color: isDarkMode ? Colors.white : Colors.black,
                  backgroundColor: isDarkMode ? Colors.black : Colors.grey[300],
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
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Livvic',
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
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
            _buildBottomButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ======================================================
  //                   STEP BUILDER
  // ======================================================
  Widget _buildStep(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return _genderStep();
      case 1:
        return _ageStep();
      case 2:
        return _weightStep();
      case 3:
        return _heightStep();
      case 4:
        return _goalStep();
      case 5:
        return _trainingStep();
      default:
        return const SizedBox();
    }
  }

  // ======================================================
  //                   STEPS
  // ======================================================

  Widget _genderStep() {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Column(
          key: const ValueKey('gender'),
          children: [
            const SizedBox(height: 10),
            Text(
              "Let's start simple — what's your gender?",
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 20,
                fontFamily: 'LindenHill',
                fontStyle: FontStyle.normal,
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
      },
    );
  }

  Widget _genderButton(String label, IconData icon) {
    final isSelected = gender == label;
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return GestureDetector(
          onTap: () => setState(() => gender = label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.yellow : AppTheme.darkSurface,
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 120,
                  color: isSelected
                      ? Colors.black
                      : (isDarkMode ? Colors.white : Colors.black),
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
                    color: isSelected
                        ? Colors.black
                        : (isDarkMode ? Colors.white70 : Colors.black54),
                    fontFamily: 'Livvic',
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 6,
                        color: Colors.black45,
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
  }

  Widget _ageStep() {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Column(
          key: const ValueKey('age'),
          children: [
            Text(
              "Cool — how old are you?",
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment(0, -0.15),
                    child: Container(
                      height: 9,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 60),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.yellowAccent,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment(0, 0.15),
                    child: Container(
                      height: 9,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 60),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.yellowAccent,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: buildPicker(
                      ages,
                      age ?? '21',
                      isDarkMode,
                      (val) => setState(() => age = val),
                      fontSize: 36,
                      selectedHeight: 260,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _weightStep() {
    final List<String> weights = selectedUnitWeight == 'kg'
        ? weightsKg
        : weightsLbs;
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Column(
          key: const ValueKey('weight'),
          children: [
            Text(
              "Almost done 💪 — what's your current weight?",
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
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
                  onChanged: (val) {
                    setState(() {
                      // If the unit actually changed
                      if (selectedUnitWeight != val) {
                        // Convert the current value before switching
                        double numericValue =
                            double.tryParse(selectedWeight) ?? 0;

                        if (val == 'kg') {
                          // Convert from lbs → kg
                          double converted = numericValue / 2.20462;
                          selectedWeight = converted.round().toString();
                        } else {
                          // Convert from kg → lbs
                          double converted = numericValue * 2.20462;
                          selectedWeight = converted.round().toString();
                        }

                        selectedUnitWeight = val;
                      }
                    });
                  },
                ),
              ],
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment(0, -0.15),
                    child: Container(
                      height: 9,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 60),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.yellowAccent,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment(0, 0.15),
                    child: Container(
                      height: 9,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 60),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.yellowAccent,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: buildPicker(
                      weights, // List<String> items
                      selectedWeight, // String selectedValue
                      isDarkMode,
                      (val) => setState(() => selectedWeight = val), // Callback
                      fontSize: 36,
                      selectedHeight: 280, // Named parameter
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _heightStep() {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Column(
          key: const ValueKey('height'),
          children: [
            Text(
              "And how tall are you?",
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
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
                  onChanged: (val) => setState(() => selectedHeightUnit = val),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: selectedHeightUnit == 'cm'
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment(0, -0.15),
                          child: Container(
                            height: 9,
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 60),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.yellowAccent,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment(0, 0.15),
                          child: Container(
                            height: 9,
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 60),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.yellowAccent,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: buildPicker(
                            cmHeights,
                            selectedHeightCm,
                            isDarkMode,
                            (val) {
                              setState(() => selectedHeightCm = val);
                            },
                            fontSize: 20.0,
                            selectedHeight: 280,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ============ FEET PICKER ============
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Align(
                                alignment: const Alignment(0, -0.15),
                                child: Container(
                                  height: 4,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.yellowAccent,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: const Alignment(0, 0.15),
                                child: Container(
                                  height: 4,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.yellowAccent,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: buildPicker(
                                  ftHeights,
                                  selectedHeightFt,
                                  isDarkMode,
                                  (val) =>
                                      setState(() => selectedHeightFt = val),
                                  fontSize: 28.0,
                                  selectedHeight: 240,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // ============ INCH PICKER ============
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Align(
                                alignment: const Alignment(0, -0.15),
                                child: Container(
                                  height: 4,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.yellowAccent,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: const Alignment(0, 0.15),
                                child: Container(
                                  height: 4,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.yellowAccent,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: buildPicker(
                                  inHeights,
                                  selectedHeightIn,
                                  isDarkMode,
                                  (val) =>
                                      setState(() => selectedHeightIn = val),
                                  fontSize: 28.0,
                                  selectedHeight: 240,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _goalStep() {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Column(
          key: const ValueKey('goal'),
          children: [
            Text(
              "What's your main goal right now?",
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            ...goals.map((goal) {
              final selected = selectedGoal == goal;
              return Padding(
                padding: const EdgeInsets.only(bottom: 18.0),
                child: GestureDetector(
                  onTap: () => setState(() => selectedGoal = goal),
                  child: Row(
                    children: [
                      Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDarkMode ? Colors.white : Colors.black,
                            width: 2,
                          ),
                          color: selected
                              ? (isDarkMode ? Colors.white70 : Colors.black12)
                              : Colors.transparent,
                        ),
                        child: selected
                            ? const Icon(
                                Icons.check,
                                color: AppTheme.darkBackground,
                                size: 20,
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        goal,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
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
      },
    );
  }

  Widget _trainingStep() {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Column(
          key: const ValueKey('training'),
          children: [
            Text(
              "Finally, let's find your perfect rhythm 💪\nHow many days a week do you want to train?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),

            // 🔹 Wrap row in a SizedBox or Expanded to give height
            SizedBox(
              height: 350, // ensures enough space for picker + bars
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 🔹 The picker area
                  Expanded(
                    flex: 1,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: const Alignment(0, -0.15),
                          child: Container(
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 60),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.yellowAccent,
                            ),
                          ),
                        ),
                        Align(
                          alignment: const Alignment(0, 0.15),
                          child: Container(
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 60),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.yellowAccent,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: buildPicker(
                            trainingDays,
                            selectedTrainingDays,
                            isDarkMode,
                            (val) => setState(() => selectedTrainingDays = val),
                            fontSize: 32.0,
                            selectedHeight: 240,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 🔹 Text label next to picker
                  Text(
                    'Days/week',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
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
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ],
        );
      },
    );
  }

  // Shared "Select" button
  Widget _buildBottomButton() {
    return ElevatedButton(
      onPressed: _next,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.yellow,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      ),
      child: Text(
        _currentStep == 5 ? "Finish" : "Select",
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _getTrainingMessage(String days) {
    switch (days) {
      case '2':
        return "Perfect start! Two focused sessions are enough to build momentum 💪";
      case '3':
        return "Three days a week? That’s a smart, sustainable routine 🔥";
      case '4':
        return "Nice! Four sessions give a great balance of intensity and recovery ⚖️";
      case '5':
        return "Five days — now we’re getting serious! Let’s push your limits 💥";
      case '6':
        return "Six days? You’re in beast mode 😤 — recovery will be key here.";
      case '7':
        return "Every day?! That’s elite dedication 🏆 — Corely will help you stay balanced.";
      default:
        return "Choose what fits your life — Corely adapts to you.";
    }
  }
}
