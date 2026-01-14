import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../models/workout_sets/workout_set.dart';
import '../../models/workout_sets/weighted_workout_set.dart';
import '../../models/workout_sets/bodyweight_workout_set.dart';
import '../../models/workout_sets/isometric_workout_set.dart';
import '../../models/workout_sets/distance_cardio_workout_set.dart';
import '../../models/workout_sets/duration_cardio_workout_set.dart';
import '../../models/exercises/exercise.dart';
import '../../models/exercises/strength_exercise.dart';
import '../../models/exercises/bodyweight_exercise.dart';
import '../../models/exercises/free_weight_exercise.dart';
import '../../models/exercises/machine_exercise.dart';
import '../../models/exercises/isometric_exercise.dart';
import '../../models/exercises/distance_cardio_exercise.dart';
import '../../models/exercises/duration_cardio_exercise.dart';
import '../../models/common/weight.dart';
import '../../models/common/distance.dart';

/// Generates realistic mock workout data for testing with typed models
class MockDataGenerator {
  static final Random _random = Random();
  static final _uuid = const Uuid();

  /// Generate mock workout sets spanning 3 months
  static List<WorkoutSet> generateMockWorkoutSets(List<Exercise> exercises) {
    final List<WorkoutSet> workoutSets = [];
    final now = DateTime.now();

    // Group exercises by type
    final strengthExercises = exercises
        .where((e) => e is StrengthExercise)
        .toList();
    final cardioExercises = exercises
        .where(
          (e) => e is DistanceCardioExercise || e is DurationCardioExercise,
        )
        .toList();

    if (strengthExercises.isEmpty && cardioExercises.isEmpty) {
      return workoutSets;
    }

    // Select main exercises for regular tracking
    final mainStrength = strengthExercises.take(8).toList();
    final mainCardio = cardioExercises.take(3).toList();

    // Generate 90 days of workout data (including today) - every day
    for (int daysAgo = 90; daysAgo >= 0; daysAgo--) {
      final date = now.subtract(Duration(days: daysAgo));

      final isCardioDay = daysAgo % 3 == 0;

      if (isCardioDay && mainCardio.isNotEmpty) {
        // Cardio day
        final cardioCount = 2 + _random.nextInt(2);
        for (int i = 0; i < cardioCount && i < mainCardio.length; i++) {
          workoutSets.add(_generateCardioSet(mainCardio[i], date, daysAgo));
        }
      } else if (mainStrength.isNotEmpty) {
        // Strength day: 4 exercises, 3 sets each
        final exercisesTodo = mainStrength.take(4).toList();
        for (final exercise in exercisesTodo) {
          workoutSets.addAll(_generateStrengthSets(exercise, date, daysAgo));
        }
      }
    }

    return workoutSets;
  }

  static List<WorkoutSet> _generateStrengthSets(
    Exercise exercise,
    DateTime date,
    int daysAgo,
  ) {
    final sets = <WorkoutSet>[];
    final baseProgress = (90 - daysAgo) / 90.0; // 0 to 1 over time

    // Generate 3 sets per exercise
    for (int setNum = 0; setNum < 3; setNum++) {
      final timestamp = date.add(Duration(minutes: setNum * 3));

      if (exercise is FreeWeightExercise || exercise is MachineExercise) {
        // Weighted sets with progression
        final baseWeight = 40.0 + (baseProgress * 20); // 40-60kg progression
        final weight = Weight(baseWeight + _random.nextDouble() * 5);
        final reps = 8 + _random.nextInt(5); // 8-12 reps

        sets.add(
          WeightedWorkoutSet(
            id: _uuid.v4(),
            exerciseId: exercise.id,
            timestamp: timestamp,
            weight: weight,
            reps: reps,
          ),
        );
      } else if (exercise is BodyweightExercise) {
        // Bodyweight sets with rep progression
        final baseReps = 10 + (baseProgress * 10).toInt(); // 10-20 reps
        final reps = baseReps + _random.nextInt(3);

        sets.add(
          BodyweightWorkoutSet(
            id: _uuid.v4(),
            exerciseId: exercise.id,
            timestamp: timestamp,
            reps: reps,
            additionalWeight: null,
          ),
        );
      } else if (exercise is IsometricExercise) {
        // Isometric holds with duration progression
        final baseDuration = 30 + (baseProgress * 30).toInt(); // 30-60s
        final duration = Duration(seconds: baseDuration + _random.nextInt(10));

        // 30% chance of using additional weight for progression
        final weight = _random.nextDouble() < 0.3
            ? Weight(5.0 + _random.nextInt(4) * 2.5) // 5, 7.5, 10, 12.5 kg
            : null;

        sets.add(
          IsometricWorkoutSet(
            id: _uuid.v4(),
            exerciseId: exercise.id,
            timestamp: timestamp,
            duration: duration,
            weight: weight,
          ),
        );
      }
    }

    return sets;
  }

  static WorkoutSet _generateCardioSet(
    Exercise exercise,
    DateTime date,
    int daysAgo,
  ) {
    final timestamp = date.add(Duration(minutes: 10));
    final baseProgress = (90 - daysAgo) / 90.0;

    if (exercise is DistanceCardioExercise) {
      // Distance cardio with improvement over time
      final baseDistance = 3000 + (baseProgress * 2000); // 3-5km
      final distance = Distance(baseDistance + _random.nextDouble() * 500);
      final baseDuration = 20 + (baseProgress * -5).toInt(); // Getting faster
      final duration = Duration(minutes: baseDuration + _random.nextInt(3));

      return DistanceCardioWorkoutSet(
        id: _uuid.v4(),
        exerciseId: exercise.id,
        timestamp: timestamp,
        duration: duration,
        distance: distance,
      );
    } else {
      // Duration cardio with endurance improvement
      final baseDuration = 20 + (baseProgress * 10).toInt(); // 20-30 min
      final duration = Duration(minutes: baseDuration + _random.nextInt(5));

      return DurationCardioWorkoutSet(
        id: _uuid.v4(),
        exerciseId: exercise.id,
        timestamp: timestamp,
        duration: duration,
      );
    }
  }
}
