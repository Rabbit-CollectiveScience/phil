import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/exercises/bodyweight_exercise.dart';
import 'package:phil/l2_domain/models/common/muscle_group.dart';
import 'package:phil/l2_domain/models/common/equipment_type.dart';

void main() {
  group('BodyweightExercise', () {
    group('constructor', () {
      test('creates BodyweightExercise with all required fields', () {
        final exercise = BodyweightExercise(
          id: '1',
          name: 'Push-up',
          description: 'Standard push-up',
          isCustom: false,
          targetMuscles: [MuscleGroup.chest, MuscleGroup.arms],
          canAddWeight: false,
          equipmentType: EquipmentType.other,
        );

        expect(exercise.id, '1');
        expect(exercise.name, 'Push-up');
        expect(exercise.description, 'Standard push-up');
        expect(exercise.isCustom, false);
        expect(exercise.targetMuscles, [MuscleGroup.chest, MuscleGroup.arms]);
        expect(exercise.canAddWeight, false);
      });

      test('creates BodyweightExercise that can add weight', () {
        final exercise = BodyweightExercise(
          id: '1',
          name: 'Pull-up',
          description: 'Pull-up with weight belt',
          isCustom: false,
          targetMuscles: [MuscleGroup.back],
          canAddWeight: true,
          equipmentType: EquipmentType.other,
        );

        expect(exercise.canAddWeight, true);
      });

      test('creates custom BodyweightExercise', () {
        final exercise = BodyweightExercise(
          id: '1',
          name: 'Custom exercise',
          description: 'My custom bodyweight exercise',
          isCustom: true,
          targetMuscles: [MuscleGroup.core],
          canAddWeight: false,
          equipmentType: EquipmentType.other,
        );

        expect(exercise.isCustom, true);
      });

      test('creates BodyweightExercise with empty description', () {
        final exercise = BodyweightExercise(
          id: '1',
          name: 'Exercise',
          description: '',
          isCustom: false,
          targetMuscles: [MuscleGroup.legs],
          canAddWeight: false,
          equipmentType: EquipmentType.other,
        );

        expect(exercise.description, '');
      });

      test('creates BodyweightExercise with multiple target muscles', () {
        final exercise = BodyweightExercise(
          id: '1',
          name: 'Burpee',
          description: 'Full body exercise',
          isCustom: false,
          targetMuscles: [
            MuscleGroup.chest,
            MuscleGroup.legs,
            MuscleGroup.core,
            MuscleGroup.shoulders,
          ],
          canAddWeight: false,
          equipmentType: EquipmentType.other,
        );

        expect(exercise.targetMuscles.length, 4);
      });

      test('creates BodyweightExercise with single target muscle', () {
        final exercise = BodyweightExercise(
          id: '1',
          name: 'Plank',
          description: 'Core exercise',
          isCustom: false,
          targetMuscles: [MuscleGroup.core],
          canAddWeight: false,
          equipmentType: EquipmentType.other,
        );

        expect(exercise.targetMuscles.length, 1);
        expect(exercise.targetMuscles.first, MuscleGroup.core);
      });
    });

    group('toJson', () {
      test('serializes to JSON correctly', () {
        final exercise = BodyweightExercise(
          id: '1',
          name: 'Push-up',
          description: 'Standard push-up',
          isCustom: false,
          targetMuscles: [MuscleGroup.chest, MuscleGroup.arms],
          canAddWeight: false,
          equipmentType: EquipmentType.other,
        );

        final json = exercise.toJson();

        expect(json['id'], '1');
        expect(json['name'], 'Push-up');
        expect(json['description'], 'Standard push-up');
        expect(json['isCustom'], false);
        expect(json['type'], 'bodyweight');
        expect(json['targetMuscles'], ['chest', 'arms']);
        expect(json['canAddWeight'], false);
      });

      test('serializes custom exercise to JSON', () {
        final exercise = BodyweightExercise(
          id: '1',
          name: 'Custom',
          description: 'Custom description',
          isCustom: true,
          targetMuscles: [MuscleGroup.back],
          canAddWeight: true,
          equipmentType: EquipmentType.other,
        );

        final json = exercise.toJson();

        expect(json['isCustom'], true);
        expect(json['canAddWeight'], true);
      });

      test('serializes exercise with multiple muscles to JSON', () {
        final exercise = BodyweightExercise(
          id: '1',
          name: 'Exercise',
          description: 'Description',
          isCustom: false,
          targetMuscles: [
            MuscleGroup.chest,
            MuscleGroup.shoulders,
            MuscleGroup.arms,
          ],
          canAddWeight: false,
          equipmentType: EquipmentType.other,
        );

        final json = exercise.toJson();

        expect(json['targetMuscles'], ['chest', 'shoulders', 'arms']);
      });
    });

    group('fromJson', () {
      test('deserializes from JSON correctly', () {
        final json = {
          'id': '1',
          'name': 'Push-up',
          'description': 'Standard push-up',
          'isCustom': false,
          'type': 'bodyweight',
          'targetMuscles': ['chest', 'arms'],
          'canAddWeight': false,
        };

        final exercise = BodyweightExercise.fromJson(json);

        expect(exercise.id, '1');
        expect(exercise.name, 'Push-up');
        expect(exercise.description, 'Standard push-up');
        expect(exercise.isCustom, false);
        expect(exercise.targetMuscles, [MuscleGroup.chest, MuscleGroup.arms]);
        expect(exercise.canAddWeight, false);
      });

      test('deserializes custom exercise from JSON', () {
        final json = {
          'id': '1',
          'name': 'Custom',
          'description': 'Custom description',
          'isCustom': true,
          'type': 'bodyweight',
          'targetMuscles': ['back'],
          'canAddWeight': true,
        };

        final exercise = BodyweightExercise.fromJson(json);

        expect(exercise.isCustom, true);
        expect(exercise.canAddWeight, true);
      });
    });

    group('copyWith', () {
      test('returns new instance with updated fields', () {
        final exercise = BodyweightExercise(
          id: '1',
          name: 'Push-up',
          description: 'Standard push-up',
          isCustom: false,
          targetMuscles: [MuscleGroup.chest],
          canAddWeight: false,
          equipmentType: EquipmentType.other,
        );

        final updated = exercise.copyWith(
          name: 'Wide Push-up',
          canAddWeight: true,
        );

        expect(updated.name, 'Wide Push-up');
        expect(updated.canAddWeight, true);
        expect(updated.id, '1');
        expect(updated.description, 'Standard push-up');
        expect(exercise.name, 'Push-up');
        expect(exercise.canAddWeight, false);
      });

      test('returns new instance with no changes when no params provided', () {
        final exercise = BodyweightExercise(
          id: '1',
          name: 'Push-up',
          description: 'Standard push-up',
          isCustom: false,
          targetMuscles: [MuscleGroup.chest],
          canAddWeight: false,
          equipmentType: EquipmentType.other,
        );

        final updated = exercise.copyWith();

        expect(updated.id, exercise.id);
        expect(updated.name, exercise.name);
        expect(updated.description, exercise.description);
        expect(updated.canAddWeight, exercise.canAddWeight);
      });

      test('can update target muscles', () {
        final exercise = BodyweightExercise(
          id: '1',
          name: 'Exercise',
          description: 'Description',
          isCustom: false,
          targetMuscles: [MuscleGroup.chest],
          canAddWeight: false,
          equipmentType: EquipmentType.other,
        );

        final updated = exercise.copyWith(
          targetMuscles: [MuscleGroup.back, MuscleGroup.arms],
        );

        expect(updated.targetMuscles, [MuscleGroup.back, MuscleGroup.arms]);
        expect(exercise.targetMuscles, [MuscleGroup.chest]);
      });
    });

    group('equality', () {
      test('two exercises with same values are equal', () {
        final exercise1 = BodyweightExercise(
          id: '1',
          name: 'Push-up',
          description: 'Standard push-up',
          isCustom: false,
          targetMuscles: [MuscleGroup.chest],
          canAddWeight: false,
          equipmentType: EquipmentType.other,
        );

        final exercise2 = BodyweightExercise(
          id: '1',
          name: 'Push-up',
          description: 'Standard push-up',
          isCustom: false,
          targetMuscles: [MuscleGroup.chest],
          canAddWeight: false,
          equipmentType: EquipmentType.other,
        );

        expect(exercise1, exercise2);
      });

      test('two exercises with different ids are not equal', () {
        final exercise1 = BodyweightExercise(
          id: '1',
          name: 'Push-up',
          description: 'Standard push-up',
          isCustom: false,
          targetMuscles: [MuscleGroup.chest],
          canAddWeight: false,
          equipmentType: EquipmentType.other,
        );

        final exercise2 = BodyweightExercise(
          id: '2',
          name: 'Push-up',
          description: 'Standard push-up',
          isCustom: false,
          targetMuscles: [MuscleGroup.chest],
          canAddWeight: false,
          equipmentType: EquipmentType.other,
        );

        expect(exercise1, isNot(exercise2));
      });

      test('two exercises with different canAddWeight are not equal', () {
        final exercise1 = BodyweightExercise(
          id: '1',
          name: 'Push-up',
          description: 'Standard push-up',
          isCustom: false,
          targetMuscles: [MuscleGroup.chest],
          canAddWeight: false,
          equipmentType: EquipmentType.other,
        );

        final exercise2 = BodyweightExercise(
          id: '1',
          name: 'Push-up',
          description: 'Standard push-up',
          isCustom: false,
          targetMuscles: [MuscleGroup.chest],
          canAddWeight: true,
          equipmentType: EquipmentType.other,
        );

        expect(exercise1, isNot(exercise2));
      });
    });

    group('hashCode', () {
      test('same values produce same hashCode', () {
        final exercise1 = BodyweightExercise(
          id: '1',
          name: 'Push-up',
          description: 'Standard push-up',
          isCustom: false,
          targetMuscles: [MuscleGroup.chest],
          canAddWeight: false,
          equipmentType: EquipmentType.other,
        );

        final exercise2 = BodyweightExercise(
          id: '1',
          name: 'Push-up',
          description: 'Standard push-up',
          isCustom: false,
          targetMuscles: [MuscleGroup.chest],
          canAddWeight: false,
          equipmentType: EquipmentType.other,
        );

        expect(exercise1.hashCode, exercise2.hashCode);
      });

      test('different canAddWeight values produce different hashCode', () {
        final exercise1 = BodyweightExercise(
          id: '1',
          name: 'Push-up',
          description: 'Standard push-up',
          isCustom: false,
          targetMuscles: [MuscleGroup.chest],
          canAddWeight: false,
          equipmentType: EquipmentType.other,
        );

        final exercise2 = BodyweightExercise(
          id: '1',
          name: 'Push-up',
          description: 'Standard push-up',
          isCustom: false,
          targetMuscles: [MuscleGroup.chest],
          canAddWeight: true,
          equipmentType: EquipmentType.other,
        );

        expect(exercise1.hashCode, isNot(exercise2.hashCode));
      });
    });

    group('serialization round-trip', () {
      test('deserialize(serialize(exercise)) equals original', () {
        final exercise = BodyweightExercise(
          id: '1',
          name: 'Push-up',
          description: 'Standard push-up',
          isCustom: false,
          targetMuscles: [MuscleGroup.chest, MuscleGroup.arms],
          canAddWeight: true,
          equipmentType: EquipmentType.other,
        );

        final json = exercise.toJson();
        final deserialized = BodyweightExercise.fromJson(json);

        expect(deserialized, exercise);
      });
    });
  });
}
