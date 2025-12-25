// Model: Recorded workout set data
//
// Purpose:
// - Stores completed workout data for a specific exercise
// - Values keys correspond to Exercise.fields[].name
// - Always used with Exercise context to interpret values
//
// Examples:
// - Squat set: {'weight': 100, 'reps': 10, 'unit': 'kg'}
// - Run set: {'durationInSeconds': 1800, 'distance': 5.0, 'unit': 'km'}
// - Stretch set: {'holdTimeInSeconds': 30, 'reps': 3}

class WorkoutSet {
  final String id;
  final String exerciseId;
  final DateTime completedAt;
  final Map<String, dynamic> values; // Keys match Exercise.fields[].name

  WorkoutSet({
    required this.id,
    required this.exerciseId,
    required this.completedAt,
    required this.values,
  });
}
