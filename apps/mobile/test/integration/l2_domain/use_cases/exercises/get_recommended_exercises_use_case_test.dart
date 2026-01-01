import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/use_cases/exercises/get_recommended_exercises_use_case.dart';
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

    // ========== SEARCH FUNCTIONALITY TESTS ==========

    test('should search exercises by name ignoring filter', () async {
      // Act - search for "squat" even though we might have a filter
      final result = await useCase.execute(searchQuery: 'squat');

      // Assert
      expect(result, isNotEmpty);
      for (final exercise in result) {
        expect(
          exercise.name.toLowerCase().contains('squat'),
          isTrue,
          reason: 'Exercise "${exercise.name}" should contain "squat"',
        );
      }
    });

    test('should search case-insensitive', () async {
      // Act - search with different cases
      final lowerCase = await useCase.execute(searchQuery: 'squat');
      final upperCase = await useCase.execute(searchQuery: 'SQUAT');
      final mixedCase = await useCase.execute(searchQuery: 'SqUaT');

      // Assert - all should return same results
      expect(lowerCase.length, equals(upperCase.length));
      expect(lowerCase.length, equals(mixedCase.length));
      expect(
        lowerCase.map((e) => e.id).toSet(),
        equals(upperCase.map((e) => e.id).toSet()),
      );
    });

    test('should return empty list when no exercises match search', () async {
      // Act - search for something that doesn't exist
      final result = await useCase.execute(searchQuery: 'zzzznonexistent');

      // Assert
      expect(result, isEmpty);
    });

    test(
      'should prioritize exercises starting with query over contains',
      () async {
        // Act - search for "curl" (should have "Barbell Curl" before "Preacher Curl")
        final result = await useCase.execute(searchQuery: 'curl');

        // Assert
        expect(result, isNotEmpty);

        // Find exercises that start with "curl" and ones that contain "curl"
        final startsWithCurl = result
            .where((e) => e.name.toLowerCase().startsWith('curl'))
            .toList();
        final containsCurl = result
            .where(
              (e) =>
                  e.name.toLowerCase().contains('curl') &&
                  !e.name.toLowerCase().startsWith('curl'),
            )
            .toList();

        // If both exist, verify ordering
        if (startsWithCurl.isNotEmpty && containsCurl.isNotEmpty) {
          final firstStartsWithIndex = result.indexOf(startsWithCurl.first);
          final firstContainsIndex = result.indexOf(containsCurl.first);
          expect(
            firstStartsWithIndex,
            lessThan(firstContainsIndex),
            reason: 'Exercises starting with query should come first',
          );
        }
      },
    );

    test(
      'should return all exercises when search query is empty string',
      () async {
        // Act
        final emptySearch = await useCase.execute(searchQuery: '');
        final noSearch = await useCase.execute();

        // Assert - both should return same results
        expect(emptySearch.length, equals(noSearch.length));
      },
    );

    test(
      'should search all exercises even when filterCategory is provided (search overrides filter)',
      () async {
        // Arrange - Get all exercises first
        final allExercises = await useCase.execute();

        // Find an exercise that's NOT in the 'arms' category
        final nonArmsExercise = allExercises.firstWhere(
          (e) => !e.categories.contains('arms'),
          orElse: () => allExercises.first,
        );

        // Act - Search for that exercise while having 'arms' filter
        final result = await useCase.execute(
          searchQuery: nonArmsExercise.name.substring(0, 5),
          filterCategory: 'arms',
        );

        // Assert - Should find the non-arms exercise (search overrides filter)
        expect(
          result.any((e) => e.id == nonArmsExercise.id),
          isTrue,
          reason:
              'Search should override filter and find exercises from any category',
        );
      },
    );
  });
}
