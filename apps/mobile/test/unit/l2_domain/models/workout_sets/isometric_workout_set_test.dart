import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/workout_sets/isometric_workout_set.dart';

void main() {
  group('IsometricWorkoutSet', () {
    final testDate = DateTime(2024, 1, 1, 12, 0);

    group('constructor', () {
      test('creates IsometricWorkoutSet with all required fields', () {
        final set = IsometricWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(seconds: 60),
        );

        expect(set.id, '1');
        expect(set.exerciseId, 'exercise1');
        expect(set.timestamp, testDate);
        expect(set.duration, const Duration(seconds: 60));
      });

      test('creates IsometricWorkoutSet with zero duration', () {
        final set = IsometricWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: Duration.zero,
        );

        expect(set.duration, Duration.zero);
      });

      test('creates IsometricWorkoutSet with long duration', () {
        final set = IsometricWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 5, seconds: 30),
        );

        expect(set.duration.inSeconds, 330);
      });

      test('creates IsometricWorkoutSet with milliseconds', () {
        final set = IsometricWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(seconds: 30, milliseconds: 500),
        );

        expect(set.duration.inMilliseconds, 30500);
      });
    });

    group('getVolume', () {
      test('returns null for isometric set', () {
        final set = IsometricWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(seconds: 60),
        );

        expect(set.getVolume(), isNull);
      });

      test('returns null even for long duration', () {
        final set = IsometricWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 10),
        );

        expect(set.getVolume(), isNull);
      });
    });

    group('toJson', () {
      test('serializes to JSON correctly', () {
        final set = IsometricWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(seconds: 60),
        );

        final json = set.toJson();

        expect(json['id'], '1');
        expect(json['exerciseId'], 'exercise1');
        expect(json['timestamp'], testDate.toIso8601String());
        expect(json['type'], 'isometric');
        expect(json['duration'], 60);
      });

      test('serializes duration in seconds', () {
        final set = IsometricWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 2, seconds: 30),
        );

        final json = set.toJson();

        expect(json['duration'], 150);
      });

      test('serializes zero duration', () {
        final set = IsometricWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: Duration.zero,
        );

        final json = set.toJson();

        expect(json['duration'], 0);
      });
    });

    group('fromJson', () {
      test('deserializes from JSON correctly', () {
        final json = {
          'id': '1',
          'exerciseId': 'exercise1',
          'timestamp': testDate.toIso8601String(),
          'type': 'isometric',
          'duration': 60,
        };

        final set = IsometricWorkoutSet.fromJson(json);

        expect(set.id, '1');
        expect(set.exerciseId, 'exercise1');
        expect(set.timestamp, testDate);
        expect(set.duration, const Duration(seconds: 60));
      });

      test('deserializes long duration from JSON', () {
        final json = {
          'id': '1',
          'exerciseId': 'exercise1',
          'timestamp': testDate.toIso8601String(),
          'type': 'isometric',
          'duration': 330,
        };

        final set = IsometricWorkoutSet.fromJson(json);

        expect(set.duration.inSeconds, 330);
        expect(set.duration.inMinutes, 5);
      });
    });

    group('copyWith', () {
      test('returns new instance with updated duration', () {
        final set = IsometricWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(seconds: 60),
        );

        final updated = set.copyWith(duration: const Duration(seconds: 90));

        expect(updated.duration, const Duration(seconds: 90));
        expect(set.duration, const Duration(seconds: 60));
      });

      test('returns new instance with updated timestamp', () {
        final set = IsometricWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(seconds: 60),
        );

        final newDate = DateTime(2024, 1, 2);
        final updated = set.copyWith(timestamp: newDate);

        expect(updated.timestamp, newDate);
        expect(set.timestamp, testDate);
      });

      test('returns new instance with no changes when no params provided', () {
        final set = IsometricWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(seconds: 60),
        );

        final updated = set.copyWith();

        expect(updated.id, set.id);
        expect(updated.duration, set.duration);
      });
    });

    group('equality', () {
      test('two sets with same values are equal', () {
        final set1 = IsometricWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(seconds: 60),
        );

        final set2 = IsometricWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(seconds: 60),
        );

        expect(set1, set2);
      });

      test('two sets with different durations are not equal', () {
        final set1 = IsometricWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(seconds: 60),
        );

        final set2 = IsometricWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(seconds: 90),
        );

        expect(set1, isNot(set2));
      });

      test('two sets with different ids are not equal', () {
        final set1 = IsometricWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(seconds: 60),
        );

        final set2 = IsometricWorkoutSet(
          id: '2',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(seconds: 60),
        );

        expect(set1, isNot(set2));
      });
    });

    group('hashCode', () {
      test('same values produce same hashCode', () {
        final set1 = IsometricWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(seconds: 60),
        );

        final set2 = IsometricWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(seconds: 60),
        );

        expect(set1.hashCode, set2.hashCode);
      });

      test('different durations produce different hashCode', () {
        final set1 = IsometricWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(seconds: 60),
        );

        final set2 = IsometricWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(seconds: 90),
        );

        expect(set1.hashCode, isNot(set2.hashCode));
      });
    });

    group('serialization round-trip', () {
      test('deserialize(serialize(set)) equals original', () {
        final set = IsometricWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(seconds: 60),
        );

        final json = set.toJson();
        final deserialized = IsometricWorkoutSet.fromJson(json);

        expect(deserialized, set);
      });

      test('handles complex duration in round-trip', () {
        final set = IsometricWorkoutSet(
          id: '1',
          exerciseId: 'exercise1',
          timestamp: testDate,
          duration: const Duration(minutes: 5, seconds: 30),
        );

        final json = set.toJson();
        final deserialized = IsometricWorkoutSet.fromJson(json);

        expect(deserialized.duration.inSeconds, 330);
      });
    });
  });
}
