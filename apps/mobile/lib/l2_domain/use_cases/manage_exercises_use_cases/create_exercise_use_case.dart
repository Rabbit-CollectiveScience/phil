import '../../models/exercise.dart';

// Use Case: Create a new exercise (Analyze Mode)
//
// Responsibility:
// - Create new exercise entry in the system
// - Validate exercise data based on type
// - Save to repository
// - Return created exercise
//
// Used by: Analyze mode pages for adding exercises to catalog

class CreateExerciseUseCase {
  Future<Exercise> execute(Exercise exercise) async {
    // TODO: Implement
    // - Validate exercise fields based on type
    // - Generate unique ID if not provided
    // - Save to repository
    // - Return created exercise
    throw UnimplementedError();
  }
}
