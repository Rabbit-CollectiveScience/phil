import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/personal_record.dart';

void main() {
  group('PersonalRecord Model', () {
    group('Construction', () {
      test('should create a valid PersonalRecord instance', () {
        final pr = PersonalRecord(
          id: 'pr_1',
          exerciseId: 'bench_press',
          type: 'maxWeight',
          value: 100.0,
          achievedAt: DateTime(2026, 1, 2),
        );

        expect(pr.id, equals('pr_1'));
        expect(pr.exerciseId, equals('bench_press'));
        expect(pr.type, equals('maxWeight'));
        expect(pr.value, equals(100.0));
        expect(pr.achievedAt, equals(DateTime(2026, 1, 2)));
      });

      test('should create a maxReps PR', () {
        final pr = PersonalRecord(
          id: 'pr_2',
          exerciseId: 'push_ups',
          type: 'maxReps',
          value: 50.0,
          achievedAt: DateTime(2026, 1, 2),
        );

        expect(pr.type, equals('maxReps'));
        expect(pr.value, equals(50.0));
      });

      test('should create a maxVolume PR', () {
        final pr = PersonalRecord(
          id: 'pr_3',
          exerciseId: 'bench_press',
          type: 'maxVolume',
          value: 2700.0,
          achievedAt: DateTime(2026, 1, 2),
        );

        expect(pr.type, equals('maxVolume'));
        expect(pr.value, equals(2700.0));
      });
    });

    group('JSON Serialization', () {
      test('should convert to JSON correctly', () {
        final pr = PersonalRecord(
          id: 'pr_1',
          exerciseId: 'bench_press',
          type: 'maxWeight',
          value: 100.0,
          achievedAt: DateTime(2026, 1, 2, 10, 30),
        );

        final json = pr.toJson();

        expect(json['id'], equals('pr_1'));
        expect(json['exerciseId'], equals('bench_press'));
        expect(json['type'], equals('maxWeight'));
        expect(json['value'], equals(100.0));
        expect(json['achievedAt'], isA<String>());
      });

      test('should create from JSON correctly', () {
        final json = {
          'id': 'pr_1',
          'exerciseId': 'bench_press',
          'type': 'maxWeight',
          'value': 100.0,
          'achievedAt': '2026-01-02T10:30:00.000',
        };

        final pr = PersonalRecord.fromJson(json);

        expect(pr.id, equals('pr_1'));
        expect(pr.exerciseId, equals('bench_press'));
        expect(pr.type, equals('maxWeight'));
        expect(pr.value, equals(100.0));
        expect(pr.achievedAt, equals(DateTime(2026, 1, 2, 10, 30)));
      });

      test('should handle maxReps type in JSON', () {
        final json = {
          'id': 'pr_2',
          'exerciseId': 'push_ups',
          'type': 'maxReps',
          'value': 50.0,
          'achievedAt': '2026-01-02T10:30:00.000',
        };

        final pr = PersonalRecord.fromJson(json);

        expect(pr.type, equals('maxReps'));
      });

      test('should handle maxVolume type in JSON', () {
        final json = {
          'id': 'pr_3',
          'exerciseId': 'bench_press',
          'type': 'maxVolume',
          'value': 2700.0,
          'achievedAt': '2026-01-02T10:30:00.000',
        };

        final pr = PersonalRecord.fromJson(json);

        expect(pr.type, equals('maxVolume'));
      });

      test('should round-trip through JSON correctly', () {
        final original = PersonalRecord(
          id: 'pr_1',
          exerciseId: 'squat',
          type: 'maxWeight',
          value: 150.5,
          achievedAt: DateTime(2026, 1, 2, 15, 45, 30),
        );

        final json = original.toJson();
        final restored = PersonalRecord.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.exerciseId, equals(original.exerciseId));
        expect(restored.type, equals(original.type));
        expect(restored.value, equals(original.value));
        expect(restored.achievedAt, equals(original.achievedAt));
      });
    });

    group('Equality', () {
      test('should be equal when all properties match', () {
        final pr1 = PersonalRecord(
          id: 'pr_1',
          exerciseId: 'bench_press',
          type: 'maxWeight',
          value: 100.0,
          achievedAt: DateTime(2026, 1, 2),
        );

        final pr2 = PersonalRecord(
          id: 'pr_1',
          exerciseId: 'bench_press',
          type: 'maxWeight',
          value: 100.0,
          achievedAt: DateTime(2026, 1, 2),
        );

        expect(pr1, equals(pr2));
        expect(pr1.hashCode, equals(pr2.hashCode));
      });

      test('should not be equal when id differs', () {
        final pr1 = PersonalRecord(
          id: 'pr_1',
          exerciseId: 'bench_press',
          type: 'maxWeight',
          value: 100.0,
          achievedAt: DateTime(2026, 1, 2),
        );

        final pr2 = PersonalRecord(
          id: 'pr_2',
          exerciseId: 'bench_press',
          type: 'maxWeight',
          value: 100.0,
          achievedAt: DateTime(2026, 1, 2),
        );

        expect(pr1, isNot(equals(pr2)));
      });

      test('should not be equal when value differs', () {
        final pr1 = PersonalRecord(
          id: 'pr_1',
          exerciseId: 'bench_press',
          type: 'maxWeight',
          value: 100.0,
          achievedAt: DateTime(2026, 1, 2),
        );

        final pr2 = PersonalRecord(
          id: 'pr_1',
          exerciseId: 'bench_press',
          type: 'maxWeight',
          value: 105.0,
          achievedAt: DateTime(2026, 1, 2),
        );

        expect(pr1, isNot(equals(pr2)));
      });
    });

    group('Validation', () {
      test('should accept positive values', () {
        expect(
          () => PersonalRecord(
            id: 'pr_1',
            exerciseId: 'bench_press',
            type: 'maxWeight',
            value: 100.0,
            achievedAt: DateTime(2026, 1, 2),
          ),
          returnsNormally,
        );
      });

      test('should accept zero value', () {
        expect(
          () => PersonalRecord(
            id: 'pr_1',
            exerciseId: 'bench_press',
            type: 'maxWeight',
            value: 0.0,
            achievedAt: DateTime(2026, 1, 2),
          ),
          returnsNormally,
        );
      });

      test('should accept decimal values', () {
        final pr = PersonalRecord(
          id: 'pr_1',
          exerciseId: 'bench_press',
          type: 'maxWeight',
          value: 102.5,
          achievedAt: DateTime(2026, 1, 2),
        );

        expect(pr.value, equals(102.5));
      });
    });

    group('Edge Cases', () {
      test('should handle very large values', () {
        final pr = PersonalRecord(
          id: 'pr_1',
          exerciseId: 'deadlift',
          type: 'maxWeight',
          value: 999999.99,
          achievedAt: DateTime(2026, 1, 2),
        );

        expect(pr.value, equals(999999.99));
      });

      test('should handle exerciseId with special characters', () {
        final pr = PersonalRecord(
          id: 'pr_1',
          exerciseId: 'exercise_with_underscores_and_123',
          type: 'maxWeight',
          value: 100.0,
          achievedAt: DateTime(2026, 1, 2),
        );

        expect(pr.exerciseId, equals('exercise_with_underscores_and_123'));
      });

      test('should handle dates with time components', () {
        final dateTime = DateTime(2026, 1, 2, 14, 30, 45, 123);
        final pr = PersonalRecord(
          id: 'pr_1',
          exerciseId: 'bench_press',
          type: 'maxWeight',
          value: 100.0,
          achievedAt: dateTime,
        );

        expect(pr.achievedAt, equals(dateTime));
      });
    });
  });
}
