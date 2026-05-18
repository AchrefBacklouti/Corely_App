class DailyWorkoutStats {
  final DateTime date;
  final int exercisesCompleted;
  final int totalSets;
  final int totalReps;
  final double totalVolume; // sum of (weight × reps × sets)
  final double durationMin; // workout duration
  final List<String> musclesTrained;

  DailyWorkoutStats({
    required this.date,
    required this.exercisesCompleted,
    required this.totalSets,
    required this.totalReps,
    required this.totalVolume,
    required this.durationMin,
    required this.musclesTrained,
  });
}

class WeeklyAnalytics {
  final DateTime startOfWeek;
  final DateTime endOfWeek;
  final List<DailyWorkoutStats> dailyStats;

  WeeklyAnalytics({
    required this.startOfWeek,
    required this.endOfWeek,
    required this.dailyStats,
  });

  double get totalVolume =>
      dailyStats.fold(0, (sum, day) => sum + day.totalVolume);

  int get workoutsCompleted => dailyStats.length;

  double get avgWorkoutDuration {
    if (dailyStats.isEmpty) return 0.0;

    final totalDuration = dailyStats.fold<double>(
      0.0,
      (sum, day) => sum + day.durationMin,
    );

    return totalDuration / dailyStats.length;
  }

  Map<String, int> get muscleFrequency {
    final map = <String, int>{};
    for (final day in dailyStats) {
      for (final muscle in day.musclesTrained) {
        map[muscle] = (map[muscle] ?? 0) + 1;
      }
    }
    return map;
  }
}

class PRRecord {
  final String exerciseName;
  final double weight;
  final int reps;
  final DateTime dateAchieved;

  PRRecord({
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.dateAchieved,
  });
}

class BodyWeightRecord {
  final DateTime date;
  final double weight;

  BodyWeightRecord({required this.date, required this.weight});
}

class UserAnalyticsOverview {
  final List<WeeklyAnalytics> weeklyData;
  final List<PRRecord> prRecords;
  final List<BodyWeightRecord> bodyWeightProgress;

  UserAnalyticsOverview({
    required this.weeklyData,
    required this.prRecords,
    required this.bodyWeightProgress,
  });
}
