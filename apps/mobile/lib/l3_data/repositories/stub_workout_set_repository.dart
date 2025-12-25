import '../../l2_domain/models/workout_set.dart';
import 'workout_set_repository.dart';

// Strategy: Stub implementation of WorkoutSetRepository
//
// Responsibility:
// - Provides hardcoded/stub data for testing and development
// - Returns predefined workout set data
// - Strategy Pattern: Simple stub data strategy
//
// Usage: For initial development and testing without real data source

class StubWorkoutSetRepository implements WorkoutSetRepository {
  @override
  Future<WorkoutSet> saveWorkoutSet(WorkoutSet workoutSet) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<List<WorkoutSet>> getWorkoutSets({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<List<WorkoutSet>> getTodayWorkoutSets() async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<void> deleteWorkoutSet(String id) async {
    // TODO: Implement
    throw UnimplementedError();
  }

  @override
  Future<int> getWorkoutCount({DateTime? startDate, DateTime? endDate}) async {
    // TODO: Implement
    throw UnimplementedError();
  }
}
