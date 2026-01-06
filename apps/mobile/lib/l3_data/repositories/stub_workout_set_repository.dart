import '../../l2_domain/legacy_models/workout_set.dart';
import 'workout_set_repository.dart';

// Strategy: Stub implementation of WorkoutSetRepository
//
// Responsibility:
// - Provides in-memory stub data for testing and development
// - Simulates database operations without persistence
// - Strategy Pattern: Simple stub data strategy
//
// Usage: For initial development and testing without real data source

class StubWorkoutSetRepository implements WorkoutSetRepository {
  final List<WorkoutSet> _workoutSets = [];

  @override
  Future<WorkoutSet> saveWorkoutSet(WorkoutSet workoutSet) async {
    // Simulate save by adding to in-memory list
    _workoutSets.add(workoutSet);
    return workoutSet;
  }

  @override
  Future<List<WorkoutSet>> getWorkoutSets({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (startDate == null && endDate == null) {
      return List.from(_workoutSets);
    }

    return _workoutSets.where((set) {
      if (startDate != null && set.completedAt.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && set.completedAt.isAfter(endDate)) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<List<WorkoutSet>> getTodayWorkoutSets() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getWorkoutSets(startDate: startOfDay, endDate: endOfDay);
  }

  @override
  Future<void> deleteWorkoutSet(String id) async {
    _workoutSets.removeWhere((set) => set.id == id);
  }

  @override
  Future<int> getWorkoutCount({DateTime? startDate, DateTime? endDate}) async {
    final sets = await getWorkoutSets(startDate: startDate, endDate: endDate);
    return sets.length;
  }

  // Helper method for testing - clear all data
  void clear() {
    _workoutSets.clear();
  }

  // Helper method for testing - get count
  int get count => _workoutSets.length;
}
