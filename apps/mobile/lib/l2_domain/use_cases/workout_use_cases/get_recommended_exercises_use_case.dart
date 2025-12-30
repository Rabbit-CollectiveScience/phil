import '../../models/exercise.dart';
import '../../../l3_data/repositories/exercise_repository.dart';

// Use Case: Get recommended exercises for workout session
//
// Responsibility:
// - Load all available exercises from data source
// - Apply user preferences/filters if any
// - Sort by recommendation logic (e.g., recently used, favorites)
//
// Used by: WorkoutHomePage on app start

class GetRecommendedExercisesUseCase {
  final ExerciseRepository _repository;

  GetRecommendedExercisesUseCase(this._repository);

  Future<List<Exercise>> execute({String? filterCategory}) async {
    // Load all available exercises
    final exercises = await _repository.getAllExercises();

    // If filter is provided and not 'all', filter by category
    final filteredExercises =
        (filterCategory != null && filterCategory != 'all')
        ? exercises.where((e) => e.categories.contains(filterCategory)).toList()
        : exercises;

    // TODO: Sort by recommendation logic (e.g., recently used, favorites, etc.)

    return filteredExercises;
  }
}
