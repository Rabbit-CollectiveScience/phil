import 'exercise.dart';
import 'exercise_type_enum.dart';

class CustomExercise extends Exercise {
  final Map<String, dynamic> fields;

  CustomExercise({
    required super.id,
    required super.name,
    required this.fields,
  }) : super(type: ExerciseTypeEnum.custom);
}
