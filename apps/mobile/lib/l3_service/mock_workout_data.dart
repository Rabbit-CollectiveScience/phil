import '../l2_domain/models/workout.dart';
import '../l2_domain/models/workout_exercise.dart';

/// Mock workout data with 10 weeks of progressive training
/// Covers all muscle groups, cardio, and flexibility
/// All weights in kg and distances in km (base units)
/// Data is dynamically generated from the most recent Monday
class MockWorkoutData {
  static List<Workout> get mockWorkouts {
    // Get today as reference date (not Monday)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _generateMockWorkouts(today, weeksBack: 10);
  }

  /// Get the most recent Monday (today if Monday, or previous Monday)
  static DateTime _getMostRecentMonday(DateTime date) {
    final weekday = date.weekday; // Monday = 1, Sunday = 7
    final daysToSubtract = weekday == DateTime.monday ? 0 : weekday - 1;
    final monday = date.subtract(Duration(days: daysToSubtract));
    return DateTime(monday.year, monday.month, monday.day);
  }

  /// Generate workouts spanning the specified number of weeks
  static List<Workout> _generateMockWorkouts(
    DateTime referenceDate, {
    required int weeksBack,
  }) {
    final workouts = <Workout>[];

    // Exercise library with baseline stats (starting point)
    final exerciseLibrary = _getExerciseLibrary();

    // Get current week bounds (Monday to Sunday)
    final now = DateTime.now();
    final currentWeekMonday = _getMostRecentMonday(now);
    final currentWeekSunday = currentWeekMonday.add(const Duration(days: 6));

    // Generate workouts through the end of current week (next Sunday at 23:59:59)
    final endOfWeek = DateTime(
      currentWeekSunday.year,
      currentWeekSunday.month,
      currentWeekSunday.day,
      23,
      59,
      59,
    );

    // Helper to check if a date is in current week
    bool isCurrentWeek(DateTime date) {
      return date.isAfter(
            currentWeekMonday.subtract(const Duration(days: 1)),
          ) &&
          date.isBefore(currentWeekSunday.add(const Duration(days: 1)));
    }

    for (int week = 0; week < weeksBack; week++) {
      // Calculate the Monday of this week, going backwards from today
      final daysBack = 7 * (weeksBack - week - 1);
      final targetDate = referenceDate.subtract(Duration(days: daysBack));
      final weekStart = _getMostRecentMonday(targetDate);

      // Calculate progression multiplier (increases every 2 weeks)
      final progressionWeek = week ~/ 2;
      final weightMultiplier =
          1.0 + (progressionWeek * 0.05); // +5% every 2 weeks
      final repsBonus = progressionWeek; // +1 rep every 2 weeks
      final distanceMultiplier =
          1.0 + (progressionWeek * 0.03); // +3% every 2 weeks

      // For current week: balanced strength every day, similar volumes
      // For past weeks: varied schedule
      final isCurWeek = isCurrentWeek(weekStart);

      // Monday: Push Day
      final monday = weekStart;
      final skipMonday = !isCurWeek && week % 7 == 3;
      if (!skipMonday && (monday.isBefore(endOfWeek))) {
        workouts.add(
          _createPushWorkout(
            monday,
            exerciseLibrary,
            weightMultiplier,
            repsBonus,
          ),
        );
      }

      // Tuesday: Pull Day (or balanced if current week)
      final tuesday = weekStart.add(const Duration(days: 1));
      if (tuesday.isBefore(endOfWeek)) {
        workouts.add(
          _createPullWorkout(
            tuesday,
            exerciseLibrary,
            weightMultiplier,
            repsBonus,
          ),
        );
      }

      // Wednesday: Leg Day (or balanced if current week)
      final wednesday = weekStart.add(const Duration(days: 2));
      if (wednesday.isBefore(endOfWeek)) {
        workouts.add(
          _createLegWorkout(
            wednesday,
            exerciseLibrary,
            weightMultiplier,
            repsBonus,
          ),
        );
      }

      // Thursday: Full Body for current week, Cardio for past weeks
      final thursday = weekStart.add(const Duration(days: 3));
      if (thursday.isBefore(endOfWeek)) {
        if (isCurWeek) {
          // Current week: Full body strength (balanced volume)
          workouts.add(
            _createFullBodyWorkout(
              thursday,
              exerciseLibrary,
              weightMultiplier,
              repsBonus,
            ),
          );
        } else {
          // Past weeks: Cardio only
          workouts.add(_createCardioWorkout(thursday, distanceMultiplier));
        }
      }

      // Friday: Upper Body
      final friday = weekStart.add(const Duration(days: 4));
      final skipFriday = !isCurWeek && week % 11 == 5;
      if (!skipFriday && friday.isBefore(endOfWeek)) {
        workouts.add(
          _createUpperBodyWorkout(
            friday,
            exerciseLibrary,
            weightMultiplier,
            repsBonus,
          ),
        );
      }

      // Saturday: Strength for current week, occasional cardio for past
      final saturday = weekStart.add(const Duration(days: 5));
      if (saturday.isBefore(endOfWeek)) {
        if (isCurWeek) {
          // Current week: Leg focus (balanced volume)
          workouts.add(
            _createLegWorkout(
              saturday,
              exerciseLibrary,
              weightMultiplier * 0.9,
              repsBonus,
            ),
          );
        } else if (week % 3 == 0) {
          workouts.add(
            _createWeekendCardioWorkout(saturday, distanceMultiplier),
          );
        }
      }

      // Sunday: Strength for current week
      final sunday = weekStart.add(const Duration(days: 6));
      if (sunday.isBefore(endOfWeek)) {
        if (isCurWeek) {
          // Current week: Upper body (balanced volume)
          workouts.add(
            _createUpperBodyWorkout(
              sunday,
              exerciseLibrary,
              weightMultiplier * 0.85,
              repsBonus,
            ),
          );
        }
      }
    }

    return workouts;
  }

