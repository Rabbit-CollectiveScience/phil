import 'strength_exercise.dart';
import '../common/muscle_group.dart';

class IsometricExercise extends StrengthExercise {
  final bool isBodyweightBased;

  const IsometricExercise({
    required super.id,
    required super.name,
    required super.description,
    required super.isCustom,
    required super.targetMuscles,
    required this.isBodyweightBased,
  });

  IsometricExercise copyWith({
    String? id,
    String? name,
    String? description,
    bool? isCustom,
    List<MuscleGroup>? targetMuscles,
    bool? isBodyweightBased,
  }) {
    return IsometricExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isCustom: isCustom ?? this.isCustom,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      isBodyweightBased: isBodyweightBased ?? this.isBodyweightBased,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'isometric',
    'id': id,
    'name': name,
    'description': description,
    'isCustom': isCustom,
    'targetMuscles': targetMuscles.map((m) => m.name).toList(),
    'isBodyweightBased': isBodyweightBased,
  };

  factory IsometricExercise.fromJson(Map<String, dynamic> json) {
    return IsometricExercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isCustom: json['isCustom'],
      targetMuscles: (json['targetMuscles'] as List)
          .map((m) => MuscleGroup.values.byName(m))
          .toList(),
      isBodyweightBased: json['isBodyweightBased'] ?? true,
    );
  }
}
