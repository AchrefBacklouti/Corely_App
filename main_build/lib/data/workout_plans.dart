enum PlanCategory { cardio, strength, hypertrophy, calisthenics }

String? _cleanAssetPath(String? value) {
  if (value == null) return null;
  final cleaned = value.trim().replaceFirst(RegExp(r'^-\s+'), '');
  return cleaned.isEmpty ? null : cleaned;
}

class WorkoutDay {
  final String label; // e.g. "Day 1 – Push"
  final List<String>
  exercises; // e.g. ["Bench Press 4×8", "Incline DB Press 3×10"]

  const WorkoutDay({required this.label, required this.exercises});

  factory WorkoutDay.fromJson(Map<String, dynamic> json) {
    return WorkoutDay(
      label: json['label'] as String? ?? '',
      exercises:
          (json['exercises'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {'label': label, 'exercises': exercises};
}

class WorkoutPlan {
  final String title;
  final String duration; // e.g. "45 min"
  final String exercises; // short summary e.g. "6 exercises"
  final String? imageAsset;
  final String? imagePath; // user-picked local image
  final int difficulty; // 1–4
  final PlanCategory? category;
  final String? description; // intro paragraph shown in detail sheet
  final List<WorkoutDay>? days;
  final String? credit;
  final String? creditUrl;

  // ── Custom-plan fields (used by EditPlanPage / PlayPlanPage) ──
  final List<dynamic> dayExercises; // List<List<Map<String,dynamic>>>
  final List<String> dayNames; // custom label per day
  final List<String> selectedDays; // e.g. ["Monday", "Wednesday", "Friday"]

  const WorkoutPlan({
    required this.title,
    required this.duration,
    required this.exercises,
    this.imageAsset,
    this.imagePath,
    this.difficulty = 2,
    this.category,
    this.description,
    this.days,
    this.credit,
    this.creditUrl,
    this.dayExercises = const [],
    this.dayNames = const [],
    this.selectedDays = const [],
  });

  // ── JSON deserialisation ──────────────────────
  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    // category
    PlanCategory? category;
    final catRaw = json['category'] as String?;
    if (catRaw != null) {
      category = PlanCategory.values.firstWhere(
        (e) => e.name == catRaw,
        orElse: () => PlanCategory.strength,
      );
    }

    // WorkoutDay list (used by suggested plans stored as JSON)
    List<WorkoutDay>? days;
    final rawDays = json['days'];
    if (rawDays is List && rawDays.isNotEmpty) {
      days = rawDays
          .whereType<Map>()
          .map((d) => WorkoutDay.fromJson(Map<String, dynamic>.from(d)))
          .toList();
    }

    // dayExercises — stored as List<List<Map>> in Hive / JSON
    final rawDayEx = json['dayExercises'];
    final List<dynamic> dayExercises = rawDayEx is List
        ? List<dynamic>.from(rawDayEx)
        : [];

    // dayNames
    final rawDayNames = json['dayNames'];
    final List<String> dayNames = rawDayNames is List
        ? rawDayNames.map((e) => e.toString()).toList()
        : [];

    // selectedDays
    final rawSelectedDays = json['selectedDays'];
    final List<String> selectedDays = rawSelectedDays is List
        ? rawSelectedDays.map((e) => e.toString()).toList()
        : [];

    return WorkoutPlan(
      title: json['title'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      exercises: json['exercises'] as String? ?? '',
      imageAsset: _cleanAssetPath(json['imageAsset'] as String?),
      imagePath: _cleanAssetPath(json['imagePath'] as String?),
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 2,
      category: category,
      description: json['description'] as String?,
      days: days,
      credit: json['credit'] as String?,
      creditUrl: json['creditUrl'] as String?,
      dayExercises: dayExercises,
      dayNames: dayNames,
      selectedDays: selectedDays,
    );
  }

  // ── JSON serialisation ────────────────────────
  Map<String, dynamic> toJson() => {
    'title': title,
    'duration': duration,
    'exercises': exercises,
    if (imageAsset != null) 'imageAsset': imageAsset,
    if (imagePath != null) 'imagePath': imagePath,
    'difficulty': difficulty,
    if (category != null) 'category': category!.name,
    if (description != null) 'description': description,
    if (days != null) 'days': days!.map((d) => d.toJson()).toList(),
    if (credit != null) 'credit': credit,
    if (creditUrl != null) 'creditUrl': creditUrl,
    'dayExercises': dayExercises,
    'dayNames': dayNames,
    'selectedDays': selectedDays,
  };

  // ── copyWith ──────────────────────────────────
  WorkoutPlan copyWith({
    String? title,
    String? duration,
    String? exercises,
    String? imageAsset,
    String? imagePath,
    int? difficulty,
    PlanCategory? category,
    String? description,
    List<WorkoutDay>? days,
    String? credit,
    String? creditUrl,
    List<dynamic>? dayExercises,
    List<String>? dayNames,
    List<String>? selectedDays,
  }) {
    return WorkoutPlan(
      title: title ?? this.title,
      duration: duration ?? this.duration,
      exercises: exercises ?? this.exercises,
      imageAsset: _cleanAssetPath(imageAsset ?? this.imageAsset),
      imagePath: _cleanAssetPath(imagePath ?? this.imagePath),
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      description: description ?? this.description,
      days: days ?? this.days,
      credit: credit ?? this.credit,
      creditUrl: creditUrl ?? this.creditUrl,
      dayExercises: dayExercises ?? this.dayExercises,
      dayNames: dayNames ?? this.dayNames,
      selectedDays: selectedDays ?? this.selectedDays,
    );
  }
}

// ─────────────────────────────────────────────
// Catalogue of suggested plans
// ─────────────────────────────────────────────
const List<WorkoutPlan> kSuggestedPlans = [
  // ── STRENGTH ─────────────────────────────────
  WorkoutPlan(
    title: 'Push / Pull / Legs',
    duration: '75 min',
    exercises: '18 exercises',
    imageAsset: 'assets/img/plans/gsb.png',
    difficulty: 3,
    category: PlanCategory.strength,
    description:
        'A classic 6-day-a-week programme that divides training into '
        'push movements (chest, shoulders, triceps), pull movements '
        '(back, biceps) and leg days. Each muscle group is hit twice a '
        'week for maximum strength and size gains.',
    days: [
      WorkoutDay(
        label: 'Day 1 – Push A',
        exercises: [
          'Bench Press 4×5',
          'Overhead Press 3×6',
          'Incline DB Press 3×8',
          'Lateral Raises 4×12',
          'Tricep Pushdown 3×12',
          'Overhead Tricep Extension 3×12',
        ],
      ),
      WorkoutDay(
        label: 'Day 2 – Pull A',
        exercises: [
          'Deadlift 4×5',
          'Barbell Row 4×6',
          'Lat Pulldown 3×10',
          'Face Pulls 4×15',
          'Barbell Curl 3×10',
          'Hammer Curl 3×12',
        ],
      ),
      WorkoutDay(
        label: 'Day 3 – Legs A',
        exercises: [
          'Squat 4×5',
          'Romanian Deadlift 3×8',
          'Leg Press 3×12',
          'Leg Curl 3×12',
          'Calf Raises 5×15',
          'Leg Extension 3×15',
        ],
      ),
      WorkoutDay(
        label: 'Day 4 – Push B',
        exercises: [
          'Overhead Press 4×5',
          'Incline Bench Press 4×8',
          'Cable Fly 3×12',
          'Lateral Raises 4×15',
          'Skull Crushers 3×12',
          'Dips 3×12',
        ],
      ),
      WorkoutDay(
        label: 'Day 5 – Pull B',
        exercises: [
          'Pull-ups 4×6',
          'Pendlay Row 4×6',
          'Seated Cable Row 3×10',
          'Chest-Supported Row 3×10',
          'Preacher Curl 3×10',
          'Cable Curl 3×15',
        ],
      ),
      WorkoutDay(
        label: 'Day 6 – Legs B',
        exercises: [
          'Front Squat 4×5',
          'Hack Squat 3×10',
          'Bulgarian Split Squat 3×10',
          'Lying Leg Curl 3×12',
          'Hip Thrust 3×12',
          'Standing Calf Raise 5×20',
        ],
      ),
    ],
  ),

  WorkoutPlan(
    title: '5×5 Stronglifts',
    duration: '60 min',
    exercises: '5 exercises',
    imageAsset: 'assets/img/plans/candito.png',
    difficulty: 2,
    category: PlanCategory.strength,
    description:
        'A 3-day-a-week beginner strength programme. You alternate between '
        'Workout A and Workout B, adding 2.5 kg to every lift each session. '
        'Simple, proven, and brutally effective for building a strength base.',
    days: [
      WorkoutDay(
        label: 'Workout A',
        exercises: ['Squat 5×5', 'Bench Press 5×5', 'Barbell Row 5×5'],
      ),
      WorkoutDay(
        label: 'Workout B',
        exercises: ['Squat 5×5', 'Overhead Press 5×5', 'Deadlift 1×5'],
      ),
    ],
  ),

  WorkoutPlan(
    title: 'Starting Strength',
    duration: '50 min',
    exercises: '4 exercises',
    imageAsset: 'assets/img/plans/dumbells.jpg',
    difficulty: 1,
    category: PlanCategory.strength,
    description:
        'Mark Rippetoe\'s foundational novice programme. 3 days per week, '
        'alternating A/B sessions. Focuses exclusively on the big barbell '
        'lifts to build a solid strength foundation as fast as possible.',
    days: [
      WorkoutDay(
        label: 'Session A',
        exercises: ['Squat 3×5', 'Bench Press 3×5', 'Deadlift 1×5'],
      ),
      WorkoutDay(
        label: 'Session B',
        exercises: [
          'Squat 3×5',
          'Overhead Press 3×5',
          'Deadlift 1×5',
          'Power Clean 5×3',
        ],
      ),
    ],
  ),

  // ── HYPERTROPHY ───────────────────────────────
  WorkoutPlan(
    title: 'Upper / Lower Split',
    duration: '70 min',
    exercises: '14 exercises',
    imageAsset: 'assets/img/plans/wendler.png',
    difficulty: 2,
    category: PlanCategory.hypertrophy,
    description:
        'A 4-day-a-week upper/lower split designed for hypertrophy. '
        'Each muscle group is trained twice a week with a mix of heavy '
        'compound work and higher-rep isolation movements.',
    days: [
      WorkoutDay(
        label: 'Day 1 – Upper A',
        exercises: [
          'Bench Press 4×8',
          'Barbell Row 4×8',
          'Overhead Press 3×10',
          'Lat Pulldown 3×10',
          'Lateral Raises 3×15',
          'Barbell Curl 3×12',
          'Tricep Pushdown 3×12',
        ],
      ),
      WorkoutDay(
        label: 'Day 2 – Lower A',
        exercises: [
          'Squat 4×8',
          'Romanian Deadlift 3×10',
          'Leg Press 3×12',
          'Leg Curl 3×12',
          'Calf Raises 4×15',
        ],
      ),
      WorkoutDay(
        label: 'Day 3 – Upper B',
        exercises: [
          'Incline DB Press 4×10',
          'Cable Row 4×10',
          'Arnold Press 3×12',
          'Pull-ups 3×8',
          'Cable Fly 3×15',
          'Hammer Curl 3×12',
          'Overhead Tricep Extension 3×12',
        ],
      ),
      WorkoutDay(
        label: 'Day 4 – Lower B',
        exercises: [
          'Deadlift 4×6',
          'Hack Squat 3×12',
          'Bulgarian Split Squat 3×10',
          'Lying Leg Curl 3×12',
          'Hip Thrust 3×15',
        ],
      ),
    ],
  ),

  WorkoutPlan(
    title: 'PHAT Programme',
    duration: '80 min',
    exercises: '20 exercises',
    imageAsset: 'assets/img/plans/Phenq.jpg',
    difficulty: 4,
    category: PlanCategory.hypertrophy,
    description:
        'Power Hypertrophy Adaptive Training — a 5-day programme by '
        'Dr Layne Norton that combines heavy power work early in the week '
        'with higher-volume hypertrophy work later. Ideal for intermediate '
        'to advanced lifters chasing both size and strength.',
    days: [
      WorkoutDay(
        label: 'Day 1 – Upper Power',
        exercises: [
          'Bench Press 3×3–5',
          'Barbell Row 3×3–5',
          'Overhead Press 3×5',
          'Weighted Pull-ups 3×5',
          'Barbell Curl 3×5',
          'Skull Crushers 3×6',
        ],
      ),
      WorkoutDay(
        label: 'Day 2 – Lower Power',
        exercises: [
          'Squat 3×3–5',
          'Deadlift 3×3–5',
          'Leg Press 3×10',
          'Leg Curl 3×8',
        ],
      ),
      WorkoutDay(
        label: 'Day 3 – Rest / Cardio',
        exercises: ['20–30 min light cardio'],
      ),
      WorkoutDay(
        label: 'Day 4 – Back & Shoulders Hypertrophy',
        exercises: [
          'Incline DB Row 4×12',
          'Seated Cable Row 4×12',
          'Lat Pulldown 3×12',
          'Dumbbell Shoulder Press 4×12',
          'Lateral Raises 4×15',
          'Face Pulls 4×15',
        ],
      ),
      WorkoutDay(
        label: 'Day 5 – Lower Hypertrophy',
        exercises: [
          'Hack Squat 4×12',
          'Leg Press 4×15',
          'Leg Extension 3×15',
          'Lying Leg Curl 4×12',
          'Standing Calf Raise 5×15',
        ],
      ),
      WorkoutDay(
        label: 'Day 6 – Chest & Arms Hypertrophy',
        exercises: [
          'Incline Bench Press 4×12',
          'Cable Fly 4×15',
          'Dumbbell Press 3×12',
          'Preacher Curl 4×12',
          'Cable Curl 3×15',
          'Tricep Pushdown 4×12',
          'Overhead Tricep Extension 3×15',
        ],
      ),
    ],
  ),

  WorkoutPlan(
    title: 'Arnold Split',
    duration: '75 min',
    exercises: '16 exercises',
    imageAsset: 'assets/img/plans/dumbells.jpg',
    difficulty: 3,
    category: PlanCategory.hypertrophy,
    description:
        'The 6-day split Arnold Schwarzenegger used during his Mr. Olympia '
        'years. Chest & Back are trained together to create a massive pump; '
        'Shoulders & Arms are paired; Legs get a full day. Each grouping '
        'is repeated twice a week.',
    days: [
      WorkoutDay(
        label: 'Day 1 & 4 – Chest & Back',
        exercises: [
          'Bench Press 4×10',
          'Incline DB Press 4×10',
          'Cable Fly 3×12',
          'Pull-ups 4×10',
          'Barbell Row 4×10',
          'One-Arm DB Row 3×12',
        ],
      ),
      WorkoutDay(
        label: 'Day 2 & 5 – Shoulders & Arms',
        exercises: [
          'Arnold Press 4×10',
          'Lateral Raises 4×12',
          'Front Raises 3×12',
          'Barbell Curl 4×10',
          'Incline DB Curl 3×12',
          'Skull Crushers 4×10',
          'Cable Pushdown 3×12',
        ],
      ),
      WorkoutDay(
        label: 'Day 3 & 6 – Legs',
        exercises: [
          'Squat 5×10',
          'Leg Press 4×12',
          'Leg Curl 4×12',
          'Calf Raises 6×15',
          'Leg Extension 3×15',
        ],
      ),
    ],
  ),

  // ── CARDIO ────────────────────────────────────
  WorkoutPlan(
    title: 'Couch to 5K',
    duration: '30 min',
    exercises: 'Run / Walk intervals',
    imageAsset: 'assets/img/plans/cardio_1.webp',
    difficulty: 1,
    category: PlanCategory.cardio,
    description:
        'A beginner-friendly 9-week running programme that gradually '
        'increases running intervals until you can run 5 km non-stop. '
        '3 sessions per week. No equipment needed beyond a good pair of shoes.',
    days: [
      WorkoutDay(
        label: 'Week 1 (×3)',
        exercises: [
          '5 min brisk walk warm-up',
          '8× (60 s run + 90 s walk)',
          '5 min cool-down walk',
        ],
      ),
      WorkoutDay(
        label: 'Week 3 (×3)',
        exercises: [
          '5 min brisk walk warm-up',
          '2× (90 s run + 90 s walk + 3 min run + 3 min walk)',
          '5 min cool-down',
        ],
      ),
      WorkoutDay(
        label: 'Week 5 – Day 3 (milestone)',
        exercises: [
          '5 min brisk walk warm-up',
          '20 min continuous run',
          '5 min cool-down',
        ],
      ),
      WorkoutDay(
        label: 'Week 9 (×3)',
        exercises: [
          '5 min brisk walk warm-up',
          '30 min continuous run (≈5 km)',
          '5 min cool-down',
        ],
      ),
    ],
  ),

  WorkoutPlan(
    title: 'HIIT Fat Burner',
    duration: '25 min',
    exercises: '8 exercises',
    imageAsset: 'assets/img/plans/cardio_2.jpg',
    difficulty: 3,
    category: PlanCategory.cardio,
    description:
        'High-Intensity Interval Training designed to maximise calorie burn '
        'in minimum time. 4 days a week. Each session alternates 40 s of '
        'all-out effort with 20 s rest across 8 bodyweight movements.',
    days: [
      WorkoutDay(
        label: 'Session A (Mon & Thu)',
        exercises: [
          'Jump Squats 40 s / 20 s rest',
          'Push-ups 40 s / 20 s rest',
          'High Knees 40 s / 20 s rest',
          'Mountain Climbers 40 s / 20 s rest',
          'Burpees 40 s / 20 s rest',
          'Plank Shoulder Taps 40 s / 20 s rest',
          'Jump Lunges 40 s / 20 s rest',
          'Hollow Body Hold 40 s / 20 s rest',
          '× 3 rounds',
        ],
      ),
      WorkoutDay(
        label: 'Session B (Tue & Fri)',
        exercises: [
          'Sprint in place 40 s / 20 s rest',
          'Pike Push-ups 40 s / 20 s rest',
          'Lateral Jumps 40 s / 20 s rest',
          'V-ups 40 s / 20 s rest',
          'Box Jumps 40 s / 20 s rest',
          'Tricep Dips 40 s / 20 s rest',
          'Skaters 40 s / 20 s rest',
          'Bear Crawl 40 s / 20 s rest',
          '× 3 rounds',
        ],
      ),
    ],
  ),

  WorkoutPlan(
    title: 'Zone 2 Aerobic Base',
    duration: '45 min',
    exercises: 'Steady-state cardio',
    imageAsset: 'assets/img/plans/cardio_3.webp',
    difficulty: 1,
    category: PlanCategory.cardio,
    description:
        'A 4-week aerobic base-building block. All sessions are performed '
        'at low intensity (60–70 % max HR) to develop the aerobic engine '
        'without taxing the CNS. Ideal as active recovery between strength '
        'blocks or as a standalone health programme.',
    days: [
      WorkoutDay(
        label: 'Day 1 – Easy Run / Cycle',
        exercises: [
          '5 min warm-up walk',
          '35 min run or cycle at conversational pace (60–70 % HR max)',
          '5 min cool-down',
        ],
      ),
      WorkoutDay(
        label: 'Day 2 – Cross-Training',
        exercises: ['45 min rowing machine or elliptical at zone 2'],
      ),
      WorkoutDay(
        label: 'Day 3 – Long Slow Distance',
        exercises: ['60 min outdoor walk / jog at zone 2'],
      ),
      WorkoutDay(
        label: 'Day 4 – Easy Swim or Bike',
        exercises: ['40 min swim (easy) or stationary bike at zone 2'],
      ),
    ],
  ),
];