  /// Exercise library with baseline parameters
  static Map<String, Map<String, dynamic>> _getExerciseLibrary() {
    return {
      // Push exercises
      'bench-press': {'weight': 60.0, 'reps': 8, 'sets': 4},
      'incline-db-press': {'weight': 25.0, 'reps': 10, 'sets': 3},
      'overhead-press': {'weight': 40.0, 'reps': 8, 'sets': 4},
      'lateral-raise': {'weight': 12.0, 'reps': 12, 'sets': 3},
      'tricep-dips': {'weight': 0.0, 'reps': 12, 'sets': 3},
      'cable-fly': {'weight': 15.0, 'reps': 12, 'sets': 3},

      // Pull exercises
      'deadlift': {'weight': 100.0, 'reps': 5, 'sets': 4},
      'pull-ups': {'weight': 0.0, 'reps': 8, 'sets': 4},
      'barbell-row': {'weight': 70.0, 'reps': 8, 'sets': 4},
      'lat-pulldown': {'weight': 60.0, 'reps': 10, 'sets': 3},
      'face-pulls': {'weight': 20.0, 'reps': 15, 'sets': 3},
      'bicep-curls': {'weight': 15.0, 'reps': 12, 'sets': 3},
      'hammer-curls': {'weight': 17.5, 'reps': 10, 'sets': 3},

      // Leg exercises
      'squat': {'weight': 80.0, 'reps': 8, 'sets': 4},
      'leg-press': {'weight': 140.0, 'reps': 12, 'sets': 3},
      'romanian-deadlift': {'weight': 70.0, 'reps': 10, 'sets': 3},
      'leg-curl': {'weight': 50.0, 'reps': 12, 'sets': 3},
      'leg-extension': {'weight': 55.0, 'reps': 12, 'sets': 3},
      'calf-raise': {'weight': 60.0, 'reps': 15, 'sets': 4},

      // Cardio baselines
      'running': {'distance': 4.0, 'duration': 25},
      'cycling': {'distance': 12.0, 'duration': 30},
      'rowing': {'distance': 3.0, 'duration': 15},
    };
  }

