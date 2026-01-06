import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/personal_records/volume_pr.dart';

void main() {
  group('VolumePR', () {
    final testAchievedDate = DateTime(2024, 1, 1, 12, 0);

    group('constructor', () {
      test('creates VolumePR with all required fields', () {
        final pr = VolumePR(
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
        final pr = VolumePR(
          id: '1',
          exerciseId: 'exercise1',
          workoutSetId: 'set1',
          achievedAt: testAchievedDate,
        );

        final json = pr.toJson();

        expect(json['type'], 'volume');
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
          'type': 'volume',
        };

        final pr = VolumePR.fromJson(json);

        expect(pr.id, '1');
        expect(pr.exerciseId, 'exercise1');
      });
    });

    group('equality', () {
      test('two PRs with same values are equal', () {
        final pr1 = VolumePR(
          id: '1',
          exerciseId: 'exercise1',
          workoutSetId: 'set1',
          achievedAt: testAchievedDate,
        );

        final pr2 = VolumePR(
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
        final pr = VolumePR(
          id: '1',
          exerciseId: 'exercise1',
          workoutSetId: 'set1',
          achievedAt: testAchievedDate,
        );

        final json = pr.toJson();
        final deserialized = VolumePR.fromJson(json);

        expect(deserialized, pr);
      });
    });
  });
}
