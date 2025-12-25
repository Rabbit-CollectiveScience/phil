import '../models/exercise.dart';

// Use Case: Update exercise configuration/details
//
// Responsibility:
// - Update exercise parameters (e.g., default weight, reps for strength)
// - Validate new values based on exercise type
// - Save updated exercise to data store
//
// Used by: SwipeableCard when user adjusts weight/reps before completing

class UpdateExerciseDetailsUseCase {
  Future<Exercise> execute({
    required String exerciseId,
    required Map<String, dynamic> updatedValues,
  }) async {
    // TODO: Implement
    // - Retrieve existing exercise
    // - Update fields with new values
    // - Validate based on exercise type
    // - Save to repository
    // - Return updated exercise
    throw UnimplementedError();
  }
}
