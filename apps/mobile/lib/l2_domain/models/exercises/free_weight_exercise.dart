import 'strength_exercise.dart';
import '../common/muscle_group.dart';

class FreeWeightExercise extends StrengthExercise {
  const FreeWeightExercise({
    required super.id,
    required super.name,
    required super.description,
    required super.isCustom,
    required super.targetMuscles,
  });

  FreeWeightExercise copyWith({
    String? id,
    String? name,
    String? description,
    bool? isCustom,
    List<MuscleGroup>? targetMuscles,
  }) {
    return FreeWeightExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isCustom: isCustom ?? this.isCustom,
      targetMuscles: targetMuscles ?? this.targetMuscles,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'freeWeight',
        'id': id,
        'name': name,
        'description': description,
        'isCustom': isCustom,
        'targetMuscles': targetMuscles.map((m) => m.name).toList(),
      };

  factory FreeWeightExercise.fromJson(Map<String, dynamic> json) {
    return FreeWeightExercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isCustom: json['isCustom'],
      targetMuscles: (json['targetMuscles'] as List)
          .map((m) => MuscleGroup.values.byName(m))
          .toList(),
    );
  }
}
