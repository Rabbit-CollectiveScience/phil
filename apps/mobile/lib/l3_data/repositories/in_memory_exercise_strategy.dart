import '../repositories/exercise_repository.dart';
import '../../l2_domain/models/exercise.dart';

// Strategy: In-memory implementation of ExerciseRepository
//
// Responsibility:
// - Implements exercise repository using in-memory storage (hardcoded data)
// - Strategy Pattern: Different way to access exercise data
// - Will be replaced with other strategies (API, database) in production
//
// Usage: For testing and initial development

class InMemoryExerciseStrategy implements ExerciseRepository {
  // TODO: Implement with hardcoded exercise list
  
  @override
  Future<List<Exercise>> getAllExercises() async {
    throw UnimplementedError();
  }

  @override
  Future<Exercise> getExerciseById(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Exercise>> searchExercises(String query) async {
    throw UnimplementedError();
  }

  @override
  Future<Exercise> updateExercise(Exercise exercise) async {
    throw UnimplementedError();
  }
}
