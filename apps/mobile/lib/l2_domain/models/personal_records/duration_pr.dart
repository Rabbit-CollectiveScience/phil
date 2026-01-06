import 'personal_record.dart';

class DurationPR extends PersonalRecord {
  const DurationPR({
    required super.id,
    required super.exerciseId,
    required super.workoutSetId,
    required super.achievedAt,
  });

  DurationPR copyWith({
    String? id,
    String? exerciseId,
    String? workoutSetId,
    DateTime? achievedAt,
  }) {
    return DurationPR(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      workoutSetId: workoutSetId ?? this.workoutSetId,
      achievedAt: achievedAt ?? this.achievedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'duration',
        'id': id,
        'exerciseId': exerciseId,
        'workoutSetId': workoutSetId,
        'achievedAt': achievedAt.toIso8601String(),
      };

  factory DurationPR.fromJson(Map<String, dynamic> json) {
    return DurationPR(
      id: json['id'],
      exerciseId: json['exerciseId'],
      workoutSetId: json['workoutSetId'],
      achievedAt: DateTime.parse(json['achievedAt']),
    );
  }
}
