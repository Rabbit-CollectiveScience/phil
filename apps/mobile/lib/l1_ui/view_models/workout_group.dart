import '../../l2_domain/use_cases/workout_use_cases/get_today_completed_list_use_case.dart';

// View Model: Grouped workout sets for UI display
//
// Purpose:
// - Groups consecutive workout sets of the same exercise
// - Provides display-ready data for completed list page
// - Pure UI presentation logic
//
// Example grouping:
// Push Up, Push Up, Squat, Squat, Push Up
// → Group 1: Push Up (2 sets)
// → Group 2: Squat (2 sets)
// → Group 3: Push Up (1 set)

class WorkoutGroup {
  final String exerciseName;
  final String exerciseId;
  final int setCount;
  final List<WorkoutSetWithDetails> sets;
  final DateTime firstCompletedAt;
  final DateTime lastCompletedAt;

  WorkoutGroup({
    required this.exerciseName,
    required this.exerciseId,
    required this.setCount,
    required this.sets,
    required this.firstCompletedAt,
    required this.lastCompletedAt,
  });

  /// Returns time range display string
  /// Single set: "10:00"
  /// Multiple sets: "10:00 - 10:35"
  String getTimeRangeDisplay() {
    final startTime = _formatTime(firstCompletedAt);
    
    if (setCount == 1) {
      return startTime;
    }
    
    final endTime = _formatTime(lastCompletedAt);
    return '$startTime - $endTime';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Groups consecutive workout sets by exercise
  /// Input: List of WorkoutSetWithDetails (should be sorted by time)
  /// Output: List of WorkoutGroup with consecutive same exercises grouped
  ///
  /// Algorithm:
  /// 1. Reverse list (newest to oldest → oldest to newest)
  /// 2. Group consecutive same exercises
  /// 3. Reverse groups (to show newest group first)
  static List<WorkoutGroup> groupConsecutive(
    List<WorkoutSetWithDetails> workouts,
  ) {
    if (workouts.isEmpty) return [];

    // Step 1: Reverse to process oldest to newest
    final orderedWorkouts = workouts.reversed.toList();

    // Step 2: Group consecutive same exercises
    final groups = <WorkoutGroup>[];
    List<WorkoutSetWithDetails> currentGroup = [orderedWorkouts[0]];
    String currentExerciseId = orderedWorkouts[0].workoutSet.exerciseId;

    for (int i = 1; i < orderedWorkouts.length; i++) {
      final workout = orderedWorkouts[i];

      if (workout.workoutSet.exerciseId == currentExerciseId) {
        // Same exercise, add to current group
        currentGroup.add(workout);
      } else {
        // Different exercise, finalize current group and start new one
        groups.add(_createGroup(currentGroup));
        currentGroup = [workout];
        currentExerciseId = workout.workoutSet.exerciseId;
      }
    }

    // Add final group
    if (currentGroup.isNotEmpty) {
      groups.add(_createGroup(currentGroup));
    }

    // Step 3: Reverse groups to show newest first
    return groups.reversed.toList();
  }

  static WorkoutGroup _createGroup(List<WorkoutSetWithDetails> sets) {
    final firstSet = sets.first;
    final lastSet = sets.last;

    return WorkoutGroup(
      exerciseName: firstSet.exerciseName,
      exerciseId: firstSet.workoutSet.exerciseId,
      setCount: sets.length,
      sets: sets,
      firstCompletedAt: firstSet.workoutSet.completedAt,
      lastCompletedAt: lastSet.workoutSet.completedAt,
    );
  }
}
