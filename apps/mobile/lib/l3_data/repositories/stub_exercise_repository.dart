import '../../l2_domain/models/exercise.dart';
import 'exercise_repository.dart';

// Strategy: Stub implementation of ExerciseRepository
//
// Responsibility:
// - Provides hardcoded/stub data for testing and development
// - Returns predefined exercise list
// - Strategy Pattern: Simple stub data strategy
//
// Usage: For initial development and testing without real data source

class StubExerciseRepository implements ExerciseRepository {
  @override
  Future<List<Exercise>> getAllExercises() async {
    // TODO: Implement with stub/hardcoded exercise list
    throw UnimplementedError();
  }

  @override
  Future<Exercise> getExerciseById(String id) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<List<Exercise>> searchExercises(String query) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<Exercise> updateExercise(Exercise exercise) async {
    // TODO: Implement
    throw UnimplementedError();
  }
}
