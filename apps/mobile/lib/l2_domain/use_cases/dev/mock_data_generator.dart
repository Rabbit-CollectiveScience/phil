import 'dart:math';
import '../../legacy_models/workout_set.dart';
import '../../legacy_models/exercise.dart';

/// Generates realistic mock workout data for testing
/// Includes edge cases, null values, and stress test data
class MockDataGenerator {
  static final Random _random = Random();

  /// Generate comprehensive mock workout sets spanning 3 months
  /// Includes all exercise types with progression, edge cases, and null values
  static List<WorkoutSet> generateMockWorkoutSets(List<Exercise> exercises) {
    final List<WorkoutSet> workoutSets = [];
    final now = DateTime.now();

    // Group exercises by category
    final strengthExercises = exercises
        .where((e) => e.categories.contains('strength'))
        .toList();
    final cardioExercises = exercises
        .where((e) => e.categories.contains('cardio'))
        .toList();

    // Select key exercises for regular tracking
    final mainStrengthExercises = _selectMainExercises(strengthExercises, 8);
    final mainCardioExercises = _selectMainExercises(cardioExercises, 3);

    // Generate 3 months of workout data (90 days)
    for (int daysAgo = 90; daysAgo >= 0; daysAgo--) {
      final date = now.subtract(Duration(days: daysAgo));

      // 3-4 workouts per week (skip some days randomly)
      if (_random.nextDouble() < 0.5 && date.weekday != DateTime.sunday) {
        // Alternate between strength-focused and cardio-focused days
        final isCardioDay =
            daysAgo % 3 == 0; // Every 3rd workout is cardio-focused

        if (isCardioDay && mainCardioExercises.isNotEmpty) {
          // Cardio-focused day: 2-3 cardio exercises
          final cardioCount = 2 + _random.nextInt(2);
          for (int i = 0; i < cardioCount; i++) {
            final cardioEx =
                mainCardioExercises[i % mainCardioExercises.length];
            workoutSets.add(_generateCardioSet(cardioEx, date, daysAgo));
          }
        } else {
          // Strength workout (3 sets per exercise)
          final exercisesTodo = _selectRandomExercises(
            mainStrengthExercises,
            4,
          );
          for (final exercise in exercisesTodo) {
            final sets = _generateStrengthSets(exercise, date, daysAgo);
            workoutSets.addAll(sets);
          }

          // Add cardio cooldown on some strength days
          if (_random.nextDouble() < 0.4 && mainCardioExercises.isNotEmpty) {
            final cardioEx =
                mainCardioExercises[_random.nextInt(
                  mainCardioExercises.length,
                )];
            workoutSets.add(_generateCardioSet(cardioEx, date, daysAgo));
          }
        }
      }
    }

    // Add edge cases and null value scenarios
    workoutSets.addAll(_generateEdgeCases(exercises, now));

    // Add stress test data (lots of sets on one day)
    workoutSets.addAll(_generateStressTestData(exercises, now));

    return workoutSets;
  }

  /// Select main exercises for consistent tracking
  static List<Exercise> _selectMainExercises(
    List<Exercise> exercises,
    int count,
  ) {
    if (exercises.isEmpty) return [];
    final shuffled = List<Exercise>.from(exercises)..shuffle(_random);
    return shuffled.take(min(count, exercises.length)).toList();
  }

  /// Select random subset of exercises for a workout
  static List<Exercise> _selectRandomExercises(
    List<Exercise> exercises,
    int maxCount,
  ) {
    if (exercises.isEmpty) return [];
    final count = _random.nextInt(maxCount) + 2; // 2-maxCount exercises
    final shuffled = List<Exercise>.from(exercises)..shuffle(_random);
    return shuffled.take(min(count, exercises.length)).toList();
  }

  /// Generate 3 progressive sets for a strength exercise
  static List<WorkoutSet> _generateStrengthSets(
    Exercise exercise,
    DateTime date,
    int daysAgo,
  ) {
    final sets = <WorkoutSet>[];

    // Calculate base weight with progression over time
    // Start lighter 90 days ago, progress to heavier
    final progressionFactor =
        1.0 + ((90 - daysAgo) / 90) * 0.3; // 0-30% increase
    final baseWeight = _getBaseWeight(exercise) * progressionFactor;

    // Generate 3 sets with typical pyramid structure
    for (int setNum = 0; setNum < 3; setNum++) {
      final weight = baseWeight + (setNum * 2.5); // Slightly increase each set
      final reps = 10 - setNum; // Decrease reps as weight increases

      // 10% chance of null values (incomplete set)
      final hasNullValues = _random.nextDouble() < 0.1;

      sets.add(
        WorkoutSet(
          id: 'mock_${exercise.id}_${date.millisecondsSinceEpoch}_$setNum',
          exerciseId: exercise.id,
          completedAt: date.add(Duration(minutes: setNum * 3)),
          values: hasNullValues
              ? null
              : {'weight': weight, 'reps': reps, 'unit': 'kg'},
        ),
      );
    }

    return sets;
  }

  /// Get realistic base weight for an exercise
  static double _getBaseWeight(Exercise exercise) {
    final name = exercise.name.toLowerCase();
    if (name.contains('squat')) return 80.0;
    if (name.contains('deadlift')) return 100.0;
    if (name.contains('bench')) return 60.0;
    if (name.contains('press') && name.contains('shoulder')) return 40.0;
    if (name.contains('row')) return 50.0;
    if (name.contains('curl')) return 12.0;
    if (name.contains('extension')) return 20.0;
    if (name.contains('pull')) return 60.0;
    return 30.0; // default
  }

