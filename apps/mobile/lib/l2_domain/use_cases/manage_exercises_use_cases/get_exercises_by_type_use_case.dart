import '../../models/exercise.dart';

// Use Case: Get exercises filtered by category (Analyze Mode)
//
// Responsibility:
// - Retrieve all exercises from data store
// - Filter by specific category (e.g., strength, arms, cardio, flexibility)
// - Return filtered list
//
// Used by: Analyze mode pages for viewing exercises by category

class GetExercisesByTypeUseCase {
  Future<List<Exercise>> execute(String category) async {
    // TODO: Implement
    // - Load all exercises from repository
    // - Filter by category (exercise.categories.contains(category))
    // - Return filtered list
    throw UnimplementedError();
  }
}
