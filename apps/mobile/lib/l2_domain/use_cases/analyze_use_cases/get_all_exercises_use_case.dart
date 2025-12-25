import '../../models/exercise.dart';

// Use Case: View all exercises in the system
//
// Responsibility:
// - Retrieve all exercises from data store
// - Return complete list without filtering by today/session
// - Used for browsing/analyzing exercise catalog
//
// Used by: Analyze mode pages for viewing all available exercises

class GetAllExercisesUseCase {
  Future<List<Exercise>> execute() async {
    // TODO: Implement
    // - Load all exercises from repository
    // - Return complete unfiltered list
    throw UnimplementedError();
  }
}
