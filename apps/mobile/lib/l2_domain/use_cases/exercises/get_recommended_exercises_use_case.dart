import '../../models/exercises/exercise.dart';
import '../../models/exercises/strength_exercise.dart';
import '../../models/exercises/cardio_exercise.dart';
import '../../models/common/muscle_group.dart';
import '../../../l3_data/repositories/exercise_repository.dart';

// Use Case: Get recommended exercises for workout session
//
// Responsibility:
// - Load all available exercises from data source
// - Apply search query or type/muscle filters
// - Sort by recommendation logic (e.g., recently used, favorites)
//
// Business Rules:
// - Search query overrides type filter
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
    final exercises = await _repository.getAll();

    // Business Rule: Search overrides type filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      return _searchExercises(exercises, searchQuery);
    }

    // If filter is provided and not 'all', filter by type/muscle group
    final filteredExercises = _filterByCategory(exercises, filterCategory);

    // TODO: Sort by recommendation logic (e.g., recently used, favorites, etc.)

    return filteredExercises;
  }

  /// Filter exercises by category (strength/cardio/muscle group)
  List<Exercise> _filterByCategory(List<Exercise> exercises, String? category) {
    if (category == null || category == 'all') return exercises;

    // Check if filtering by type
    if (category == 'strength') {
      return exercises.whereType<StrengthExercise>().toList();
    }
    if (category == 'cardio') {
      return exercises.whereType<CardioExercise>().toList();
    }

    // Try to match muscle group for strength exercises
    try {
      final muscleGroup = MuscleGroup.values.firstWhere(
        (m) => m.name.toLowerCase() == category.toLowerCase(),
      );
      return exercises
          .whereType<StrengthExercise>()
          .where((e) => e.targetMuscles.contains(muscleGroup))
          .toList();
    } catch (_) {
      // Category not recognized, return all
      return exercises;
    }
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
