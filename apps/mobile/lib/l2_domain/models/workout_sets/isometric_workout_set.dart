import 'workout_set.dart';
import '../common/weight.dart';

class IsometricWorkoutSet extends WorkoutSet {
  final Duration? duration;
  final Weight? weight;

  const IsometricWorkoutSet({
    required super.id,
    required super.exerciseId,
    required super.timestamp,
    this.duration,
    this.weight,
  });

  @override
  double? getVolume() => null; // No volume for duration-based exercises

  IsometricWorkoutSet copyWith({
    String? id,
    String? exerciseId,
    DateTime? timestamp,
    Duration? duration,
    Weight? weight,
  }) {
    return IsometricWorkoutSet(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      timestamp: timestamp ?? this.timestamp,
      duration: duration ?? this.duration,
      weight: weight ?? this.weight,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'isometric',
        'id': id,
        'exerciseId': exerciseId,
        'timestamp': timestamp.toIso8601String(),
        'duration': duration?.inSeconds,
        'weight': weight?.kg,
      };

  factory IsometricWorkoutSet.fromJson(Map<String, dynamic> json) {
    return IsometricWorkoutSet(
      id: json['id'],
      exerciseId: json['exerciseId'],
      timestamp: DateTime.parse(json['timestamp']),
      duration: json['duration'] != null 
          ? Duration(seconds: json['duration']) 
          : null,
      weight: json['weight'] != null 
          ? Weight(json['weight']) 
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is IsometricWorkoutSet &&
          runtimeType == other.runtimeType &&
          duration == other.duration &&
          weight == other.weight;

  @override
  int get hashCode => super.hashCode ^ duration.hashCode ^ weight.hashCode;
}
