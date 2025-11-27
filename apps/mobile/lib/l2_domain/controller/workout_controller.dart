import 'package:hive/hive.dart';
import '../models/workout.dart';
import '../models/workout_exercise.dart';
import '../../l3_service/workout_service.dart';
import '../../l4_infrastructure/database/boxes.dart';

/// Core workout business logic controller
/// Handles workout lifecycle, grouping rules, and exercise management
/// Used by both manual UI logging and AI voice logging
class WorkoutController {
  final WorkoutService _workoutService = WorkoutService();

  /// Default time threshold for grouping exercises into same workout
  static const Duration defaultTimeThreshold = Duration(hours: 1);

  /// Add exercise to appropriate workout based on time-based grouping rules
  ///
  /// Creates a new workout if:
  /// - No workout exists today
  /// - Last workout was more than [timeThreshold] ago (default: 1 hour)
  /// - [forceNewWorkout] is true
  ///
  /// Otherwise adds to most recent workout
  Future<Workout> addExerciseToAppropriateWorkout({
    required WorkoutExercise exercise,
    Duration? timeThreshold,
    bool forceNewWorkout = false,
  }) async {
    final threshold = timeThreshold ?? defaultTimeThreshold;

    if (forceNewWorkout) {
      return await _createNewWorkout(
        dateTime: exercise.createdAt,
        exercises: [exercise],
      );
    }

    // Find most recent workout today
    final recentWorkout = await _findMostRecentWorkoutToday();

    // Determine if we should create new workout
    final shouldCreateNew = _shouldCreateNewWorkout(
      recentWorkout,
      exerciseTime: exercise.createdAt,
      threshold: threshold,
    );

    if (shouldCreateNew) {
      return await _createNewWorkout(
        dateTime: exercise.createdAt,
        exercises: [exercise],
      );
    } else {
      // Add to existing workout
      return await _addExerciseToWorkout(recentWorkout!, exercise);
    }
  }

  /// Create a new workout
  Future<Workout> _createNewWorkout({
    DateTime? dateTime,
    List<WorkoutExercise>? exercises,
  }) async {
    final workout = Workout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dateTime: dateTime ?? DateTime.now(),
      exercises: exercises ?? [],
      durationMinutes: 0,
    );

    await _workoutService.saveWorkout(workout);
    print('✅ Created new workout: ${workout.id} at ${workout.dateTime}');
    return workout;
  }

  /// Add exercise to existing workout
  Future<Workout> _addExerciseToWorkout(
    Workout workout,
    WorkoutExercise exercise,
  ) async {
    final updatedExercises = [...workout.exercises, exercise];
    final updatedWorkout = Workout(
      id: workout.id,
      dateTime: workout.dateTime,
      exercises: updatedExercises,
      durationMinutes: workout.durationMinutes,
    );

    await _workoutService.updateWorkout(updatedWorkout);
    print('✅ Added exercise to workout: ${workout.id}');
    return updatedWorkout;
  }

  /// Update existing workout
  Future<void> updateWorkout(Workout workout) async {
    await _workoutService.updateWorkout(workout);
  }

  /// Delete workout by ID
  Future<void> deleteWorkout(String workoutId) async {
    await _workoutService.deleteWorkout(workoutId);
  }

  /// Determine if a new workout should be created
  /// Returns true if:
  /// - No recent workout exists
  /// - Time gap between exercise and last workout exceeds threshold
  bool _shouldCreateNewWorkout(
    Workout? lastWorkout, {
    required DateTime exerciseTime,
    required Duration threshold,
  }) {
    if (lastWorkout == null) {
      return true;
    }

    // Check time gap from last workout's start time
    final timeSinceLastWorkout = exerciseTime.difference(lastWorkout.dateTime);
    return timeSinceLastWorkout >= threshold;
  }

  /// Find the most recent workout today
  Future<Workout?> _findMostRecentWorkoutToday() async {
    final workoutBox = Hive.box<Workout>(HiveBoxes.workouts);

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    Workout? mostRecent;
    DateTime? mostRecentTime;

    for (final workout in workoutBox.values) {
      if (workout.dateTime.isAfter(todayStart) &&
          workout.dateTime.isBefore(todayEnd)) {
        if (mostRecentTime == null ||
            workout.dateTime.isAfter(mostRecentTime)) {
          mostRecent = workout;
          mostRecentTime = workout.dateTime;
        }
      }
    }

    return mostRecent;
  }

  /// Replace an exercise in a workout
  Future<void> replaceExercise({
    required Workout workout,
    required WorkoutExercise oldExercise,
    required WorkoutExercise newExercise,
  }) async {
    final updatedExercises = workout.exercises.map((ex) {
      // Compare by creation time to find the exact exercise
      if (ex.createdAt == oldExercise.createdAt) {
        return newExercise;
      }
      return ex;
    }).toList();

    final updatedWorkout = Workout(
      id: workout.id,
      dateTime: workout.dateTime,
      exercises: updatedExercises,
      durationMinutes: workout.durationMinutes,
    );

    await _workoutService.updateWorkout(updatedWorkout);
  }

  /// Get today's most recent workout (public method for corrections)
  Future<Workout?> getTodaysMostRecentWorkout() async {
    return await _findMostRecentWorkoutToday();
  }

  /// Get all workouts
  Future<List<Workout>> getAllWorkouts() async {
    return await _workoutService.getAllWorkouts();
  }

  /// Get specific workout by ID
  Future<Workout?> getWorkout(String workoutId) async {
    return await _workoutService.getWorkout(workoutId);
  }
}
