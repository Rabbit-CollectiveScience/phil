import 'personal_record.dart';

class VolumePR extends PersonalRecord {
  const VolumePR({
    required super.id,
    required super.exerciseId,
    required super.workoutSetId,
    required super.achievedAt,
  });

  VolumePR copyWith({
    String? id,
    String? exerciseId,
    String? workoutSetId,
    DateTime? achievedAt,
  }) {
    return VolumePR(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      workoutSetId: workoutSetId ?? this.workoutSetId,
      achievedAt: achievedAt ?? this.achievedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'volume',
    'id': id,
    'exerciseId': exerciseId,
    'workoutSetId': workoutSetId,
    'achievedAt': achievedAt.toIso8601String(),
  };

  factory VolumePR.fromJson(Map<String, dynamic> json) {
    return VolumePR(
      id: json['id'],
      exerciseId: json['exerciseId'],
      workoutSetId: json['workoutSetId'],
      achievedAt: DateTime.parse(json['achievedAt']),
    );
  }
}
