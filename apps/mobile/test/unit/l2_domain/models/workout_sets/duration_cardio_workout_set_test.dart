import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/workout_sets/duration_cardio_workout_set.dart';

void main() {
  group('DurationCardioWorkoutSet', () {
    final testDate = DateTime(2024, 1, 1, 12, 0);

    group('constructor', () {
      test('creates DurationCardioWorkoutSet with all required fields', () {
        final set = DurationCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 45),
        );

        expect(set.id, '1');
        expect(set.exerciseId, 'exercise1');
        expect(set.timestamp, testDate);
        expect(set.duration, const Duration(minutes: 45));
      });

      test('creates set with zero duration', () {
        final set = DurationCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: Duration.zero,
        );

        expect(set.duration, Duration.zero);
      });

      test('creates set with hours', () {
        final set = DurationCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(hours: 2, minutes: 30),
        );

        expect(set.duration.inMinutes, 150);
      });
    });

    group('getVolume', () {
      test('returns null for duration cardio set', () {
        final set = DurationCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 45),
        );

        expect(set.getVolume(), isNull);
      });
    });

    group('toJson', () {
      test('serializes to JSON correctly', () {
        final set = DurationCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 45),
        );

        final json = set.toJson();

        expect(json['id'], '1');
        expect(json['exerciseId'], 'exercise1');
        expect(json['timestamp'], testDate.toIso8601String());
        expect(json['type'], 'duration_cardio');
        expect(json['duration'], 2700);
      });

      test('serializes duration in seconds', () {
        final set = DurationCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(hours: 1, minutes: 15, seconds: 30),
        );

        final json = set.toJson();

        expect(json['duration'], 4530);
      });
    });

    group('fromJson', () {
      test('deserializes from JSON correctly', () {
        final json = {
          'id': '1',
          'exerciseId': 'exercise1',
          'timestamp': testDate.toIso8601String(),
          'type': 'durationCardio',
          'duration': 2700,
        };

        final set = DurationCardioWorkoutSet.fromJson(json);

        expect(set.id, '1');
        expect(set.exerciseId, 'exercise1');
        expect(set.timestamp, testDate);
        expect(set.duration.inSeconds, 2700);
      });
    });

    group('copyWith', () {
      test('returns new instance with updated duration', () {
        final set = DurationCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 45),
        );

        final updated = set.copyWith(duration: const Duration(minutes: 60));

        expect(updated.duration, const Duration(minutes: 60));
        expect(set.duration, const Duration(minutes: 45));
      });

      test('returns new instance with no changes when no params provided', () {
        final set = DurationCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 45),
        );

        final updated = set.copyWith();

        expect(updated.id, set.id);
        expect(updated.duration, set.duration);
      });
    });

    group('equality', () {
      test('two sets with same values are equal', () {
        final set1 = DurationCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 45),
        );

        final set2 = DurationCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 45),
        );

        expect(set1, set2);
      });

      test('two sets with different durations are not equal', () {
        final set1 = DurationCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 45),
        );

        final set2 = DurationCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 60),
        );

        expect(set1, isNot(set2));
      });
    });

    group('hashCode', () {
      test('same values produce same hashCode', () {
        final set1 = DurationCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 45),
        );

        final set2 = DurationCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 45),
        );

        expect(set1.hashCode, set2.hashCode);
      });

      test('different durations produce different hashCode', () {
        final set1 = DurationCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 45),
        );

        final set2 = DurationCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 60),
        );

        expect(set1.hashCode, isNot(set2.hashCode));
      });
    });

    group('serialization round-trip', () {
      test('deserialize(serialize(set)) equals original', () {
        final set = DurationCardioWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(hours: 1, minutes: 23, seconds: 45),
        );

        final json = set.toJson();
        final deserialized = DurationCardioWorkoutSet.fromJson(json);

        expect(deserialized, set);
      });
    });
  });
}
