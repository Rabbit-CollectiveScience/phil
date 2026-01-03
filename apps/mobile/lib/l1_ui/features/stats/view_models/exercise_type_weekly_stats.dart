/// Exercise type weekly statistics view model
class ExerciseTypeWeeklyStats {
  final String type;
  final int exercises;
  final int sets;
  final double volume;
  final double? duration; // in minutes

  const ExerciseTypeWeeklyStats({
    required this.type,
    required this.exercises,
    required this.sets,
    required this.volume,
    this.duration,
  });

  factory ExerciseTypeWeeklyStats.fromMap(Map<String, dynamic> map) {
    return ExerciseTypeWeeklyStats(
      type: map['type'] as String,
      exercises: (map['exercises'] as num).toInt(),
      sets: (map['sets'] as num).toInt(),
      volume: (map['volume'] as num).toDouble(),
      duration: map['duration'] != null
          ? (map['duration'] as num).toDouble()
          : null,
    );
  }

  factory ExerciseTypeWeeklyStats.empty(String type) {
    return ExerciseTypeWeeklyStats(
      type: type,
      exercises: 0,
      sets: 0,
      volume: 0.0,
      duration: 0.0,
    );
  }
}
