import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/get_today_completed_list_use_case.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/record_workout_set_use_case.dart';
import 'package:phil/l3_data/repositories/stub_workout_set_repository.dart';
import 'package:phil/l3_data/repositories/stub_exercise_repository.dart';
import 'package:phil/l2_domain/legacy_models/workout_set.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GetTodayCompletedListUseCase Integration Tests', () {
    late GetTodayCompletedListUseCase useCase;
    late StubWorkoutSetRepository workoutSetRepository;
    late StubExerciseRepository exerciseRepository;
    late RecordWorkoutSetUseCase recordUseCase;

    setUp(() {
      workoutSetRepository = StubWorkoutSetRepository();
      exerciseRepository = StubExerciseRepository();
      useCase = GetTodayCompletedListUseCase(
        workoutSetRepository,
        exerciseRepository,
      );
      recordUseCase = RecordWorkoutSetUseCase(workoutSetRepository);
    });

    tearDown(() {
      workoutSetRepository.clear();
    });

    test('should return empty list when no workouts completed today', () async {
      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, isEmpty);
    });

    test(
      'should return list of completed workouts with exercise details',
      () async {
        // Arrange - Get a known exercise ID from stub repository
        final exercises = await exerciseRepository.getAllExercises();
        final firstExercise = exercises.first;

        // Record a workout set
        await recordUseCase.execute(
          exerciseId: firstExercise.id,
          values: {'reps': 10, 'weight': 100},
        );

        // Act
        final result = await useCase.execute();

        // Assert
        expect(result, isNotEmpty);
        expect(result.length, 1);

        final workoutDetails = result.first;
        expect(workoutDetails.workoutSet.exerciseId, firstExercise.id);
        expect(workoutDetails.exerciseName, firstExercise.name);
        expect(workoutDetails.exercise, isNotNull);
        expect(workoutDetails.exercise!.id, firstExercise.id);
      },
    );

    test('should return multiple completed workouts', () async {
      // Arrange - Get exercises
      final exercises = await exerciseRepository.getAllExercises();

      // Record multiple workout sets
      await recordUseCase.execute(
        exerciseId: exercises[0].id,
        values: {'reps': 10},
      );

      await recordUseCase.execute(
        exerciseId: exercises[1].id,
        values: {'reps': 12},
      );

      await recordUseCase.execute(exerciseId: exercises[2].id, values: null);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result.length, 3);
      // Results are ordered by most recent first, so check in reverse
      expect(result[0].exerciseName, exercises[2].name);
      expect(result[1].exerciseName, exercises[1].name);
      expect(result[2].exerciseName, exercises[0].name);
    });

    test('should only return today\'s workouts, not yesterday', () async {
      // Arrange - Get exercise
      final exercises = await exerciseRepository.getAllExercises();
      final exercise = exercises.first;

      // Record today's workout
      await recordUseCase.execute(
        exerciseId: exercise.id,
        values: {'reps': 10},
      );

      // Manually add yesterday's workout to repository
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await workoutSetRepository.saveWorkoutSet(
        WorkoutSet(
          id: 'yesterday-id',
          exerciseId: exercise.id,
          completedAt: yesterday,
          values: {'reps': 5},
        ),
      );

      // Act
      final result = await useCase.execute();

      // Assert - Should only return today's workout
      expect(result.length, 1);
      expect(result.first.workoutSet.values?['reps'], 10);
    });

    test('should handle workout sets with null values', () async {
      // Arrange
      final exercises = await exerciseRepository.getAllExercises();
      final exercise = exercises.first;

      await recordUseCase.execute(exerciseId: exercise.id, values: null);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, isNotEmpty);
      expect(result.first.workoutSet.values, isNull);
      expect(result.first.exerciseName, exercise.name);
    });

    test(
      'should order workouts by completion time (most recent first)',
      () async {
        // Arrange
        final exercises = await exerciseRepository.getAllExercises();

        // Record workouts in sequence
        final set1 = await recordUseCase.execute(
          exerciseId: exercises[0].id,
          values: {'reps': 10},
        );

        // Small delay to ensure different timestamps
        await Future.delayed(const Duration(milliseconds: 10));

        final set2 = await recordUseCase.execute(
          exerciseId: exercises[1].id,
          values: {'reps': 12},
        );

        await Future.delayed(const Duration(milliseconds: 10));

        final set3 = await recordUseCase.execute(
          exerciseId: exercises[2].id,
          values: {'reps': 15},
        );

        // Act
        final result = await useCase.execute();

        // Assert - Most recent first
        expect(result.length, 3);
        expect(result[0].workoutSet.id, set3.id);
        expect(result[1].workoutSet.id, set2.id);
        expect(result[2].workoutSet.id, set1.id);
      },
    );

    test('should include complete exercise details in result', () async {
      // Arrange
      final exercises = await exerciseRepository.getAllExercises();
      final exercise = exercises.first;

      await recordUseCase.execute(
        exerciseId: exercise.id,
        values: {'reps': 10},
      );

      // Act
      final result = await useCase.execute();

      // Assert
      final workoutDetails = result.first;
      expect(workoutDetails.exercise!.id, exercise.id);
      expect(workoutDetails.exercise!.name, exercise.name);
      expect(workoutDetails.exercise!.categories, exercise.categories);
      expect(workoutDetails.exercise!.description, exercise.description);
      expect(workoutDetails.exercise!.fields, isNotEmpty);
    });

    test('should handle unknown exercise IDs gracefully', () async {
      // Arrange - Record workout with unknown exercise ID
      await workoutSetRepository.saveWorkoutSet(
        WorkoutSet(
          id: 'unknown-workout',
          exerciseId: 'unknown-exercise-id',
          completedAt: DateTime.now(),
          values: {'reps': 10},
        ),
      );

      // Act
      final result = await useCase.execute();

      // Assert - Should return workout with "Unknown Exercise" name
      expect(result.length, 1);
      expect(result.first.exerciseName, 'Unknown Exercise');
      expect(result.first.workoutSet.exerciseId, 'unknown-exercise-id');
    });
  });
}
