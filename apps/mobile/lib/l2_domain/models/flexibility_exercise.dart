import 'exercise.dart';
import 'exercise_type_enum.dart';

class FlexibilityExercise extends Exercise {
  final int?
  holdTimeInSeconds; // Hold duration in seconds (e.g., 30 = 30 seconds)
  final int? reps; // Number of holds/repetitions

  FlexibilityExercise({
    required super.id,
    required super.name,
    this.holdTimeInSeconds,
    this.reps,
  }) : super(type: ExerciseTypeEnum.flexibility);
}
