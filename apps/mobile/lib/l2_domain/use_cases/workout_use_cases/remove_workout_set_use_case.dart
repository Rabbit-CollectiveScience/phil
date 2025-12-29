import '../../../l3_data/repositories/workout_set_repository.dart';

// Use Case: Remove a completed workout set
//
// Responsibility:
// - Delete a workout set from data store by ID
// - Repository handles the actual deletion
//
// Used by: CompletedListPage when user deletes a workout entry

class RemoveWorkoutSetUseCase {
  final WorkoutSetRepository _repository;

  RemoveWorkoutSetUseCase(this._repository);

  Future<void> execute(String workoutSetId) async {
    await _repository.deleteWorkoutSet(workoutSetId);
  }
}
