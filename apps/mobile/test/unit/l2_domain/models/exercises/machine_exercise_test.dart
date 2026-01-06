import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/exercises/machine_exercise.dart';
import 'package:phil/l2_domain/models/common/muscle_group.dart';

void main() {
  group('MachineExercise', () {
    group('constructor', () {
      test('creates MachineExercise with all required fields', () {
        final exercise = MachineExercise(
          id: '1',
          name: 'Leg Press',
          description: 'Machine leg exercise',
          isCustom: false,
          targetMuscles: [MuscleGroup.legs],
        );

        expect(exercise.id, '1');
        expect(exercise.name, 'Leg Press');
        expect(exercise.description, 'Machine leg exercise');
        expect(exercise.isCustom, false);
        expect(exercise.targetMuscles, [MuscleGroup.legs]);
      });

      test('creates custom MachineExercise', () {
        final exercise = MachineExercise(
          id: '1',
          name: 'Custom Machine',
          description: 'Custom machine exercise',
          isCustom: true,
          targetMuscles: [MuscleGroup.back],
        );

        expect(exercise.isCustom, true);
      });

      test('creates MachineExercise with multiple target muscles', () {
        final exercise = MachineExercise(
          id: '1',
          name: 'Chest Press Machine',
          description: 'Chest machine',
          isCustom: false,
          targetMuscles: [
            MuscleGroup.chest,
            MuscleGroup.shoulders,
            MuscleGroup.arms,
          ],
        );

        expect(exercise.targetMuscles.length, 3);
      });
    });

    group('toJson', () {
      test('serializes to JSON correctly', () {
        final exercise = MachineExercise(
          id: '1',
          name: 'Lat Pulldown',
          description: 'Back machine exercise',
          isCustom: false,
          targetMuscles: [MuscleGroup.back, MuscleGroup.arms],
        );

        final json = exercise.toJson();

        expect(json['id'], '1');
        expect(json['name'], 'Lat Pulldown');
        expect(json['description'], 'Back machine exercise');
        expect(json['isCustom'], false);
        expect(json['type'], 'machine');
        expect(json['targetMuscles'], ['back', 'arms']);
      });
    });

    group('fromJson', () {
      test('deserializes from JSON correctly', () {
        final json = {
          'id': '1',
          'name': 'Cable Fly',
          'description': 'Chest cable machine',
          'isCustom': false,
          'type': 'machine',
          'targetMuscles': ['chest'],
        };

        final exercise = MachineExercise.fromJson(json);

        expect(exercise.id, '1');
        expect(exercise.name, 'Cable Fly');
        expect(exercise.description, 'Chest cable machine');
        expect(exercise.isCustom, false);
        expect(exercise.targetMuscles, [MuscleGroup.chest]);
      });
    });

    group('copyWith', () {
      test('returns new instance with updated fields', () {
        final exercise = MachineExercise(
          id: '1',
          name: 'Leg Extension',
          description: 'Quad isolation',
          isCustom: false,
          targetMuscles: [MuscleGroup.legs],
        );

        final updated = exercise.copyWith(
          name: 'Leg Curl',
          description: 'Hamstring isolation',
        );

        expect(updated.name, 'Leg Curl');
        expect(updated.description, 'Hamstring isolation');
        expect(exercise.name, 'Leg Extension');
      });
    });

    group('equality', () {
      test('two exercises with same values are equal', () {
        final exercise1 = MachineExercise(
          id: '1',
          name: 'Seated Row',
          description: 'Back machine',
          isCustom: false,
          targetMuscles: [MuscleGroup.back],
        );

        final exercise2 = MachineExercise(
          id: '1',
          name: 'Seated Row',
          description: 'Back machine',
          isCustom: false,
          targetMuscles: [MuscleGroup.back],
        );

        expect(exercise1, exercise2);
      });

      test('two exercises with different names are not equal', () {
        final exercise1 = MachineExercise(
          id: '1',
          name: 'Exercise 1',
          description: 'Description',
          isCustom: false,
          targetMuscles: [MuscleGroup.chest],
        );

        final exercise2 = MachineExercise(
          id: '1',
          name: 'Exercise 2',
          description: 'Description',
          isCustom: false,
          targetMuscles: [MuscleGroup.chest],
        );

        expect(exercise1, isNot(exercise2));
      });
    });

    group('serialization round-trip', () {
      test('deserialize(serialize(exercise)) equals original', () {
        final exercise = MachineExercise(
          id: '1',
          name: 'Smith Machine Squat',
          description: 'Guided squat machine',
          isCustom: false,
          targetMuscles: [MuscleGroup.legs, MuscleGroup.core],
        );

        final json = exercise.toJson();
        final deserialized = MachineExercise.fromJson(json);

        expect(deserialized, exercise);
      });
    });
  });
}