  /// Generate cardio workout set
  static WorkoutSet _generateCardioSet(
    Exercise exercise,
    DateTime date,
    int daysAgo,
  ) {
    // Progress over time: start slower/shorter, get faster/longer
    final progressionFactor =
        1.0 + ((90 - daysAgo) / 90) * 0.4; // 0-40% improvement

    // 5% chance of incomplete data
    final hasNullValues = _random.nextDouble() < 0.05;

    if (hasNullValues) {
      return WorkoutSet(
        id: 'mock_${exercise.id}_${date.millisecondsSinceEpoch}',
        exerciseId: exercise.id,
        completedAt: date.add(const Duration(hours: 1)),
        values: null,
      );
    }

    // Build values map based on exercise's actual fields
    final values = <String, dynamic>{};

    for (final field in exercise.fields) {
      final fieldName = field.name;

      if (fieldName == 'durationInSeconds') {
        final baseDuration = 1200; // 20 minutes base
        values[fieldName] = (baseDuration * progressionFactor).round();
      } else if (fieldName == 'distance') {
        final baseDistance = 3.0; // 3km base
        values[fieldName] = baseDistance * progressionFactor;
      } else if (fieldName == 'speed') {
        final baseSpeed = 8.0; // 8 km/h base
        values[fieldName] = baseSpeed * progressionFactor;
      } else if (fieldName == 'resistance') {
        final baseResistance = 5.0; // level 5 base
        values[fieldName] = (baseResistance * progressionFactor)
            .round()
            .toDouble();
      } else if (fieldName == 'incline') {
        final baseIncline = 10.0; // 10% base
        values[fieldName] = (baseIncline * progressionFactor).clamp(5.0, 15.0);
      } else if (fieldName == 'calories') {
        values[fieldName] = (200 * progressionFactor).round().toDouble();
      }
    }

    return WorkoutSet(
      id: 'mock_${exercise.id}_${date.millisecondsSinceEpoch}',
      exerciseId: exercise.id,
      completedAt: date.add(const Duration(hours: 1)),
      values: values.isNotEmpty ? values : null,
    );
  }

  /// Generate edge cases for testing
  static List<WorkoutSet> _generateEdgeCases(
    List<Exercise> exercises,
    DateTime now,
  ) {
    if (exercises.isEmpty) return [];

    final edgeCases = <WorkoutSet>[];
    final testExercises = exercises.take(5).toList();

    for (int i = 0; i < testExercises.length; i++) {
      final exercise = testExercises[i];

      // Edge case 1: Null values
      edgeCases.add(
        WorkoutSet(
          id: 'edge_null_$i',
          exerciseId: exercise.id,
          completedAt: now.subtract(Duration(days: 10 + i)),
          values: null,
        ),
      );

      // Edge case 2: Empty map
      edgeCases.add(
        WorkoutSet(
          id: 'edge_empty_$i',
          exerciseId: exercise.id,
          completedAt: now.subtract(Duration(days: 15 + i)),
          values: {},
        ),
      );

      // Edge case 3: Partial data (only some fields)
      edgeCases.add(
        WorkoutSet(
          id: 'edge_partial_$i',
          exerciseId: exercise.id,
          completedAt: now.subtract(Duration(days: 20 + i)),
          values: {
            'weight': 50.0,
            // Missing reps
          },
        ),
      );

      // Edge case 4: Very high values
      edgeCases.add(
        WorkoutSet(
          id: 'edge_high_$i',
          exerciseId: exercise.id,
          completedAt: now.subtract(Duration(days: 25 + i)),
          values: {'weight': 999.9, 'reps': 100, 'unit': 'kg'},
        ),
      );

      // Edge case 5: Very low/zero values
      edgeCases.add(
        WorkoutSet(
          id: 'edge_low_$i',
          exerciseId: exercise.id,
          completedAt: now.subtract(Duration(days: 30 + i)),
          values: {'weight': 0.0, 'reps': 1, 'unit': 'kg'},
        ),
      );
    }

    return edgeCases;
  }

  /// Generate stress test data (many sets)
  static List<WorkoutSet> _generateStressTestData(
    List<Exercise> exercises,
    DateTime now,
  ) {
    if (exercises.isEmpty) return [];

    final stressData = <WorkoutSet>[];
    final stressDate = now.subtract(const Duration(days: 7));

    // Generate 100 sets in one day across various exercises
    for (int i = 0; i < 100; i++) {
      final exercise = exercises[i % exercises.length];
      final categories = exercise.categories;

      Map<String, dynamic>? values;

      if (categories.contains('strength')) {
        values = {'weight': 40.0 + (i % 50), 'reps': 8 + (i % 7), 'unit': 'kg'};
      } else if (categories.contains('cardio')) {
        values = {
          'durationInSeconds': 600 + (i % 1800),
          'distance': 2.0 + (i % 10),
          'unit': 'km',
        };
      }

      stressData.add(
        WorkoutSet(
          id: 'stress_$i',
          exerciseId: exercise.id,
          completedAt: stressDate.add(Duration(minutes: i * 2)),
          values: values,
        ),
      );
    }

    return stressData;
  }
}
