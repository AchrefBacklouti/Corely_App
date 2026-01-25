class WorkoutPlan {
  final String title;
  final String duration;
  final String exercises;
  final String imageAsset;
  final String? imagePath; // Optional user-selected image file path
  final int difficulty;
  final List<dynamic> dayExercises;
  final List<String>
  dayNames; // Custom names for each day (e.g., "Pull Day", "Lower Body")
  final List<String>
  selectedDays; // Weekdays (e.g., ["Monday", "Wednesday", "Friday"])

  const WorkoutPlan({
    required this.title,
    required this.duration,
    required this.exercises,
    required this.imageAsset,
    this.imagePath,
    required this.difficulty,
    this.dayExercises = const [],
    this.dayNames = const [],
    this.selectedDays = const [],
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      title: json['title'] as String,
      duration: json['duration'] as String,
      exercises: json['exercises'] as String,
      imageAsset: json['imageAsset'] as String,
      imagePath: json['imagePath'] as String?,
      difficulty: (json['difficulty'] as num).toInt(),
      dayExercises: json['dayExercises'] as List? ?? [],
      dayNames: List<String>.from(json['dayNames'] as List? ?? []),
      selectedDays: List<String>.from(json['selectedDays'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'duration': duration,
      'exercises': exercises,
      'imageAsset': imageAsset,
      'imagePath': imagePath,
      'difficulty': difficulty,
      'dayExercises': dayExercises,
      'dayNames': dayNames,
      'selectedDays': selectedDays,
    };
  }
}

const List<WorkoutPlan> customWorkoutPlans = [];

// Suggested plans with exercises pre-loaded for each day
const List<WorkoutPlan> suggestedWorkoutPlans = [
  WorkoutPlan(
    title: "Push-Pull-Leg",
    duration: "75 mins",
    exercises: "18 exercises",
    imageAsset: 'assets/img/logo_light.png',
    difficulty: 4,
    selectedDays: ['Monday', 'Wednesday', 'Friday'],
    dayNames: ['Push Day', 'Pull Day', 'Leg Day'],
    dayExercises: [
      // Monday - Push Day
      [
        {'name': 'Bench Press', 'sets': '4', 'reps': '6-8', 'rest': '2 min'},
        {
          'name': 'Incline Dumbbell Press',
          'sets': '3',
          'reps': '8-10',
          'rest': '90 sec',
        },
        {'name': 'Tricep Dips', 'sets': '3', 'reps': '8-12', 'rest': '90 sec'},
        {
          'name': 'Lateral Raises',
          'sets': '3',
          'reps': '12-15',
          'rest': '60 sec',
        },
        {
          'name': 'Tricep Rope Pushdown',
          'sets': '3',
          'reps': '12-15',
          'rest': '60 sec',
        },
        {
          'name': 'Cable Crossover',
          'sets': '3',
          'reps': '12-15',
          'rest': '60 sec',
        },
      ],
      // Wednesday - Pull Day
      [
        {'name': 'Deadlift', 'sets': '3', 'reps': '5-6', 'rest': '2-3 min'},
        {
          'name': 'Weighted Pullups',
          'sets': '4',
          'reps': '6-8',
          'rest': '2 min',
        },
        {'name': 'Barbell Rows', 'sets': '4', 'reps': '8-10', 'rest': '90 sec'},
        {'name': 'Face Pulls', 'sets': '3', 'reps': '15-20', 'rest': '60 sec'},
        {
          'name': 'Barbell Curls',
          'sets': '3',
          'reps': '8-10',
          'rest': '90 sec',
        },
        {
          'name': 'Incline Dumbbell Curls',
          'sets': '3',
          'reps': '10-12',
          'rest': '60 sec',
        },
      ],
      // Friday - Leg Day
      [
        {'name': 'Squats', 'sets': '4', 'reps': '6-8', 'rest': '2-3 min'},
        {
          'name': 'Romanian Deadlift',
          'sets': '3',
          'reps': '8-10',
          'rest': '2 min',
        },
        {'name': 'Leg Press', 'sets': '3', 'reps': '8-12', 'rest': '90 sec'},
        {'name': 'Leg Curls', 'sets': '3', 'reps': '10-12', 'rest': '90 sec'},
        {
          'name': 'Leg Extensions',
          'sets': '3',
          'reps': '12-15',
          'rest': '60 sec',
        },
        {'name': 'Calf Raises', 'sets': '4', 'reps': '12-15', 'rest': '60 sec'},
      ],
    ],
  ),
  WorkoutPlan(
    title: "Upper-Lower Split",
    duration: "60 mins",
    exercises: "16 exercises",
    imageAsset: 'assets/img/logo_light.png',
    difficulty: 3,
    selectedDays: ['Monday', 'Tuesday', 'Thursday', 'Friday'],
    dayNames: ['Upper A', 'Lower A', 'Upper B', 'Lower B'],
    dayExercises: [
      // Monday - Upper A
      [
        {'name': 'Bench Press', 'sets': '4', 'reps': '6-8', 'rest': '2 min'},
        {'name': 'Barbell Rows', 'sets': '4', 'reps': '6-8', 'rest': '2 min'},
        {
          'name': 'Incline Dumbbell Press',
          'sets': '3',
          'reps': '8-10',
          'rest': '90 sec',
        },
        {
          'name': 'Lat Pulldowns',
          'sets': '3',
          'reps': '8-10',
          'rest': '90 sec',
        },
      ],
      // Tuesday - Lower A
      [
        {'name': 'Squats', 'sets': '4', 'reps': '6-8', 'rest': '2-3 min'},
        {'name': 'Leg Press', 'sets': '3', 'reps': '8-10', 'rest': '90 sec'},
        {'name': 'Leg Curls', 'sets': '3', 'reps': '8-10', 'rest': '90 sec'},
        {'name': 'Calf Raises', 'sets': '4', 'reps': '12-15', 'rest': '60 sec'},
      ],
      // Thursday - Upper B
      [
        {
          'name': 'Weighted Pullups',
          'sets': '4',
          'reps': '6-8',
          'rest': '2 min',
        },
        {
          'name': 'Dumbbell Press',
          'sets': '4',
          'reps': '8-10',
          'rest': '90 sec',
        },
        {'name': 'Seal Rows', 'sets': '3', 'reps': '8-10', 'rest': '90 sec'},
        {
          'name': 'Dumbbell Flyes',
          'sets': '3',
          'reps': '10-12',
          'rest': '60 sec',
        },
      ],
      // Friday - Lower B
      [
        {
          'name': 'Romanian Deadlift',
          'sets': '4',
          'reps': '6-8',
          'rest': '2 min',
        },
        {'name': 'Hack Squat', 'sets': '3', 'reps': '8-10', 'rest': '90 sec'},
        {
          'name': 'Leg Extensions',
          'sets': '3',
          'reps': '12-15',
          'rest': '90 sec',
        },
        {'name': 'Leg Curls', 'sets': '3', 'reps': '12-15', 'rest': '60 sec'},
      ],
    ],
  ),
  WorkoutPlan(
    title: "Full Body 3x/Week",
    duration: "50 mins",
    exercises: "15 exercises",
    imageAsset: 'assets/img/logo_light.png',
    difficulty: 2,
    selectedDays: ['Monday', 'Wednesday', 'Friday'],
    dayNames: ['Full Body A', 'Full Body B', 'Full Body C'],
    dayExercises: [
      // Monday - Full Body A
      [
        {'name': 'Barbell Squats', 'sets': '3', 'reps': '6-8', 'rest': '2 min'},
        {'name': 'Bench Press', 'sets': '3', 'reps': '6-8', 'rest': '2 min'},
        {'name': 'Barbell Rows', 'sets': '3', 'reps': '6-8', 'rest': '2 min'},
        {'name': 'Leg Press', 'sets': '2', 'reps': '10-12', 'rest': '90 sec'},
        {
          'name': 'Lat Pulldowns',
          'sets': '2',
          'reps': '10-12',
          'rest': '90 sec',
        },
      ],
      // Wednesday - Full Body B
      [
        {'name': 'Deadlifts', 'sets': '3', 'reps': '5-6', 'rest': '2-3 min'},
        {
          'name': 'Incline Dumbbell Press',
          'sets': '3',
          'reps': '8-10',
          'rest': '90 sec',
        },
        {
          'name': 'Weighted Pullups',
          'sets': '3',
          'reps': '6-8',
          'rest': '2 min',
        },
        {'name': 'Leg Curls', 'sets': '3', 'reps': '10-12', 'rest': '90 sec'},
        {
          'name': 'Dumbbell Rows',
          'sets': '3',
          'reps': '8-10',
          'rest': '90 sec',
        },
      ],
      // Friday - Full Body C
      [
        {'name': 'Front Squats', 'sets': '3', 'reps': '6-8', 'rest': '2 min'},
        {
          'name': 'Dumbbell Press',
          'sets': '3',
          'reps': '8-10',
          'rest': '90 sec',
        },
        {'name': 'Seal Rows', 'sets': '3', 'reps': '8-10', 'rest': '90 sec'},
        {
          'name': 'Leg Extensions',
          'sets': '2',
          'reps': '12-15',
          'rest': '60 sec',
        },
        {'name': 'Cable Curls', 'sets': '2', 'reps': '12-15', 'rest': '60 sec'},
      ],
    ],
  ),
];
