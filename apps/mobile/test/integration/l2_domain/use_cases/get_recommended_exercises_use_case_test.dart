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

    test('should return 10 exercises from chest strength workout', () async {
      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, isNotEmpty);
      expect(result.length, 10);

      // Verify first exercise structure
      final firstExercise = result.first;
      expect(firstExercise.id, isNotEmpty);
      expect(firstExercise.name, isNotEmpty);
      expect(firstExercise.description, isNotEmpty);
      expect(firstExercise.type, ExerciseTypeEnum.strength);
      expect(firstExercise.fields, isNotEmpty);

      // Verify fields structure
      for (final field in firstExercise.fields) {
        expect(field.name, isNotEmpty);
        expect(field.label, isNotEmpty);
        expect(field.unit, isNotEmpty);
        expect(field.type, isNotNull);
      }
    });

    test('should return exercises with chest IDs', () async {
      // Act
      final result = await useCase.execute();

      // Assert
      for (final exercise in result) {
        expect(exercise.id, startsWith('chest_'));
      }
    });

    test('should return exercises with proper field structure', () async {
      // Act
      final result = await useCase.execute();

      // Assert
      for (final exercise in result) {
        // Most chest exercises should have weight and reps fields
        expect(exercise.fields.length, greaterThanOrEqualTo(1));

        final fieldNames = exercise.fields.map((f) => f.name).toList();
        // At minimum should have reps field for bodyweight, or weight+reps for loaded
        expect(fieldNames, isNotEmpty);
      }
    });
  });
}
