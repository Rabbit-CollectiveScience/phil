import 'package:hive/hive.dart';
import '../../l2_domain/legacy_models/workout_set.dart';
import 'workout_set_repository.dart';

// Implementation: Hive-based WorkoutSetRepository
//
// Responsibility:
// - Persists workout sets to local device storage using Hive
// - Provides CRUD operations for workout sets
// - Handles date-based queries for analytics
//
// Strategy: On-device NoSQL document storage
// Future: Can be extended to sync with MongoDB

class HiveWorkoutSetRepository implements WorkoutSetRepository {
  static const String _boxName = 'workout_sets';

  Box<WorkoutSet> get _box => Hive.box<WorkoutSet>(_boxName);

  @override
  Future<WorkoutSet> saveWorkoutSet(WorkoutSet workoutSet) async {
    await _box.put(workoutSet.id, workoutSet);
    return workoutSet;
  }

  @override
  Future<List<WorkoutSet>> getWorkoutSets({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final allSets = _box.values.toList();

    if (startDate == null && endDate == null) {
      return allSets;
    }

    return allSets.where((set) {
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
    await _box.delete(id);
  }

  @override
  Future<int> getWorkoutCount({DateTime? startDate, DateTime? endDate}) async {
    final sets = await getWorkoutSets(startDate: startDate, endDate: endDate);
    return sets.length;
  }
}
