import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/personal_records/reps_pr.dart';

void main() {
  group('RepsPR', () {
    final testAchievedDate = DateTime(2024, 1, 1, 12, 0);

    group('constructor', () {
      test('creates RepsPR with all required fields', () {
        final pr = RepsPR(
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
    });

    group('toJson', () {
      test('serializes to JSON with correct type', () {
        final pr = RepsPR(
          id: '1',
          exerciseId: 'exercise1',
          workoutSetId: 'set1',
          achievedAt: testAchievedDate,
        );

        final json = pr.toJson();

        expect(json['type'], 'reps');
        expect(json['id'], '1');
      });
    });

    group('fromJson', () {
      test('deserializes from JSON correctly', () {
        final json = {
          'id': '1',
          'exerciseId': 'exercise1',
          'workoutSetId': 'set1',
          'achievedAt': testAchievedDate.toIso8601String(),
          'type': 'reps',
        };

        final pr = RepsPR.fromJson(json);

        expect(pr.id, '1');
        expect(pr.exerciseId, 'exercise1');
      });
    });

    group('equality', () {
      test('two PRs with same values are equal', () {
        final pr1 = RepsPR(
          id: '1',
          exerciseId: 'exercise1',
          workoutSetId: 'set1',
          achievedAt: testAchievedDate,
        );

        final pr2 = RepsPR(
          id: '1',
          exerciseId: 'exercise1',
          workoutSetId: 'set1',
          achievedAt: testAchievedDate,
        );

        expect(pr1, pr2);
      });
    });

    group('serialization round-trip', () {
      test('deserialize(serialize(pr)) equals original', () {
        final pr = RepsPR(
          id: '1',
          exerciseId: 'exercise1',
          workoutSetId: 'set1',
          achievedAt: testAchievedDate,
        );

        final json = pr.toJson();
        final deserialized = RepsPR.fromJson(json);

        expect(deserialized, pr);
      });
    });
  });
}
