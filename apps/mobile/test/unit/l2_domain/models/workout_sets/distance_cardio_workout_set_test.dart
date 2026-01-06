import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/workout_sets/distance_cardio_workout_set.dart';
import 'package:phil/l2_domain/models/common/distance.dart';

void main() {
  group('DistanceCardioWorkoutSet', () {
    final testDate = DateTime(2024, 1, 1, 12, 0);

    group('constructor', () {
      test('creates DistanceCardioWorkoutSet with all required fields', () {
        final set = DistanceCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 30),
          distance: Distance(5000.0),
        );

        expect(set.id, '1');
        expect(set.exerciseId, 'exercise1');
        expect(set.timestamp, testDate);
        expect(set.duration, const Duration(minutes: 30));
        expect(set.distance.meters, 5000.0);
      });

      test('creates set with zero duration', () {
        final set = DistanceCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: Duration.zero,
          distance: Distance(5000.0),
        );

        expect(set.duration, Duration.zero);
      });

      test('creates set with zero distance', () {
        final set = DistanceCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 30),
          distance: Distance(0.0),
        );

        expect(set.distance.meters, 0.0);
      });
    });

    group('getPace', () {
      test('calculates pace correctly in minutes per km', () {
        final set = DistanceCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 25),
          distance: Distance(5000.0),
        );

        expect(set.getPace(), closeTo(5.0, 0.01));
      });

      test('calculates pace for 1 km distance', () {
        final set = DistanceCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 5, seconds: 30),
          distance: Distance(1000.0),
        );

        expect(set.getPace(), closeTo(5.5, 0.01));
      });

      test('returns 0 pace for zero distance', () {
        final set = DistanceCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 30),
          distance: Distance(0.0),
        );

        expect(set.getPace(), 0.0);
      });

      test('returns very large pace for very small distance', () {
        final set = DistanceCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 30),
          distance: Distance(10.0),
        );

        expect(set.getPace(), greaterThan(1000.0));
      });

      test('calculates pace for marathon', () {
        final set = DistanceCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(hours: 4, minutes: 30),
          distance: Distance(42195.0),
        );

        expect(set.getPace(), closeTo(6.4, 0.1));
      });
    });

    group('getVolume', () {
      test('returns null for cardio set', () {
        final set = DistanceCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 30),
          distance: Distance(5000.0),
        );

        expect(set.getVolume(), isNull);
      });
    });

    group('toJson', () {
      test('serializes to JSON correctly', () {
        final set = DistanceCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 30),
          distance: Distance(5000.0),
        );

        final json = set.toJson();

        expect(json['id'], '1');
        expect(json['exerciseId'], 'exercise1');
        expect(json['timestamp'], testDate.toIso8601String());
        expect(json['type'], 'distance_cardio');
        expect(json['duration'], 1800);
        expect(json['distance'], {'meters': 5000.0});
      });
    });

    group('fromJson', () {
      test('deserializes from JSON correctly', () {
        final json = {
          'id': '1',
          'exerciseId': 'exercise1',
          'timestamp': testDate.toIso8601String(),
          'type': 'distanceCardio',
          'duration': 1800,
          'distance': {'meters': 5000.0},
        };

        final set = DistanceCardioWorkoutSet.fromJson(json);

        expect(set.id, '1');
        expect(set.exerciseId, 'exercise1');
        expect(set.timestamp, testDate);
        expect(set.duration.inSeconds, 1800);
        expect(set.distance.meters, 5000.0);
      });
    });

    group('copyWith', () {
      test('returns new instance with updated fields', () {
        final set = DistanceCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 30),
          distance: Distance(5000.0),
        );

        final updated = set.copyWith(
          duration: const Duration(minutes: 25),
          distance: Distance(6000.0),
        );

        expect(updated.duration, const Duration(minutes: 25));
        expect(updated.distance.meters, 6000.0);
        expect(set.duration, const Duration(minutes: 30));
        expect(set.distance.meters, 5000.0);
      });
    });

    group('equality', () {
      test('two sets with same values are equal', () {
        final set1 = DistanceCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 30),
          distance: Distance(5000.0),
        );

        final set2 = DistanceCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 30),
          distance: Distance(5000.0),
        );

        expect(set1, set2);
      });

      test('two sets with different durations are not equal', () {
        final set1 = DistanceCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 30),
          distance: Distance(5000.0),
        );

        final set2 = DistanceCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 25),
          distance: Distance(5000.0),
        );

        expect(set1, isNot(set2));
      });

      test('two sets with different distances are not equal', () {
        final set1 = DistanceCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 30),
          distance: Distance(5000.0),
        );

        final set2 = DistanceCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 30),
          distance: Distance(6000.0),
        );

        expect(set1, isNot(set2));
      });
    });

    group('serialization round-trip', () {
      test('deserialize(serialize(set)) equals original', () {
        final set = DistanceCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 30, seconds: 45),
          distance: Distance(5234.5),
        );

        final json = set.toJson();
        final deserialized = DistanceCardioWorkoutSet.fromJson(json);

        expect(deserialized, set);
        expect(deserialized.getPace(), closeTo(set.getPace(), 0.01));
      });
    });
  });
}
