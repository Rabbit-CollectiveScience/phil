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

  // Convenience getters
  int? get weight => values['weight'] as int?;
  int? get reps => values['reps'] as int?;
  int? get duration => values['duration'] as int?;
  int? get level => values['level'] as int?;
  int? get holdTime => values['holdTime'] as int?;
  String? get unit => values['unit'] as String?;
  String? get levelUnit => values['levelUnit'] as String?;
}
