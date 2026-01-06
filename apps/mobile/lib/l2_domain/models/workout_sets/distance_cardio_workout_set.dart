import '../common/distance.dart';
import 'workout_set.dart';

class DistanceCardioWorkoutSet extends WorkoutSet {
  final Duration duration;
  final Distance distance;

  const DistanceCardioWorkoutSet({
    required super.id,
    required super.exerciseId,
    required super.timestamp,
    required this.duration,
    required this.distance,
  });

  /// Returns pace in meters per second
  double getPace() => distance.meters / duration.inSeconds;

  @override
  double? getVolume() => null; // No volume for cardio

  DistanceCardioWorkoutSet copyWith({
    String? id,
    String? exerciseId,
    DateTime? timestamp,
    Duration? duration,
    Distance? distance,
  }) {
    return DistanceCardioWorkoutSet(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      timestamp: timestamp ?? this.timestamp,
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'distanceCardio',
    'id': id,
    'exerciseId': exerciseId,
    'timestamp': timestamp.toIso8601String(),
    'duration': duration.inSeconds,
    'distance': distance.toJson(),
  };

  factory DistanceCardioWorkoutSet.fromJson(Map<String, dynamic> json) {
    return DistanceCardioWorkoutSet(
      id: json['id'],
      exerciseId: json['exerciseId'],
      timestamp: DateTime.parse(json['timestamp']),
      duration: Duration(seconds: json['duration']),
      distance: Distance.fromJson(json['distance']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is DistanceCardioWorkoutSet &&
          runtimeType == other.runtimeType &&
          duration == other.duration &&
          distance == other.distance;

  @override
  int get hashCode => super.hashCode ^ duration.hashCode ^ distance.hashCode;
}
