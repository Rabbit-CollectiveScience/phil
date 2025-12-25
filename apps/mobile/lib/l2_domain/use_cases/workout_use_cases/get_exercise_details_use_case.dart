import '../../models/exercise.dart';

// Use Case: Get exercise details and input fields for selected exercise
//
// Responsibility:
// - Retrieve exercise by ID
// - Return exercise with type-specific fields:
//   - Strength: weight, unit (kg/lb), reps
//   - Cardio: duration, level, levelUnit
//   - Flexibility: holdTime, reps
//   - Custom: dynamic fields map
//
// Used by: SwipeableCard when user taps/selects an exercise

class GetExerciseDetailsUseCase {
  Future<Exercise> execute(String exerciseId) async {
    // TODO: Implement
    // - Retrieve exercise from repository by ID
    // - Return exercise (UI will handle type-specific rendering)
    throw UnimplementedError();
  }
}
