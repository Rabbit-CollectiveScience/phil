import 'personal_record.dart';

class WeightPR extends PersonalRecord {
  const WeightPR({
    required super.id,
    required super.exerciseId,
    required super.workoutSetId,
    required super.achievedAt,
  });

  WeightPR copyWith({
    String? id,
    String? exerciseId,
    String? workoutSetId,
    DateTime? achievedAt,
  }) {
    return WeightPR(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      workoutSetId: workoutSetId ?? this.workoutSetId,
      achievedAt: achievedAt ?? this.achievedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'weight',
    'id': id,
    'exerciseId': exerciseId,
    'workoutSetId': workoutSetId,
    'achievedAt': achievedAt.toIso8601String(),
  };

  factory WeightPR.fromJson(Map<String, dynamic> json) {
    return WeightPR(
      id: json['id'],
      exerciseId: json['exerciseId'],
      workoutSetId: json['workoutSetId'],
      achievedAt: DateTime.parse(json['achievedAt']),
    );
  }
}
