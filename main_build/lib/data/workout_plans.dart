class WorkoutPlan {
  final String title;
  final String duration;
  final String exercises;
  final String imageAsset;
  final int difficulty;

  const WorkoutPlan({
    required this.title,
    required this.duration,
    required this.exercises,
    required this.imageAsset,
    required this.difficulty,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      title: json['title'] as String,
      duration: json['duration'] as String,
      exercises: json['exercises'] as String,
      imageAsset: json['imageAsset'] as String,
      difficulty: (json['difficulty'] as num).toInt(),
    );
  }
}

const List<WorkoutPlan> customWorkoutPlans = [
  WorkoutPlan(
    title: "Push day",
    duration: "45 mins",
    exercises: "6 moves",
    imageAsset: 'assets/img/logo_light.png',
    difficulty: 2,
  ),
  WorkoutPlan(
    title: "Lower body",
    duration: "50 mins",
    exercises: "7 moves",
    imageAsset: 'assets/img/logo_light.png',
    difficulty: 3,
  ),
  WorkoutPlan(
    title: "Core burner",
    duration: "20 mins",
    exercises: "4 moves",
    imageAsset: 'assets/img/logo_light.png',
    difficulty: 2,
  ),
];

const List<WorkoutPlan> suggestedWorkoutPlans = [
  WorkoutPlan(
    title: "Full body express",
    duration: "30 mins",
    exercises: "5 moves",
    imageAsset: 'assets/img/logo_light.png',
    difficulty: 2,
  ),
  WorkoutPlan(
    title: "Glutes & hamstrings",
    duration: "40 mins",
    exercises: "6 moves",
    imageAsset: 'assets/img/logo_light.png',
    difficulty: 3,
  ),
  WorkoutPlan(
    title: "HIIT cardio",
    duration: "18 mins",
    exercises: "6 rounds",
    imageAsset: 'assets/img/logo_light.png',
    difficulty: 4,
  ),
];
