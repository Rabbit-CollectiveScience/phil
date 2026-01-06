import 'personal_record.dart';

class DistancePR extends PersonalRecord {
  const DistancePR({
    required super.id,
    required super.exerciseId,
    required super.workoutSetId,
    required super.achievedAt,
  });

  DistancePR copyWith({
    String? id,
    String? exerciseId,
    String? workoutSetId,
    DateTime? achievedAt,
  }) {
    return DistancePR(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      workoutSetId: workoutSetId ?? this.workoutSetId,
      achievedAt: achievedAt ?? this.achievedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'distance',
    'id': id,
    'exerciseId': exerciseId,
    'workoutSetId': workoutSetId,
    'achievedAt': achievedAt.toIso8601String(),
  };

  factory DistancePR.fromJson(Map<String, dynamic> json) {
    return DistancePR(
      id: json['id'],
      exerciseId: json['exerciseId'],
      workoutSetId: json['workoutSetId'],
      achievedAt: DateTime.parse(json['achievedAt']),
    );
  }
}
