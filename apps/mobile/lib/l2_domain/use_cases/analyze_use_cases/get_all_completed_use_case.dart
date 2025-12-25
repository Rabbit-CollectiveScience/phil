import '../../models/workout_set.dart';

// Use Case: View all completed workout sets (Analyze Mode)
//
// Responsibility:
// - Retrieve all completed workout sets from data store
// - No date filtering (returns all-time history)
// - Include exercise details for each set
// - Used for analyzing workout history, trends, and progress
//
// Used by: Analyze mode pages for viewing complete workout history

class GetAllCompletedUseCase {
  Future<List<WorkoutSetWithDetails>> execute({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // TODO: Implement
    // - Query all workout sets (or filter by optional date range)
    // - Join with exercise data
    // - Return complete history with details
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

  WorkoutSetWithDetails({required this.workoutSet, required this.exerciseName});
}
