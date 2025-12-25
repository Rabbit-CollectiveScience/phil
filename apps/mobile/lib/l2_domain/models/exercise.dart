import 'exercise_type_enum.dart';

abstract class Exercise {
  final String id;
  final String name;
  final String
  description; // Description of the exercise (instructions, notes, etc.)
  final ExerciseTypeEnum type;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
  });
}
