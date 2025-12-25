import '../../models/workout_set.dart';
import '../../models/exercise_type_enum.dart';

// Use Case: Record a completed workout set
//
// Responsibility:
// - Create WorkoutSet with exercise data and completion timestamp
// - Validate set data based on exercise type
// - Save set to data store
// - Update workout session progress
//
// Used by: SwipeableCard when user completes exercise (presses ZET button)

class RecordWorkoutSetUseCase {
  Future<WorkoutSet> execute({
    required String exerciseId,
    required ExerciseTypeEnum exerciseType,
    required Map<String, dynamic> values,
  }) async {
    // TODO: Implement
    // - Validate values based on exercise type
    // - Create WorkoutSet with current timestamp
    // - Save to repository
    // - Return created WorkoutSet
    throw UnimplementedError();
  }
}
