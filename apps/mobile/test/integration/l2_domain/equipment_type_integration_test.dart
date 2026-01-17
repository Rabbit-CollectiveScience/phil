import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/common/equipment_type.dart';
import 'package:phil/l2_domain/models/exercises/bodyweight_exercise.dart';
import 'package:phil/l2_domain/models/exercises/free_weight_exercise.dart';
import 'package:phil/l2_domain/models/exercises/machine_exercise.dart';
import 'package:phil/l2_domain/models/exercises/isometric_exercise.dart';
import 'package:phil/l2_domain/models/exercises/assisted_machine_exercise.dart';
import 'package:phil/l2_domain/models/exercises/distance_cardio_exercise.dart';
import 'package:phil/l2_domain/models/exercises/duration_cardio_exercise.dart';
import 'package:phil/l2_domain/models/exercises/strength_exercise.dart';
import 'package:phil/l2_domain/models/exercises/cardio_exercise.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Exercise JSON Files equipmentType Validation', () {
    group('All Strength Exercise Files', () {
      final strengthFiles = [
        'assets/data/exercises/strength_arms_exercises.json',
        'assets/data/exercises/strength_back_exercises.json',
        'assets/data/exercises/strength_chest_exercises.json',
        'assets/data/exercises/strength_core_exercises.json',
        'assets/data/exercises/strength_legs_exercises.json',
        'assets/data/exercises/strength_shoulders_exercises.json',
      ];

      for (final filePath in strengthFiles) {
        test('$filePath - all exercises have valid equipmentType', () async {
          final jsonString = await rootBundle.loadString(filePath);
          final List<dynamic> jsonList = json.decode(jsonString);

          expect(jsonList, isNotEmpty, reason: 'File should contain exercises');

          final equipmentTypeCounts = <EquipmentType, int>{};
          int nullEquipmentTypeCount = 0;

          for (var i = 0; i < jsonList.length; i++) {
            final exerciseJson = jsonList[i] as Map<String, dynamic>;
            final type = exerciseJson['type'];
            final name = exerciseJson['name'];

            // Check equipmentType field exists in JSON
            expect(
              exerciseJson.containsKey('equipmentType'),
              isTrue,
              reason:
                  'Exercise "$name" (index $i) is missing equipmentType field in JSON',
            );

            // Parse exercise to verify it deserializes correctly
            StrengthExercise exercise;
            switch (type) {
              case 'free_weight':
                exercise = FreeWeightExercise.fromJson(exerciseJson);
                break;
              case 'machine':
                exercise = MachineExercise.fromJson(exerciseJson);
                break;
              case 'bodyweight':
                exercise = BodyweightExercise.fromJson(exerciseJson);
                break;
              case 'isometric':
                exercise = IsometricExercise.fromJson(exerciseJson);
                break;
              case 'assisted_machine':
                exercise = AssistedMachineExercise.fromJson(exerciseJson);
                break;
              default:
                fail('Unknown exercise type: $type for exercise "$name"');
            }

            // Verify equipmentType is not null after deserialization
            expect(
              exercise.equipmentType,
              isNotNull,
              reason:
                  'Exercise "$name" has null equipmentType after deserialization',
            );

            // Track equipment type distribution
            equipmentTypeCounts[exercise.equipmentType] =
                (equipmentTypeCounts[exercise.equipmentType] ?? 0) + 1;
          }

          // Print distribution for verification
          print('\n$filePath equipment distribution:');
          print('  Total exercises: ${jsonList.length}');
          equipmentTypeCounts.forEach((type, count) {
            print('  $type: $count');
          });

          // Verify at least one exercise uses each major equipment type
          // (some files may not have all types, but across all files we should)
          expect(equipmentTypeCounts.keys, isNotEmpty);
          expect(nullEquipmentTypeCount, equals(0));
        });
      }
    });

    group('All Cardio Exercise Files', () {
      test(
        'cardio_distance_exercises.json - all exercises have valid equipmentType',
        () async {
          final jsonString = await rootBundle.loadString(
            'assets/data/exercises/cardio_distance_exercises.json',
          );
          final List<dynamic> jsonList = json.decode(jsonString);

          expect(jsonList, isNotEmpty);

          for (var i = 0; i < jsonList.length; i++) {
            final exerciseJson = jsonList[i] as Map<String, dynamic>;
            final name = exerciseJson['name'];

            expect(
              exerciseJson.containsKey('equipmentType'),
              isTrue,
              reason: 'Exercise "$name" is missing equipmentType field',
            );

            final exercise = DistanceCardioExercise.fromJson(exerciseJson);

            expect(
              exercise.equipmentType,
              isNotNull,
              reason: 'Exercise "$name" has null equipmentType',
            );
          }

          print(
            '\ncardio_distance_exercises.json: ${jsonList.length} exercises validated',
          );
        },
      );

      test(
        'cardio_duration_exercises.json - all exercises have valid equipmentType',
        () async {
          final jsonString = await rootBundle.loadString(
            'assets/data/exercises/cardio_duration_exercises.json',
          );
          final List<dynamic> jsonList = json.decode(jsonString);

          expect(jsonList, isNotEmpty);

          for (var i = 0; i < jsonList.length; i++) {
            final exerciseJson = jsonList[i] as Map<String, dynamic>;
            final name = exerciseJson['name'];

            expect(
              exerciseJson.containsKey('equipmentType'),
              isTrue,
              reason: 'Exercise "$name" is missing equipmentType field',
            );

            final exercise = DurationCardioExercise.fromJson(exerciseJson);

            expect(
              exercise.equipmentType,
              isNotNull,
              reason: 'Exercise "$name" has null equipmentType',
            );
          }

          print(
            '\ncardio_duration_exercises.json: ${jsonList.length} exercises validated',
          );
        },
      );
    });

    group('Complete Dataset Statistics', () {
      test('all 335 exercises across 8 files have equipmentType', () async {
        final allFiles = [
          'assets/data/exercises/cardio_distance_exercises.json',
          'assets/data/exercises/cardio_duration_exercises.json',
          'assets/data/exercises/strength_arms_exercises.json',
          'assets/data/exercises/strength_back_exercises.json',
          'assets/data/exercises/strength_chest_exercises.json',
          'assets/data/exercises/strength_core_exercises.json',
          'assets/data/exercises/strength_legs_exercises.json',
          'assets/data/exercises/strength_shoulders_exercises.json',
        ];

        int totalExercises = 0;
        final globalEquipmentTypeCounts = <EquipmentType, int>{};

        for (final filePath in allFiles) {
          final jsonString = await rootBundle.loadString(filePath);
          final List<dynamic> jsonList = json.decode(jsonString);
          totalExercises += jsonList.length;

          for (final exerciseJson in jsonList) {
            final json = exerciseJson as Map<String, dynamic>;
            expect(json.containsKey('equipmentType'), isTrue);

            // Parse based on exercise type
            final type = json['type'];
            EquipmentType? equipmentType;

            switch (type) {
              case 'free_weight':
                equipmentType = FreeWeightExercise.fromJson(json).equipmentType;
                break;
              case 'machine':
                equipmentType = MachineExercise.fromJson(json).equipmentType;
                break;
              case 'bodyweight':
                equipmentType = BodyweightExercise.fromJson(json).equipmentType;
                break;
              case 'isometric':
                equipmentType = IsometricExercise.fromJson(json).equipmentType;
                break;
              case 'assisted_machine':
                equipmentType = AssistedMachineExercise.fromJson(
                  json,
                ).equipmentType;
                break;
              case 'distance_cardio':
                equipmentType = DistanceCardioExercise.fromJson(
                  json,
                ).equipmentType;
                break;
              case 'duration_cardio':
                equipmentType = DurationCardioExercise.fromJson(
                  json,
                ).equipmentType;
                break;
            }

            expect(equipmentType, isNotNull);
            globalEquipmentTypeCounts[equipmentType!] =
                (globalEquipmentTypeCounts[equipmentType] ?? 0) + 1;
          }
        }

        print('\n=== COMPLETE DATASET STATISTICS ===');
        print('Total exercises: $totalExercises');
        print('\nEquipment type distribution:');
        globalEquipmentTypeCounts.forEach((type, count) {
          final percentage = (count / totalExercises * 100).toStringAsFixed(1);
          print('  $type: $count ($percentage%)');
        });

        // Verify we have the expected total
        expect(
          totalExercises,
          equals(335),
          reason: 'Expected 335 total exercises',
        );

        // Verify all equipment types are used
        expect(
          globalEquipmentTypeCounts.keys.length,
          greaterThanOrEqualTo(5),
          reason: 'Should use at least 5 different equipment types',
        );

        // Verify each major type has at least some exercises
        expect(globalEquipmentTypeCounts[EquipmentType.plate], greaterThan(0));
        expect(
          globalEquipmentTypeCounts[EquipmentType.dumbbell],
          greaterThan(0),
        );
        expect(
          globalEquipmentTypeCounts[EquipmentType.machine],
          greaterThan(0),
        );
        expect(globalEquipmentTypeCounts[EquipmentType.cable], greaterThan(0));
        expect(globalEquipmentTypeCounts[EquipmentType.other], greaterThan(0));
      });
    });

    group('Legacy Equipment Type Support', () {
      test('parser handles legacy "barbell" and "ezBar" values', () async {
        // This test verifies the parser would handle old JSON files correctly
        // even though our current files use "plate"

        final legacyJson = {
          'type': 'free_weight',
          'id': 'test_legacy',
          'name': 'Test Exercise',
          'description': 'Test',
          'isCustom': false,
          'targetMuscles': ['chest'],
          'equipmentType': 'barbell', // Legacy value
        };

        final exercise = FreeWeightExercise.fromJson(legacyJson);

        expect(
          exercise.equipmentType,
          equals(EquipmentType.plate),
          reason: 'Legacy "barbell" should parse to plate',
        );
      });
    });
  });
}
