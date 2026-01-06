import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/exercises/duration_cardio_exercise.dart';

void main() {
  group('DurationCardioExercise', () {
    group('constructor', () {
      test('creates DurationCardioExercise with all required fields', () {
        final exercise = DurationCardioExercise(
          id: '1',
          name: 'Jumping Jacks',
          description: 'Basic cardio exercise',
          isCustom: false,
        );

        expect(exercise.id, '1');
        expect(exercise.name, 'Jumping Jacks');
        expect(exercise.description, 'Basic cardio exercise');
        expect(exercise.isCustom, false);
      });

      test('creates custom DurationCardioExercise', () {
        final exercise = DurationCardioExercise(
          id: '1',
          name: 'Custom Cardio',
          description: 'My custom cardio',
          isCustom: true,
        );

        expect(exercise.isCustom, true);
      });

      test('creates DurationCardioExercise with empty description', () {
        final exercise = DurationCardioExercise(
          id: '1',
          name: 'Burpees',
          description: '',
          isCustom: false,
        );

        expect(exercise.description, '');
      });
    });

    group('toJson', () {
      test('serializes to JSON correctly', () {
        final exercise = DurationCardioExercise(
          id: '1',
          name: 'Mountain Climbers',
          description: 'Full body cardio',
          isCustom: false,
        );

        final json = exercise.toJson();

        expect(json['id'], '1');
        expect(json['name'], 'Mountain Climbers');
        expect(json['description'], 'Full body cardio');
        expect(json['isCustom'], false);
        expect(json['type'], 'durationCardio');
      });

      test('serializes custom exercise to JSON', () {
        final exercise = DurationCardioExercise(
          id: '1',
          name: 'Custom',
          description: 'Custom description',
          isCustom: true,
        );

        final json = exercise.toJson();

        expect(json['isCustom'], true);
      });
    });

    group('fromJson', () {
      test('deserializes from JSON correctly', () {
        final json = {
          'id': '1',
          'name': 'High Knees',
          'description': 'Running in place',
          'isCustom': false,
          'type': 'durationCardio',
        };

        final exercise = DurationCardioExercise.fromJson(json);

        expect(exercise.id, '1');
        expect(exercise.name, 'High Knees');
        expect(exercise.description, 'Running in place');
        expect(exercise.isCustom, false);
      });

      test('deserializes custom exercise from JSON', () {
        final json = {
          'id': '1',
          'name': 'Custom',
          'description': 'Custom description',
          'isCustom': true,
          'type': 'durationCardio',
        };

        final exercise = DurationCardioExercise.fromJson(json);

        expect(exercise.isCustom, true);
      });
    });

    group('copyWith', () {
      test('returns new instance with updated fields', () {
        final exercise = DurationCardioExercise(
          id: '1',
          name: 'Jump Rope',
          description: 'Rope skipping',
          isCustom: false,
        );

        final updated = exercise.copyWith(
          name: 'Speed Jump Rope',
          description: 'Fast rope skipping',
        );

        expect(updated.name, 'Speed Jump Rope');
        expect(updated.description, 'Fast rope skipping');
        expect(exercise.name, 'Jump Rope');
      });

      test('returns new instance with no changes when no params provided', () {
        final exercise = DurationCardioExercise(
          id: '1',
          name: 'Burpees',
          description: 'Full body exercise',
          isCustom: false,
        );

        final updated = exercise.copyWith();

        expect(updated.id, exercise.id);
        expect(updated.name, exercise.name);
        expect(updated.description, exercise.description);
      });
    });

    group('equality', () {
      test('two exercises with same values are equal', () {
        final exercise1 = DurationCardioExercise(
          id: '1',
          name: 'Jumping Jacks',
          description: 'Basic cardio',
          isCustom: false,
        );

        final exercise2 = DurationCardioExercise(
          id: '1',
          name: 'Jumping Jacks',
          description: 'Basic cardio',
          isCustom: false,
        );

        expect(exercise1, exercise2);
      });

      test('two exercises with different ids are not equal', () {
        final exercise1 = DurationCardioExercise(
          id: '1',
          name: 'Exercise',
          description: 'Description',
          isCustom: false,
        );

        final exercise2 = DurationCardioExercise(
          id: '2',
          name: 'Exercise',
          description: 'Description',
          isCustom: false,
        );

        expect(exercise1, isNot(exercise2));
      });

      test('two exercises with different isCustom are not equal', () {
        final exercise1 = DurationCardioExercise(
          id: '1',
          name: 'Exercise',
          description: 'Description',
          isCustom: false,
        );

        final exercise2 = DurationCardioExercise(
          id: '1',
          name: 'Exercise',
          description: 'Description',
          isCustom: true,
        );

        expect(exercise1, isNot(exercise2));
      });
    });

    group('hashCode', () {
      test('same values produce same hashCode', () {
        final exercise1 = DurationCardioExercise(
          id: '1',
          name: 'Burpees',
          description: 'Full body',
          isCustom: false,
        );

        final exercise2 = DurationCardioExercise(
          id: '1',
          name: 'Burpees',
          description: 'Full body',
          isCustom: false,
        );

        expect(exercise1.hashCode, exercise2.hashCode);
      });

      test('different values produce different hashCode', () {
        final exercise1 = DurationCardioExercise(
          id: '1',
          name: 'Burpees',
          description: 'Description',
          isCustom: false,
        );

        final exercise2 = DurationCardioExercise(
          id: '2',
          name: 'Burpees',
          description: 'Description',
          isCustom: false,
        );

        expect(exercise1.hashCode, isNot(exercise2.hashCode));
      });
    });

    group('serialization round-trip', () {
      test('deserialize(serialize(exercise)) equals original', () {
        final exercise = DurationCardioExercise(
          id: '1',
          name: 'Box Jumps',
          description: 'Plyometric exercise',
          isCustom: false,
        );

        final json = exercise.toJson();
        final deserialized = DurationCardioExercise.fromJson(json);

        expect(deserialized, exercise);
      });
    });
  });
}
