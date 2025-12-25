import '../repositories/workout_repository.dart';
import '../../l2_domain/models/workout_set.dart';

// Strategy: In-memory implementation of WorkoutRepository
//
// Responsibility:
// - Implements workout repository using in-memory storage
// - Strategy Pattern: Different way to persist workout data
// - Will be replaced with other strategies (SQLite, Hive, etc.) in production
//
// Usage: For testing and initial development

class InMemoryWorkoutStrategy implements WorkoutRepository {
  final List<WorkoutSet> _workoutSets = [];

  // TODO: Implement with in-memory list
  
  @override
  Future<WorkoutSet> saveWorkoutSet(WorkoutSet workoutSet) async {
    throw UnimplementedError();
  }

  @override
  Future<List<WorkoutSet>> getWorkoutSets({DateTime? startDate, DateTime? endDate}) async {
    throw UnimplementedError();
  }

  @override
  Future<List<WorkoutSet>> getTodayWorkoutSets() async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteWorkoutSet(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<int> getWorkoutCount({DateTime? startDate, DateTime? endDate}) async {
    throw UnimplementedError();
  }
}
