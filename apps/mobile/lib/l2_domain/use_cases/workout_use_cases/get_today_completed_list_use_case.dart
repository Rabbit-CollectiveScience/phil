import '../../models/workout_set.dart';
import '../../models/exercise.dart';
import '../../../l3_data/repositories/workout_set_repository.dart';
import '../../../l3_data/repositories/exercise_repository.dart';

// Use Case: Get detailed list of completed workout sets for TODAY (Workout Mode)
//
// Responsibility:
// - Retrieve completed workout sets from data store
// - Filter by today's date (workout mode focuses on current session)
// - Include exercise details for each set
// - Return full workout set details with exercise info
//
// Used by: CompletedListPage to display today's workout history

class GetTodayCompletedListUseCase {
  final WorkoutSetRepository _workoutSetRepository;
  final ExerciseRepository _exerciseRepository;

  GetTodayCompletedListUseCase(
    this._workoutSetRepository,
    this._exerciseRepository,
  );

  Future<List<WorkoutSetWithDetails>> execute({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Get today's workout sets
    final todayWorkouts = await _workoutSetRepository.getTodayWorkoutSets();

    // Get all exercises for lookup
    final exercises = await _exerciseRepository.getAllExercises();
    final exerciseMap = {for (var e in exercises) e.id: e};

    // Join workout sets with exercise data
    final workoutsWithDetails = todayWorkouts.map((workoutSet) {
      final exercise = exerciseMap[workoutSet.exerciseId];

      return WorkoutSetWithDetails(
        workoutSet: workoutSet,
        exerciseName: exercise?.name ?? 'Unknown Exercise',
        exercise: exercise,
      );
    }).toList();

    // Sort by completion time - most recent first
    workoutsWithDetails.sort(
      (a, b) => b.workoutSet.completedAt.compareTo(a.workoutSet.completedAt),
    );

    return workoutsWithDetails;
  }
}

// DTO for returning workout set with exercise details
class WorkoutSetWithDetails {
  final WorkoutSet workoutSet;
  final String exerciseName;
  final Exercise? exercise;

  WorkoutSetWithDetails({
    required this.workoutSet,
    required this.exerciseName,
    this.exercise,
  });
}
