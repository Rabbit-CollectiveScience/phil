import 'exercise.dart';

abstract class CardioExercise extends Exercise {
  const CardioExercise({
    required super.id,
    required super.name,
    required super.description,
    required super.isCustom,
    required super.equipmentType,
  });
}
