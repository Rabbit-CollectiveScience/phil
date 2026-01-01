import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/get_today_completed_count_use_case.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/record_workout_set_use_case.dart';
import 'package:phil/l3_data/repositories/stub_workout_set_repository.dart';
import 'package:phil/l2_domain/models/workout_set.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GetTodayCompletedCountUseCase Integration Tests', () {
    late GetTodayCompletedCountUseCase useCase;
    late StubWorkoutSetRepository repository;
    late RecordWorkoutSetUseCase recordUseCase;

    setUp(() {
      repository = StubWorkoutSetRepository();
      useCase = GetTodayCompletedCountUseCase(repository);
      recordUseCase = RecordWorkoutSetUseCase(repository);
    });

    tearDown(() {
      repository.clear();
    });

    test('should return 0 when no workouts completed today', () async {
      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, 0);
    });

    test('should return count of workouts completed today', () async {
      // Arrange - Record 3 workout sets today
      await recordUseCase.execute(
        exerciseId: 'exercise_1',
        values: {'reps': 10},
      );

      await recordUseCase.execute(exerciseId: 'exercise_2', values: null);

      await recordUseCase.execute(
        exerciseId: 'exercise_3',
        values: {'weight': 50, 'reps': 8},
      );

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, 3);
    });

    test('should only count today\'s workouts, not yesterday', () async {
      // Arrange - Record today's workout
      await recordUseCase.execute(
        exerciseId: 'today_exercise',
        values: {'reps': 10},
      );

      // Manually add yesterday's workout to repository
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await repository.saveWorkoutSet(
        WorkoutSet(
          id: 'yesterday-id',
          exerciseId: 'yesterday_exercise',
          completedAt: yesterday,
          values: {'reps': 5},
        ),
      );

      // Act
      final result = await useCase.execute();

      // Assert - Should only count today's workout
      expect(result, 1);
    });

    test('should handle multiple workouts throughout the day', () async {
      // Arrange - Simulate multiple workout sessions
      for (int i = 0; i < 5; i++) {
        await recordUseCase.execute(exerciseId: 'exercise_$i', values: null);
      }

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, 5);
    });

    test('should return correct count after recording more workouts', () async {
      // Arrange - Record initial workouts
      await recordUseCase.execute(
        exerciseId: 'exercise_1',
        values: {'reps': 10},
      );

      // Act - Get initial count
      final initialCount = await useCase.execute();
      expect(initialCount, 1);

      // Arrange - Record more workouts
      await recordUseCase.execute(exerciseId: 'exercise_2', values: null);

      await recordUseCase.execute(
        exerciseId: 'exercise_3',
        values: {'duration': 30},
      );

      // Act - Get updated count
      final updatedCount = await useCase.execute();

      // Assert
      expect(updatedCount, 3);
    });

    test('should work correctly after clearing repository', () async {
      // Arrange - Record some workouts
      await recordUseCase.execute(
        exerciseId: 'exercise_1',
        values: {'reps': 10},
      );

      // Act - Get count
      var count = await useCase.execute();
      expect(count, 1);

      // Clear and check again
      repository.clear();
      count = await useCase.execute();

      // Assert
      expect(count, 0);
    });
  });
}
