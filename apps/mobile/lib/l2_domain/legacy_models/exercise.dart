import 'exercise_field.dart';

// Model: Exercise with flexible field-based tracking
//
// Purpose:
// - Defines an exercise with metadata and trackable fields
// - Single class handles all exercise types (strength, cardio)
// - Uses categories as tags for filtering (activity type + body parts)
// - Fields list defines what data the exercise tracks
//
// Examples:
// - Barbell Curl: categories=["strength", "arms"], fields=[weight, reps]
// - Deadlift: categories=["strength", "back", "legs", "core"], fields=[weight, reps]
// - Treadmill: categories=["cardio"], fields=[duration, speed]

class Exercise {
  final String id;
  final String name;
  final String
  description; // Description of the exercise (instructions, notes, etc.)
  final List<String>
  categories; // Tags for filtering: activity type + body parts
  final List<ExerciseField> fields; // Defines what this exercise tracks

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.categories,
    required this.fields,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    // Support both new format (categories) and old format (type)
    List<String> categories;

    if (json.containsKey('categories')) {
      // New format: parse categories array
      categories = (json['categories'] as List<dynamic>)
          .map((e) => e as String)
          .toList();
    } else if (json.containsKey('type')) {
      // Old format: convert type to categories array
      final typeString = json['type'] as String;
      categories = [typeString.toLowerCase()];
    } else {
      // Fallback: default to strength
      categories = ['strength'];
    }

    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      categories: categories,
      fields: (json['fields'] as List<dynamic>)
          .map(
            (fieldJson) =>
                ExerciseField.fromJson(fieldJson as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
