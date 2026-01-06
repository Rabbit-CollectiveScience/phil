import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/exercises/distance_cardio_exercise.dart';
import 'package:phil/l2_domain/models/exercises/duration_cardio_exercise.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Exercise JSON Serialization Tests', () {
    test('Distance cardio exercises JSON can be deserialized', () async {
      // Load the JSON file
      final jsonString = await rootBundle.loadString(
        'assets/data/exercises/cardio_distance_exercises.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);

      // Verify we have exercises
      expect(jsonList.isNotEmpty, true);
      print('Found ${jsonList.length} distance cardio exercises');

      // Try to deserialize each exercise
      for (final exerciseJson in jsonList) {
        final exercise = DistanceCardioExercise.fromJson(exerciseJson);
        
        // Verify all required fields are present
        expect(exercise.id, isNotEmpty);
        expect(exercise.name, isNotEmpty);
        expect(exercise.description, isNotEmpty);
        expect(exercise.isCustom, false);
        
        // Verify the JSON has the correct type field
        expect(exerciseJson['type'], 'distance_cardio');
        
        print('✓ Successfully deserialized: ${exercise.name} (${exercise.id})');
      }
    });

    test('Duration cardio exercises JSON can be deserialized', () async {
      // Load the JSON file
      final jsonString = await rootBundle.loadString(
        'assets/data/exercises/cardio_duration_exercises.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);

      // Verify we have exercises
      expect(jsonList.isNotEmpty, true);
      print('Found ${jsonList.length} duration cardio exercises');

      // Try to deserialize each exercise
      for (final exerciseJson in jsonList) {
        final exercise = DurationCardioExercise.fromJson(exerciseJson);
        
        // Verify all required fields are present
        expect(exercise.id, isNotEmpty);
        expect(exercise.name, isNotEmpty);
        expect(exercise.description, isNotEmpty);
        expect(exercise.isCustom, false);
        
        // Verify the JSON has the correct type field
        expect(exerciseJson['type'], 'duration_cardio');
        
        print('✓ Successfully deserialized: ${exercise.name} (${exercise.id})');
      }
    });

    test('Serialization round-trip works for distance cardio', () async {
      final jsonString = await rootBundle.loadString(
        'assets/data/exercises/cardio_distance_exercises.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);

      for (final exerciseJson in jsonList) {
        // Deserialize
        final exercise = DistanceCardioExercise.fromJson(exerciseJson);
        
        // Serialize back to JSON
        final serialized = exercise.toJson();
        
        // Verify key fields match
        expect(serialized['type'], 'distance_cardio');
        expect(serialized['id'], exerciseJson['id']);
        expect(serialized['name'], exerciseJson['name']);
        expect(serialized['description'], exerciseJson['description']);
        expect(serialized['isCustom'], exerciseJson['isCustom']);
        
        print('✓ Round-trip successful: ${exercise.name}');
      }
    });

    test('Serialization round-trip works for duration cardio', () async {
      final jsonString = await rootBundle.loadString(
        'assets/data/exercises/cardio_duration_exercises.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);

      for (final exerciseJson in jsonList) {
        // Deserialize
        final exercise = DurationCardioExercise.fromJson(exerciseJson);
        
        // Serialize back to JSON
        final serialized = exercise.toJson();
        
        // Verify key fields match
        expect(serialized['type'], 'duration_cardio');
        expect(serialized['id'], exerciseJson['id']);
        expect(serialized['name'], exerciseJson['name']);
        expect(serialized['description'], exerciseJson['description']);
        expect(serialized['isCustom'], exerciseJson['isCustom']);
        
        print('✓ Round-trip successful: ${exercise.name}');
      }
    });
  });
}
