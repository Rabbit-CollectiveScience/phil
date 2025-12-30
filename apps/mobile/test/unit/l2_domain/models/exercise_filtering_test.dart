import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/exercise.dart';

void main() {
  group('Exercise Filtering by Categories', () {
    late List<Exercise> exercises;

    setUp(() {
      // Create test exercises with different categories
      exercises = [
        Exercise(
          id: 'arms_1',
          name: 'Barbell Curl',
          description: 'Bicep exercise',
          categories: ['strength', 'arms'],
          fields: [],
        ),
        Exercise(
          id: 'chest_1',
          name: 'Bench Press',
          description: 'Chest exercise',
          categories: ['strength', 'chest'],
          fields: [],
        ),
        Exercise(
          id: 'legs_1',
          name: 'Squat',
          description: 'Leg exercise',
          categories: ['strength', 'legs'],
          fields: [],
        ),
        Exercise(
          id: 'legs_10',
          name: 'Deadlift',
          description: 'Compound exercise',
          categories: ['strength', 'back', 'legs', 'core'],
          fields: [],
        ),
        Exercise(
          id: 'cardio_1',
          name: 'Treadmill',
          description: 'Cardio exercise',
          categories: ['cardio'],
          fields: [],
        ),
        Exercise(
          id: 'flex_1',
          name: 'Hamstring Stretch',
          description: 'Flexibility exercise',
          categories: ['flexibility', 'legs'],
          fields: [],
        ),
      ];
    });

    test('should return all exercises when filter is "all"', () {
      final filterId = 'all';

      final filtered = exercises.where((exercise) {
        return filterId == 'all' || exercise.categories.contains(filterId);
      }).toList();

      expect(filtered.length, 6);
      expect(filtered, equals(exercises));
    });

    test('should filter by "arms" category', () {
      final filterId = 'arms';

      final filtered = exercises.where((exercise) {
        return exercise.categories.contains(filterId);
      }).toList();

      expect(filtered.length, 1);
      expect(filtered.first.id, 'arms_1');
    });

    test('should filter by "chest" category', () {
      final filterId = 'chest';

      final filtered = exercises.where((exercise) {
        return exercise.categories.contains(filterId);
      }).toList();

      expect(filtered.length, 1);
      expect(filtered.first.id, 'chest_1');
    });

    test('should filter by "legs" category and include compound exercises', () {
      final filterId = 'legs';

      final filtered = exercises.where((exercise) {
        return exercise.categories.contains(filterId);
      }).toList();

      expect(filtered.length, 3); // squat, deadlift, hamstring stretch
      expect(filtered.any((e) => e.id == 'legs_1'), true);
      expect(
        filtered.any((e) => e.id == 'legs_10'),
        true,
      ); // deadlift (compound)
      expect(filtered.any((e) => e.id == 'flex_1'), true); // hamstring stretch
    });

    test('should filter by "back" category', () {
      final filterId = 'back';

      final filtered = exercises.where((exercise) {
        return exercise.categories.contains(filterId);
      }).toList();

      expect(filtered.length, 1);
      expect(filtered.first.id, 'legs_10'); // deadlift has back in categories
    });

    test('should filter by "core" category', () {
      final filterId = 'core';

      final filtered = exercises.where((exercise) {
        return exercise.categories.contains(filterId);
      }).toList();

      expect(filtered.length, 1);
      expect(filtered.first.id, 'legs_10'); // deadlift has core in categories
    });

    test('should filter by "cardio" category', () {
      final filterId = 'cardio';

      final filtered = exercises.where((exercise) {
        return exercise.categories.contains(filterId);
      }).toList();

      expect(filtered.length, 1);
      expect(filtered.first.id, 'cardio_1');
    });

    test('should filter by "flexibility" category', () {
      final filterId = 'flexibility';

      final filtered = exercises.where((exercise) {
        return exercise.categories.contains(filterId);
      }).toList();

      expect(filtered.length, 1);
      expect(filtered.first.id, 'flex_1');
    });

    test('should return empty list when no exercises match filter', () {
      final filterId = 'shoulders';

      final filtered = exercises.where((exercise) {
        return exercise.categories.contains(filterId);
      }).toList();

      expect(filtered.length, 0);
      expect(filtered.isEmpty, true);
    });

    test('compound exercise appears in multiple filter results', () {
      final deadlift = exercises.firstWhere((e) => e.id == 'legs_10');

      // Deadlift should appear when filtering by any of its categories
      expect(deadlift.categories, contains('back'));
      expect(deadlift.categories, contains('legs'));
      expect(deadlift.categories, contains('core'));
      expect(deadlift.categories, contains('strength'));

      // Verify it would appear in all these filters
      final backFiltered = exercises
          .where((e) => e.categories.contains('back'))
          .toList();
      final legsFiltered = exercises
          .where((e) => e.categories.contains('legs'))
          .toList();
      final coreFiltered = exercises
          .where((e) => e.categories.contains('core'))
          .toList();

      expect(backFiltered, contains(deadlift));
      expect(legsFiltered, contains(deadlift));
      expect(coreFiltered, contains(deadlift));
    });
  });
}
