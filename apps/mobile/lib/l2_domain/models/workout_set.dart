import 'package:hive/hive.dart';

part 'workout_set.g.dart';

// Model: Recorded workout set data
//
// Purpose:
// - Stores completed workout data for a specific exercise
// - Values keys correspond to Exercise.fields[].name
// - Always used with Exercise context to interpret values
// - Values can be null if user didn't input data yet
//
// Examples:
// - Squat set: {'weight': 100, 'reps': 10, 'unit': 'kg'}
// - Run set: {'durationInSeconds': 1800, 'distance': 5.0, 'unit': 'km'}
// - Stretch set: {'holdTimeInSeconds': 30, 'reps': 3}
// - No input yet: {} or null values

@HiveType(typeId: 0)
class WorkoutSet extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String exerciseId;

  @HiveField(2)
  final DateTime completedAt;

  @HiveField(3)
  final Map<String, dynamic>? values; // Keys match Exercise.fields[].name, nullable

  WorkoutSet({
    required this.id,
    required this.exerciseId,
    required this.completedAt,
    this.values,
  });

  // Convert to JSON for debugging/logging
  Map<String, dynamic> toJson() => {
    'id': id,
    'exerciseId': exerciseId,
    'completedAt': completedAt.toIso8601String(),
    'values': values,
  };

  // Create from JSON
  factory WorkoutSet.fromJson(Map<String, dynamic> json) => WorkoutSet(
    id: json['id'] as String,
    exerciseId: json['exerciseId'] as String,
    completedAt: DateTime.parse(json['completedAt'] as String),
    values: json['values'] as Map<String, dynamic>?,
  );
}
