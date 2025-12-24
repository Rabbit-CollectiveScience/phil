import 'package:hive_flutter/hive_flutter.dart';
import '../l2_domain/models/workout.dart';
import '../l4_infrastructure/database/boxes.dart';

/// Service for managing workout data persistence with Hive
class WorkoutService {
  /// Get the workouts box
  Box<Workout> get _box => Hive.box<Workout>(HiveBoxes.workouts);

  /// Save a new workout
  Future<void> saveWorkout(Workout workout) async {
    await _box.put(workout.id, workout);
  }

  /// Get all workouts, sorted by date (newest first)
  Future<List<Workout>> getAllWorkouts() async {
    final workouts = _box.values.toList();
    workouts.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return workouts;
  }

  /// Get a specific workout by ID
  Future<Workout?> getWorkout(String id) async {
    return _box.get(id);
  }

  /// Update an existing workout
  Future<void> updateWorkout(Workout workout) async {
    await _box.put(workout.id, workout);
  }

  /// Delete a workout by ID
  Future<void> deleteWorkout(String id) async {
    // Find and delete the workout by searching for matching workout.id
    // (needed because old workouts may be stored with auto-increment keys)
    for (final key in _box.keys) {
      final workout = _box.get(key);
      if (workout?.id == id) {
        await _box.delete(key);
        break;
      }
    }
  }

  /// Get workouts count
  int get workoutCount => _box.length;

  /// Check if a workout exists
  bool hasWorkout(String id) => _box.containsKey(id);

  /// Export all workouts to JSON (for MongoDB migration)
  Future<List<Map<String, dynamic>>> exportToJson() async {
    final workouts = await getAllWorkouts();
    return workouts.map((w) => w.toJson()).toList();
  }

  /// Import workouts from JSON (for MongoDB migration)
  Future<void> importFromJson(List<Map<String, dynamic>> jsonList) async {
    for (final json in jsonList) {
      final workout = Workout.fromJson(json);
      await saveWorkout(workout);
    }
  }

  /// Clear all workouts (for testing/reset)
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Stream of all workouts (for real-time updates)
  Stream<List<Workout>> watchWorkouts() {
    return _box.watch().map((_) {
      final workouts = _box.values.toList();
      workouts.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return workouts;
    });
  }
}
