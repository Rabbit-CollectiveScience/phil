import 'exercise.dart';
import '../common/muscle_group.dart';

abstract class StrengthExercise extends Exercise {
  final List<MuscleGroup> targetMuscles;

  const StrengthExercise({
    required super.id,
    required super.name,
    required super.description,
    required super.isCustom,
    required this.targetMuscles,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is StrengthExercise &&
          runtimeType == other.runtimeType &&
          _listEquals(targetMuscles, other.targetMuscles);

  @override
  int get hashCode {
    int listHash = 0;
    for (var muscle in targetMuscles) {
      listHash = listHash ^ muscle.hashCode;
    }
    return super.hashCode ^ listHash;
  }

  bool _listEquals(List a, List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