  /// Create Push Day workout (Chest, Shoulders, Triceps)
  static Workout _createPushWorkout(
    DateTime date,
    Map<String, Map<String, dynamic>> library,
    double weightMultiplier,
    int repsBonus,
  ) {
    final workoutTime = date.add(const Duration(hours: 18)); // 6 PM

    return Workout(
      id: workoutTime.millisecondsSinceEpoch.toString(),
      dateTime: workoutTime,
      durationMinutes: 65,
      exercises: [
        _createExercise(
          'barbell-bench-press',
          'Barbell Bench Press',
          'strength',
          'chest',
          library['bench-press']!,
          weightMultiplier,
          repsBonus,
          workoutTime,
        ),
        _createExercise(
          'incline-dumbbell-press',
          'Incline Dumbbell Press',
          'strength',
          'chest',
          library['incline-db-press']!,
          weightMultiplier,
          repsBonus,
          workoutTime.add(const Duration(minutes: 12)),
        ),
        _createExercise(
          'overhead-press',
          'Overhead Press',
          'strength',
          'shoulders',
          library['overhead-press']!,
          weightMultiplier,
          repsBonus,
          workoutTime.add(const Duration(minutes: 25)),
        ),
        _createExercise(
          'lateral-raise',
          'Lateral Raise',
          'strength',
          'shoulders',
          library['lateral-raise']!,
          weightMultiplier,
          repsBonus,
          workoutTime.add(const Duration(minutes: 38)),
        ),
        _createExercise(
          'cable-chest-fly',
          'Cable Chest Fly',
          'strength',
          'chest',
          library['cable-fly']!,
          weightMultiplier,
          repsBonus,
          workoutTime.add(const Duration(minutes: 48)),
        ),
        _createExercise(
          'tricep-dips',
          'Tricep Dips',
          'strength',
          'arms',
          library['tricep-dips']!,
          weightMultiplier,
          repsBonus,
          workoutTime.add(const Duration(minutes: 58)),
        ),
      ],
    );
  }

  /// Create Pull Day workout (Back, Biceps)
  static Workout _createPullWorkout(
    DateTime date,
    Map<String, Map<String, dynamic>> library,
    double weightMultiplier,
    int repsBonus,
  ) {
    final workoutTime = date.add(
      const Duration(hours: 18, minutes: 30),
    ); // 6:30 PM

    return Workout(
      id: workoutTime.millisecondsSinceEpoch.toString(),
      dateTime: workoutTime,
      durationMinutes: 70,
      exercises: [
        _createExercise(
          'deadlift',
          'Deadlift',
          'strength',
          'back',
          library['deadlift']!,
          weightMultiplier,
          repsBonus,
          workoutTime,
        ),
        _createExercise(
          'pull-ups',
          'Pull Ups',
          'strength',
          'back',
          library['pull-ups']!,
          weightMultiplier,
          repsBonus,
          workoutTime.add(const Duration(minutes: 15)),
        ),
        _createExercise(
          'barbell-row',
          'Barbell Row',
          'strength',
          'back',
          library['barbell-row']!,
          weightMultiplier,
          repsBonus,
          workoutTime.add(const Duration(minutes: 28)),
        ),
        _createExercise(
          'lat-pulldown',
          'Lat Pulldown',
          'strength',
          'back',
          library['lat-pulldown']!,
          weightMultiplier,
          repsBonus,
          workoutTime.add(const Duration(minutes: 40)),
        ),
        _createExercise(
          'face-pulls',
          'Face Pulls',
          'strength',
          'shoulders',
          library['face-pulls']!,
          weightMultiplier,
          repsBonus,
          workoutTime.add(const Duration(minutes: 50)),
        ),
        _createExercise(
          'barbell-curl',
          'Barbell Curl',
          'strength',
          'arms',
          library['bicep-curls']!,
          weightMultiplier,
          repsBonus,
          workoutTime.add(const Duration(minutes: 58)),
        ),
        _createExercise(
          'hammer-curls',
          'Hammer Curls',
          'strength',
          'arms',
          library['hammer-curls']!,
          weightMultiplier,
          repsBonus,
          workoutTime.add(const Duration(minutes: 65)),
        ),
      ],
    );
  }

