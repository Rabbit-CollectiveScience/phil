abstract class PersonalRecord {
  final String id;
  final String exerciseId;
  final String workoutSetId;
  final DateTime achievedAt;

  const PersonalRecord({
    required this.id,
    required this.exerciseId,
    required this.workoutSetId,
    required this.achievedAt,
  });

  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          exerciseId == other.exerciseId &&
          workoutSetId == other.workoutSetId &&
          achievedAt == other.achievedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      exerciseId.hashCode ^
      workoutSetId.hashCode ^
      achievedAt.hashCode;
}
