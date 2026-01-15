import '../common/distance.dart';
import 'workout_set.dart';

class DistanceCardioWorkoutSet extends WorkoutSet {
  final Duration? duration;
  final Distance? distance;

  const DistanceCardioWorkoutSet({
    required super.id,
    required super.exerciseId,
    required super.timestamp,
    this.duration,
    this.distance,
  });

  /// Returns pace in minutes per kilometer
  double getPace() {
    if (distance == null || duration == null || distance!.meters == 0)
      return 0.0;
    final km = distance!.getInKm();
    final minutes = duration!.inSeconds / 60.0;
    return minutes / km;
  }

  @override
  double? getVolume() => null; // No volume for cardio

  @override
  String formatForDisplay() {
    final distanceStr = distance != null
        ? '${distance!.getInKm().toStringAsFixed(1)} km'
        : '-- km';
    final durationStr = duration != null
        ? '${duration!.inMinutes} min'
        : '-- min';
    return '$distanceStr · $durationStr';
  }

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
    'type': 'distance_cardio',
    'id': id,
    'exerciseId': exerciseId,
    'timestamp': timestamp.toIso8601String(),
    'duration': duration?.inSeconds,
    'distance': distance?.toJson(),
  };

  factory DistanceCardioWorkoutSet.fromJson(Map<String, dynamic> json) {
    return DistanceCardioWorkoutSet(
      id: json['id'],
      exerciseId: json['exerciseId'],
      timestamp: DateTime.parse(json['timestamp']),
      duration: json['duration'] != null
          ? Duration(seconds: json['duration'])
          : null,
      distance: json['distance'] != null
          ? Distance.fromJson(Map<String, dynamic>.from(json['distance']))
          : null,
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
