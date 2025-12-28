import 'package:uuid/uuid.dart';
import '../../models/workout_set.dart';
import '../../../l3_data/repositories/workout_set_repository.dart';

// Use Case: Record a completed workout set
//
// Responsibility:
// - Create WorkoutSet with exercise data and completion timestamp
// - Validate set data based on exercise type (optional validation)
// - Save set to data store
// - Update workout session progress
//
// Used by: SwipeableCard when user completes exercise (presses ZET button)

class RecordWorkoutSetUseCase {
  final WorkoutSetRepository _repository;
  final _uuid = const Uuid();

  RecordWorkoutSetUseCase(this._repository);

  Future<WorkoutSet> execute({
    required String exerciseId,
    Map<String, dynamic>? values,
  }) async {
    // Create WorkoutSet with current timestamp
    final workoutSet = WorkoutSet(
      id: _uuid.v4(),
      exerciseId: exerciseId,
      completedAt: DateTime.now(),
      values: values,
    );

    // Save to repository
    final savedSet = await _repository.saveWorkoutSet(workoutSet);

    return savedSet;
  }
}
