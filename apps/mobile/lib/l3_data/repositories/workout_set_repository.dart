import 'package:hive/hive.dart';
import '../../l2_domain/models/workout_sets/workout_set.dart';
import '../../l2_domain/models/workout_sets/bodyweight_workout_set.dart';
import '../../l2_domain/models/workout_sets/weighted_workout_set.dart';
import '../../l2_domain/models/workout_sets/assisted_machine_workout_set.dart';
import '../../l2_domain/models/workout_sets/isometric_workout_set.dart';
import '../../l2_domain/models/workout_sets/distance_cardio_workout_set.dart';
import '../../l2_domain/models/workout_sets/duration_cardio_workout_set.dart';

/// Repository for managing WorkoutSet entities using Hive storage
///
/// Uses single-table inheritance pattern where all workout set types
/// are stored in one Hive box with type discriminators for polymorphism.
class WorkoutSetRepository {
  static const String _boxName = 'workout_sets';

  Box<Map<dynamic, dynamic>> get _box =>
      Hive.box<Map<dynamic, dynamic>>(_boxName);

  /// Deserialize JSON to the appropriate WorkoutSet subclass based on type field
  WorkoutSet _fromJson(Map<dynamic, dynamic> json) {
    final type = json['type'] as String;

    switch (type) {
      case 'bodyweight':
        return BodyweightWorkoutSet.fromJson(Map<String, dynamic>.from(json));
      case 'weighted':
        return WeightedWorkoutSet.fromJson(Map<String, dynamic>.from(json));
      case 'assisted_machine':
        return AssistedMachineWorkoutSet.fromJson(
          Map<String, dynamic>.from(json),
        );
      case 'isometric':
        return IsometricWorkoutSet.fromJson(Map<String, dynamic>.from(json));
      case 'distance_cardio':
        return DistanceCardioWorkoutSet.fromJson(
          Map<String, dynamic>.from(json),
        );
      case 'duration_cardio':
        return DurationCardioWorkoutSet.fromJson(
          Map<String, dynamic>.from(json),
        );
      default:
        throw Exception('Unknown workout set type: $type');
    }
  }

  /// Save or update a workout set
  Future<WorkoutSet> save(WorkoutSet workoutSet) async {
    await _box.put(workoutSet.id, workoutSet.toJson());
    return workoutSet;
  }

  /// Get all workout sets
  Future<List<WorkoutSet>> getAll() async {
    return _box.values.map((json) => _fromJson(json)).toList();
  }

  /// Get workout set by ID
  Future<WorkoutSet?> getById(String id) async {
    final json = _box.get(id);
    if (json == null) return null;
    return _fromJson(json);
  }

  /// Get all workout sets for a specific exercise
  Future<List<WorkoutSet>> getByExerciseId(String exerciseId) async {
    final all = await getAll();
    return all.where((set) => set.exerciseId == exerciseId).toList();
  }

  /// Get workout sets within a date range
  Future<List<WorkoutSet>> getByDateRange({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final all = await getAll();

    return all.where((set) {
      if (startDate != null && set.timestamp.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && set.timestamp.isAfter(endDate)) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Get today's workout sets
  Future<List<WorkoutSet>> getToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getByDateRange(startDate: startOfDay, endDate: endOfDay);
  }

  /// Get weighted workout sets only (for volume calculations)
  Future<List<WeightedWorkoutSet>> getWeightedSets({
    String? exerciseId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final all = await getByDateRange(startDate: startDate, endDate: endDate);
    var weighted = all.whereType<WeightedWorkoutSet>();

    if (exerciseId != null) {
      weighted = weighted.where((set) => set.exerciseId == exerciseId);
    }

    return weighted.toList();
  }

  /// Delete a workout set
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Delete all workout sets for a specific exercise
  Future<void> deleteByExerciseId(String exerciseId) async {
    final sets = await getByExerciseId(exerciseId);
    for (final set in sets) {
      await delete(set.id);
    }
  }

  /// Delete all workout sets
  Future<void> deleteAll() async {
    await _box.clear();
  }

  /// Get count of workout sets
  Future<int> getCount({DateTime? startDate, DateTime? endDate}) async {
    final sets = await getByDateRange(startDate: startDate, endDate: endDate);
    return sets.length;
  }

  /// Get total volume from weighted sets
  Future<double> getTotalVolume({
    String? exerciseId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final weighted = await getWeightedSets(
      exerciseId: exerciseId,
      startDate: startDate,
      endDate: endDate,
    );

    return weighted.fold<double>(
      0.0,
      (sum, set) => sum + (set.getVolume() ?? 0.0),
    );
  }
}
