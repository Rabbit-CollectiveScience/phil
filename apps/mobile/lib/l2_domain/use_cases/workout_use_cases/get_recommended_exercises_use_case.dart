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

  Future<List<Exercise>> execute() async {
    // Load all available exercises
    final exercises = await _repository.getAllExercises();

    // TODO: Apply user preferences/filters if any
    // TODO: Sort by recommendation logic (e.g., recently used, favorites, etc.)

    // For now, return first 10 exercises
    return exercises.take(10).toList();
  }
}
