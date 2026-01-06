import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/exercises/isometric_exercise.dart';
import 'package:phil/l2_domain/models/common/muscle_group.dart';

void main() {
  group('IsometricExercise', () {
    group('constructor', () {
      test('creates IsometricExercise with all required fields', () {
        final exercise = IsometricExercise(
          id: '1',
          name: 'Plank',
          description: 'Core stability exercise',
          isCustom: false,
          targetMuscles: [MuscleGroup.core],
        );

        expect(exercise.id, '1');
        expect(exercise.name, 'Plank');
        expect(exercise.description, 'Core stability exercise');
        expect(exercise.isCustom, false);
        expect(exercise.targetMuscles, [MuscleGroup.core]);
      });

      test('creates custom IsometricExercise', () {
        final exercise = IsometricExercise(
          id: '1',
          name: 'Custom Hold',
          description: 'Custom isometric',
          isCustom: true,
          targetMuscles: [MuscleGroup.shoulders],
        );

        expect(exercise.isCustom, true);
      });

      test('creates IsometricExercise with multiple target muscles', () {
        final exercise = IsometricExercise(
          id: '1',
          name: 'Side Plank',
          description: 'Oblique plank',
          isCustom: false,
          targetMuscles: [MuscleGroup.core, MuscleGroup.shoulders],
        );

        expect(exercise.targetMuscles.length, 2);
      });
    });

    group('toJson', () {
      test('serializes to JSON correctly', () {
        final exercise = IsometricExercise(
          id: '1',
          name: 'Wall Sit',
          description: 'Leg isometric',
          isCustom: false,
          targetMuscles: [MuscleGroup.legs],
        );

        final json = exercise.toJson();

        expect(json['id'], '1');
        expect(json['name'], 'Wall Sit');
        expect(json['description'], 'Leg isometric');
        expect(json['isCustom'], false);
        expect(json['type'], 'isometric');
        expect(json['targetMuscles'], ['legs']);
      });
    });

    group('fromJson', () {
      test('deserializes from JSON correctly', () {
        final json = {
          'id': '1',
          'name': 'L-Sit',
          'description': 'Core and arm isometric',
          'isCustom': false,
          'type': 'isometric',
          'targetMuscles': ['core', 'arms'],
        };

        final exercise = IsometricExercise.fromJson(json);

        expect(exercise.id, '1');
        expect(exercise.name, 'L-Sit');
        expect(exercise.description, 'Core and arm isometric');
        expect(exercise.isCustom, false);
        expect(exercise.targetMuscles, [MuscleGroup.core, MuscleGroup.arms]);
      });
    });

    group('copyWith', () {
      test('returns new instance with updated fields', () {
        final exercise = IsometricExercise(
          id: '1',
          name: 'Plank',
          description: 'Standard plank',
          isCustom: false,
          targetMuscles: [MuscleGroup.core],
        );

        final updated = exercise.copyWith(
          name: 'Forearm Plank',
          description: 'Plank on forearms',
        );

        expect(updated.name, 'Forearm Plank');
        expect(updated.description, 'Plank on forearms');
        expect(exercise.name, 'Plank');
      });
    });

    group('equality', () {
      test('two exercises with same values are equal', () {
        final exercise1 = IsometricExercise(
          id: '1',
          name: 'Dead Hang',
          description: 'Hanging exercise',
          isCustom: false,
          targetMuscles: [MuscleGroup.back, MuscleGroup.arms],
        );

        final exercise2 = IsometricExercise(
          id: '1',
          name: 'Dead Hang',
          description: 'Hanging exercise',
          isCustom: false,
          targetMuscles: [MuscleGroup.back, MuscleGroup.arms],
        );

        expect(exercise1, exercise2);
      });

      test('two exercises with different target muscles are not equal', () {
        final exercise1 = IsometricExercise(
          id: '1',
          name: 'Plank',
          description: 'Core exercise',
          isCustom: false,
          targetMuscles: [MuscleGroup.core],
        );

        final exercise2 = IsometricExercise(
          id: '1',
          name: 'Plank',
          description: 'Core exercise',
          isCustom: false,
          targetMuscles: [MuscleGroup.core, MuscleGroup.shoulders],
        );

        expect(exercise1, isNot(exercise2));
      });
    });

    group('serialization round-trip', () {
      test('deserialize(serialize(exercise)) equals original', () {
        final exercise = IsometricExercise(
          id: '1',
          name: 'Hollow Body Hold',
          description: 'Core control',
          isCustom: false,
          targetMuscles: [MuscleGroup.core],
        );

        final json = exercise.toJson();
        final deserialized = IsometricExercise.fromJson(json);

        expect(deserialized, exercise);
      });
    });
  });
}
