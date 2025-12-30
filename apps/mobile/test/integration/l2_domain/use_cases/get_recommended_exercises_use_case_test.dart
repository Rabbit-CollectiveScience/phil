import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/use_cases/workout_use_cases/get_recommended_exercises_use_case.dart';
import 'package:phil/l3_data/repositories/stub_exercise_repository.dart';

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

    test('should return all exercises when no filter is provided', () async {
      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, isNotEmpty);
      expect(result.length, greaterThan(0));
    });

    test('should return all exercises when filter is "all"', () async {
      // Act
      final result = await useCase.execute(filterCategory: 'all');

      // Assert
      expect(result, isNotEmpty);
      expect(result.length, greaterThan(0));
    });

    test(
      'should filter exercises by category when filter is provided',
      () async {
        // Act - filter by shoulders
        final shoulderExercises = await useCase.execute(
          filterCategory: 'shoulders',
        );

        // Assert
        expect(shoulderExercises, isNotEmpty);
        for (final exercise in shoulderExercises) {
          expect(exercise.categories, contains('shoulders'));
        }
      },
    );

    test('should filter exercises by strength category', () async {
      // Act
      final strengthExercises = await useCase.execute(
        filterCategory: 'strength',
      );

      // Assert
      expect(strengthExercises, isNotEmpty);
      for (final exercise in strengthExercises) {
        expect(exercise.categories, contains('strength'));
      }
    });

    test('should filter exercises by cardio category', () async {
      // Act
      final cardioExercises = await useCase.execute(filterCategory: 'cardio');

      // Assert
      expect(cardioExercises, isNotEmpty);
      for (final exercise in cardioExercises) {
        expect(exercise.categories, contains('cardio'));
      }
    });

    test('should return empty list when no exercises match filter', () async {
      // Act - use a non-existent category
      final result = await useCase.execute(filterCategory: 'nonexistent');

      // Assert
      expect(result, isEmpty);
    });

    test('should return exercises with valid structure', () async {
      // Act
      final result = await useCase.execute();

      // Assert
      for (final exercise in result) {
        expect(exercise.id, isNotEmpty);
        expect(exercise.name, isNotEmpty);
        expect(exercise.categories, isNotEmpty);
        expect(exercise.fields.length, greaterThanOrEqualTo(1));

        // Verify field structure
        for (final field in exercise.fields) {
          expect(field.name, isNotEmpty);
          expect(field.label, isNotEmpty);
          expect(
            field.unit,
            isNotNull,
          ); // Unit can be empty string for text fields
          expect(field.type, isNotNull);
        }
      }
    });

    test('should handle compound exercises with multiple categories', () async {
      // Act - Get all exercises
      final allExercises = await useCase.execute();

      // Find a compound exercise (has multiple categories)
      final compoundExercise = allExercises.firstWhere(
        (e) => e.categories.length > 1,
        orElse: () => allExercises.first,
      );

      if (compoundExercise.categories.length > 1) {
        // Act - Filter by first category
        final firstCategoryFilter = await useCase.execute(
          filterCategory: compoundExercise.categories[0],
        );

        // Assert - compound exercise should appear in filter results
        expect(
          firstCategoryFilter.any((e) => e.id == compoundExercise.id),
          isTrue,
        );

        // Act - Filter by second category
        final secondCategoryFilter = await useCase.execute(
          filterCategory: compoundExercise.categories[1],
        );

        // Assert - compound exercise should also appear in this filter
        expect(
          secondCategoryFilter.any((e) => e.id == compoundExercise.id),
          isTrue,
        );
      }
    });
  });
}
