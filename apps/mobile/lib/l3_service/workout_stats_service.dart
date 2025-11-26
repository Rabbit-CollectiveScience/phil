import '../l2_domain/models/workout.dart';
import '../l2_domain/models/workout_exercise.dart';

/// Service for calculating workout statistics
class WorkoutStatsService {
  /// Calculate total volume for an exercise (sets × reps × weight)
  static double calculateExerciseVolume(WorkoutExercise exercise) {
    final params = exercise.parameters;
    final sets = params['sets'] as int? ?? 0;
    final reps = params['reps'] as int? ?? 0;
    final weight = params['weight'] as num? ?? 0;

    return sets * reps * weight.toDouble();
  }

  /// Calculate total volume for a workout
  static double calculateWorkoutVolume(Workout workout) {
    return workout.exercises.fold(0.0, (sum, exercise) {
      return sum + calculateExerciseVolume(exercise);
    });
  }

  /// Get today's workouts
  static List<Workout> getTodayWorkouts(List<Workout> allWorkouts) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return allWorkouts.where((workout) {
      return workout.dateTime.isAfter(todayStart) &&
          workout.dateTime.isBefore(todayEnd);
    }).toList();
  }

  /// Get this week's workouts (Monday to Sunday)
  static List<Workout> getThisWeekWorkouts(List<Workout> allWorkouts) {
    final now = DateTime.now();

    // Calculate Monday of current week
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDay = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );
    final weekEnd = weekStartDay.add(const Duration(days: 7));

    return allWorkouts.where((workout) {
      return workout.dateTime.isAfter(weekStartDay) &&
          workout.dateTime.isBefore(weekEnd);
    }).toList();
  }

  /// Calculate today's stats
  static ({
    int exerciseCount,
    double totalVolume,
    int totalDuration,
    Set<String> muscleGroups,
  })
  getTodayStats(List<Workout> allWorkouts) {
    final todayWorkouts = getTodayWorkouts(allWorkouts);

    int exerciseCount = 0;
    double totalVolume = 0.0;
    int totalDuration = 0;
    Set<String> muscleGroups = {};

    for (final workout in todayWorkouts) {
      exerciseCount += workout.exercises.length;
      totalVolume += calculateWorkoutVolume(workout);
      totalDuration += workout.durationMinutes;

      for (final exercise in workout.exercises) {
        if (exercise.muscleGroup.isNotEmpty) {
          muscleGroups.add(exercise.muscleGroup);
        }
      }
    }

    return (
      exerciseCount: exerciseCount,
      totalVolume: totalVolume,
      totalDuration: totalDuration,
      muscleGroups: muscleGroups,
    );
  }

  /// Calculate this week's stats
  static ({
    int workoutCount,
    double totalVolume,
    String mostTrainedMuscleGroup,
    int currentStreak,
    Map<String, int> setsPerMuscleGroup,
    Map<String, double> volumePerMuscleGroup,
  })
  getWeeklyStats(List<Workout> allWorkouts) {
    final weekWorkouts = getThisWeekWorkouts(allWorkouts);

    int workoutCount = weekWorkouts.length;
    double totalVolume = 0.0;
    Map<String, int> muscleGroupCounts = {};
    Map<String, int> setsPerMuscleGroup = {};
    Map<String, double> volumePerMuscleGroup = {};

    for (final workout in weekWorkouts) {
      totalVolume += calculateWorkoutVolume(workout);

      for (final exercise in workout.exercises) {
        if (exercise.muscleGroup.isNotEmpty) {
          muscleGroupCounts[exercise.muscleGroup] =
              (muscleGroupCounts[exercise.muscleGroup] ?? 0) + 1;

          // Calculate total sets for this muscle group
          final params = exercise.parameters;
          final sets = params['sets'] as int? ?? 0;

          setsPerMuscleGroup[exercise.muscleGroup] =
              (setsPerMuscleGroup[exercise.muscleGroup] ?? 0) + sets;

          // Calculate volume for this muscle group
          final exerciseVolume = calculateExerciseVolume(exercise);
          volumePerMuscleGroup[exercise.muscleGroup] =
              (volumePerMuscleGroup[exercise.muscleGroup] ?? 0.0) +
                  exerciseVolume;
        }
      }
    }

    // Find most trained muscle group
    String mostTrainedMuscleGroup = '-';
    int maxCount = 0;
    muscleGroupCounts.forEach((muscle, count) {
      if (count > maxCount) {
        maxCount = count;
        mostTrainedMuscleGroup = muscle;
      }
    });

    // Calculate current streak
    int currentStreak = _calculateStreak(allWorkouts);

    return (
      workoutCount: workoutCount,
      totalVolume: totalVolume,
      mostTrainedMuscleGroup: mostTrainedMuscleGroup,
      currentStreak: currentStreak,
      setsPerMuscleGroup: setsPerMuscleGroup,
      volumePerMuscleGroup: volumePerMuscleGroup,
    );
  }

  /// Calculate current workout streak (consecutive days with workouts)
  static int _calculateStreak(List<Workout> allWorkouts) {
    if (allWorkouts.isEmpty) return 0;

    // Sort workouts by date (most recent first)
    final sortedWorkouts = List<Workout>.from(allWorkouts)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if there's a workout today or yesterday (streak can continue)
    final mostRecent = sortedWorkouts.first.dateTime;
    final mostRecentDay = DateTime(
      mostRecent.year,
      mostRecent.month,
      mostRecent.day,
    );

    final daysSinceLastWorkout = today.difference(mostRecentDay).inDays;
    if (daysSinceLastWorkout > 1) {
      return 0; // Streak broken
    }

    // Count consecutive days with workouts
    int streak = 0;
    DateTime currentDay = today;

    // Group workouts by day
    Map<String, bool> workoutDays = {};
    for (final workout in sortedWorkouts) {
      final day = DateTime(
        workout.dateTime.year,
        workout.dateTime.month,
        workout.dateTime.day,
      );
      workoutDays[day.toString()] = true;
    }

    // Count backwards from today
    for (int i = 0; i < 365; i++) {
      if (workoutDays.containsKey(currentDay.toString())) {
        streak++;
        currentDay = currentDay.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Format volume for display (in kg or lbs depending on settings)
  static String formatVolume(double volume, {bool inKg = true}) {
    if (volume == 0) return '0';

    if (inKg) {
      return volume >= 1000
          ? '${(volume / 1000).toStringAsFixed(1)}k kg'
          : '${volume.toStringAsFixed(0)} kg';
    } else {
      final volumeLbs = volume * 2.20462;
      return volumeLbs >= 1000
          ? '${(volumeLbs / 1000).toStringAsFixed(1)}k lbs'
          : '${volumeLbs.toStringAsFixed(0)} lbs';
    }
  }

  /// Capitalize first letter of string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
