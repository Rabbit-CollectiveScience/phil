import '../../models/exercise.dart';
import '../../../l3_data/repositories/exercise_repository.dart';

// Use Case: Get recommended exercises for workout session
//
// Responsibility:
// - Load all available exercises from data source
// - Apply search query or category filters
// - Sort by recommendation logic (e.g., recently used, favorites)
//
// Business Rules:
// - Search query overrides category filter
// - Search is case-insensitive
// - Search prioritizes: starts-with > contains
//
// Used by: WorkoutHomePage on app start and search

class GetRecommendedExercisesUseCase {
  final ExerciseRepository _repository;

  GetRecommendedExercisesUseCase(this._repository);

  Future<List<Exercise>> execute({
    String? filterCategory,
    String? searchQuery,
  }) async {
    // Load all available exercises
    final exercises = await _repository.getAllExercises();

    // Business Rule: Search overrides category filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      return _searchExercises(exercises, searchQuery);
    }

    // If filter is provided and not 'all', filter by category
    final filteredExercises =
        (filterCategory != null && filterCategory != 'all')
            ? exercises
                .where((e) => e.categories.contains(filterCategory))
                .toList()
            : exercises;

    // TODO: Sort by recommendation logic (e.g., recently used, favorites, etc.)

    return filteredExercises;
  }

  /// Search exercises by name with prioritization
  /// Priority: starts-with > contains
  List<Exercise> _searchExercises(List<Exercise> exercises, String query) {
    final queryLower = query.toLowerCase();
    
    final startsWith = <Exercise>[];
    final contains = <Exercise>[];

    for (final exercise in exercises) {
      final nameLower = exercise.name.toLowerCase();
      
      if (nameLower.startsWith(queryLower)) {
        startsWith.add(exercise);
      } else if (nameLower.contains(queryLower)) {
        contains.add(exercise);
      }
    }

    // Return prioritized results
    return [...startsWith, ...contains];
  }
}
