import 'cardio_exercise.dart';

class DurationCardioExercise extends CardioExercise {
  const DurationCardioExercise({
    required super.id,
    required super.name,
    required super.description,
    required super.isCustom,
  });

  DurationCardioExercise copyWith({
    String? id,
    String? name,
    String? description,
    bool? isCustom,
  }) {
    return DurationCardioExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'duration_cardio',
        'id': id,
        'name': name,
        'description': description,
        'isCustom': isCustom,
      };

  factory DurationCardioExercise.fromJson(Map<String, dynamic> json) {
    return DurationCardioExercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isCustom: json['isCustom'],
    );
  }
}
