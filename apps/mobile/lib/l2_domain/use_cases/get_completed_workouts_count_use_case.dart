// Use Case: Get count of completed workout sets
//
// Responsibility:
// - Retrieve completed workout sets from data store
// - Filter by date range (e.g., today, this week)
// - Return count only
//
// Used by: WorkoutHomePage to display completion counter

class GetCompletedWorkoutsCountUseCase {
  Future<int> execute({DateTime? startDate, DateTime? endDate}) async {
    // TODO: Implement
    // - Query workout sets within date range
    // - Return count
    throw UnimplementedError();
  }
}
