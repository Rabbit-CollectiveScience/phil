import '../../../l3_data/repositories/workout_set_repository.dart';

// Use Case: Get count of completed workout sets for TODAY (Workout Mode)
//
// Responsibility:
// - Retrieve completed workout sets from data store
// - Filter by today's date (workout mode focuses on current session)
// - Return count only for display in workout counter
//
// Used by: WorkoutHomePage to display completion counter

class GetTodayCompletedCountUseCase {
  final WorkoutSetRepository _repository;

  GetTodayCompletedCountUseCase(this._repository);

  Future<int> execute({DateTime? startDate, DateTime? endDate}) async {
    // Get today's workout sets
    final todayWorkouts = await _repository.getTodayWorkoutSets();

    // Return count
    return todayWorkouts.length;
  }
}
