import 'package:hive/hive.dart';

part 'workout_exercise.g.dart';

@HiveType(typeId: 1)
class WorkoutExercise {
  @HiveField(0)
  final String exerciseId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String muscleGroup;

  @HiveField(4)
  final Map<String, dynamic> parameters;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  WorkoutExercise({
    required this.exerciseId,
    required this.name,
    required this.category,
    required this.muscleGroup,
    required this.parameters,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Format parameters for display (e.g., "4 × 8 • 185 lbs")
  String get formattedParameters {
    final parts = <String>[];

    if (parameters.containsKey('sets') && parameters.containsKey('reps')) {
      parts.add('${parameters['sets']} × ${parameters['reps']}');
    }

    if (parameters.containsKey('weight')) {
      final unit = parameters['weightUnit'] ?? 'lbs';
      parts.add('${parameters['weight']} $unit');
    }

    if (parameters.containsKey('duration')) {
      final duration = parameters['duration'];
      if (duration is int) {
        parts.add('$duration min');
      } else {
        parts.add(duration.toString());
      }
    }

    if (parameters.containsKey('distance')) {
      final unit = parameters['distanceUnit'] ?? 'miles';
      parts.add('${parameters['distance']} $unit');
    }

    if (parameters.containsKey('holdDuration')) {
      parts.add('${parameters['holdDuration']} sec hold');
    }

    return parts.join(' • ');
  }

  /// Convert to JSON (for MongoDB migration)
  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'name': name,
    'category': category,
    'muscleGroup': muscleGroup,
    'parameters': parameters,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// Create from JSON (for MongoDB migration)
  factory WorkoutExercise.fromJson(Map<String, dynamic> json) =>
      WorkoutExercise(
        exerciseId: json['exerciseId'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        muscleGroup: json['muscleGroup'] as String,
        parameters: Map<String, dynamic>.from(json['parameters'] as Map),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );

  /// Create a copy with updated fields
  WorkoutExercise copyWith({
    String? exerciseId,
    String? name,
    String? category,
    String? muscleGroup,
    Map<String, dynamic>? parameters,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WorkoutExercise(
    exerciseId: exerciseId ?? this.exerciseId,
    name: name ?? this.name,
    category: category ?? this.category,
    muscleGroup: muscleGroup ?? this.muscleGroup,
    parameters: parameters ?? this.parameters,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
