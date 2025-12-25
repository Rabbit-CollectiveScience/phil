import 'exercise_type_enum.dart';

abstract class Exercise {
  final String id;
  final String name;
  final ExerciseTypeEnum type;

  Exercise({
    required this.id,
    required this.name,
    required this.type,
  });
}
