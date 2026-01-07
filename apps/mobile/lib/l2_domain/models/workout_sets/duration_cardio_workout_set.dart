import 'workout_set.dart';

class DurationCardioWorkoutSet extends WorkoutSet {
  final Duration? duration;

  const DurationCardioWorkoutSet({
    required super.id,
    required super.exerciseId,
    required super.timestamp,
    this.duration,
  });

  @override
  double? getVolume() => null; // No volume for cardio

  DurationCardioWorkoutSet copyWith({
    String? id,
    String? exerciseId,
    DateTime? timestamp,
    Duration? duration,
  }) {
    return DurationCardioWorkoutSet(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      timestamp: timestamp ?? this.timestamp,
      duration: duration ?? this.duration,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'duration_cardio',
    'id': id,
    'exerciseId': exerciseId,
    'timestamp': timestamp.toIso8601String(),
    'duration': duration?.inSeconds,
  };

  factory DurationCardioWorkoutSet.fromJson(Map<String, dynamic> json) {
    return DurationCardioWorkoutSet(
      id: json['id'],
      exerciseId: json['exerciseId'],
      timestamp: DateTime.parse(json['timestamp']),
      duration: json['duration'] != null
          ? Duration(seconds: json['duration'])
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is DurationCardioWorkoutSet &&
          runtimeType == other.runtimeType &&
          duration == other.duration;

  @override
  int get hashCode => super.hashCode ^ duration.hashCode;
}
