import '../../models/workout_set.dart';

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
  Future<List<WorkoutSetWithDetails>> execute({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // TODO: Implement
    // - Query workout sets within date range
    // - Join with exercise data
    // - Return list with full details
    throw UnimplementedError();
  }
}

// DTO for returning workout set with exercise details
class WorkoutSetWithDetails {
  final WorkoutSet workoutSet;
  final String exerciseName;
  // TODO: Add more fields as needed
  // - Exercise type
  // - Formatted display values

  WorkoutSetWithDetails({
    required this.workoutSet,
    required this.exerciseName,
  });
}
