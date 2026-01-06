import 'personal_record.dart';

class RepsPR extends PersonalRecord {
  const RepsPR({
    required super.id,
    required super.exerciseId,
    required super.workoutSetId,
    required super.achievedAt,
  });

  RepsPR copyWith({
    String? id,
    String? exerciseId,
    String? workoutSetId,
    DateTime? achievedAt,
  }) {
    return RepsPR(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      workoutSetId: workoutSetId ?? this.workoutSetId,
      achievedAt: achievedAt ?? this.achievedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'reps',
        'id': id,
        'exerciseId': exerciseId,
        'workoutSetId': workoutSetId,
        'achievedAt': achievedAt.toIso8601String(),
      };

  factory RepsPR.fromJson(Map<String, dynamic> json) {
    return RepsPR(
      id: json['id'],
      exerciseId: json['exerciseId'],
      workoutSetId: json['workoutSetId'],
      achievedAt: DateTime.parse(json['achievedAt']),
    );
  }
}
