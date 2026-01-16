import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../models/workout_sets/workout_set.dart';
import '../../models/workout_sets/weighted_workout_set.dart';
import '../../models/workout_sets/bodyweight_workout_set.dart';
import '../../models/workout_sets/assisted_machine_workout_set.dart';
import '../../models/workout_sets/isometric_workout_set.dart';
import '../../models/workout_sets/distance_cardio_workout_set.dart';
import '../../models/workout_sets/duration_cardio_workout_set.dart';
import '../../models/exercises/exercise.dart';
import '../../models/exercises/strength_exercise.dart';
import '../../models/exercises/bodyweight_exercise.dart';
import '../../models/exercises/free_weight_exercise.dart';
import '../../models/exercises/machine_exercise.dart';
import '../../models/exercises/assisted_machine_exercise.dart';
import '../../models/exercises/isometric_exercise.dart';
import '../../models/exercises/distance_cardio_exercise.dart';
import '../../models/exercises/duration_cardio_exercise.dart';
import '../../models/common/weight.dart';
import '../../models/common/distance.dart';

/// Generates realistic mock workout data for testing with typed models
/// Each day includes one exercise of each type (8 exercises total per day)
class MockDataGenerator {
  static final Random _random = Random();
  static final _uuid = const Uuid();

  /// Generate mock workout sets spanning 3 months
  /// Each day has exactly one exercise of each type (8 exercises per day)
  static List<WorkoutSet> generateMockWorkoutSets(List<Exercise> exercises) {
    final List<WorkoutSet> workoutSets = [];
    final now = DateTime.now();

    // Group exercises by specific subtypes
    final freeWeightExercises = exercises
        .whereType<FreeWeightExercise>()
        .toList();
    final machineExercises = exercises.whereType<MachineExercise>().toList();
    final assistedMachineExercises = exercises
        .whereType<AssistedMachineExercise>()
        .toList();
    final bodyweightExercises = exercises
        .whereType<BodyweightExercise>()
        .toList();
    final isometricExercises = exercises
        .whereType<IsometricExercise>()
        .toList();
    final distanceCardioExercises = exercises
        .whereType<DistanceCardioExercise>()
        .toList();
    final durationCardioExercises = exercises
        .whereType<DurationCardioExercise>()
        .toList();

    // Select one of each type for consistent tracking
    final freeWeight = freeWeightExercises.isNotEmpty
        ? freeWeightExercises.first
        : null;
    final machine = machineExercises.isNotEmpty ? machineExercises.first : null;
    final assistedMachine = assistedMachineExercises.isNotEmpty
        ? assistedMachineExercises.first
        : null;
    final bodyweight = bodyweightExercises.isNotEmpty
        ? bodyweightExercises.first
        : null;
    final isometricWeighted = isometricExercises.isNotEmpty
        ? isometricExercises.first
        : null;
    final isometricBodyweight = isometricExercises.length > 1
        ? isometricExercises[1]
        : null;
    final distanceCardio = distanceCardioExercises.isNotEmpty
        ? distanceCardioExercises.first
        : null;
    final durationCardio = durationCardioExercises.isNotEmpty
        ? durationCardioExercises.first
        : null;

    // Generate 90 days of workout data (including today)
    for (int daysAgo = 90; daysAgo >= 0; daysAgo--) {
      final date = now.subtract(Duration(days: daysAgo));

      // Generate one exercise of each type per day (3 sets each)
      if (freeWeight != null) {
        workoutSets.addAll(_generateFreeWeightSets(freeWeight, date, daysAgo));
      }
      if (machine != null) {
        workoutSets.addAll(_generateMachineSets(machine, date, daysAgo));
      }
      if (assistedMachine != null) {
        workoutSets.addAll(
          _generateAssistedMachineSets(assistedMachine, date, daysAgo),
        );
      }
      if (bodyweight != null) {
        workoutSets.addAll(_generateBodyweightSets(bodyweight, date, daysAgo));
      }
      if (isometricWeighted != null) {
        workoutSets.addAll(
          _generateIsometricSets(
            isometricWeighted,
            date,
            daysAgo,
            isBodyweightBased: false,
          ),
        );
      }
      if (isometricBodyweight != null) {
        workoutSets.addAll(
          _generateIsometricSets(
            isometricBodyweight,
            date,
            daysAgo,
            isBodyweightBased: true,
          ),
        );
      }
      if (distanceCardio != null) {
        workoutSets.add(
          _generateDistanceCardioSet(distanceCardio, date, daysAgo),
        );
      }
      if (durationCardio != null) {
        workoutSets.add(
          _generateDurationCardioSet(durationCardio, date, daysAgo),
        );
      }
    }

    return workoutSets;
  }

  static List<WorkoutSet> _generateFreeWeightSets(
    FreeWeightExercise exercise,
    DateTime date,
    int daysAgo,
  ) {
    final sets = <WorkoutSet>[];
    final baseProgress = (90 - daysAgo) / 90.0;

    for (int setNum = 0; setNum < 3; setNum++) {
      final timestamp = date.add(Duration(minutes: setNum * 3));
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
    }
    return sets;
  }

