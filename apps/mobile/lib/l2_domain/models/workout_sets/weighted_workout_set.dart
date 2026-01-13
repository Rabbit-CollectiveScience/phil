import '../common/weight.dart';
import 'workout_set.dart';

class WeightedWorkoutSet extends WorkoutSet {
  final Weight? weight;
  final int? reps;

  const WeightedWorkoutSet({
    required super.id,
    required super.exerciseId,
    required super.timestamp,
    this.weight,
    this.reps,
  });

  @override
  double? getVolume() =>
      (weight != null && reps != null) ? weight!.kg * reps! : null;

  WeightedWorkoutSet copyWith({
    String? id,
    String? exerciseId,
    DateTime? timestamp,
    Weight? weight,
    int? reps,
  }) {
    return WeightedWorkoutSet(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      timestamp: timestamp ?? this.timestamp,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'weighted',
    'id': id,
    'exerciseId': exerciseId,
    'timestamp': timestamp.toIso8601String(),
    'weight': weight?.toJson(),
    'reps': reps,
  };

  factory WeightedWorkoutSet.fromJson(Map<String, dynamic> json) {
    return WeightedWorkoutSet(
      id: json['id'],
      exerciseId: json['exerciseId'],
      timestamp: DateTime.parse(json['timestamp']),
      weight: json['weight'] != null
          ? Weight.fromJson(Map<String, dynamic>.from(json['weight']))
          : null,
      reps: json['reps'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is WeightedWorkoutSet &&
          runtimeType == other.runtimeType &&
          weight == other.weight &&
          reps == other.reps;

  @override
  int get hashCode => super.hashCode ^ weight.hashCode ^ reps.hashCode;
}
