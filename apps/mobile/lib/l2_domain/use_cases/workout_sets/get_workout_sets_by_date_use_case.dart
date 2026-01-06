import '../../models/workout_sets/workout_set.dart';
import '../../models/exercises/exercise.dart';
import '../../../l3_data/repositories/workout_set_repository.dart';
import '../../../l3_data/repositories/exercise_repository.dart';

// Use Case: Get workout sets for a specific date
//
// Responsibility:
// - Retrieve all workout sets for a specific date
// - Join with exercise data to get field definitions
// - Return enriched workout set details for display
//
// Business Rules:
// - Query full day range (start to end of selected date)
// - Include exercise details for dynamic field rendering
// - Sort by completion time (most recent first)
//
// Used by: LogView to display sets for any selected date

class GetWorkoutSetsByDateUseCase {
  final WorkoutSetRepository _workoutSetRepository;
  final ExerciseRepository _exerciseRepository;

  GetWorkoutSetsByDateUseCase(
    this._workoutSetRepository,
    this._exerciseRepository,
  );

  Future<List<WorkoutSetWithDetails>> execute({required DateTime date}) async {
    // Business rule: Query full day from start to end
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Get workout sets for the selected date
    final workoutSets = await _workoutSetRepository.getByDateRange(
      startDate: startOfDay,
      endDate: endOfDay,
    );

    // Get all exercises for lookup
    final exercises = await _exerciseRepository.getAll();
    final exerciseMap = {for (var e in exercises) e.id: e};

    // Join workout sets with exercise data
    final workoutsWithDetails = workoutSets.map((workoutSet) {
      final exercise = exerciseMap[workoutSet.exerciseId];

      return WorkoutSetWithDetails(
        workoutSet: workoutSet,
        exerciseName: exercise?.name ?? 'Unknown Exercise',
        exercise: exercise,
      );
    }).toList();

    // Sort by completion time - most recent first
    workoutsWithDetails.sort(
      (a, b) => b.workoutSet.timestamp.compareTo(a.workoutSet.timestamp),
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