  /// Create Leg Day workout
  static Workout _createLegWorkout(
    DateTime date,
    Map<String, Map<String, dynamic>> library,
    double weightMultiplier,
    int repsBonus,
  ) {
    final workoutTime = date.add(
      const Duration(hours: 17, minutes: 45),
    ); // 5:45 PM

    return Workout(
      id: workoutTime.millisecondsSinceEpoch.toString(),
      dateTime: workoutTime,
      durationMinutes: 75,
      exercises: [
        _createExercise(
          'barbell-squat',
          'Barbell Squat',
          'strength',
          'legs',
          library['squat']!,
          weightMultiplier,
          repsBonus,
          workoutTime,
        ),
        _createExercise(
          'leg-press',
          'Leg Press',
          'strength',
          'legs',
          library['leg-press']!,
          weightMultiplier,
          repsBonus,
          workoutTime.add(const Duration(minutes: 15)),
        ),
        _createExercise(
          'romanian-deadlift',
          'Romanian Deadlift',
          'strength',
          'legs',
          library['romanian-deadlift']!,
          weightMultiplier,
          repsBonus,
          workoutTime.add(const Duration(minutes: 28)),
        ),
        _createExercise(
          'leg-curl',
          'Leg Curl',
          'strength',
          'legs',
          library['leg-curl']!,
          weightMultiplier,
          repsBonus,
          workoutTime.add(const Duration(minutes: 40)),
        ),
        _createExercise(
          'leg-extension',
          'Leg Extension',
          'strength',
          'legs',
          library['leg-extension']!,
          weightMultiplier,
          repsBonus,
          workoutTime.add(const Duration(minutes: 50)),
        ),
        _createExercise(
          'calf-raise',
          'Calf Raise',
          'strength',
          'legs',
          library['calf-raise']!,
          weightMultiplier,
          repsBonus,
          workoutTime.add(const Duration(minutes: 60)),
        ),
      ],
    );
  }

  /// Create Full Body workout (balanced volume for current week)
  static Workout _createFullBodyWorkout(
    DateTime date,
    Map<String, Map<String, dynamic>> library,
    double weightMultiplier,
    int repsBonus,
  ) {
    final workoutTime = date.add(const Duration(hours: 18)); // 6 PM

    return Workout(
      id: workoutTime.millisecondsSinceEpoch.toString(),
      dateTime: workoutTime,
      durationMinutes: 60,
      exercises: [
        _createExercise(
          'barbell-squat',
          'Barbell Squat',
          'strength',
          'legs',
          library['squat']!,
          weightMultiplier * 0.9,
          repsBonus,
          workoutTime,
        ),
        _createExercise(
          'barbell-bench-press',
          'Barbell Bench Press',
          'strength',
          'chest',
          library['bench-press']!,
          weightMultiplier * 0.9,
          repsBonus,
          workoutTime.add(const Duration(minutes: 15)),
        ),
        _createExercise(
          'barbell-row',
          'Barbell Row',
          'strength',
          'back',
          library['barbell-row']!,
          weightMultiplier * 0.9,
          repsBonus,
          workoutTime.add(const Duration(minutes: 28)),
        ),
        _createExercise(
          'overhead-press',
          'Overhead Press',
          'strength',
          'shoulders',
          library['overhead-press']!,
          weightMultiplier * 0.9,
          repsBonus,
          workoutTime.add(const Duration(minutes: 40)),
        ),
      ],
    );
  }

  /// Create Cardio Day workout
  static Workout _createCardioWorkout(
    DateTime date,
    double distanceMultiplier,
  ) {
    final workoutTime = date.add(const Duration(hours: 7)); // 7 AM

    final distance = (4.0 * distanceMultiplier).clamp(4.0, 6.5);
    final duration = (distance / 4.0 * 25).round();
    final pace = _calculatePace(distance, duration);

    return Workout(
      id: workoutTime.millisecondsSinceEpoch.toString(),
      dateTime: workoutTime,
      durationMinutes: duration + 10,
      exercises: [
        WorkoutExercise(
          exerciseId: 'running',
          name: 'Running',
          category: 'cardio',
          muscleGroup: 'cardio',
          parameters: {
            'duration': duration,
            'distance': double.parse(distance.toStringAsFixed(1)),
            'pace': pace,
          },
          createdAt: workoutTime,
          updatedAt: workoutTime,
        ),
        WorkoutExercise(
          exerciseId: 'stretching',
          name: 'Post-Run Stretching',
          category: 'flexibility',
          muscleGroup: 'flexibility',
          parameters: {'duration': 10},
          createdAt: workoutTime.add(Duration(minutes: duration)),
          updatedAt: workoutTime.add(Duration(minutes: duration)),
        ),
      ],
    );
  }

