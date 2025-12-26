import 'exercise_type_enum.dart';
import 'exercise_field.dart';

// Model: Exercise with flexible field-based tracking
//
// Purpose:
// - Defines an exercise with metadata and trackable fields
// - Single class handles all exercise types (strength, cardio, flexibility)
// - Fields list defines what data the exercise tracks
//
// Examples:
// - Squat: [weight, reps] fields
// - Running: [duration, distance, pace] fields
// - Stretching: [holdTime, reps] fields
// - Custom: User-defined fields

class Exercise {
  final String id;
  final String name;
  final String
  description; // Description of the exercise (instructions, notes, etc.)
  final ExerciseTypeEnum type;
  final List<ExerciseField> fields; // Defines what this exercise tracks

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.fields,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: _parseExerciseType(json['type'] as String),
      fields: (json['fields'] as List<dynamic>)
          .map(
            (fieldJson) =>
                ExerciseField.fromJson(fieldJson as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  static ExerciseTypeEnum _parseExerciseType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'strength':
        return ExerciseTypeEnum.strength;
      case 'cardio':
        return ExerciseTypeEnum.cardio;
      case 'flexibility':
        return ExerciseTypeEnum.flexibility;
      default:
        return ExerciseTypeEnum.strength; // Default fallback
    }
  }
}
