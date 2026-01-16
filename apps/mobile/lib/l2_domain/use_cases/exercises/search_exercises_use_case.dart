import '../../models/exercises/exercise.dart';
import '../../models/exercise_searcher.dart';
import '../../../l3_data/repositories/exercise_repository.dart';

// Use Case: Search all exercises by name
//
// Purpose:
// - Search across ALL exercises in database (no personalization/recommendation logic)
// - Filter by name match
// - Used in log view where user needs to find any exercise, not just recommended ones
//
// Difference from GetRecommendedExercisesUseCase:
// - No personalization based on user patterns
// - No filtering by recent/frequent exercises
// - Pure search functionality

class SearchExercisesUseCase {
  final ExerciseRepository _exerciseRepository;
  final ExerciseSearcher _searcher;

  SearchExercisesUseCase(this._exerciseRepository)
      : _searcher = ExerciseSearcher();

  Future<List<Exercise>> execute({required String searchQuery}) async {
    // Get all exercises
    final allExercises = await _exerciseRepository.getAll();

    // If no search query, return empty list (user needs to type to search)
    if (searchQuery.trim().isEmpty) {
      return [];
    }

    // Use sophisticated token-based search
    return _searcher.search(allExercises, searchQuery);
  }
}