  /// Create Upper Body workout (lighter, with flexibility)
  static Workout _createUpperBodyWorkout(
    DateTime date,
    Map<String, Map<String, dynamic>> library,
    double weightMultiplier,
    int repsBonus,
  ) {
    final workoutTime = date.add(
      const Duration(hours: 18, minutes: 15),
    ); // 6:15 PM

    // Use 85% of normal weight for this lighter session
    final lightWeightMultiplier = weightMultiplier * 0.85;

    return Workout(
      id: workoutTime.millisecondsSinceEpoch.toString(),
      dateTime: workoutTime,
      durationMinutes: 55,
      exercises: [
        _createExercise(
          'incline-dumbbell-press',
          'Incline Dumbbell Press',
          'strength',
          'chest',
          library['incline-db-press']!,
          lightWeightMultiplier,
          repsBonus,
          workoutTime,
        ),
        _createExercise(
          'lat-pulldown',
          'Lat Pulldown',
          'strength',
          'back',
          library['lat-pulldown']!,
          lightWeightMultiplier,
          repsBonus,
          workoutTime.add(const Duration(minutes: 12)),
        ),
        _createExercise(
          'lateral-raise',
          'Lateral Raise',
          'strength',
          'shoulders',
          library['lateral-raise']!,
          lightWeightMultiplier,
          repsBonus,
          workoutTime.add(const Duration(minutes: 22)),
        ),
        _createExercise(
          'barbell-curl',
          'Barbell Curl',
          'strength',
          'arms',
          library['bicep-curls']!,
          lightWeightMultiplier,
          repsBonus,
          workoutTime.add(const Duration(minutes: 32)),
        ),
        WorkoutExercise(
          exerciseId: 'yoga-flow',
          name: 'Yoga Flow',
          category: 'flexibility',
          muscleGroup: 'flexibility',
          parameters: {'duration': 15},
          createdAt: workoutTime.add(const Duration(minutes: 40)),
          updatedAt: workoutTime.add(const Duration(minutes: 40)),
        ),
      ],
    );
  }

  /// Create weekend cardio workout
  static Workout _createWeekendCardioWorkout(
    DateTime date,
    double distanceMultiplier,
  ) {
    final workoutTime = date.add(const Duration(hours: 8)); // 8 AM

    final cyclingDistance = (12.0 * distanceMultiplier).clamp(12.0, 18.0);
    final cyclingDuration = (cyclingDistance / 12.0 * 30).round();

    return Workout(
      id: workoutTime.millisecondsSinceEpoch.toString(),
      dateTime: workoutTime,
      durationMinutes: cyclingDuration + 15,
      exercises: [
        WorkoutExercise(
          exerciseId: 'cycling',
          name: 'Cycling',
          category: 'cardio',
          muscleGroup: 'cardio',
          parameters: {
            'duration': cyclingDuration,
            'distance': double.parse(cyclingDistance.toStringAsFixed(1)),
          },
          createdAt: workoutTime,
          updatedAt: workoutTime,
        ),
        WorkoutExercise(
          exerciseId: 'rowing-machine',
          name: 'Rowing Machine',
          category: 'cardio',
          muscleGroup: 'cardio',
          parameters: {'duration': 15, 'distance': 3.0},
          createdAt: workoutTime.add(Duration(minutes: cyclingDuration)),
          updatedAt: workoutTime.add(Duration(minutes: cyclingDuration)),
        ),
      ],
    );
  }

  /// Helper to create a strength exercise with progression
  static WorkoutExercise _createExercise(
    String exerciseId,
    String name,
    String category,
    String muscleGroup,
    Map<String, dynamic> baseline,
    double weightMultiplier,
    int repsBonus,
    DateTime timestamp,
  ) {
    final baseWeight = baseline['weight'] as double;
    final baseReps = baseline['reps'] as int;
    final sets = baseline['sets'] as int;

    // Apply progression
    final weight = baseWeight > 0
        ? double.parse((baseWeight * weightMultiplier).toStringAsFixed(1))
        : 0.0;
    final reps = baseReps + repsBonus;

    return WorkoutExercise(
      exerciseId: exerciseId,
      name: name,
      category: category,
      muscleGroup: muscleGroup,
      parameters: {
        'sets': sets,
        'reps': reps,
        if (weight > 0) 'weight': weight,
        'restBetweenSets': 90,
      },
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  /// Calculate pace in min:sec per km format
  static String _calculatePace(double distance, int duration) {
    final paceMinutes = duration / distance;
    final minutes = paceMinutes.floor();
    final seconds = ((paceMinutes - minutes) * 60).round();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
