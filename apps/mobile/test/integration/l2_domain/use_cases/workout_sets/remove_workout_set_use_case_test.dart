import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/remove_workout_set_use_case.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/record_workout_set_use_case.dart';
import 'package:phil/l3_data/repositories/stub_workout_set_repository.dart';
import 'package:phil/l3_data/repositories/stub_personal_record_repository.dart';
import 'package:phil/l3_data/repositories/stub_exercise_repository.dart';
import 'package:phil/l2_domain/models/personal_record.dart';

void main() {
  // Initialize Flutter bindings for testing
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RemoveWorkoutSetUseCase Integration Tests', () {
    late RemoveWorkoutSetUseCase useCase;
    late RecordWorkoutSetUseCase recordUseCase;
    late StubWorkoutSetRepository repository;

    setUp(() {
      repository = StubWorkoutSetRepository();
      useCase = RemoveWorkoutSetUseCase(repository);
      recordUseCase = RecordWorkoutSetUseCase(repository);
    });

    tearDown(() {
      repository.clear();
    });

    test('should delete existing workout set by ID', () async {
      // Arrange - Create 3 workout sets
      final set1 = await recordUseCase.execute(
        exerciseId: 'exercise_1',
        values: {'reps': 10},
      );

      final set2 = await recordUseCase.execute(
        exerciseId: 'exercise_2',
        values: {'reps': 12},
      );

      final set3 = await recordUseCase.execute(
        exerciseId: 'exercise_3',
        values: {'reps': 15},
      );

      expect(repository.count, 3);

      // Act - Delete the middle one
      await useCase.execute(set2.id);

      // Assert
      expect(repository.count, 2);

      final remainingSets = await repository.getWorkoutSets();
      expect(remainingSets.length, 2);

      final remainingIds = remainingSets.map((s) => s.id).toList();
      expect(remainingIds, contains(set1.id));
      expect(remainingIds, contains(set3.id));
      expect(remainingIds, isNot(contains(set2.id)));
    });

    test('should handle deleting non-existent ID gracefully', () async {
      // Arrange - Create 2 sets
      await recordUseCase.execute(
        exerciseId: 'exercise_1',
        values: {'reps': 10},
      );

      await recordUseCase.execute(
        exerciseId: 'exercise_2',
        values: {'reps': 12},
      );

      expect(repository.count, 2);

      // Act - Try to delete non-existent ID
      await useCase.execute('fake-id-that-does-not-exist');

      // Assert - Should complete without error, count unchanged
      expect(repository.count, 2);
    });

    test('should delete workout set and update today\'s count', () async {
      // Arrange - Record 5 sets today
      final sets = <String>[];
      for (int i = 0; i < 5; i++) {
        final set = await recordUseCase.execute(
          exerciseId: 'exercise_$i',
          values: {'reps': 10 + i},
        );
        sets.add(set.id);
      }

      expect(repository.count, 5);

      // Act - Delete 2 of them
      await useCase.execute(sets[1]);
      await useCase.execute(sets[3]);

      // Assert
      final todaySets = await repository.getTodayWorkoutSets();
      expect(todaySets.length, 3);

      final remainingIds = todaySets.map((s) => s.id).toList();
      expect(remainingIds, contains(sets[0]));
      expect(remainingIds, contains(sets[2]));
      expect(remainingIds, contains(sets[4]));
      expect(remainingIds, isNot(contains(sets[1])));
      expect(remainingIds, isNot(contains(sets[3])));
    });

    test('should only delete specified set, not affect others', () async {
      // Arrange - Create sets for different exercises
      final benchPress = await recordUseCase.execute(
        exerciseId: 'chest_bench_press',
        values: {'weight': 100, 'reps': 10},
      );

      final squat = await recordUseCase.execute(
        exerciseId: 'legs_squat',
        values: {'weight': 150, 'reps': 8},
      );

      final deadlift = await recordUseCase.execute(
        exerciseId: 'back_deadlift',
        values: {'weight': 200, 'reps': 5},
      );

      // Act - Delete squat set
      await useCase.execute(squat.id);

      // Assert - Verify others unchanged
      final remainingSets = await repository.getWorkoutSets();
      expect(remainingSets.length, 2);

      final benchPressSet = remainingSets.firstWhere(
        (s) => s.id == benchPress.id,
      );
      expect(benchPressSet.exerciseId, 'chest_bench_press');
      expect(benchPressSet.values, equals({'weight': 100, 'reps': 10}));
      expect(benchPressSet.completedAt, benchPress.completedAt);

      final deadliftSet = remainingSets.firstWhere((s) => s.id == deadlift.id);
      expect(deadliftSet.exerciseId, 'back_deadlift');
      expect(deadliftSet.values, equals({'weight': 200, 'reps': 5}));
      expect(deadliftSet.completedAt, deadlift.completedAt);
    });

    test('should handle deleting the only workout set', () async {
      // Arrange - Create 1 set
      final onlySet = await recordUseCase.execute(
        exerciseId: 'exercise_1',
        values: {'reps': 10},
      );

      expect(repository.count, 1);

      // Act - Delete it
      await useCase.execute(onlySet.id);

      // Assert - Repository empty
      expect(repository.count, 0);

      final allSets = await repository.getWorkoutSets();
      expect(allSets, isEmpty);
    });

    test('should work correctly after deleting and re-recording', () async {
      // Arrange - Record a set
      final firstSet = await recordUseCase.execute(
        exerciseId: 'exercise_1',
        values: {'reps': 10},
      );

      // Act - Delete it
      await useCase.execute(firstSet.id);

      // Record a new set
      final secondSet = await recordUseCase.execute(
        exerciseId: 'exercise_2',
        values: {'reps': 15},
      );

      // Assert - Only new set exists
      expect(repository.count, 1);

      final allSets = await repository.getWorkoutSets();
      expect(allSets.length, 1);
      expect(allSets.first.id, secondSet.id);
      expect(allSets.first.id, isNot(equals(firstSet.id)));
      expect(allSets.first.exerciseId, 'exercise_2');
      expect(allSets.first.values, equals({'reps': 15}));
    });

    group('Personal Record Recalculation', () {
      late StubPersonalRecordRepository prRepo;
      late StubExerciseRepository exerciseRepo;
      late List<dynamic> exercises;
      late RemoveWorkoutSetUseCase useCaseWithPR;
      late RecordWorkoutSetUseCase recordUseCaseWithPR;

      setUp(() async {
        prRepo = StubPersonalRecordRepository();
        exerciseRepo = StubExerciseRepository();
        exercises = await exerciseRepo.getAllExercises();
        useCaseWithPR = RemoveWorkoutSetUseCase(
          repository,
          prRepository: prRepo,
          exerciseRepository: exerciseRepo,
        );
        recordUseCaseWithPR = RecordWorkoutSetUseCase(
          repository,
          prRepository: prRepo,
          exerciseRepository: exerciseRepo,
        );
      });

      test('should recalculate PRs after deleting a workout set', () async {
        // Arrange - Get a weighted exercise
        final exercise = exercises.firstWhere(
          (e) =>
              e.name.contains('Bench Press') &&
              e.fields.any((f) => f.name == 'weight'),
        );

        // Record multiple sets for the exercise
        await recordUseCaseWithPR.execute(
          exerciseId: exercise.id,
          values: {'weight': 80, 'reps': 10},
        );

        final setToDelete = await recordUseCaseWithPR.execute(
          exerciseId: exercise.id,
          values: {'weight': 100, 'reps': 8},
        );

        await recordUseCaseWithPR.execute(
          exerciseId: exercise.id,
          values: {'weight': 90, 'reps': 9},
        );

        // Simulate PR being saved for the 100kg set
        final oldPR = PersonalRecord(
          id: 'pr_1',
          exerciseId: exercise.id,
          type: 'maxWeight',
          value: 100,
          achievedAt: DateTime.now(),
        );
        await prRepo.save(oldPR);

        // Act - Delete the set that was the PR
        await useCaseWithPR.execute(setToDelete.id);

        // Assert - Should recalculate and find new PR (90kg)
        // Note: This test will fail until RecalculatePRsForExerciseUseCase is called from RemoveWorkoutSetUseCase
        final currentPR = await prRepo.getCurrentPR(exercise.id, 'maxWeight');
        expect(currentPR, isNotNull);
        expect(currentPR!.value, 90);
      });

      test(
        'should update maxWeight PR when deleted set was current PR',
        () async {
          // Arrange
          final exercise = exercises.firstWhere(
            (e) =>
                e.name.contains('Squat') &&
                e.fields.any((f) => f.name == 'weight'),
          );

          // Record sets with increasing weights
          await recordUseCaseWithPR.execute(
            exerciseId: exercise.id,
            values: {'weight': 100, 'reps': 5},
          );

          final prSet = await recordUseCaseWithPR.execute(
            exerciseId: exercise.id,
            values: {'weight': 120, 'reps': 5},
          );

          // Simulate PR
          final pr = PersonalRecord(
            id: 'pr_1',
            exerciseId: exercise.id,
            type: 'maxWeight',
            value: 120,
            achievedAt: DateTime.now(),
          );
          await prRepo.save(pr);

          // Act - Delete the PR set
          await useCaseWithPR.execute(prSet.id);

          // Assert - PR should fall back to 100kg
          final updatedPR = await prRepo.getCurrentPR(exercise.id, 'maxWeight');
          expect(updatedPR, isNotNull);
          expect(updatedPR!.value, 100);
          expect(
            updatedPR.id,
            isNot(equals(pr.id)),
          ); // Should be a new PR record
        },
      );

      test('should find next best PR value after deletion', () async {
        // Arrange
        final exercise = exercises.firstWhere(
          (e) =>
              e.name.contains('Pull') &&
              !e.fields.any((f) => f.name == 'weight'),
        );

        // Record multiple sets with different rep counts
        await recordUseCaseWithPR.execute(
          exerciseId: exercise.id,
          values: {'reps': 10},
        );

        final maxRepsSet = await recordUseCaseWithPR.execute(
          exerciseId: exercise.id,
          values: {'reps': 15},
        );

        await recordUseCaseWithPR.execute(
          exerciseId: exercise.id,
          values: {'reps': 12},
        );

        // Simulate maxReps PR
        final pr = PersonalRecord(
          id: 'pr_1',
          exerciseId: exercise.id,
          type: 'maxReps',
          value: 15,
          achievedAt: DateTime.now(),
        );
        await prRepo.save(pr);

        // Act - Delete the max reps set
        await useCaseWithPR.execute(maxRepsSet.id);

        // Assert - Should find next best (12 reps)
        final updatedPR = await prRepo.getCurrentPR(exercise.id, 'maxReps');
        expect(updatedPR, isNotNull);
        expect(updatedPR!.value, 12);
      });

      test(
        'should delete all PRs when last set for exercise is removed',
        () async {
          // Arrange
          final exercise = exercises.firstWhere(
            (e) =>
                e.name.contains('Deadlift') &&
                e.fields.any((f) => f.name == 'weight'),
          );

          // Record a single set
          final onlySet = await recordUseCaseWithPR.execute(
            exerciseId: exercise.id,
            values: {'weight': 150, 'reps': 5},
          );

          // Simulate PRs being created
          final weightPR = PersonalRecord(
            id: 'pr_weight',
            exerciseId: exercise.id,
            type: 'maxWeight',
            value: 150,
            achievedAt: DateTime.now(),
          );
          final volumePR = PersonalRecord(
            id: 'pr_volume',
            exerciseId: exercise.id,
            type: 'maxVolume',
            value: 750, // 150 * 5
            achievedAt: DateTime.now(),
          );
          await prRepo.save(weightPR);
          await prRepo.save(volumePR);

          // Act - Delete the only set
          await useCaseWithPR.execute(onlySet.id);

          // Assert - All PRs should be gone
          final weightPRAfter = await prRepo.getCurrentPR(
            exercise.id,
            'maxWeight',
          );
          final volumePRAfter = await prRepo.getCurrentPR(
            exercise.id,
            'maxVolume',
          );
          expect(weightPRAfter, isNull);
          expect(volumePRAfter, isNull);
        },
      );
    });
  });
}
