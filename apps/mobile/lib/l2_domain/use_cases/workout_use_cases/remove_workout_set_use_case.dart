import '../../models/workout_set.dart';

// Use Case: Remove a completed workout set
//
// Responsibility:
// - Delete a workout set from data store by ID
// - Update workout session totals/counts
//
// Used by: CompletedListPage when user deletes a workout entry

class RemoveWorkoutSetUseCase {
  Future<void> execute(String workoutSetId) async {
    // TODO: Implement
    // - Find workout set by ID
    // - Delete from repository
    // - Update related counts/totals
    throw UnimplementedError();
  }
}
