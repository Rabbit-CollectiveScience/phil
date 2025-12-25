import '../models/exercise.dart';

// Use Case: Search/filter exercises based on user query
//
// Responsibility:
// - Filter exercises by name matching query
// - Rank results: starts with > contains > fuzzy match
// - Return sorted results
//
// Used by: WorkoutHomePage when user types in search bar

class SearchExercisesUseCase {
  Future<List<Exercise>> execute(String query) async {
    // TODO: Implement
    // - Filter exercises by name matching query
    // - Rank results: starts with > contains > fuzzy match
    // - Return sorted results
    throw UnimplementedError();
  }
}
