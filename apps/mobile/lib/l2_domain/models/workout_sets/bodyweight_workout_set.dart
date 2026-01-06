import '../common/weight.dart';
import 'workout_set.dart';

class BodyweightWorkoutSet extends WorkoutSet {
  final int reps;
  final Weight? additionalWeight;

  const BodyweightWorkoutSet({
    required super.id,
    required super.exerciseId,
    required super.timestamp,
    required this.reps,
    this.additionalWeight,
  });

  @override
  double? getVolume() => null; // No volume calculation for bodyweight

  BodyweightWorkoutSet copyWith({
    String? id,
    String? exerciseId,
    DateTime? timestamp,
    int? reps,
    Weight? additionalWeight,
    bool clearAdditionalWeight = false,
  }) {
    return BodyweightWorkoutSet(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      timestamp: timestamp ?? this.timestamp,
      reps: reps ?? this.reps,
      additionalWeight: clearAdditionalWeight
          ? null
          : (additionalWeight ?? this.additionalWeight),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'bodyweight',
    'id': id,
    'exerciseId': exerciseId,
    'timestamp': timestamp.toIso8601String(),
    'reps': reps,
    'additionalWeight': additionalWeight?.toJson(),
  };

  factory BodyweightWorkoutSet.fromJson(Map<String, dynamic> json) {
    return BodyweightWorkoutSet(
      id: json['id'],
      exerciseId: json['exerciseId'],
      timestamp: DateTime.parse(json['timestamp']),
      reps: json['reps'],
      additionalWeight: json['additionalWeight'] != null
          ? Weight.fromJson(json['additionalWeight'])
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is BodyweightWorkoutSet &&
          runtimeType == other.runtimeType &&
          reps == other.reps &&
          additionalWeight == other.additionalWeight;

  @override
  int get hashCode =>
      super.hashCode ^ reps.hashCode ^ additionalWeight.hashCode;
}
