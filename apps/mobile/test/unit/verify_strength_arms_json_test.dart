import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/exercises/bodyweight_exercise.dart';
import 'package:phil/l2_domain/models/exercises/free_weight_exercise.dart';
import 'package:phil/l2_domain/models/exercises/machine_exercise.dart';
import 'package:phil/l2_domain/models/exercises/isometric_exercise.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Strength Arms Exercises JSON Serialization Tests', () {
    test('All arm exercises can be deserialized by type', () async {
      final jsonString = await rootBundle.loadString(
        'assets/data/exercises/strength_arms_exercises.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);

      expect(jsonList.length, 50);
      print('Found ${jsonList.length} arm exercises');

      int freeWeightCount = 0;
      int machineCount = 0;
      int bodyweightCount = 0;
      int isometricCount = 0;

      for (final exerciseJson in jsonList) {
        final type = exerciseJson['type'];

        switch (type) {
          case 'free_weight':
            final exercise = FreeWeightExercise.fromJson(exerciseJson);
            expect(exercise.id, isNotEmpty);
            expect(exercise.name, isNotEmpty);
            expect(exercise.description, isNotEmpty);
            expect(exercise.isCustom, false);
            expect(exercise.targetMuscles, isNotEmpty);
            freeWeightCount++;
            print('✓ Free Weight: ${exercise.name} (${exercise.id})');
            break;

          case 'machine':
            final exercise = MachineExercise.fromJson(exerciseJson);
            expect(exercise.id, isNotEmpty);
            expect(exercise.name, isNotEmpty);
            expect(exercise.description, isNotEmpty);
            expect(exercise.isCustom, false);
            expect(exercise.targetMuscles, isNotEmpty);
            machineCount++;
            print('✓ Machine: ${exercise.name} (${exercise.id})');
            break;

          case 'bodyweight':
            final exercise = BodyweightExercise.fromJson(exerciseJson);
            expect(exercise.id, isNotEmpty);
            expect(exercise.name, isNotEmpty);
            expect(exercise.description, isNotEmpty);
            expect(exercise.isCustom, false);
            expect(exercise.targetMuscles, isNotEmpty);
            expect(exercise.canAddWeight, isNotNull);
            bodyweightCount++;
            print(
              '✓ Bodyweight: ${exercise.name} (${exercise.id}) - canAddWeight: ${exercise.canAddWeight}',
            );
            break;

          case 'isometric':
            final exercise = IsometricExercise.fromJson(exerciseJson);
            expect(exercise.id, isNotEmpty);
            expect(exercise.name, isNotEmpty);
            expect(exercise.description, isNotEmpty);
            expect(exercise.isCustom, false);
            expect(exercise.targetMuscles, isNotEmpty);
            isometricCount++;
            print('✓ Isometric: ${exercise.name} (${exercise.id})');
            break;

          default:
            fail('Unknown exercise type: $type');
        }
      }

      print('\n=== Summary ===');
      print('Free Weight: $freeWeightCount');
      print('Machine: $machineCount');
      print('Bodyweight: $bodyweightCount');
      print('Isometric: $isometricCount');
      print(
        'Total: ${freeWeightCount + machineCount + bodyweightCount + isometricCount}',
      );

      expect(
        freeWeightCount + machineCount + bodyweightCount + isometricCount,
        50,
      );
    });

    test('Round-trip serialization works for all types', () async {
      final jsonString = await rootBundle.loadString(
        'assets/data/exercises/strength_arms_exercises.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);

      for (final exerciseJson in jsonList) {
        final type = exerciseJson['type'];

        switch (type) {
          case 'free_weight':
            final exercise = FreeWeightExercise.fromJson(exerciseJson);
            final serialized = exercise.toJson();
            expect(serialized['type'], 'free_weight');
            expect(serialized['id'], exerciseJson['id']);
            expect(serialized['name'], exerciseJson['name']);
            expect(serialized['targetMuscles'], isNotEmpty);
            break;

          case 'machine':
            final exercise = MachineExercise.fromJson(exerciseJson);
            final serialized = exercise.toJson();
            expect(serialized['type'], 'machine');
            expect(serialized['id'], exerciseJson['id']);
            expect(serialized['name'], exerciseJson['name']);
            expect(serialized['targetMuscles'], isNotEmpty);
            break;

          case 'bodyweight':
            final exercise = BodyweightExercise.fromJson(exerciseJson);
            final serialized = exercise.toJson();
            expect(serialized['type'], 'bodyweight');
            expect(serialized['id'], exerciseJson['id']);
            expect(serialized['name'], exerciseJson['name']);
            expect(serialized['targetMuscles'], isNotEmpty);
            expect(serialized['canAddWeight'], isNotNull);
            break;

          case 'isometric':
            final exercise = IsometricExercise.fromJson(exerciseJson);
            final serialized = exercise.toJson();
            expect(serialized['type'], 'isometric');
            expect(serialized['id'], exerciseJson['id']);
            expect(serialized['name'], exerciseJson['name']);
            expect(serialized['targetMuscles'], isNotEmpty);
            break;
        }
      }

      print('✓ All 50 exercises serialized and deserialized successfully');
    });
  });
}
