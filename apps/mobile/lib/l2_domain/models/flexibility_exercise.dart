import 'exercise.dart';
import 'exercise_type_enum.dart';

class FlexibilityExercise extends Exercise {
  final int holdTime;
  final int reps;

  FlexibilityExercise({
    required super.id,
    required super.name,
    required this.holdTime,
    required this.reps,
  }) : super(type: ExerciseTypeEnum.flexibility);
}
