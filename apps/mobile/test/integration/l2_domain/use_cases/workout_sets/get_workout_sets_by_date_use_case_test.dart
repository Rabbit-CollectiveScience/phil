import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/get_workout_sets_by_date_use_case.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/record_workout_set_use_case.dart';
import 'package:phil/l3_data/repositories/stub_workout_set_repository.dart';
import 'package:phil/l3_data/repositories/stub_exercise_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GetWorkoutSetsByDateUseCase Integration Tests', () {
    late GetWorkoutSetsByDateUseCase useCase;
    late StubWorkoutSetRepository workoutSetRepository;
    late StubExerciseRepository exerciseRepository;
    late RecordWorkoutSetUseCase recordUseCase;

    setUp(() {
      workoutSetRepository = StubWorkoutSetRepository();
      exerciseRepository = StubExerciseRepository();
      useCase = GetWorkoutSetsByDateUseCase(
        workoutSetRepository,
        exerciseRepository,
      );
      recordUseCase = RecordWorkoutSetUseCase(workoutSetRepository);
    });

    tearDown(() {
      workoutSetRepository.clear();
    });

    test(
      'should return empty list when no workouts on selected date',
      () async {
        // Arrange
        final selectedDate = DateTime(2024, 1, 15);

        // Act
        final result = await useCase.execute(date: selectedDate);

        // Assert
        expect(result, isEmpty);
      },
    );

    test('should return workouts for specific date', () async {
      // Arrange
      final exercises = await exerciseRepository.getAllExercises();
      final firstExercise = exercises.first;

      // Record workout set (will have today's date)
      await recordUseCase.execute(
        exerciseId: firstExercise.id,
        values: {'reps': 10, 'weight': 100},
      );

      // Act - query today's date
      final today = DateTime.now();
      final result = await useCase.execute(date: today);

      // Assert
      expect(result, isNotEmpty);
      expect(result.first.exerciseName, equals(firstExercise.name));
      expect(result.first.exercise, isNotNull);
      expect(
        result.first.workoutSet.values,
        equals({'reps': 10, 'weight': 100}),
      );
    });

    test('should return multiple sets for same date', () async {
      // Arrange
      final exercises = await exerciseRepository.getAllExercises();
      final firstExercise = exercises.first;
      final secondExercise = exercises[1];

      // Record multiple workout sets
      await recordUseCase.execute(
        exerciseId: firstExercise.id,
        values: {'reps': 10, 'weight': 100},
      );
      await recordUseCase.execute(
        exerciseId: firstExercise.id,
        values: {'reps': 8, 'weight': 100},
      );
      await recordUseCase.execute(
        exerciseId: secondExercise.id,
        values: {'reps': 12, 'weight': 80},
      );

      // Act - query today
      final today = DateTime.now();
      final result = await useCase.execute(date: today);

      // Assert
      expect(result.length, equals(3));
    });

    test(
      'should only return workouts for selected date, not other dates',
      () async {
        // Arrange
        final exercises = await exerciseRepository.getAllExercises();
        final exercise = exercises.first;

        // Record workout for today
        await recordUseCase.execute(
          exerciseId: exercise.id,
          values: {'reps': 10, 'weight': 100},
        );

        // Act - query tomorrow (should be empty)
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final result = await useCase.execute(date: tomorrow);

        // Assert - should not find workouts from different date
        expect(result, isEmpty);
      },
    );

    test(
      'should return workouts sorted by completion time (most recent first)',
      () async {
        // Arrange
        final exercises = await exerciseRepository.getAllExercises();
        final exercise = exercises.first;

        // Record multiple sets with slight delays
        await recordUseCase.execute(
          exerciseId: exercise.id,
          values: {'reps': 10, 'weight': 100},
        );
        await Future.delayed(const Duration(milliseconds: 10));
        await recordUseCase.execute(
          exerciseId: exercise.id,
          values: {'reps': 8, 'weight': 100},
        );
        await Future.delayed(const Duration(milliseconds: 10));
        await recordUseCase.execute(
          exerciseId: exercise.id,
          values: {'reps': 6, 'weight': 100},
        );

        // Act - query today
        final today = DateTime.now();
        final result = await useCase.execute(date: today);

        // Assert - most recent should be first (reps: 6)
        expect(result.length, equals(3));
        expect(result[0].workoutSet.values?['reps'], equals(6));
        expect(result[1].workoutSet.values?['reps'], equals(8));
        expect(result[2].workoutSet.values?['reps'], equals(10));
      },
    );

    test(
      'should include exercise details for dynamic field rendering',
      () async {
        // Arrange
        final exercises = await exerciseRepository.getAllExercises();
        final exercise = exercises.first;

        await recordUseCase.execute(
          exerciseId: exercise.id,
          values: {'reps': 10, 'weight': 100},
        );

        // Act - query today
        final today = DateTime.now();
        final result = await useCase.execute(date: today);

        // Assert - exercise details included
        expect(result.first.exercise, isNotNull);
        expect(result.first.exercise!.id, equals(exercise.id));
        expect(result.first.exercise!.name, equals(exercise.name));
        expect(result.first.exercise!.fields, isNotEmpty);
      },
    );

    test('should handle unknown exercise gracefully', () async {
      // Arrange
      final unknownExerciseId = 'unknown-exercise-id';

      // Directly save workout set with unknown exercise ID
      await recordUseCase.execute(
        exerciseId: unknownExerciseId,
        values: {'reps': 10},
      );

      // Act - query today
      final today = DateTime.now();
      final result = await useCase.execute(date: today);

      // Assert
      expect(result, isNotEmpty);
      expect(result.first.exerciseName, equals('Unknown Exercise'));
      expect(result.first.exercise, isNull);
    });
  });
}
