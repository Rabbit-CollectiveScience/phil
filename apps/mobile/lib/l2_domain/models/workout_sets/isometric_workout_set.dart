import 'workout_set.dart';

class IsometricWorkoutSet extends WorkoutSet {
  final Duration duration;

  const IsometricWorkoutSet({
    required super.id,
    required super.exerciseId,
    required super.timestamp,
    required this.duration,
  });

  @override
  double? getVolume() => null; // No volume for duration-based exercises

  IsometricWorkoutSet copyWith({
    String? id,
    String? exerciseId,
    DateTime? timestamp,
    Duration? duration,
  }) {
    return IsometricWorkoutSet(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      timestamp: timestamp ?? this.timestamp,
      duration: duration ?? this.duration,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'isometric',
        'id': id,
        'exerciseId': exerciseId,
        'timestamp': timestamp.toIso8601String(),
        'duration': duration.inSeconds,
      };

  factory IsometricWorkoutSet.fromJson(Map<String, dynamic> json) {
    return IsometricWorkoutSet(
      id: json['id'],
      exerciseId: json['exerciseId'],
      timestamp: DateTime.parse(json['timestamp']),
      duration: Duration(seconds: json['duration']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is IsometricWorkoutSet &&
          runtimeType == other.runtimeType &&
          duration == other.duration;

  @override
  int get hashCode => super.hashCode ^ duration.hashCode;
}
