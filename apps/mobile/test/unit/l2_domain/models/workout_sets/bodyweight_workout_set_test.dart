import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/workout_sets/bodyweight_workout_set.dart';
import 'package:phil/l2_domain/models/common/weight.dart';

void main() {
  group('BodyweightWorkoutSet', () {
    final testDate = DateTime(2024, 1, 1, 12, 0);

    group('constructor', () {
      test('creates BodyweightWorkoutSet with required fields only', () {
        final set = BodyweightWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          reps: 20,
        );

        expect(set.id, '1');
        expect(set.exerciseId, 'exercise1');
        expect(set.timestamp, testDate);
        expect(set.reps, 20);
        expect(set.additionalWeight, isNull);
      });

      test('creates BodyweightWorkoutSet with additional weight', () {
        final set = BodyweightWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          reps: 10,
          additionalWeight: Weight(10.0),
        );

        expect(set.reps, 10);
        expect(set.additionalWeight?.kg, 10.0);
      });

      test('creates BodyweightWorkoutSet with one rep', () {
        final set = BodyweightWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          reps: 1,
        );

        expect(set.reps, 1);
      });

      test('creates BodyweightWorkoutSet with zero reps', () {
        final set = BodyweightWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          reps: 0,
        );

        expect(set.reps, 0);
      });
    });

    group('getVolume', () {
      test('returns null for bodyweight-only set', () {
        final set = BodyweightWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          reps: 20,
        );

        expect(set.getVolume(), isNull);
      });

      test('returns null even with additional weight', () {
        final set = BodyweightWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          reps: 10,
          additionalWeight: Weight(10.0),
        );

        expect(set.getVolume(), isNull);
      });
    });

    group('toJson', () {
      test('serializes to JSON without additional weight', () {
        final set = BodyweightWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          reps: 20,
        );

        final json = set.toJson();

        expect(json['id'], '1');
        expect(json['exerciseId'], 'exercise1');
        expect(json['timestamp'], testDate.toIso8601String());
        expect(json['type'], 'bodyweight');
        expect(json['reps'], 20);
        expect(json['additionalWeight'], isNull);
      });

      test('serializes to JSON with additional weight', () {
        final set = BodyweightWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          reps: 10,
          additionalWeight: Weight(10.0),
        );

        final json = set.toJson();

        expect(json['reps'], 10);
        expect(json['additionalWeight'], 10.0);
      });

      test('serializes set with zero reps', () {
        final set = BodyweightWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          reps: 0,
        );

        final json = set.toJson();

        expect(json['reps'], 0);
      });
    });

    group('fromJson', () {
      test('deserializes from JSON without additional weight', () {
        final json = {
          'id': '1',
          'exerciseId': 'exercise1',
          'timestamp': testDate.toIso8601String(),
          'type': 'bodyweight',
          'reps': 20,
        };

        final set = BodyweightWorkoutSet.fromJson(json);

        expect(set.id, '1');
        expect(set.exerciseId, 'exercise1');
        expect(set.timestamp, testDate);
        expect(set.reps, 20);
        expect(set.additionalWeight, isNull);
      });

      test('deserializes from JSON with additional weight', () {
        final json = {
          'id': '1',
          'exerciseId': 'exercise1',
          'timestamp': testDate.toIso8601String(),
          'type': 'bodyweight',
          'reps': 10,
          'additionalWeight': 10.0,
        };

        final set = BodyweightWorkoutSet.fromJson(json);

        expect(set.reps, 10);
        expect(set.additionalWeight?.kg, 10.0);
      });

      test('deserializes from JSON with null additional weight', () {
        final json = {
          'id': '1',
          'exerciseId': 'exercise1',
          'timestamp': testDate.toIso8601String(),
          'type': 'bodyweight',
          'reps': 15,
          'additionalWeight': null,
        };

        final set = BodyweightWorkoutSet.fromJson(json);

        expect(set.additionalWeight, isNull);
      });
    });

    group('copyWith', () {
      test('returns new instance with updated reps', () {
        final set = BodyweightWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          reps: 20,
        );

        final updated = set.copyWith(reps: 25);

        expect(updated.reps, 25);
        expect(set.reps, 20);
      });

      test('can add additional weight via copyWith', () {
        final set = BodyweightWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          reps: 10,
        );

        final updated = set.copyWith(additionalWeight: Weight(10.0));

        expect(updated.additionalWeight?.kg, 10.0);
        expect(set.additionalWeight, isNull);
      });

      test('can remove additional weight via copyWith', () {
        final set = BodyweightWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          reps: 10,
          additionalWeight: Weight(10.0),
        );

        final updated = set.copyWith(additionalWeight: null);

        expect(updated.additionalWeight, isNull);
        expect(set.additionalWeight?.kg, 10.0);
      });

      test('returns new instance with no changes when no params provided', () {
        final set = BodyweightWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          reps: 20,
          additionalWeight: Weight(5.0),
        );

        final updated = set.copyWith();

        expect(updated.id, set.id);
        expect(updated.reps, set.reps);
        expect(updated.additionalWeight?.kg, set.additionalWeight?.kg);
      });
    });

    group('equality', () {
      test('two sets with same values are equal', () {
        final set1 = BodyweightWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          reps: 20,
        );

        final set2 = BodyweightWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          reps: 20,
        );

        expect(set1, set2);
      });

      test('two sets with different reps are not equal', () {
        final set1 = BodyweightWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          reps: 20,
        );

        final set2 = BodyweightWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          reps: 25,
        );

        expect(set1, isNot(set2));
      });

      test('two sets with different additional weight are not equal', () {
        final set1 = BodyweightWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          reps: 10,
          additionalWeight: Weight(10.0),
        );

        final set2 = BodyweightWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          reps: 10,
          additionalWeight: Weight(20.0),
        );

        expect(set1, isNot(set2));
      });

      test('set with additional weight not equal to set without', () {
        final set1 = BodyweightWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          reps: 10,
        );

        final set2 = BodyweightWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          reps: 10,
          additionalWeight: Weight(10.0),
        );

        expect(set1, isNot(set2));
      });
    });

    group('hashCode', () {
      test('same values produce same hashCode', () {
        final set1 = BodyweightWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          reps: 20,
        );

        final set2 = BodyweightWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          reps: 20,
        );

        expect(set1.hashCode, set2.hashCode);
      });

      test('different reps produce different hashCode', () {
        final set1 = BodyweightWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          reps: 20,
        );

        final set2 = BodyweightWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          reps: 25,
        );

        expect(set1.hashCode, isNot(set2.hashCode));
      });
    });

    group('serialization round-trip', () {
      test('deserialize(serialize(set)) equals original without weight', () {
        final set = BodyweightWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          reps: 20,
        );

        final json = set.toJson();
        final deserialized = BodyweightWorkoutSet.fromJson(json);

        expect(deserialized, set);
      });

      test('deserialize(serialize(set)) equals original with weight', () {
        final set = BodyweightWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          reps: 10,
          additionalWeight: Weight(10.0),
        );

        final json = set.toJson();
        final deserialized = BodyweightWorkoutSet.fromJson(json);

        expect(deserialized, set);
        expect(deserialized.additionalWeight?.kg, 10.0);
      });
    });
  });
}
