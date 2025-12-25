import 'exercise.dart';
import 'exercise_type_enum.dart';
import 'weight_unit_enum.dart';

class StrengthExercise extends Exercise {
  final int? weight; // Weight value (numeric only, unit specified separately)
  final WeightUnitEnum? unit; // Weight unit (kg or lb)
  final int? reps; // Number of repetitions

  StrengthExercise({
    required super.id,
    required super.name,
    required super.description,
    this.weight,
    this.unit,
    this.reps,
  }) : super(type: ExerciseTypeEnum.strength);
}
