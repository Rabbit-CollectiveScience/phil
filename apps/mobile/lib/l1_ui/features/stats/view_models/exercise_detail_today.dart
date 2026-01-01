class ExerciseDetailToday {
  final String name;
  final int sets;
  final double volumeToday;
  final double? maxWeightToday;

  ExerciseDetailToday({
    required this.name,
    required this.sets,
    required this.volumeToday,
    this.maxWeightToday,
  });

  factory ExerciseDetailToday.fromMap(Map<String, dynamic> map) {
    return ExerciseDetailToday(
      name: map['name'] as String,
      sets: map['sets'] as int,
      volumeToday: (map['volumeToday'] as num).toDouble(),
      maxWeightToday: map['maxWeightToday'] != null
          ? (map['maxWeightToday'] as num).toDouble()
          : null,
    );
  }
}
