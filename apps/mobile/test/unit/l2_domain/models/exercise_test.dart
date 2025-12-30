import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/exercise.dart';
import 'package:phil/l2_domain/models/exercise_type_enum.dart';

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

    test('should derive type from categories for backward compatibility', () {
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

      final flexibilityJson = {
        'id': 'flex_1',
        'name': 'Hamstring Stretch',
        'description': 'Test',
        'categories': ['flexibility', 'legs'],
        'fields': [],
      };

      final strengthExercise = Exercise.fromJson(strengthJson);
      final cardioExercise = Exercise.fromJson(cardioJson);
      final flexibilityExercise = Exercise.fromJson(flexibilityJson);

      // ignore: deprecated_member_use_from_same_package
      expect(strengthExercise.type, ExerciseTypeEnum.strength);
      // ignore: deprecated_member_use_from_same_package
      expect(cardioExercise.type, ExerciseTypeEnum.cardio);
      // ignore: deprecated_member_use_from_same_package
      expect(flexibilityExercise.type, ExerciseTypeEnum.flexibility);
    });

    test('should fallback to strength if no valid category found', () {
      final json = {
        'id': 'test_1',
        'name': 'Test Exercise',
        'description': 'Test',
        'categories': ['unknown'],
        'fields': [],
      };

      final exercise = Exercise.fromJson(json);

      // ignore: deprecated_member_use_from_same_package
      expect(exercise.type, ExerciseTypeEnum.strength);
    });

    test('should handle missing categories and type gracefully', () {
      final json = {
        'id': 'test_1',
        'name': 'Test Exercise',
        'description': 'Test',
        'fields': [],
      };

      final exercise = Exercise.fromJson(json);

      expect(exercise.categories, ['strength']); // Default fallback
      // ignore: deprecated_member_use_from_same_package
      expect(exercise.type, ExerciseTypeEnum.strength);
    });
  });
}
