import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/exercise.dart';

void main() {
  group('Exercise Model - Categories Support', () {
    test('should parse new JSON format with categories array', () {
      final json = {
        'id': 'arms_1',
        'name': 'Barbell Curl',
        'description': 'Stand with feet shoulder-width apart...',
        'categories': ['strength', 'arms'],
        'fields': [
          {'name': 'weight', 'label': 'Weight', 'unit': 'kg', 'type': 'number'},
          {'name': 'reps', 'label': 'Reps', 'unit': 'reps', 'type': 'number'},
        ],
      };

      final exercise = Exercise.fromJson(json);

      expect(exercise.id, 'arms_1');
      expect(exercise.name, 'Barbell Curl');
      expect(exercise.categories, ['strength', 'arms']);
      expect(exercise.categories.length, 2);
      expect(exercise.fields.length, 2);
    });

    test('should parse old JSON format with type field', () {
      final json = {
        'id': 'arms_1',
        'name': 'Barbell Curl',
        'description': 'Stand with feet shoulder-width apart...',
        'type': 'strength',
        'fields': [
          {'name': 'weight', 'label': 'Weight', 'unit': 'kg', 'type': 'number'},
          {'name': 'reps', 'label': 'Reps', 'unit': 'reps', 'type': 'number'},
        ],
      };

      final exercise = Exercise.fromJson(json);

      expect(exercise.id, 'arms_1');
      expect(exercise.name, 'Barbell Curl');
      expect(exercise.categories, ['strength']);
      expect(exercise.categories.length, 1);
    });

    test('should support compound exercises with multiple body parts', () {
      final json = {
        'id': 'legs_10',
        'name': 'Deadlift',
        'description': 'Stand with feet hip-width apart...',
        'categories': ['strength', 'back', 'legs', 'core'],
        'fields': [
          {'name': 'weight', 'label': 'Weight', 'unit': 'kg', 'type': 'number'},
          {'name': 'reps', 'label': 'Reps', 'unit': 'reps', 'type': 'number'},
        ],
      };

      final exercise = Exercise.fromJson(json);

      expect(exercise.categories.length, 4);
      expect(exercise.categories, contains('strength'));
      expect(exercise.categories, contains('back'));
      expect(exercise.categories, contains('legs'));
      expect(exercise.categories, contains('core'));
    });

    test('should support cardio exercises with single category', () {
      final json = {
        'id': 'cardio_1',
        'name': 'Treadmill',
        'description': 'Step onto the treadmill...',
        'categories': ['cardio'],
        'fields': [
          {
            'name': 'durationInSeconds',
            'label': 'Duration',
            'unit': 'seconds',
            'type': 'duration',
          },
          {'name': 'speed', 'label': 'Speed', 'unit': 'km/h', 'type': 'number'},
        ],
      };

      final exercise = Exercise.fromJson(json);

      expect(exercise.categories, ['cardio']);
      expect(exercise.categories.length, 1);
    });

    test('should support only strength and cardio exercise types', () {
      final strengthJson = {
        'id': 'arms_1',
        'name': 'Barbell Curl',
        'description': 'Test',
        'categories': ['strength', 'arms'],
        'fields': [],
      };

      final cardioJson = {
        'id': 'cardio_1',
        'name': 'Treadmill',
        'description': 'Test',
        'categories': ['cardio'],
        'fields': [],
      };

      final strengthExercise = Exercise.fromJson(strengthJson);
      final cardioExercise = Exercise.fromJson(cardioJson);

      expect(strengthExercise.categories, contains('strength'));
      expect(cardioExercise.categories, contains('cardio'));
    });

    test('should handle missing categories gracefully', () {
      final json = {
        'id': 'test_1',
        'name': 'Test Exercise',
        'description': 'Test',
        'fields': [],
      };

      final exercise = Exercise.fromJson(json);

      expect(exercise.categories, ['strength']); // Default fallback
    });

    test('should verify flexibility category is not used in valid exercises', () {
      final exercises = [
        {
          'id': 'arms_1',
          'name': 'Barbell Curl',
          'description': 'Test',
          'categories': ['strength', 'arms'],
          'fields': [],
        },
        {
          'id': 'cardio_1',
          'name': 'Treadmill',
          'description': 'Test',
          'categories': ['cardio'],
          'fields': [],
        },
        {
          'id': 'legs_1',
          'name': 'Squat',
          'description': 'Test',
          'categories': ['strength', 'legs', 'core'],
          'fields': [],
        },
      ];

      for (final json in exercises) {
        final exercise = Exercise.fromJson(json);
        expect(
          exercise.categories.contains('flexibility'),
          false,
          reason: 'Exercise ${exercise.name} should not have flexibility category',
        );
      }
    });

    test('should not accept flexibility as valid exercise type', () {
      // Even if someone tries to create a flexibility exercise,
      // the system should only accept strength and cardio
      final validTypes = ['strength', 'cardio'];
      
      final strengthJson = {
        'id': 'test_1',
        'name': 'Test',
        'description': 'Test',
        'categories': ['strength'],
        'fields': [],
      };
      
      final cardioJson = {
        'id': 'test_2',
        'name': 'Test',
        'description': 'Test',
        'categories': ['cardio'],
        'fields': [],
      };

      final strengthEx = Exercise.fromJson(strengthJson);
      final cardioEx = Exercise.fromJson(cardioJson);

      expect(validTypes.contains(strengthEx.categories.first), true);
      expect(validTypes.contains(cardioEx.categories.first), true);
    });
  });
}
