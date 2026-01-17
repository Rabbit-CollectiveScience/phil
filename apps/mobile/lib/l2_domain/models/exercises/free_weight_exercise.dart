import 'strength_exercise.dart';
import '../common/muscle_group.dart';
import '../common/equipment_type.dart';
import 'equipment_type_parser.dart';

class FreeWeightExercise extends StrengthExercise {
  const FreeWeightExercise({
    required super.id,
    required super.name,
    required super.description,
    required super.isCustom,
    required super.equipmentType,
    required super.targetMuscles,
  });

  FreeWeightExercise copyWith({
    String? id,
    String? name,
    String? description,
    bool? isCustom,
    EquipmentType? equipmentType,
    List<MuscleGroup>? targetMuscles,
  }) {
    return FreeWeightExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isCustom: isCustom ?? this.isCustom,
      equipmentType: equipmentType ?? this.equipmentType,
      targetMuscles: targetMuscles ?? this.targetMuscles,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'free_weight',
    'id': id,
    'name': name,
    'description': description,
    'isCustom': isCustom,
    'equipmentType': equipmentType.name,
    'targetMuscles': targetMuscles.map((m) => m.name).toList(),
  };

  factory FreeWeightExercise.fromJson(Map<String, dynamic> json) {
    return FreeWeightExercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isCustom: json['isCustom'],
      equipmentType: parseEquipmentType(json['equipmentType']),
      targetMuscles: (json['targetMuscles'] as List)
          .map((m) => MuscleGroup.values.byName(m))
          .toList(),
    );
  }
}
