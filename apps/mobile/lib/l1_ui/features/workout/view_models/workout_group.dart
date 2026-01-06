import '../../../../l2_domain/use_cases/workout_sets/get_today_completed_list_use_case.dart';

// View Model: Grouped workout sets for UI display
//
// Purpose:
// - Groups workout sets by exercise (all sets of same exercise together)
// - Provides display-ready data for completed list page
// - Pure UI presentation logic
//
// Example grouping:
// Push Up, Push Up, Squat, Squat, Push Up
// → Group 1: Push Up (3 sets)
// → Group 2: Squat (2 sets)

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

  /// Groups workout sets by exercise (all sets of same exercise together)
  /// Input: List of WorkoutSetWithDetails (should be sorted by time)
  /// Output: List of WorkoutGroup with all same exercises grouped together
  ///
  /// Algorithm:
  /// 1. Group all sets by exercise ID
  /// 2. Create groups sorted by first occurrence (newest first)
  static List<WorkoutGroup> groupConsecutive(
    List<WorkoutSetWithDetails> workouts,
  ) {
    if (workouts.isEmpty) return [];

    // Step 1: Group by exercise ID
    final Map<String, List<WorkoutSetWithDetails>> exerciseGroups = {};

    for (final workout in workouts) {
      final exerciseId = workout.workoutSet.exerciseId;
      exerciseGroups.putIfAbsent(exerciseId, () => []);
      exerciseGroups[exerciseId]!.add(workout);
    }

    // Step 2: Create groups, maintaining order of first appearance
    final groups = <WorkoutGroup>[];
    final seenExercises = <String>{};

    for (final workout in workouts) {
      final exerciseId = workout.workoutSet.exerciseId;
      if (!seenExercises.contains(exerciseId)) {
        seenExercises.add(exerciseId);
        final sets = exerciseGroups[exerciseId]!;
        groups.add(_createGroup(sets));
      }
    }

    return groups;
  }

  static WorkoutGroup _createGroup(List<WorkoutSetWithDetails> sets) {
    final firstSet = sets.first;

    // Sort sets by completion time (oldest to newest for display)
    final sortedSets = List<WorkoutSetWithDetails>.from(
      sets,
    )..sort((a, b) => a.workoutSet.timestamp.compareTo(b.workoutSet.timestamp));

    return WorkoutGroup(
      exerciseName: firstSet.exerciseName,
      exerciseId: firstSet.workoutSet.exerciseId,
      setCount: sets.length,
      sets: sortedSets,
      firstCompletedAt: sortedSets.first.workoutSet.timestamp,
      lastCompletedAt: sortedSets.last.workoutSet.timestamp,
    );
  }
}
