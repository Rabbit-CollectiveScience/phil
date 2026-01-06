import '../../l2_domain/legacy_models/exercise.dart';

// Repository Interface: Exercise data operations
//
// Responsibility:
// - Abstract interface for exercise data access
// - Implementation will handle actual data source (API, local DB, etc.)
//
// Methods needed by use cases:
// - Load all exercises
// - Get exercise by ID
// - Search/filter exercises
// - Update exercise defaults

abstract class ExerciseRepository {
  Future<List<Exercise>> getAllExercises();
  Future<Exercise> getExerciseById(String id);
  Future<List<Exercise>> searchExercises(String query);
  Future<Exercise> updateExercise(Exercise exercise);
  // TODO: Add more methods as needed
}
