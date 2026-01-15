import 'workout_set.dart';
import '../common/weight.dart';

class IsometricWorkoutSet extends WorkoutSet {
  final Duration? duration;
  final Weight? weight;
  final bool isBodyweightBased;

  const IsometricWorkoutSet({
    required super.id,
    required super.exerciseId,
    required super.timestamp,
    this.duration,
    this.weight,
    required this.isBodyweightBased,
  });

  @override
  double? getVolume() => null; // No volume for duration-based exercises

  @override
  String formatForDisplay() {
    final durationSec = duration?.inSeconds;
    final weightKg = weight?.kg;

    if (isBodyweightBased) {
      // Bodyweight-based exercises: "Bodyweight" or "BW + Xkg"
      if (durationSec != null && weightKg != null && weightKg > 0) {
        return '$durationSec sec · BW + ${_formatWeight(weightKg)} kg';
      } else if (durationSec != null && (weightKg == null || weightKg == 0)) {
        return '$durationSec sec · Bodyweight';
      } else if (weightKg != null && weightKg > 0) {
        return 'BW + ${_formatWeight(weightKg)} kg';
      } else {
        return 'Bodyweight';
      }
    } else {
      // Loaded static holds: "Xkg" or "Xkg · Ysec"
      if (durationSec != null && weightKg != null && weightKg > 0) {
        return '$durationSec sec · ${_formatWeight(weightKg)} kg';
      } else if (durationSec != null) {
        return '$durationSec sec';
      } else if (weightKg != null && weightKg > 0) {
        return '${_formatWeight(weightKg)} kg';
      } else {
        return '-';
      }
    }
  }

  /// Helper to format weight (removes .0 if whole number)
  String _formatWeight(double kg) {
    return kg.truncateToDouble() == kg
        ? kg.toStringAsFixed(0)
        : kg.toStringAsFixed(1);
  }

  IsometricWorkoutSet copyWith({
    String? id,
    String? exerciseId,
    DateTime? timestamp,
    Duration? duration,
    Weight? weight,
    bool? isBodyweightBased,
  }) {
    return IsometricWorkoutSet(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      timestamp: timestamp ?? this.timestamp,
      duration: duration ?? this.duration,
      weight: weight ?? this.weight,
      isBodyweightBased: isBodyweightBased ?? this.isBodyweightBased,
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
    'isBodyweightBased': isBodyweightBased,
  };

  factory IsometricWorkoutSet.fromJson(Map<String, dynamic> json) {
    return IsometricWorkoutSet(
      id: json['id'],
      exerciseId: json['exerciseId'],
      timestamp: DateTime.parse(json['timestamp']),
      duration: json['duration'] != null
          ? Duration(seconds: json['duration'])
          : null,
      weight: json['weight'] != null ? Weight(json['weight']) : null,
      isBodyweightBased: json['isBodyweightBased'] ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is IsometricWorkoutSet &&
          runtimeType == other.runtimeType &&
          duration == other.duration &&
          weight == other.weight &&
          isBodyweightBased == other.isBodyweightBased;

  @override
  int get hashCode => super.hashCode ^ duration.hashCode ^ weight.hashCode ^ isBodyweightBased.hashCode;
}
