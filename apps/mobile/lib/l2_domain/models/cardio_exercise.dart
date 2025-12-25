import 'exercise.dart';
import 'exercise_type_enum.dart';

class CardioExercise extends Exercise {
  final int? durationInSeconds; // Duration stored in seconds (e.g., 390 = 6:30)
  final int? level; // Intensity level (speed, resistance, etc.)
  final String? levelUnit; // Unit for level ("mph", "km/h", "level", "pace")

  CardioExercise({
    required super.id,
    required super.name,
    required super.description,
    this.durationInSeconds,
    this.level,
    this.levelUnit,
  }) : super(type: ExerciseTypeEnum.cardio);
}
