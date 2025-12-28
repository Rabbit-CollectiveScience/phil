import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/use_cases/workout_use_cases/record_workout_set_use_case.dart';
import 'package:phil/l3_data/repositories/stub_workout_set_repository.dart';
import 'package:phil/l2_domain/models/workout_set.dart';

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
      await useCase.execute(
        exerciseId: 'exercise_1',
        values: {'reps': 10},
      );

      // Assert
      expect(repository.count, 1);

      final savedSets = await repository.getWorkoutSets();
      expect(savedSets.length, 1);
      expect(savedSets.first.exerciseId, 'exercise_1');
    });

    test('should handle multiple workout sets correctly', () async {
      // Act
      await useCase.execute(
        exerciseId: 'exercise_1',
        values: {'reps': 10},
      );

      await useCase.execute(
        exerciseId: 'exercise_2',
        values: null,
      );

      await useCase.execute(
        exerciseId: 'exercise_3',
        values: {'duration': 30},
      );

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
      expect(cardioSet.values, equals({'durationInSeconds': 1800, 'distance': 5.0}));

      // Act & Assert for 3 fields (cardio with height)
      final threeFieldSet = await useCase.execute(
        exerciseId: 'cardio_17',
        values: {'durationInSeconds': 600, 'reps': 15, 'height': 45},
      );
      expect(threeFieldSet, isNotNull);
      expect(threeFieldSet.values, equals({'durationInSeconds': 600, 'reps': 15, 'height': 45}));

      // Act & Assert for 1 field (flexibility)
      final oneFieldSet = await useCase.execute(
        exerciseId: 'flex_6',
        values: {'reps': 10},
      );
      expect(oneFieldSet, isNotNull);
      expect(oneFieldSet.values, equals({'reps': 10}));

      // Verify all saved
      expect(repository.count, 4);
    });
  });
}
