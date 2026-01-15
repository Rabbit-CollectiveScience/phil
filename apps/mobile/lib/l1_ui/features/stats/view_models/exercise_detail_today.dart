class PRToday {
  final String type;
  final double value;

  PRToday({required this.type, required this.value});

  factory PRToday.fromMap(Map<String, dynamic> map) {
    return PRToday(
      type: map['type'] as String,
      value: (map['value'] as num).toDouble(),
    );
  }
}

class ExerciseDetailToday {
  final String name;
  final int sets;
  final double volumeToday;
  final double? maxWeightToday;
  final int? maxReps;
  final Duration? maxDuration;
  final double? maxDistance; // in meters
  final double? maxAdditionalWeight;
  final List<PRToday> prsToday;
  final dynamic exercise; // Exercise object for type checking

  ExerciseDetailToday({
    required this.name,
    required this.sets,
    required this.volumeToday,
    this.maxWeightToday,
    this.maxReps,
    this.maxDuration,
    this.maxDistance,
    this.maxAdditionalWeight,
    this.prsToday = const [],
    this.exercise,
  });

  factory ExerciseDetailToday.fromMap(Map<String, dynamic> map) {
    final prsData = map['prsToday'] as List<dynamic>? ?? [];
    final prs = prsData
        .map((pr) => PRToday.fromMap(pr as Map<String, dynamic>))
        .toList();

    Duration? maxDuration;
    if (map['maxDuration'] != null) {
      maxDuration = map['maxDuration'] as Duration;
    }

    return ExerciseDetailToday(
      name: map['exerciseName'] as String,
      sets: map['setCount'] as int,
      volumeToday: map['totalVolume'] != null
          ? (map['totalVolume'] as num).toDouble()
          : 0.0,
      maxWeightToday: map['maxWeight'] != null
          ? (map['maxWeight'] as num).toDouble()
          : null,
      maxReps: map['maxReps'] as int?,
      maxDuration: maxDuration,
      maxDistance: map['maxDistance'] != null
          ? (map['maxDistance'] as num).toDouble()
          : null,
      maxAdditionalWeight: map['maxAdditionalWeight'] != null
          ? (map['maxAdditionalWeight'] as num).toDouble()
          : null,
      prsToday: prs,
      exercise: map['exercise'],
    );
  }
}
