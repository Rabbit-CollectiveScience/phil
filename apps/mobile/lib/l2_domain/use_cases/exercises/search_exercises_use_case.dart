import '../../legacy_models/exercise.dart';
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

  SearchExercisesUseCase(this._exerciseRepository);

  Future<List<Exercise>> execute({required String searchQuery}) async {
    // Get all exercises
    final allExercises = await _exerciseRepository.getAllExercises();

    // If no search query, return empty list (user needs to type to search)
    if (searchQuery.trim().isEmpty) {
      return [];
    }

    // Filter by name match (case-insensitive)
    final query = searchQuery.toLowerCase();
    final filtered = allExercises
        .where((exercise) => exercise.name.toLowerCase().contains(query))
        .toList();

    // Sort by relevance: exact matches first, then starts-with, then contains
    filtered.sort((a, b) {
      final aName = a.name.toLowerCase();
      final bName = b.name.toLowerCase();

      // Exact match
      if (aName == query) return -1;
      if (bName == query) return 1;

      // Starts with query
      final aStarts = aName.startsWith(query);
      final bStarts = bName.startsWith(query);
      if (aStarts && !bStarts) return -1;
      if (!aStarts && bStarts) return 1;

      // Alphabetical for same relevance
      return aName.compareTo(bName);
    });

    return filtered;
  }
}
