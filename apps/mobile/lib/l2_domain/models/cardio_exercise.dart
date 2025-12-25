import 'exercise.dart';
import 'exercise_type_enum.dart';

class CardioExercise extends Exercise {
  final int duration;
  final int? level;
  final String? levelUnit;

  CardioExercise({
    required super.id,
    required super.name,
    required this.duration,
    this.level,
    this.levelUnit,
  }) : super(type: ExerciseTypeEnum.cardio);
}
