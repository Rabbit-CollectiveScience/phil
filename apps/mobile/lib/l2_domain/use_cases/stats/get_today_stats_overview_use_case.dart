import '../workout_sets/get_workout_sets_by_date_use_case.dart';
import '../../../l3_data/repositories/exercise_repository.dart';

/// Use case to get today's workout statistics overview.
/// Returns aggregated stats for display in the Today view overview card.
class GetTodayStatsOverviewUseCase {
  final GetWorkoutSetsByDateUseCase _getWorkoutSetsByDateUseCase;
  final ExerciseRepository _exerciseRepository;

  GetTodayStatsOverviewUseCase(
    this._getWorkoutSetsByDateUseCase,
    this._exerciseRepository,
  );

  /// Executes the use case to calculate today's overview statistics.
  ///
  /// Returns a Map containing:
  /// - setsCount: Total number of sets completed today
  /// - exercisesCount: Number of unique exercises performed today
  /// - totalVolume: Sum of calculated volume for all sets
  /// - exerciseTypes: List of unique exercise categories
  Future<Map<String, dynamic>> execute() async {
    final today = DateTime.now();
    final workoutSetsWithDetails = await _getWorkoutSetsByDateUseCase.execute(
      date: today,
    );

    if (workoutSetsWithDetails.isEmpty) {
      return {
        'setsCount': 0,
        'exercisesCount': 0,
        'totalVolume': 0.0,
        'exerciseTypes': <String>[],
      };
    }

    // Count sets
    final setsCount = workoutSetsWithDetails.length;

    // Count unique exercises
    final uniqueExerciseIds = workoutSetsWithDetails
        .map((setWithDetails) => setWithDetails.workoutSet.exerciseId)
        .toSet();
    final exercisesCount = uniqueExerciseIds.length;

    // Calculate total volume with priority system
    double totalVolume = 0.0;
    for (final setWithDetails in workoutSetsWithDetails) {
      final volume = _calculateVolume(
        setWithDetails.exercise,
        setWithDetails.workoutSet.values,
      );
      totalVolume += volume;
    }

    // Collect unique exercise categories
    final exerciseTypesSet = <String>{};
    for (final exerciseId in uniqueExerciseIds) {
      final exercise = await _exerciseRepository.getExerciseById(exerciseId);
      if (exercise != null) {
        exerciseTypesSet.addAll(exercise.categories);
      }
    }

    return {
      'setsCount': setsCount,
      'exercisesCount': exercisesCount,
      'totalVolume': totalVolume,
      'exerciseTypes': exerciseTypesSet.toList(),
    };
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
