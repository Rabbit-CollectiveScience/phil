class ExerciseDetailToday {
  final String name;
  final int sets;
  final double volumeToday;
  final double? maxWeightToday;
  final double? prMaxWeight;
  final bool isPRToday;

  ExerciseDetailToday({
    required this.name,
    required this.sets,
    required this.volumeToday,
    this.maxWeightToday,
    this.prMaxWeight,
    this.isPRToday = false,
  });

  factory ExerciseDetailToday.fromMap(Map<String, dynamic> map) {
    return ExerciseDetailToday(
      name: map['name'] as String,
      sets: map['sets'] as int,
      volumeToday: (map['volumeToday'] as num).toDouble(),
      maxWeightToday: map['maxWeightToday'] != null
          ? (map['maxWeightToday'] as num).toDouble()
          : null,
      prMaxWeight: map['prMaxWeight'] != null
          ? (map['prMaxWeight'] as num).toDouble()
          : null,
      isPRToday: map['isPRToday'] == true,
    );
  }
}
