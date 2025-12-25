import '../../l2_domain/models/workout_set.dart';

// Repository Interface: Workout set data operations
//
// Responsibility:
// - Abstract interface for workout set data access
// - Implementation will handle persistence (local DB, API sync, etc.)
//
// Methods needed by use cases:
// - Save completed workout set
// - Get sets by date range
// - Get today's sets
// - Delete workout set
// - Get workout history/analytics

abstract class WorkoutSetRepository {
  Future<WorkoutSet> saveWorkoutSet(WorkoutSet workoutSet);
  Future<List<WorkoutSet>> getWorkoutSets({
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<List<WorkoutSet>> getTodayWorkoutSets();
  Future<void> deleteWorkoutSet(String id);
  Future<int> getWorkoutCount({DateTime? startDate, DateTime? endDate});
  // TODO: Add more methods as needed
}
