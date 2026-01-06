import '../../models/workout_sets/weighted_workout_set.dart';
import '../../models/workout_sets/bodyweight_workout_set.dart';
import '../../models/exercises/strength_exercise.dart';
import '../../models/exercises/cardio_exercise.dart';
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

  /// Executes the use case to calculate overview statistics for a specific date.
  ///
  /// Returns a Map containing:
  /// - setsCount: Total number of sets completed on the date
  /// - exercisesCount: Number of unique exercises performed on the date
  /// - totalVolume: Sum of calculated volume for weighted sets
  /// - avgReps: Average reps across weighted and bodyweight sets
  /// - exerciseTypes: List of types (strength/cardio)
  Future<Map<String, dynamic>> execute({DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final workoutSetsWithDetails = await _getWorkoutSetsByDateUseCase.execute(
      date: targetDate,
    );

    if (workoutSetsWithDetails.isEmpty) {
      return {
        'setsCount': 0,
        'exercisesCount': 0,
        'totalVolume': 0.0,
        'avgReps': 0.0,
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

    // Calculate total volume from weighted sets
    double totalVolume = 0.0;
    for (final setWithDetails in workoutSetsWithDetails) {
      if (setWithDetails.workoutSet is WeightedWorkoutSet) {
        final weightedSet = setWithDetails.workoutSet as WeightedWorkoutSet;
        final volume = weightedSet.getVolume();
        if (volume != null) {
          totalVolume += volume;
        }
      }
    }

    // Calculate average reps from weighted and bodyweight sets
    int totalReps = 0;
    int setsWithReps = 0;
    for (final setWithDetails in workoutSetsWithDetails) {
      final set = setWithDetails.workoutSet;
      if (set is WeightedWorkoutSet) {
        totalReps += set.reps;
        setsWithReps++;
      } else if (set is BodyweightWorkoutSet) {
        totalReps += set.reps;
        setsWithReps++;
      }
    }
    final avgReps = setsWithReps > 0 ? totalReps / setsWithReps : 0.0;

    // Collect unique exercise types
    final exerciseTypesSet = <String>{};
    for (final exerciseId in uniqueExerciseIds) {
      final exercise = await _exerciseRepository.getById(exerciseId);
      if (exercise != null) {
        if (exercise is StrengthExercise) {
          exerciseTypesSet.add('strength');
        } else if (exercise is CardioExercise) {
          exerciseTypesSet.add('cardio');
        }
      }
    }

    return {
      'setsCount': setsCount,
      'exercisesCount': exercisesCount,
      'totalVolume': totalVolume,
      'avgReps': avgReps,
      'exerciseTypes': exerciseTypesSet.toList(),
    };
  }
}
