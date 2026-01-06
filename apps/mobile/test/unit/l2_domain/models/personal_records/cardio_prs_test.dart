import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/personal_records/duration_pr.dart';
import 'package:phil/l2_domain/models/personal_records/distance_pr.dart';
import 'package:phil/l2_domain/models/personal_records/pace_pr.dart';

void main() {
  final testAchievedDate = DateTime(2024, 1, 1, 12, 0);

  group('DurationPR', () {
    test('creates and serializes DurationPR correctly', () {
      final pr = DurationPR(
        id: '1',
        exerciseId: 'exercise1',
        workoutSetId: 'set1',
        achievedAt: testAchievedDate,
      );

      expect(pr.id, '1');
      expect(pr.toJson()['type'], 'duration');
    });

    test('deserializes from JSON', () {
      final json = {
        'id': '1',
        'exerciseId': 'exercise1',
        'workoutSetId': 'set1',
        'achievedAt': testAchievedDate.toIso8601String(),
        'type': 'duration',
      };

      final pr = DurationPR.fromJson(json);
      expect(pr.id, '1');
    });

    test('serialization round-trip', () {
      final pr = DurationPR(
        id: '1',
        exerciseId: 'exercise1',
        workoutSetId: 'set1',
        achievedAt: testAchievedDate,
      );

      final json = pr.toJson();
      final deserialized = DurationPR.fromJson(json);
      expect(deserialized, pr);
    });
  });

  group('DistancePR', () {
    test('creates and serializes DistancePR correctly', () {
      final pr = DistancePR(
        id: '1',
        exerciseId: 'exercise1',
        workoutSetId: 'set1',
        achievedAt: testAchievedDate,
      );

      expect(pr.id, '1');
      expect(pr.toJson()['type'], 'distance');
    });

    test('deserializes from JSON', () {
      final json = {
        'id': '1',
        'exerciseId': 'exercise1',
        'workoutSetId': 'set1',
        'achievedAt': testAchievedDate.toIso8601String(),
        'type': 'distance',
      };

      final pr = DistancePR.fromJson(json);
      expect(pr.id, '1');
    });

    test('serialization round-trip', () {
      final pr = DistancePR(
        id: '1',
        exerciseId: 'exercise1',
        workoutSetId: 'set1',
        achievedAt: testAchievedDate,
      );

      final json = pr.toJson();
      final deserialized = DistancePR.fromJson(json);
      expect(deserialized, pr);
    });
  });

  group('PacePR', () {
    test('creates and serializes PacePR correctly', () {
      final pr = PacePR(
        id: '1',
        exerciseId: 'exercise1',
        workoutSetId: 'set1',
        achievedAt: testAchievedDate,
      );

      expect(pr.id, '1');
      expect(pr.toJson()['type'], 'pace');
    });

    test('deserializes from JSON', () {
      final json = {
        'id': '1',
        'exerciseId': 'exercise1',
        'workoutSetId': 'set1',
        'achievedAt': testAchievedDate.toIso8601String(),
        'type': 'pace',
      };

      final pr = PacePR.fromJson(json);
      expect(pr.id, '1');
    });

    test('serialization round-trip', () {
      final pr = PacePR(
        id: '1',
        exerciseId: 'exercise1',
        workoutSetId: 'set1',
        achievedAt: testAchievedDate,
      );

      final json = pr.toJson();
      final deserialized = PacePR.fromJson(json);
      expect(deserialized, pr);
    });
  });
}
