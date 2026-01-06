import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/record_workout_set_use_case.dart';
import 'package:phil/l3_data/repositories/stub_workout_set_repository.dart';
import 'package:phil/l3_data/repositories/stub_personal_record_repository.dart';
import 'package:phil/l3_data/repositories/stub_exercise_repository.dart';
import 'package:phil/l2_domain/legacy_models/workout_set.dart';
import 'package:phil/l2_domain/legacy_models/personal_record.dart';

void main() {
  // Initialize Flutter bindings for testing
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RecordWorkoutSetUseCase Integration Tests', () {
    late RecordWorkoutSetUseCase useCase;
    late StubWorkoutSetRepository repository;

    setUp(() {
      repository = StubWorkoutSetRepository();
      useCase = RecordWorkoutSetUseCase(repository);
    });

    tearDown(() {
      repository.clear();
    });

    test('should create and save a workout set with valid structure', () async {
      // Arrange
      const exerciseId = 'chest_barbell_bench_press';
      final values = {'weight': 100, 'reps': 10};

      // Act
      final result = await useCase.execute(
        exerciseId: exerciseId,
        values: values,
      );

      // Assert
      expect(result, isNotNull);
      expect(result.id, isNotEmpty);
      expect(result.exerciseId, exerciseId);
      expect(result.values, equals(values));
      expect(result.completedAt, isNotNull);
    });

    test('should generate unique UUID for workout set', () async {
      // Act
      final result1 = await useCase.execute(
        exerciseId: 'exercise_1',
        values: {'reps': 10},
      );

      final result2 = await useCase.execute(
        exerciseId: 'exercise_2',
        values: {'reps': 12},
      );

      // Assert
      expect(result1.id, isNotEmpty);
      expect(result2.id, isNotEmpty);
      expect(result1.id, isNot(equals(result2.id)));
    });

    test('should accept null values', () async {
      // Arrange
      const exerciseId = 'chest_push_up';

      // Act
      final result = await useCase.execute(
        exerciseId: exerciseId,
        values: null,
      );

      // Assert
      expect(result, isNotNull);
      expect(result.id, isNotEmpty);
      expect(result.exerciseId, exerciseId);
      expect(result.values, isNull);
      expect(result.completedAt, isNotNull);
    });

    test('should accept empty values map', () async {
      // Arrange
      const exerciseId = 'cardio_running';
      final emptyValues = <String, dynamic>{};

      // Act
      final result = await useCase.execute(
        exerciseId: exerciseId,
        values: emptyValues,
      );

      // Assert
      expect(result, isNotNull);
      expect(result.values, isEmpty);
    });

    test('should set completedAt timestamp to current time', () async {
      // Arrange
      final beforeExecution = DateTime.now();

      // Act
      final result = await useCase.execute(
        exerciseId: 'exercise_1',
        values: null,
      );

      final afterExecution = DateTime.now();

      // Assert
      expect(result.completedAt, isNotNull);
      expect(
        result.completedAt.isAfter(beforeExecution) ||
            result.completedAt.isAtSameMomentAs(beforeExecution),
        isTrue,
      );
      expect(
        result.completedAt.isBefore(afterExecution) ||
            result.completedAt.isAtSameMomentAs(afterExecution),
        isTrue,
      );
    });

    test('should persist workout set to repository', () async {
      // Arrange
      expect(repository.count, 0);

      // Act
      await useCase.execute(exerciseId: 'exercise_1', values: {'reps': 10});

      // Assert
      expect(repository.count, 1);

      final savedSets = await repository.getWorkoutSets();
      expect(savedSets.length, 1);
      expect(savedSets.first.exerciseId, 'exercise_1');
    });

    test('should handle multiple workout sets correctly', () async {
      // Act
      await useCase.execute(exerciseId: 'exercise_1', values: {'reps': 10});

      await useCase.execute(exerciseId: 'exercise_2', values: null);

      await useCase.execute(exerciseId: 'exercise_3', values: {'duration': 30});

      // Assert
      expect(repository.count, 3);

      final savedSets = await repository.getWorkoutSets();
      expect(savedSets.length, 3);

      final exerciseIds = savedSets.map((set) => set.exerciseId).toList();
      expect(
        exerciseIds,
        containsAll(['exercise_1', 'exercise_2', 'exercise_3']),
      );
    });

    test('should return the saved workout set', () async {
      // Act
      final result = await useCase.execute(
        exerciseId: 'exercise_test',
        values: {'weight': 50, 'reps': 8},
      );

      // Verify by querying repository
      final savedSets = await repository.getWorkoutSets();
      final savedSet = savedSets.firstWhere((set) => set.id == result.id);

      // Assert
      expect(result.id, equals(savedSet.id));
      expect(result.exerciseId, equals(savedSet.exerciseId));
      expect(result.values, equals(savedSet.values));
      expect(result.completedAt, equals(savedSet.completedAt));
    });

    test('should handle flexible field configurations', () async {
      // Act & Assert for 2 fields (strength)
      final strengthSet = await useCase.execute(
        exerciseId: 'chest_bench_press',
        values: {'weight': 100, 'reps': 10},
      );
      expect(strengthSet, isNotNull);
      expect(strengthSet.values, equals({'weight': 100, 'reps': 10}));

      // Act & Assert for 2 fields (cardio)
      final cardioSet = await useCase.execute(
        exerciseId: 'cardio_running',
        values: {'durationInSeconds': 1800, 'distance': 5.0},
      );
      expect(cardioSet, isNotNull);
      expect(
        cardioSet.values,
        equals({'durationInSeconds': 1800, 'distance': 5.0}),
      );

      // Act & Assert for 3 fields (cardio with height)
      final threeFieldSet = await useCase.execute(
        exerciseId: 'cardio_17',
        values: {'durationInSeconds': 600, 'reps': 15, 'height': 45},
      );
      expect(threeFieldSet, isNotNull);
      expect(
        threeFieldSet.values,
        equals({'durationInSeconds': 600, 'reps': 15, 'height': 45}),
      );

      // Act & Assert for 1 field (cardio with just reps)
      final oneFieldSet = await useCase.execute(
        exerciseId: 'cardio_1',
        values: {'reps': 10},
      );
      expect(oneFieldSet, isNotNull);
      expect(oneFieldSet.values, equals({'reps': 10}));

      // Verify all saved
      expect(repository.count, 4);
    });

    test('should use custom completedAt date when provided', () async {
      // Arrange
      final customDate = DateTime(2025, 6, 15, 10, 30);

      // Act
      final result = await useCase.execute(
        exerciseId: 'exercise_1',
        values: {'reps': 10},
        completedAt: customDate,
      );

      // Assert
      expect(result.completedAt, equals(customDate));
    });

    test('should use current time when completedAt is null', () async {
      // Arrange
      final beforeExecution = DateTime.now();

      // Act
      final result = await useCase.execute(
        exerciseId: 'exercise_1',
        values: {'reps': 10},
        completedAt: null,
      );

      final afterExecution = DateTime.now();

      // Assert
      expect(
        result.completedAt.isAfter(
          beforeExecution.subtract(Duration(seconds: 1)),
        ),
        isTrue,
      );
      expect(
        result.completedAt.isBefore(afterExecution.add(Duration(seconds: 1))),
        isTrue,
      );
    });

    group('Personal Record Detection', () {
      late StubPersonalRecordRepository prRepo;
      late StubExerciseRepository exerciseRepo;
      late RecordWorkoutSetUseCase useCaseWithPR;

      setUp(() async {
        prRepo = StubPersonalRecordRepository();
        exerciseRepo = StubExerciseRepository();
        useCaseWithPR = RecordWorkoutSetUseCase(
          repository,
          prRepository: prRepo,
          exerciseRepository: exerciseRepo,
        );
      });

      test(
        'should detect and save new maxWeight PR when weight exceeds current',
        () async {
          final exercises = await exerciseRepo.getAllExercises();
          final benchPress = exercises.firstWhere(
            (e) => e.name.contains('Bench Press'),
          );

          // Save existing PR
          await prRepo.save(
            PersonalRecord(
              id: 'pr_1',
              exerciseId: benchPress.id,
              type: 'maxWeight',
              value: 95.0,
              achievedAt: DateTime(2026, 1, 1),
            ),
          );

          // Record new set with higher weight
          final result = await useCaseWithPR.execute(
            exerciseId: benchPress.id,
            values: {'weight': 100.0, 'reps': 10},
          );

          expect(result, isNotNull);

          // Check if new PR was saved
          final currentPR = await prRepo.getCurrentPR(
            benchPress.id,
            'maxWeight',
          );
          expect(currentPR, isNotNull);
          expect(currentPR!.value, equals(100.0));
        },
      );

      test(
        'should detect and save new maxReps PR for bodyweight exercise',
        () async {
          final exercises = await exerciseRepo.getAllExercises();
          final pushups = exercises.firstWhere(
            (e) => e.name.contains('Push') && e.name.contains('Up'),
          );

          // Record set with reps only (bodyweight)
          final result = await useCaseWithPR.execute(
            exerciseId: pushups.id,
            values: {'reps': 50},
          );

          expect(result, isNotNull);

          // Check if PR was saved
          final currentPR = await prRepo.getCurrentPR(pushups.id, 'maxReps');
          expect(currentPR, isNotNull);
          expect(currentPR!.value, equals(50.0));
        },
      );

      test('should not save PR when value doesn\'t exceed current PR', () async {
        final exercises = await exerciseRepo.getAllExercises();
        final squat = exercises.firstWhere((e) => e.name.contains('Squat'));

        // Save existing PRs - weight, reps, and volume
        await prRepo.save(
          PersonalRecord(
            id: 'pr_1',
            exerciseId: squat.id,
            type: 'maxWeight',
            value: 150.0,
            achievedAt: DateTime(2026, 1, 1),
          ),
        );

        await prRepo.save(
          PersonalRecord(
            id: 'pr_2',
            exerciseId: squat.id,
            type: 'maxReps',
            value: 10.0, // Higher than the 5 we'll test
            achievedAt: DateTime(2026, 1, 1),
          ),
        );

        await prRepo.save(
          PersonalRecord(
            id: 'pr_3',
            exerciseId: squat.id,
            type: 'maxVolume',
            value: 750.0, // 150 * 5
            achievedAt: DateTime(2026, 1, 1),
          ),
        );

        final prsBefore = await prRepo.getPRsByExercise(squat.id);
        final countBefore = prsBefore.length;

        // Record set with lower weight and same reps - neither weight (140 < 150) nor reps (5 < 10) nor volume (700 < 750) is a PR
        await useCaseWithPR.execute(
          exerciseId: squat.id,
          values: {'weight': 140.0, 'reps': 5},
        );

        final prsAfter = await prRepo.getPRsByExercise(squat.id);
        expect(prsAfter.length, equals(countBefore));
      });

      test('should save first PR when no existing PR for exercise', () async {
        final exercises = await exerciseRepo.getAllExercises();
        final deadlift = exercises.firstWhere(
          (e) => e.name.contains('Deadlift'),
        );

        // Record first set ever
        final result = await useCaseWithPR.execute(
          exerciseId: deadlift.id,
          values: {'weight': 180.0, 'reps': 5},
        );

        expect(result, isNotNull);

        // Check if first PR was saved
        final currentPR = await prRepo.getCurrentPR(deadlift.id, 'maxWeight');
        expect(currentPR, isNotNull);
        expect(currentPR!.value, equals(180.0));
      });
    });
  });
}
