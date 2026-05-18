class WorkoutSplit {
  final String name; // e.g., "Upper/Lower", "Push Pull Legs"
  final List<WorkoutDay> days;

  WorkoutSplit({required this.name, required this.days});
}

class WorkoutDay {
  final String name; // e.g., "Upper Day"
  final int durationMinutes; // e.g., 60
  final String gymType; // e.g., "Large Gym", "Home", "Minimal Equipment"
  final List<ExerciseModel> exercises;

  WorkoutDay({
    required this.name,
    required this.durationMinutes,
    required this.gymType,
    required this.exercises,
  });
}

class ExerciseModel {
  final String title; // e.g., "Decline Bench Press"
  final String iconPath; // e.g., "assets/ex_icons/decline.png"
  final int sets; // e.g., 4
  final String reps; // e.g., "10–12"
  final double weight; // e.g., 15.0
  final int rpe; // e.g., 8 or 9
  final List<String> muscles; // e.g., ["Chest", "Triceps"]

  ExerciseModel({
    required this.title,
    required this.iconPath,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.rpe,
    required this.muscles,
  });
}

class TrainingPlan {
  final String title; // e.g., "Candito 5/3/1"
  final String imagePath; // e.g., "assets/plans/candito.png"

  TrainingPlan({required this.title, required this.imagePath});
}
