import 'strength_exercise.dart';
import '../common/muscle_group.dart';

class BodyweightExercise extends StrengthExercise {
  final bool canAddWeight;

  const BodyweightExercise({
    required super.id,
    required super.name,
    required super.description,
    required super.isCustom,
    required super.targetMuscles,
    required this.canAddWeight,
  });

  BodyweightExercise copyWith({
    String? id,
    String? name,
    String? description,
    bool? isCustom,
    List<MuscleGroup>? targetMuscles,
    bool? canAddWeight,
  }) {
    return BodyweightExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isCustom: isCustom ?? this.isCustom,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      canAddWeight: canAddWeight ?? this.canAddWeight,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'bodyweight',
        'id': id,
        'name': name,
        'description': description,
        'isCustom': isCustom,
        'targetMuscles': targetMuscles.map((m) => m.name).toList(),
        'canAddWeight': canAddWeight,
      };

  factory BodyweightExercise.fromJson(Map<String, dynamic> json) {
    return BodyweightExercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isCustom: json['isCustom'],
      targetMuscles: (json['targetMuscles'] as List)
          .map((m) => MuscleGroup.values.byName(m))
          .toList(),
      canAddWeight: json['canAddWeight'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is BodyweightExercise &&
          runtimeType == other.runtimeType &&
          canAddWeight == other.canAddWeight;

  @override
  int get hashCode => super.hashCode ^ canAddWeight.hashCode;
}
