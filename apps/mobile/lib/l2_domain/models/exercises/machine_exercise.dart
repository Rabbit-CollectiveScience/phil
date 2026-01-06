import 'strength_exercise.dart';
import '../common/muscle_group.dart';

class MachineExercise extends StrengthExercise {
  const MachineExercise({
    required super.id,
    required super.name,
    required super.description,
    required super.isCustom,
    required super.targetMuscles,
  });

  MachineExercise copyWith({
    String? id,
    String? name,
    String? description,
    bool? isCustom,
    List<MuscleGroup>? targetMuscles,
  }) {
    return MachineExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isCustom: isCustom ?? this.isCustom,
      targetMuscles: targetMuscles ?? this.targetMuscles,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'machine',
    'id': id,
    'name': name,
    'description': description,
    'isCustom': isCustom,
    'targetMuscles': targetMuscles.map((m) => m.name).toList(),
  };

  factory MachineExercise.fromJson(Map<String, dynamic> json) {
    return MachineExercise(
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
