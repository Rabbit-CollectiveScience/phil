abstract class WorkoutSet {
  final String id;
  final String exerciseId;
  final DateTime timestamp;

  const WorkoutSet({
    required this.id,
    required this.exerciseId,
    required this.timestamp,
  });

  double? getVolume();

  /// Format this workout set for display in the UI
  String formatForDisplay();

  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSet &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          exerciseId == other.exerciseId &&
          timestamp == other.timestamp;

  @override
  int get hashCode => id.hashCode ^ exerciseId.hashCode ^ timestamp.hashCode;
}
