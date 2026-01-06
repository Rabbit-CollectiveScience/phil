import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/workout_sets/weighted_workout_set.dart';
import 'package:phil/l2_domain/models/common/weight.dart';

void main() {
  group('WeightedWorkoutSet', () {
    final testDate = DateTime(2024, 1, 1, 12, 0);

    group('constructor', () {
      test('creates WeightedWorkoutSet with all required fields', () {
        final set = WeightedWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          weight: Weight(100.0),
          reps: 10,
        );

        expect(set.id, '1');
        expect(set.exerciseId, 'exercise1');
        expect(set.timestamp, testDate);
        expect(set.weight.kg, 100.0);
        expect(set.reps, 10);
      });

      test('creates WeightedWorkoutSet with zero weight', () {
        final set = WeightedWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          weight: Weight(0.0),
          reps: 10,
        );

        expect(set.weight.kg, 0.0);
      });

      test('creates WeightedWorkoutSet with one rep', () {
        final set = WeightedWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          weight: Weight(100.0),
          reps: 1,
        );

        expect(set.reps, 1);
      });

      test('creates WeightedWorkoutSet with decimal weight', () {
        final set = WeightedWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          weight: Weight(62.5),
          reps: 8,
        );

        expect(set.weight.kg, 62.5);
      });
    });

    group('getVolume', () {
      test('calculates volume correctly', () {
        final set = WeightedWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          weight: Weight(100.0),
          reps: 10,
        );

        expect(set.getVolume(), 1000.0);
      });

      test('returns zero volume for zero weight', () {
        final set = WeightedWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          weight: Weight(0.0),
          reps: 10,
        );

        expect(set.getVolume(), 0.0);
      });

      test('returns zero volume for zero reps', () {
        final set = WeightedWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          weight: Weight(100.0),
          reps: 0,
        );

        expect(set.getVolume(), 0.0);
      });

      test('calculates volume with decimal weight', () {
        final set = WeightedWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          weight: Weight(62.5),
          reps: 8,
        );

        expect(set.getVolume(), 500.0);
      });

      test('calculates volume with single rep', () {
        final set = WeightedWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          weight: Weight(100.0),
          reps: 1,
        );

        expect(set.getVolume(), 100.0);
      });
    });

    group('toJson', () {
      test('serializes to JSON correctly', () {
        final set = WeightedWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          weight: Weight(100.0),
          reps: 10,
        );

        final json = set.toJson();

        expect(json['id'], '1');
        expect(json['exerciseId'], 'exercise1');
        expect(json['timestamp'], testDate.toIso8601String());
        expect(json['type'], 'weighted');
        expect(json['weight'], {'kg': 100.0});
        expect(json['reps'], 10);
      });

      test('serializes set with decimal weight to JSON', () {
        final set = WeightedWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          weight: Weight(62.5),
          reps: 8,
        );

        final json = set.toJson();

        expect(json['weight'], {'kg': 62.5});
        expect(json['reps'], 8);
      });
    });

    group('fromJson', () {
      test('deserializes from JSON correctly', () {
        final json = {
          'id': '1',
          'exerciseId': 'exercise1',
          'timestamp': testDate.toIso8601String(),
          'type': 'weighted',
          'weight': {'kg': 100.0},
          'reps': 10,
        };

        final set = WeightedWorkoutSet.fromJson(json);

        expect(set.id, '1');
        expect(set.exerciseId, 'exercise1');
        expect(set.timestamp, testDate);
        expect(set.weight.kg, 100.0);
        expect(set.reps, 10);
      });

      test('deserializes set with integer weight as double', () {
        final json = {
          'id': '1',
          'exerciseId': 'exercise1',
          'timestamp': testDate.toIso8601String(),
          'type': 'weighted',
          'weight': {'kg': 100},
          'reps': 10,
        };

        final set = WeightedWorkoutSet.fromJson(json);

        expect(set.weight.kg, 100.0);
      });
    });

    group('copyWith', () {
      test('returns new instance with updated fields', () {
        final set = WeightedWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          weight: Weight(100.0),
          reps: 10,
        );

        final updated = set.copyWith(weight: Weight(120.0), reps: 8);

        expect(updated.weight.kg, 120.0);
        expect(updated.reps, 8);
        expect(updated.id, '1');
        expect(set.weight.kg, 100.0);
        expect(set.reps, 10);
      });

      test('returns new instance with no changes when no params provided', () {
        final set = WeightedWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          weight: Weight(100.0),
          reps: 10,
        );

        final updated = set.copyWith();

        expect(updated.id, set.id);
        expect(updated.weight.kg, set.weight.kg);
        expect(updated.reps, set.reps);
      });
    });

    group('equality', () {
      test('two sets with same values are equal', () {
        final set1 = WeightedWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          weight: Weight(100.0),
          reps: 10,
        );

        final set2 = WeightedWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          weight: Weight(100.0),
          reps: 10,
        );

        expect(set1, set2);
      });

      test('two sets with different weights are not equal', () {
        final set1 = WeightedWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          weight: Weight(100.0),
          reps: 10,
        );

        final set2 = WeightedWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          weight: Weight(120.0),
          reps: 10,
        );

        expect(set1, isNot(set2));
      });

      test('two sets with different reps are not equal', () {
        final set1 = WeightedWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          weight: Weight(100.0),
          reps: 10,
        );

        final set2 = WeightedWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          weight: Weight(100.0),
          reps: 8,
        );

        expect(set1, isNot(set2));
      });
    });

    group('hashCode', () {
      test('same values produce same hashCode', () {
        final set1 = WeightedWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          weight: Weight(100.0),
          reps: 10,
        );

        final set2 = WeightedWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          weight: Weight(100.0),
          reps: 10,
        );

        expect(set1.hashCode, set2.hashCode);
      });

      test('different weights produce different hashCode', () {
        final set1 = WeightedWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          weight: Weight(100.0),
          reps: 10,
        );

        final set2 = WeightedWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          weight: Weight(120.0),
          reps: 10,
        );

        expect(set1.hashCode, isNot(set2.hashCode));
      });
    });

    group('serialization round-trip', () {
      test('deserialize(serialize(set)) equals original', () {
        final set = WeightedWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          weight: Weight(100.0),
          reps: 10,
        );

        final json = set.toJson();
        final deserialized = WeightedWorkoutSet.fromJson(json);

        expect(deserialized, set);
      });

      test('handles decimal weights in round-trip', () {
        final set = WeightedWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          weight: Weight(62.5),
          reps: 8,
        );

        final json = set.toJson();
        final deserialized = WeightedWorkoutSet.fromJson(json);

        expect(deserialized.weight.kg, 62.5);
        expect(deserialized.getVolume(), 500.0);
      });
    });
  });
}
