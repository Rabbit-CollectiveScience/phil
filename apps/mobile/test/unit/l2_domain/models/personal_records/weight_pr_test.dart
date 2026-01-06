import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/personal_records/weight_pr.dart';

void main() {
  group('WeightPR', () {
    final testAchievedDate = DateTime(2024, 1, 1, 12, 0);

    group('constructor', () {
      test('creates WeightPR with all required fields', () {
        final pr = WeightPR(
          id: '1',
          exerciseId: 'exercise1',
          workoutSetId: 'set1',
          achievedAt: testAchievedDate,
        );

        expect(pr.id, '1');
        expect(pr.exerciseId, 'exercise1');
        expect(pr.workoutSetId, 'set1');
        expect(pr.achievedAt, testAchievedDate);
      });

      test('creates WeightPR with current timestamp', () {
        final now = DateTime.now();
        final pr = WeightPR(
          id: '1',
          exerciseId: 'exercise1',
          workoutSetId: 'set1',
          achievedAt: now,
        );

        expect(pr.achievedAt.difference(now).inSeconds, lessThan(1));
      });

      test('creates WeightPR with old date', () {
        final oldDate = DateTime(2020, 1, 1);
        final pr = WeightPR(
          id: '1',
          exerciseId: 'exercise1',
          workoutSetId: 'set1',
          achievedAt: oldDate,
        );

        expect(pr.achievedAt, oldDate);
      });
    });

    group('toJson', () {
      test('serializes to JSON correctly', () {
        final pr = WeightPR(
          id: '1',
          exerciseId: 'exercise1',
          workoutSetId: 'set1',
          achievedAt: testAchievedDate,
        );

        final json = pr.toJson();

        expect(json['id'], '1');
        expect(json['exerciseId'], 'exercise1');
        expect(json['workoutSetId'], 'set1');
        expect(json['achievedAt'], testAchievedDate.toIso8601String());
        expect(json['type'], 'weight');
      });

      test('serializes with correct type discriminator', () {
        final pr = WeightPR(
          id: '1',
          exerciseId: 'exercise1',
          workoutSetId: 'set1',
          achievedAt: testAchievedDate,
        );

        final json = pr.toJson();

        expect(json['type'], 'weight');
      });
    });

    group('fromJson', () {
      test('deserializes from JSON correctly', () {
        final json = {
          'id': '1',
          'exerciseId': 'exercise1',
          'workoutSetId': 'set1',
          'achievedAt': testAchievedDate.toIso8601String(),
          'type': 'weight',
        };

        final pr = WeightPR.fromJson(json);

        expect(pr.id, '1');
        expect(pr.exerciseId, 'exercise1');
        expect(pr.workoutSetId, 'set1');
        expect(pr.achievedAt, testAchievedDate);
      });

      test('handles ISO string timestamp correctly', () {
        final json = {
          'id': '1',
          'exerciseId': 'exercise1',
          'workoutSetId': 'set1',
          'achievedAt': '2024-06-15T14:30:00.000Z',
          'type': 'weight',
        };

        final pr = WeightPR.fromJson(json);

        expect(pr.achievedAt.year, 2024);
        expect(pr.achievedAt.month, 6);
        expect(pr.achievedAt.day, 15);
      });
    });

    group('copyWith', () {
      test('returns new instance with updated fields', () {
        final pr = WeightPR(
          id: '1',
          exerciseId: 'exercise1',
          workoutSetId: 'set1',
          achievedAt: testAchievedDate,
        );

        final newDate = DateTime(2024, 2, 1);
        final updated = pr.copyWith(workoutSetId: 'set2', achievedAt: newDate);

        expect(updated.workoutSetId, 'set2');
        expect(updated.achievedAt, newDate);
        expect(updated.id, '1');
        expect(pr.workoutSetId, 'set1');
        expect(pr.achievedAt, testAchievedDate);
      });

      test('returns new instance with no changes when no params provided', () {
        final pr = WeightPR(
          id: '1',
          exerciseId: 'exercise1',
          workoutSetId: 'set1',
          achievedAt: testAchievedDate,
        );

        final updated = pr.copyWith();

        expect(updated.id, pr.id);
        expect(updated.exerciseId, pr.exerciseId);
        expect(updated.workoutSetId, pr.workoutSetId);
        expect(updated.achievedAt, pr.achievedAt);
      });
    });

    group('equality', () {
      test('two PRs with same values are equal', () {
        final pr1 = WeightPR(
          id: '1',
          exerciseId: 'exercise1',
          workoutSetId: 'set1',
          achievedAt: testAchievedDate,
        );

        final pr2 = WeightPR(
          id: '1',
          exerciseId: 'exercise1',
          workoutSetId: 'set1',
          achievedAt: testAchievedDate,
        );

        expect(pr1, pr2);
      });

      test('two PRs with different ids are not equal', () {
        final pr1 = WeightPR(
          id: '1',
          exerciseId: 'exercise1',
          workoutSetId: 'set1',
          achievedAt: testAchievedDate,
        );

        final pr2 = WeightPR(
          id: '2',
          exerciseId: 'exercise1',
          workoutSetId: 'set1',
          achievedAt: testAchievedDate,
        );

        expect(pr1, isNot(pr2));
      });

      test('two PRs with different workoutSetIds are not equal', () {
        final pr1 = WeightPR(
          id: '1',
          exerciseId: 'exercise1',
          workoutSetId: 'set1',
          achievedAt: testAchievedDate,
        );

        final pr2 = WeightPR(
          id: '1',
          exerciseId: 'exercise1',
          workoutSetId: 'set2',
          achievedAt: testAchievedDate,
        );

        expect(pr1, isNot(pr2));
      });

      test('two PRs with different achievedAt are not equal', () {
        final pr1 = WeightPR(
          id: '1',
          exerciseId: 'exercise1',
          workoutSetId: 'set1',
          achievedAt: testAchievedDate,
        );

        final pr2 = WeightPR(
          id: '1',
          exerciseId: 'exercise1',
          workoutSetId: 'set1',
          achievedAt: DateTime(2024, 2, 1),
        );

        expect(pr1, isNot(pr2));
      });
    });

    group('hashCode', () {
      test('same values produce same hashCode', () {
        final pr1 = WeightPR(
          id: '1',
          exerciseId: 'exercise1',
          workoutSetId: 'set1',
          achievedAt: testAchievedDate,
        );

        final pr2 = WeightPR(
          id: '1',
          exerciseId: 'exercise1',
          workoutSetId: 'set1',
          achievedAt: testAchievedDate,
        );

        expect(pr1.hashCode, pr2.hashCode);
      });

      test('different ids produce different hashCode', () {
        final pr1 = WeightPR(
          id: '1',
          exerciseId: 'exercise1',
          workoutSetId: 'set1',
          achievedAt: testAchievedDate,
        );

        final pr2 = WeightPR(
          id: '2',
          exerciseId: 'exercise1',
          workoutSetId: 'set1',
          achievedAt: testAchievedDate,
        );

        expect(pr1.hashCode, isNot(pr2.hashCode));
      });
    });

    group('serialization round-trip', () {
      test('deserialize(serialize(pr)) equals original', () {
        final pr = WeightPR(
          id: '1',
          exerciseId: 'exercise1',
          workoutSetId: 'set1',
          achievedAt: testAchievedDate,
        );

        final json = pr.toJson();
        final deserialized = WeightPR.fromJson(json);

        expect(deserialized, pr);
      });
    });

    group('reference-only behavior', () {
      test('PR does not store cached weight value', () {
        final pr = WeightPR(
          id: '1',
          exerciseId: 'exercise1',
          workoutSetId: 'set1',
          achievedAt: testAchievedDate,
        );

        final json = pr.toJson();

        // Should not have a 'value' field - it's reference-only
        expect(json.containsKey('value'), isFalse);
        expect(json.containsKey('weight'), isFalse);
      });

      test('workoutSetId should reference the actual set', () {
        final pr = WeightPR(
          id: '1',
          exerciseId: 'exercise1',
          workoutSetId: 'set123',
          achievedAt: testAchievedDate,
        );

        expect(pr.workoutSetId, 'set123');
      });
    });
  });
}
