import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/exercises/assisted_machine_exercise.dart';
import 'package:phil/l2_domain/models/exercises/strength_exercise.dart';
import 'package:phil/l2_domain/models/common/muscle_group.dart';
import 'package:phil/l2_domain/models/common/equipment_type.dart';

void main() {
  group('AssistedMachineExercise', () {
    test('should be a subclass of StrengthExercise', () {
      final exercise = AssistedMachineExercise(
        id: 'test_1',
        name: 'Assisted Pull-Up',
        description: 'Pull-up with assistance',
        isCustom: false,
        targetMuscles: [MuscleGroup.back],
        equipmentType: EquipmentType.machine,
      );

      expect(exercise, isA<StrengthExercise>());
    });

    test('toJson should serialize correctly with assisted_machine type', () {
      final exercise = AssistedMachineExercise(
        id: 'back_13',
        name: 'Assisted Pull-Up Machine',
        description: 'Test description',
        isCustom: false,
        targetMuscles: [MuscleGroup.back, MuscleGroup.arms],
        equipmentType: EquipmentType.machine,
      );

      final json = exercise.toJson();

      expect(json['type'], 'assisted_machine');
      expect(json['id'], 'back_13');
      expect(json['name'], 'Assisted Pull-Up Machine');
      expect(json['description'], 'Test description');
      expect(json['isCustom'], false);
      expect(json['targetMuscles'], ['back', 'arms']);
    });

    test('fromJson should deserialize correctly', () {
      final json = {
        'type': 'assisted_machine',
        'id': 'back_13',
        'name': 'Assisted Pull-Up Machine',
        'description': 'Test description',
        'isCustom': false,
        'targetMuscles': ['back', 'arms'],
        'equipmentType': 'machine',
      };

      final exercise = AssistedMachineExercise.fromJson(json);

      expect(exercise.id, 'back_13');
      expect(exercise.name, 'Assisted Pull-Up Machine');
      expect(exercise.description, 'Test description');
      expect(exercise.isCustom, false);
      expect(exercise.targetMuscles, [MuscleGroup.back, MuscleGroup.arms]);
    });

    test('equality should work correctly', () {
      final exercise1 = AssistedMachineExercise(
        id: 'test_1',
        name: 'Assisted Pull-Up',
        description: 'Description',
        isCustom: false,
        targetMuscles: [MuscleGroup.back],
        equipmentType: EquipmentType.machine,
      );

      final exercise2 = AssistedMachineExercise(
        id: 'test_1',
        name: 'Assisted Pull-Up',
        description: 'Description',
        isCustom: false,
        targetMuscles: [MuscleGroup.back],
        equipmentType: EquipmentType.machine,
      );

      final exercise3 = AssistedMachineExercise(
        id: 'test_2',
        name: 'Assisted Dip',
        description: 'Description',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
        equipmentType: EquipmentType.machine,
      );

      expect(exercise1, equals(exercise2));
      expect(exercise1, isNot(equals(exercise3)));
    });

    test('copyWith should create a new instance with updated fields', () {
      final exercise = AssistedMachineExercise(
        id: 'test_1',
        name: 'Assisted Pull-Up',
        description: 'Original',
        isCustom: false,
        targetMuscles: [MuscleGroup.back],
        equipmentType: EquipmentType.machine,
      );

      final updated = exercise.copyWith(
        name: 'Updated Name',
        description: 'Updated Description',
      );

      expect(updated.id, 'test_1');
      expect(updated.name, 'Updated Name');
      expect(updated.description, 'Updated Description');
      expect(updated.isCustom, false);
      expect(updated.targetMuscles, [MuscleGroup.back]);
    });
  });
}
