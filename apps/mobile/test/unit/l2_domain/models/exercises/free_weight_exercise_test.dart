import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/exercises/free_weight_exercise.dart';
import 'package:phil/l2_domain/models/common/muscle_group.dart';

void main() {
  group('FreeWeightExercise', () {
    group('constructor', () {
      test('creates FreeWeightExercise with all required fields', () {
        final exercise = FreeWeightExercise(
          id: '1',
          name: 'Barbell Bench Press',
          description: 'Compound chest exercise',
          isCustom: false,
          targetMuscles: [
            MuscleGroup.chest,
            MuscleGroup.shoulders,
            MuscleGroup.arms,
          ],
        );

        expect(exercise.id, '1');
        expect(exercise.name, 'Barbell Bench Press');
        expect(exercise.description, 'Compound chest exercise');
        expect(exercise.isCustom, false);
        expect(exercise.targetMuscles, [
          MuscleGroup.chest,
          MuscleGroup.shoulders,
          MuscleGroup.arms,
        ]);
      });

      test('creates custom FreeWeightExercise', () {
        final exercise = FreeWeightExercise(
          id: '1',
          name: 'Custom Dumbbell Exercise',
          description: 'My custom exercise',
          isCustom: true,
          targetMuscles: [MuscleGroup.back],
        );

        expect(exercise.isCustom, true);
      });

      test('creates FreeWeightExercise with single target muscle', () {
        final exercise = FreeWeightExercise(
          id: '1',
          name: 'Bicep Curl',
          description: 'Arm isolation',
          isCustom: false,
          targetMuscles: [MuscleGroup.arms],
        );

        expect(exercise.targetMuscles.length, 1);
      });

      test('creates FreeWeightExercise with empty description', () {
        final exercise = FreeWeightExercise(
          id: '1',
          name: 'Exercise',
          description: '',
          isCustom: false,
          targetMuscles: [MuscleGroup.legs],
        );

        expect(exercise.description, '');
      });
    });

    group('toJson', () {
      test('serializes to JSON correctly', () {
        final exercise = FreeWeightExercise(
          id: '1',
          name: 'Dumbbell Press',
          description: 'Shoulder exercise',
          isCustom: false,
          targetMuscles: [MuscleGroup.shoulders, MuscleGroup.arms],
        );

        final json = exercise.toJson();

        expect(json['id'], '1');
        expect(json['name'], 'Dumbbell Press');
        expect(json['description'], 'Shoulder exercise');
        expect(json['isCustom'], false);
        expect(json['type'], 'freeWeight');
        expect(json['targetMuscles'], ['shoulders', 'arms']);
      });

      test('serializes custom exercise to JSON', () {
        final exercise = FreeWeightExercise(
          id: '1',
          name: 'Custom',
          description: 'Custom description',
          isCustom: true,
          targetMuscles: [MuscleGroup.back],
        );

        final json = exercise.toJson();

        expect(json['isCustom'], true);
      });
    });

    group('fromJson', () {
      test('deserializes from JSON correctly', () {
        final json = {
          'id': '1',
          'name': 'Barbell Row',
          'description': 'Back compound exercise',
          'isCustom': false,
          'type': 'freeWeight',
          'targetMuscles': ['back', 'arms'],
        };

        final exercise = FreeWeightExercise.fromJson(json);

        expect(exercise.id, '1');
        expect(exercise.name, 'Barbell Row');
        expect(exercise.description, 'Back compound exercise');
        expect(exercise.isCustom, false);
        expect(exercise.targetMuscles, [MuscleGroup.back, MuscleGroup.arms]);
      });
    });

    group('copyWith', () {
      test('returns new instance with updated fields', () {
        final exercise = FreeWeightExercise(
          id: '1',
          name: 'Squat',
          description: 'Leg exercise',
          isCustom: false,
          targetMuscles: [MuscleGroup.legs],
        );

        final updated = exercise.copyWith(
          name: 'Front Squat',
          targetMuscles: [MuscleGroup.legs, MuscleGroup.core],
        );

        expect(updated.name, 'Front Squat');
        expect(updated.targetMuscles, [MuscleGroup.legs, MuscleGroup.core]);
        expect(exercise.name, 'Squat');
      });
    });

    group('equality', () {
      test('two exercises with same values are equal', () {
        final exercise1 = FreeWeightExercise(
          id: '1',
          name: 'Deadlift',
          description: 'Compound back exercise',
          isCustom: false,
          targetMuscles: [MuscleGroup.back, MuscleGroup.legs],
        );

        final exercise2 = FreeWeightExercise(
          id: '1',
          name: 'Deadlift',
          description: 'Compound back exercise',
          isCustom: false,
          targetMuscles: [MuscleGroup.back, MuscleGroup.legs],
        );

        expect(exercise1, exercise2);
      });

      test('two exercises with different ids are not equal', () {
        final exercise1 = FreeWeightExercise(
          id: '1',
          name: 'Exercise',
          description: 'Description',
          isCustom: false,
          targetMuscles: [MuscleGroup.chest],
        );

        final exercise2 = FreeWeightExercise(
          id: '2',
          name: 'Exercise',
          description: 'Description',
          isCustom: false,
          targetMuscles: [MuscleGroup.chest],
        );

        expect(exercise1, isNot(exercise2));
      });
    });

    group('serialization round-trip', () {
      test('deserialize(serialize(exercise)) equals original', () {
        final exercise = FreeWeightExercise(
          id: '1',
          name: 'Overhead Press',
          description: 'Shoulder compound',
          isCustom: false,
          targetMuscles: [
            MuscleGroup.shoulders,
            MuscleGroup.arms,
            MuscleGroup.core,
          ],
        );

        final json = exercise.toJson();
        final deserialized = FreeWeightExercise.fromJson(json);

        expect(deserialized, exercise);
      });
    });
  });
}
