import 'workout_service.dart';
import 'mock_workout_data.dart';

/// Service for loading seed/mock data into the database
class SeedDataService {
  final WorkoutService _workoutService;

  SeedDataService(this._workoutService);

  /// Load mock workouts into database
  /// 
  /// Skips workouts that already exist (by ID) to prevent duplicates.
  /// Returns result with counts of added and skipped workouts.
  Future<SeedResult> loadMockData() async {
    int added = 0;
    int skipped = 0;

    for (var workout in MockWorkoutData.mockWorkouts) {
      if (!_workoutService.hasWorkout(workout.id)) {
        await _workoutService.saveWorkout(workout);
        added++;
      } else {
        skipped++;
      }
    }

    return SeedResult(added: added, skipped: skipped);
  }

  /// Check if mock data already exists in database
  Future<bool> hasMockData() async {
    for (var workout in MockWorkoutData.mockWorkouts) {
      if (_workoutService.hasWorkout(workout.id)) {
        return true;
      }
    }
    return false;
  }

  /// Get count of how many mock workouts are already in database
  Future<int> getMockDataCount() async {
    int count = 0;
    for (var workout in MockWorkoutData.mockWorkouts) {
      if (_workoutService.hasWorkout(workout.id)) {
        count++;
      }
    }
    return count;
  }
}

/// Result of loading seed data
class SeedResult {
  final int added;
  final int skipped;

  SeedResult({required this.added, required this.skipped});

  int get total => added + skipped;

  bool get hasAdded => added > 0;
  bool get hasSkipped => skipped > 0;
}
