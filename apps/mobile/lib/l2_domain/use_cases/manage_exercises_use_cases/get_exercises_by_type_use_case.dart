import '../../models/exercise.dart';
import '../../models/exercise_type_enum.dart';

// Use Case: Get exercises filtered by type (Analyze Mode)
//
// Responsibility:
// - Retrieve all exercises from data store
// - Filter by specific exercise type (strength, cardio, flexibility)
// - Return filtered list
//
// Used by: Analyze mode pages for viewing exercises by category

class GetExercisesByTypeUseCase {
  Future<List<Exercise>> execute(ExerciseTypeEnum exerciseType) async {
    // TODO: Implement
    // - Load all exercises from repository
    // - Filter by exerciseType
    // - Return filtered list
    throw UnimplementedError();
  }
}
