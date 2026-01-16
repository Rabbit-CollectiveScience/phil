import '../common/weight.dart';
import 'workout_set.dart';

class AssistedMachineWorkoutSet extends WorkoutSet {
  final Weight? assistanceWeight;
  final int? reps;

  const AssistedMachineWorkoutSet({
    required super.id,
    required super.exerciseId,
    required super.timestamp,
    this.assistanceWeight,
    this.reps,
  });

  @override
  double? getVolume() => null; // No volume calculation for assisted machines

  /// Calculate effective weight lifted (bodyweight - assistance)
  /// Returns null if assistanceWeight is null or userBodyweight not provided
  double? getEffectiveWeight(Weight? userBodyweight) {
    if (assistanceWeight == null || userBodyweight == null) return null;
    return userBodyweight.kg - assistanceWeight!.kg;
  }

  @override
  String formatForDisplay() {
    final repsStr = reps != null
        ? '$reps ${reps == 1 ? "rep" : "reps"}'
        : '-- rep';
    final assistStr = assistanceWeight != null
        ? '${assistanceWeight!.kg.toStringAsFixed(1)} assistance'
        : '-- assistance';
    return '$repsStr · $assistStr';
  }

  AssistedMachineWorkoutSet copyWith({
    String? id,
    String? exerciseId,
    DateTime? timestamp,
    Weight? assistanceWeight,
    int? reps,
  }) {
    return AssistedMachineWorkoutSet(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      timestamp: timestamp ?? this.timestamp,
      assistanceWeight: assistanceWeight ?? this.assistanceWeight,
      reps: reps ?? this.reps,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'assisted_machine',
    'id': id,
    'exerciseId': exerciseId,
    'timestamp': timestamp.toIso8601String(),
    'assistanceWeight': assistanceWeight?.toJson(),
    'reps': reps,
  };

  factory AssistedMachineWorkoutSet.fromJson(Map<String, dynamic> json) {
    return AssistedMachineWorkoutSet(
      id: json['id'],
      exerciseId: json['exerciseId'],
      timestamp: DateTime.parse(json['timestamp']),
      assistanceWeight: json['assistanceWeight'] != null
          ? Weight.fromJson(Map<String, dynamic>.from(json['assistanceWeight']))
          : null,
      reps: json['reps'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is AssistedMachineWorkoutSet &&
          runtimeType == other.runtimeType &&
          assistanceWeight == other.assistanceWeight &&
          reps == other.reps;

  @override
  int get hashCode =>
      super.hashCode ^ assistanceWeight.hashCode ^ reps.hashCode;
}
