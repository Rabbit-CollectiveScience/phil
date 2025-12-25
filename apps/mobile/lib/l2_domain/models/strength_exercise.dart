import 'exercise.dart';
import 'exercise_type_enum.dart';
import 'weight_unit_enum.dart';

class StrengthExercise extends Exercise {
  final int weight;
  final WeightUnitEnum unit;
  final int reps;

  StrengthExercise({
    required super.id,
    required super.name,
    required this.weight,
    required this.unit,
    required this.reps,
  }) : super(type: ExerciseTypeEnum.strength);
}
