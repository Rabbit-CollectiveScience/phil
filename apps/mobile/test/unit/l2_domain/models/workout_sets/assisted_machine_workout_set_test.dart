import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/workout_sets/assisted_machine_workout_set.dart';
import 'package:phil/l2_domain/models/workout_sets/workout_set.dart';
import 'package:phil/l2_domain/models/common/weight.dart';

void main() {
  group('AssistedMachineWorkoutSet', () {
    test('should be a subclass of WorkoutSet', () {
      final set = AssistedMachineWorkoutSet(
        id: 'set_1',
        exerciseId: 'back_13',
        timestamp: DateTime(2026, 1, 15),
        assistanceWeight: const Weight(30),
        reps: 8,
      );

      expect(set, isA<WorkoutSet>());
    });

    test('getVolume should return null (no volume for assisted)', () {
      final set = AssistedMachineWorkoutSet(
        id: 'set_1',
        exerciseId: 'back_13',
        timestamp: DateTime(2026, 1, 15),
        assistanceWeight: const Weight(30),
        reps: 8,
      );

      expect(set.getVolume(), null);
    });

    test('getEffectiveWeight should calculate bodyweight - assistance', () {
      final set = AssistedMachineWorkoutSet(
        id: 'set_1',
        exerciseId: 'back_13',
        timestamp: DateTime(2026, 1, 15),
        assistanceWeight: const Weight(30),
        reps: 8,
      );

      final effectiveWeight = set.getEffectiveWeight(const Weight(80));

      expect(effectiveWeight, 50.0); // 80kg - 30kg = 50kg
    });

    test(
      'getEffectiveWeight should return null if assistanceWeight is null',
      () {
        final set = AssistedMachineWorkoutSet(
          id: 'set_1',
          exerciseId: 'back_13',
          timestamp: DateTime(2026, 1, 15),
          assistanceWeight: null,
          reps: 8,
        );

        final effectiveWeight = set.getEffectiveWeight(const Weight(80));

        expect(effectiveWeight, null);
      },
    );

    test('getEffectiveWeight should return null if userBodyweight is null', () {
      final set = AssistedMachineWorkoutSet(
        id: 'set_1',
        exerciseId: 'back_13',
        timestamp: DateTime(2026, 1, 15),
        assistanceWeight: const Weight(30),
        reps: 8,
      );

      final effectiveWeight = set.getEffectiveWeight(null);

      expect(effectiveWeight, null);
    });

    test('formatForDisplay should show reps and assistance weight', () {
      final set = AssistedMachineWorkoutSet(
        id: 'set_1',
        exerciseId: 'back_13',
        timestamp: DateTime(2026, 1, 15),
        assistanceWeight: const Weight(30),
        reps: 8,
      );

      final display = set.formatForDisplay();

      expect(display, '8 reps · 30.0 assistance');
    });

    test('formatForDisplay should handle null values', () {
      final set = AssistedMachineWorkoutSet(
        id: 'set_1',
        exerciseId: 'back_13',
        timestamp: DateTime(2026, 1, 15),
        assistanceWeight: null,
        reps: null,
      );

      final display = set.formatForDisplay();

      expect(display, '-- rep · -- assistance');
    });

    test('toJson should serialize correctly with assisted_machine type', () {
      final set = AssistedMachineWorkoutSet(
        id: 'set_1',
        exerciseId: 'back_13',
        timestamp: DateTime(2026, 1, 15, 10, 30),
        assistanceWeight: const Weight(30),
        reps: 8,
      );

      final json = set.toJson();

      expect(json['type'], 'assisted_machine');
      expect(json['id'], 'set_1');
      expect(json['exerciseId'], 'back_13');
      expect(json['timestamp'], '2026-01-15T10:30:00.000');
      expect(json['assistanceWeight'], {'kg': 30.0});
      expect(json['reps'], 8);
    });

    test('fromJson should deserialize correctly', () {
      final json = {
        'type': 'assisted_machine',
        'id': 'set_1',
        'exerciseId': 'back_13',
        'timestamp': '2026-01-15T10:30:00.000',
        'assistanceWeight': {'kg': 30.0},
        'reps': 8,
      };

      final set = AssistedMachineWorkoutSet.fromJson(json);

      expect(set.id, 'set_1');
      expect(set.exerciseId, 'back_13');
      expect(set.timestamp, DateTime(2026, 1, 15, 10, 30));
      expect(set.assistanceWeight?.kg, 30.0);
      expect(set.reps, 8);
    });

    test('equality should work correctly', () {
      final set1 = AssistedMachineWorkoutSet(
        id: 'set_1',
        exerciseId: 'back_13',
        timestamp: DateTime(2026, 1, 15),
        assistanceWeight: const Weight(30),
        reps: 8,
      );

      final set2 = AssistedMachineWorkoutSet(
        id: 'set_1',
        exerciseId: 'back_13',
        timestamp: DateTime(2026, 1, 15),
        assistanceWeight: const Weight(30),
        reps: 8,
      );

      final set3 = AssistedMachineWorkoutSet(
        id: 'set_2',
        exerciseId: 'back_13',
        timestamp: DateTime(2026, 1, 15),
        assistanceWeight: const Weight(25),
        reps: 10,
      );

      expect(set1, equals(set2));
      expect(set1, isNot(equals(set3)));
    });

    test('copyWith should create a new instance with updated fields', () {
      final set = AssistedMachineWorkoutSet(
        id: 'set_1',
        exerciseId: 'back_13',
        timestamp: DateTime(2026, 1, 15),
        assistanceWeight: const Weight(30),
        reps: 8,
      );

      final updated = set.copyWith(
        assistanceWeight: const Weight(25),
        reps: 10,
      );

      expect(updated.id, 'set_1');
      expect(updated.exerciseId, 'back_13');
      expect(updated.assistanceWeight?.kg, 25.0);
      expect(updated.reps, 10);
    });
  });
}
