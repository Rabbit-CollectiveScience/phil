import 'cardio_exercise.dart';

class DistanceCardioExercise extends CardioExercise {
  const DistanceCardioExercise({
    required super.id,
    required super.name,
    required super.description,
    required super.isCustom,
  });

  DistanceCardioExercise copyWith({
    String? id,
    String? name,
    String? description,
    bool? isCustom,
  }) {
    return DistanceCardioExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'distance_cardio',
        'id': id,
        'name': name,
        'description': description,
        'isCustom': isCustom,
      };

  factory DistanceCardioExercise.fromJson(Map<String, dynamic> json) {
    return DistanceCardioExercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isCustom: json['isCustom'],
    );
  }
}
