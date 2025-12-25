import 'exercise_type_enum.dart';

class WorkoutSet {
  final String id;
  final String exerciseId;
  final ExerciseTypeEnum exerciseType;
  final DateTime completedAt;
  final Map<String, dynamic> values;

  WorkoutSet({
    required this.id,
    required this.exerciseId,
    required this.exerciseType,
    required this.completedAt,
    required this.values,
  });

  // Convenience getters for type-specific fields
  int? get weight => values['weight'] as int?; // Strength: weight value
  int? get reps => values['reps'] as int?; // Strength/Flexibility: repetitions
  int? get durationInSeconds =>
      values['durationInSeconds'] as int?; // Cardio: duration in seconds
  int? get level => values['level'] as int?; // Cardio: intensity level
  int? get holdTimeInSeconds =>
      values['holdTimeInSeconds']
          as int?; // Flexibility: hold duration in seconds
  String? get unit =>
      values['unit'] as String?; // Strength: weight unit (kg/lb)
  String? get levelUnit =>
      values['levelUnit'] as String?; // Cardio: unit for level
}
