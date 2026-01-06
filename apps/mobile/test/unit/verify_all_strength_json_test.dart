import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/exercises/bodyweight_exercise.dart';
import 'package:phil/l2_domain/models/exercises/free_weight_exercise.dart';
import 'package:phil/l2_domain/models/exercises/machine_exercise.dart';
import 'package:phil/l2_domain/models/exercises/isometric_exercise.dart';
import 'package:phil/l2_domain/models/exercises/strength_exercise.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('All Strength Exercises JSON Serialization Tests', () {
    final files = [
      'assets/data/exercises/strength_arms_exercises.json',
      'assets/data/exercises/strength_back_exercises.json',
      'assets/data/exercises/strength_chest_exercises.json',
      'assets/data/exercises/strength_core_exercises.json',
      'assets/data/exercises/strength_legs_exercises.json',
      'assets/data/exercises/strength_shoulders_exercises.json',
    ];

    for (final filePath in files) {
      test('$filePath - deserialize all exercises by type', () async {
        final jsonString = await rootBundle.loadString(filePath);
        final List<dynamic> jsonList = json.decode(jsonString);

        expect(jsonList.length, 50);
        print('\n$filePath:');

        int freeWeightCount = 0;
        int machineCount = 0;
        int bodyweightCount = 0;
        int isometricCount = 0;

        for (final exerciseJson in jsonList) {
          final type = exerciseJson['type'];
          StrengthExercise exercise;

          switch (type) {
            case 'free_weight':
              exercise = FreeWeightExercise.fromJson(exerciseJson);
              freeWeightCount++;
              break;
            case 'machine':
              exercise = MachineExercise.fromJson(exerciseJson);
              machineCount++;
              break;
            case 'bodyweight':
              exercise = BodyweightExercise.fromJson(exerciseJson);
              bodyweightCount++;
              break;
            case 'isometric':
              exercise = IsometricExercise.fromJson(exerciseJson);
              isometricCount++;
              break;
            default:
              fail('Unknown exercise type: $type');
          }

          expect(exercise.id, isNotEmpty);
          expect(exercise.name, isNotEmpty);
          expect(exercise.description, isNotEmpty);
          expect(exercise.targetMuscles, isNotEmpty);
        }

        print('  Total: ${jsonList.length}');
        print('  Free Weight: $freeWeightCount');
        print('  Machine: $machineCount');
        print('  Bodyweight: $bodyweightCount');
        print('  Isometric: $isometricCount');
      });

      test('$filePath - round-trip serialization', () async {
        final jsonString = await rootBundle.loadString(filePath);
        final List<dynamic> jsonList = json.decode(jsonString);

        for (var i = 0; i < jsonList.length; i++) {
          final originalJson = jsonList[i] as Map<String, dynamic>;
          final type = originalJson['type'];
          StrengthExercise exercise;

          switch (type) {
            case 'free_weight':
              exercise = FreeWeightExercise.fromJson(originalJson);
              break;
            case 'machine':
              exercise = MachineExercise.fromJson(originalJson);
              break;
            case 'bodyweight':
              exercise = BodyweightExercise.fromJson(originalJson);
              break;
            case 'isometric':
              exercise = IsometricExercise.fromJson(originalJson);
              break;
            default:
              fail('Unknown type: $type at index $i');
          }

          final serializedJson = exercise.toJson();

          // Verify key fields are preserved
          expect(serializedJson['type'], originalJson['type']);
          expect(serializedJson['id'], originalJson['id']);
          expect(serializedJson['name'], originalJson['name']);
          expect(serializedJson['is_custom'], originalJson['is_custom']);
        }
      });
    }

    test('All files combined statistics', () async {
      int totalExercises = 0;
      int totalFreeWeight = 0;
      int totalMachine = 0;
      int totalBodyweight = 0;
      int totalIsometric = 0;

      for (final filePath in files) {
        final jsonString = await rootBundle.loadString(filePath);
        final List<dynamic> jsonList = json.decode(jsonString);

        totalExercises += jsonList.length;

        for (final exerciseJson in jsonList) {
          final type = (exerciseJson as Map<String, dynamic>)['type'];
          switch (type) {
            case 'free_weight':
              totalFreeWeight++;
              break;
            case 'machine':
              totalMachine++;
              break;
            case 'bodyweight':
              totalBodyweight++;
              break;
            case 'isometric':
              totalIsometric++;
              break;
          }
        }
      }

      expect(totalExercises, 300);

      print('\n\nCombined Statistics (All Files):');
      print('  Total Exercises: $totalExercises');
      print('  Free Weight: $totalFreeWeight');
      print('  Machine: $totalMachine');
      print('  Bodyweight: $totalBodyweight');
      print('  Isometric: $totalIsometric');
    });
  });
}
