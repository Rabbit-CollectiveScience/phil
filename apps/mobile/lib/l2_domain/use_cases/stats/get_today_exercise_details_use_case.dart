import '../workout_sets/get_workout_sets_by_date_use_case.dart';

/// Use case to get detailed statistics for each exercise performed today.
/// Groups workout sets by exercise and calculates aggregated metrics.
class GetTodayExerciseDetailsUseCase {
  final GetWorkoutSetsByDateUseCase _getWorkoutSetsByDateUseCase;

  GetTodayExerciseDetailsUseCase(this._getWorkoutSetsByDateUseCase);

  /// Executes the use case to get exercise details for today.
  ///
  /// Returns a List of Maps, each containing:
  /// - name: Exercise name
  /// - sets: Number of sets completed
  /// - volumeToday: Total volume calculated for this exercise
  /// - maxWeightToday: Highest weight value used (null if no weight field)
  Future<List<Map<String, dynamic>>> execute() async {
    final today = DateTime.now();
    final workoutSetsWithDetails = await _getWorkoutSetsByDateUseCase.execute(
      date: today,
    );

    if (workoutSetsWithDetails.isEmpty) {
      return [];
    }

    // Group sets by exercise
    final Map<String, List<dynamic>> groupedByExercise = {};
    for (final setWithDetails in workoutSetsWithDetails) {
      final exerciseId = setWithDetails.workoutSet.exerciseId;
      if (!groupedByExercise.containsKey(exerciseId)) {
        groupedByExercise[exerciseId] = [];
      }
      groupedByExercise[exerciseId]!.add(setWithDetails);
    }

    // Calculate details for each exercise
    final List<Map<String, dynamic>> exerciseDetails = [];
    for (final entry in groupedByExercise.entries) {
      final exerciseId = entry.key;
      final setsWithDetails = entry.value;

      // Get exercise name from first set
      final exerciseName = setsWithDetails[0].exerciseName;
      final exercise = setsWithDetails[0].exercise;

      // Count sets
      final setsCount = setsWithDetails.length;

      // Calculate total volume
      double volumeToday = 0.0;
      for (final setWithDetails in setsWithDetails) {
        final volume = _calculateVolume(
          exercise,
          setWithDetails.workoutSet.values,
        );
        volumeToday += volume;
      }

      // Find max weight (if exercise has weight field)
      double? maxWeightToday;
      for (final setWithDetails in setsWithDetails) {
        final values = setWithDetails.workoutSet.values;
        if (values != null && values.containsKey('weight')) {
          final weight = (values['weight'] as num).toDouble();
          if (maxWeightToday == null || weight > maxWeightToday) {
            maxWeightToday = weight;
          }
        }
      }

      exerciseDetails.add({
        'name': exerciseName,
        'sets': setsCount,
        'volumeToday': volumeToday,
        'maxWeightToday': maxWeightToday,
      });
    }

    return exerciseDetails;
  }

  /// Calculates volume for a single set based on priority system:
  /// Priority 1: weight × reps
  /// Priority 2: reps only
  /// Priority 3: duration only
  /// Priority 4: distance only
  double _calculateVolume(dynamic exercise, Map<String, dynamic>? values) {
    if (values == null || values.isEmpty) {
      return 0.0;
    }

    // Priority 1: weight × reps
    final weight = values['weight'];
    final reps = values['reps'];
    if (weight != null && reps != null) {
      return (weight as num).toDouble() * (reps as num).toDouble();
    }

    // Priority 2: reps only
    if (reps != null) {
      return (reps as num).toDouble();
    }

    // Priority 3: duration only
    final duration = values['duration'];
    if (duration != null) {
      return (duration as num).toDouble();
    }

    // Priority 4: distance only
    final distance = values['distance'];
    if (distance != null) {
      return (distance as num).toDouble();
    }

    return 0.0;
  }
}
