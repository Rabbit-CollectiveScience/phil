import 'cardio_exercise.dart';
import '../common/equipment_type.dart';
import 'equipment_type_parser.dart';

class DurationCardioExercise extends CardioExercise {
  const DurationCardioExercise({
    required super.id,
    required super.name,
    required super.description,
    required super.isCustom,
    required super.equipmentType,
  });

  DurationCardioExercise copyWith({
    String? id,
    String? name,
    String? description,
    bool? isCustom,
    EquipmentType? equipmentType,
  }) {
    return DurationCardioExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isCustom: isCustom ?? this.isCustom,
      equipmentType: equipmentType ?? this.equipmentType,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'duration_cardio',
    'id': id,
    'name': name,
    'description': description,
    'isCustom': isCustom,
    'equipmentType': equipmentType.name,
  };

  factory DurationCardioExercise.fromJson(Map<String, dynamic> json) {
    return DurationCardioExercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isCustom: json['isCustom'],
      equipmentType: parseEquipmentType(json['equipmentType']),
    );
  }
}
