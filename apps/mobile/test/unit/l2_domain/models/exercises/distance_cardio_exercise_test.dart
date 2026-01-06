import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/exercises/distance_cardio_exercise.dart';

void main() {
  group('DistanceCardioExercise', () {
    group('constructor', () {
      test('creates DistanceCardioExercise with all required fields', () {
        final exercise = DistanceCardioExercise(
          id: '1',
          name: 'Running',
          description: 'Outdoor running',
          isCustom: false,
        );

        expect(exercise.id, '1');
        expect(exercise.name, 'Running');
        expect(exercise.description, 'Outdoor running');
        expect(exercise.isCustom, false);
      });

      test('creates custom DistanceCardioExercise', () {
        final exercise = DistanceCardioExercise(
          id: '1',
          name: 'Custom Cardio',
          description: 'My custom cardio',
          isCustom: true,
        );

        expect(exercise.isCustom, true);
      });

      test('creates DistanceCardioExercise with empty description', () {
        final exercise = DistanceCardioExercise(
          id: '1',
          name: 'Cycling',
          description: '',
          isCustom: false,
        );

        expect(exercise.description, '');
      });
    });

    group('toJson', () {
      test('serializes to JSON correctly', () {
        final exercise = DistanceCardioExercise(
          id: '1',
          name: 'Swimming',
          description: 'Pool swimming',
          isCustom: false,
        );

        final json = exercise.toJson();

        expect(json['id'], '1');
        expect(json['name'], 'Swimming');
        expect(json['description'], 'Pool swimming');
        expect(json['isCustom'], false);
        expect(json['type'], 'distance_cardio');
      });

      test('serializes custom exercise to JSON', () {
        final exercise = DistanceCardioExercise(
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
          'name': 'Rowing',
          'description': 'Indoor rowing',
          'isCustom': false,
          'type': 'distanceCardio',
        };

        final exercise = DistanceCardioExercise.fromJson(json);

        expect(exercise.id, '1');
        expect(exercise.name, 'Rowing');
        expect(exercise.description, 'Indoor rowing');
        expect(exercise.isCustom, false);
      });

      test('deserializes custom exercise from JSON', () {
        final json = {
          'id': '1',
          'name': 'Custom',
          'description': 'Custom description',
          'isCustom': true,
          'type': 'distanceCardio',
        };

        final exercise = DistanceCardioExercise.fromJson(json);

        expect(exercise.isCustom, true);
      });
    });

    group('copyWith', () {
      test('returns new instance with updated fields', () {
        final exercise = DistanceCardioExercise(
          id: '1',
          name: 'Running',
          description: 'Outdoor running',
          isCustom: false,
        );

        final updated = exercise.copyWith(
          name: 'Treadmill Running',
          description: 'Indoor treadmill',
        );

        expect(updated.name, 'Treadmill Running');
        expect(updated.description, 'Indoor treadmill');
        expect(exercise.name, 'Running');
      });

      test('returns new instance with no changes when no params provided', () {
        final exercise = DistanceCardioExercise(
          id: '1',
          name: 'Cycling',
          description: 'Road cycling',
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
        final exercise1 = DistanceCardioExercise(
          id: '1',
          name: 'Running',
          description: 'Outdoor running',
          isCustom: false,
        );

        final exercise2 = DistanceCardioExercise(
          id: '1',
          name: 'Running',
          description: 'Outdoor running',
          isCustom: false,
        );

        expect(exercise1, exercise2);
      });

      test('two exercises with different ids are not equal', () {
        final exercise1 = DistanceCardioExercise(
          id: '1',
          name: 'Running',
          description: 'Outdoor running',
          isCustom: false,
        );

        final exercise2 = DistanceCardioExercise(
          id: '2',
          name: 'Running',
          description: 'Outdoor running',
          isCustom: false,
        );

        expect(exercise1, isNot(exercise2));
      });

      test('two exercises with different names are not equal', () {
        final exercise1 = DistanceCardioExercise(
          id: '1',
          name: 'Running',
          description: 'Outdoor',
          isCustom: false,
        );

        final exercise2 = DistanceCardioExercise(
          id: '1',
          name: 'Cycling',
          description: 'Outdoor',
          isCustom: false,
        );

        expect(exercise1, isNot(exercise2));
      });
    });

    group('hashCode', () {
      test('same values produce same hashCode', () {
        final exercise1 = DistanceCardioExercise(
          id: '1',
          name: 'Swimming',
          description: 'Pool',
          isCustom: false,
        );

        final exercise2 = DistanceCardioExercise(
          id: '1',
          name: 'Swimming',
          description: 'Pool',
          isCustom: false,
        );

        expect(exercise1.hashCode, exercise2.hashCode);
      });

      test('different names produce different hashCode', () {
        final exercise1 = DistanceCardioExercise(
          id: '1',
          name: 'Running',
          description: 'Outdoor',
          isCustom: false,
        );

        final exercise2 = DistanceCardioExercise(
          id: '1',
          name: 'Cycling',
          description: 'Outdoor',
          isCustom: false,
        );

        expect(exercise1.hashCode, isNot(exercise2.hashCode));
      });
    });

    group('serialization round-trip', () {
      test('deserialize(serialize(exercise)) equals original', () {
        final exercise = DistanceCardioExercise(
          id: '1',
          name: 'Rowing',
          description: 'Indoor rowing machine',
          isCustom: false,
        );

        final json = exercise.toJson();
        final deserialized = DistanceCardioExercise.fromJson(json);

        expect(deserialized, exercise);
      });
    });
  });
}
