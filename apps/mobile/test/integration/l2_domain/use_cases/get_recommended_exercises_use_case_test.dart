import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/use_cases/workout_use_cases/get_recommended_exercises_use_case.dart';
import 'package:phil/l3_data/repositories/stub_exercise_repository.dart';
import 'package:phil/l2_domain/models/exercise.dart';
import 'package:phil/l2_domain/models/exercise_type_enum.dart';

void main() {
  // Initialize Flutter bindings for asset loading
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GetRecommendedExercisesUseCase Integration Tests', () {
    late GetRecommendedExercisesUseCase useCase;
    late StubExerciseRepository repository;

    setUp(() {
      repository = StubExerciseRepository();
      useCase = GetRecommendedExercisesUseCase(repository);
    });

    test(
      'should return 10 exercises with cardio_17 (3-field exercise) first',
      () async {
        // Act
        final result = await useCase.execute();

        // Assert
        expect(result, isNotEmpty);
        expect(result.length, 10);

        // Verify first exercise is cardio_17 with 3 fields
        final firstExercise = result.first;
        expect(firstExercise.id, 'cardio_17');
        expect(firstExercise.name, isNotEmpty);
        expect(firstExercise.description, isNotEmpty);
        expect(firstExercise.type, ExerciseTypeEnum.cardio);
        expect(firstExercise.fields.length, 3);

        // Verify fields structure
        for (final field in firstExercise.fields) {
          expect(field.name, isNotEmpty);
          expect(field.label, isNotEmpty);
          expect(field.unit, isNotEmpty);
          expect(field.type, isNotNull);
        }
      },
    );

    test('should return exercises with valid IDs', () async {
      // Act
      final result = await useCase.execute();

      // Assert
      for (final exercise in result) {
        expect(exercise.id, isNotEmpty);
      }
    });

    test('should return exercises with proper field structure', () async {
      // Act
      final result = await useCase.execute();

      // Assert
      for (final exercise in result) {
        // All exercises should have at least one field
        expect(exercise.fields.length, greaterThanOrEqualTo(1));

        final fieldNames = exercise.fields.map((f) => f.name).toList();
        expect(fieldNames, isNotEmpty);
      }
    });
  });
}
