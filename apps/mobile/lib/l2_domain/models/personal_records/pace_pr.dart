import 'personal_record.dart';

class PacePR extends PersonalRecord {
  const PacePR({
    required super.id,
    required super.exerciseId,
    required super.workoutSetId,
    required super.achievedAt,
  });

  PacePR copyWith({
    String? id,
    String? exerciseId,
    String? workoutSetId,
    DateTime? achievedAt,
  }) {
    return PacePR(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      workoutSetId: workoutSetId ?? this.workoutSetId,
      achievedAt: achievedAt ?? this.achievedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'pace',
    'id': id,
    'exerciseId': exerciseId,
    'workoutSetId': workoutSetId,
    'achievedAt': achievedAt.toIso8601String(),
  };

  factory PacePR.fromJson(Map<String, dynamic> json) {
    return PacePR(
      id: json['id'],
      exerciseId: json['exerciseId'],
      workoutSetId: json['workoutSetId'],
      achievedAt: DateTime.parse(json['achievedAt']),
    );
  }
}