  static List<WorkoutSet> _generateMachineSets(
    MachineExercise exercise,
    DateTime date,
    int daysAgo,
  ) {
    final sets = <WorkoutSet>[];
    final baseProgress = (90 - daysAgo) / 90.0;

    for (int setNum = 0; setNum < 3; setNum++) {
      final timestamp = date.add(Duration(minutes: setNum * 3 + 15));
      final baseWeight = 50.0 + (baseProgress * 25); // 50-75kg progression
      final weight = Weight(baseWeight + _random.nextDouble() * 5);
      final reps = 10 + _random.nextInt(5); // 10-14 reps

      sets.add(
        WeightedWorkoutSet(
          id: _uuid.v4(),
          exerciseId: exercise.id,
          timestamp: timestamp,
          weight: weight,
          reps: reps,
        ),
      );
    }
    return sets;
  }

  static List<WorkoutSet> _generateAssistedMachineSets(
    AssistedMachineExercise exercise,
    DateTime date,
    int daysAgo,
  ) {
    final sets = <WorkoutSet>[];
    final baseProgress = (90 - daysAgo) / 90.0;

    for (int setNum = 0; setNum < 3; setNum++) {
      final timestamp = date.add(Duration(minutes: setNum * 3 + 30));
      // INVERTED: Start with high assistance (40kg), reduce over time (to 20kg)
      final baseAssistance =
          40.0 - (baseProgress * 20); // 40-20kg (lower = better)
      final assistanceWeight = Weight(
        baseAssistance + _random.nextDouble() * 3,
      );
      final reps = 6 + _random.nextInt(4); // 6-9 reps

      sets.add(
        AssistedMachineWorkoutSet(
          id: _uuid.v4(),
          exerciseId: exercise.id,
          timestamp: timestamp,
          assistanceWeight: assistanceWeight,
          reps: reps,
        ),
      );
    }
    return sets;
  }

  static List<WorkoutSet> _generateBodyweightSets(
    BodyweightExercise exercise,
    DateTime date,
    int daysAgo,
  ) {
    final sets = <WorkoutSet>[];
    final baseProgress = (90 - daysAgo) / 90.0;

    for (int setNum = 0; setNum < 3; setNum++) {
      final timestamp = date.add(Duration(minutes: setNum * 3 + 45));
      final baseReps =
          10 + (baseProgress * 10).toInt(); // 10-20 reps progression
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
    }
    return sets;
  }

  static List<WorkoutSet> _generateIsometricSets(
    IsometricExercise exercise,
    DateTime date,
    int daysAgo, {
    required bool isBodyweightBased,
  }) {
    final sets = <WorkoutSet>[];
    final baseProgress = (90 - daysAgo) / 90.0;

    for (int setNum = 0; setNum < 3; setNum++) {
      final timestamp = date.add(Duration(minutes: setNum * 3 + 60));
      final baseDuration =
          30 + (baseProgress * 30).toInt(); // 30-60s progression
      final duration = Duration(seconds: baseDuration + _random.nextInt(10));

      final weight = !isBodyweightBased
          ? Weight(
              5.0 + (baseProgress * 10) + _random.nextDouble() * 2.5,
            ) // 5-15kg
          : null;

      sets.add(
        IsometricWorkoutSet(
          id: _uuid.v4(),
          exerciseId: exercise.id,
          timestamp: timestamp,
          duration: duration,
          weight: weight,
          isBodyweightBased: isBodyweightBased,
        ),
      );
    }
    return sets;
  }

  static WorkoutSet _generateDistanceCardioSet(
    DistanceCardioExercise exercise,
    DateTime date,
    int daysAgo,
  ) {
    final timestamp = date.add(Duration(minutes: 75));
    final baseProgress = (90 - daysAgo) / 90.0;

    // Distance cardio with improvement over time
    final baseDistance = 3000 + (baseProgress * 2000); // 3-5km progression
    final distance = Distance(baseDistance + _random.nextDouble() * 500);
    final baseDuration =
        20 + (baseProgress * -5).toInt(); // Getting faster (20-15 min)
    final duration = Duration(minutes: baseDuration + _random.nextInt(3));

    return DistanceCardioWorkoutSet(
      id: _uuid.v4(),
      exerciseId: exercise.id,
      timestamp: timestamp,
      duration: duration,
      distance: distance,
    );
  }

  static WorkoutSet _generateDurationCardioSet(
    DurationCardioExercise exercise,
    DateTime date,
    int daysAgo,
  ) {
    final timestamp = date.add(Duration(minutes: 90));
    final baseProgress = (90 - daysAgo) / 90.0;

    // Duration cardio with endurance improvement
    final baseDuration =
        20 + (baseProgress * 10).toInt(); // 20-30 min progression
    final duration = Duration(minutes: baseDuration + _random.nextInt(5));

    return DurationCardioWorkoutSet(
      id: _uuid.v4(),
      exerciseId: exercise.id,
      timestamp: timestamp,
      duration: duration,
    );
  }
}
