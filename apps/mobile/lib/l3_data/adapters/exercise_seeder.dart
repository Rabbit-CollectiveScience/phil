import 'dart:convert';
import 'package:flutter/services.dart';
import '../repositories/exercise_repository.dart';
import '../../l2_domain/models/exercises/exercise.dart';
import '../../l2_domain/models/exercises/bodyweight_exercise.dart';
import '../../l2_domain/models/exercises/free_weight_exercise.dart';
import '../../l2_domain/models/exercises/machine_exercise.dart';
import '../../l2_domain/models/exercises/isometric_exercise.dart';
import '../../l2_domain/models/exercises/distance_cardio_exercise.dart';
import '../../l2_domain/models/exercises/duration_cardio_exercise.dart';

/// Seeds the exercise database from JSON files in assets
class ExerciseSeeder {
  final ExerciseRepository _repository;

  ExerciseSeeder(this._repository);

  /// Seed exercises from JSON files if database is empty
  Future<void> seedIfEmpty() async {
    // Check if database already has exercises
    final existing = await _repository.getAll();
    if (existing.isNotEmpty) {
      print('✓ Exercises already seeded (${existing.length} exercises found)');
      return;
    }

    print('📦 Seeding exercises from assets...');

    final assetPaths = [
      'assets/data/exercises/strength_chest_exercises.json',
      'assets/data/exercises/strength_back_exercises.json',
      'assets/data/exercises/strength_legs_exercises.json',
      'assets/data/exercises/strength_shoulders_exercises.json',
      'assets/data/exercises/strength_arms_exercises.json',
      'assets/data/exercises/strength_core_exercises.json',
      'assets/data/exercises/cardio_distance_exercises.json',
      'assets/data/exercises/cardio_duration_exercises.json',
    ];

    int totalSeeded = 0;

    for (final path in assetPaths) {
      try {
        final jsonString = await rootBundle.loadString(path);
        final List<dynamic> jsonList = json.decode(jsonString);

        for (final exerciseJson in jsonList) {
          final exercise = _parseExercise(exerciseJson);
          await _repository.save(exercise);
          totalSeeded++;
        }

        print('  ✓ Loaded ${jsonList.length} exercises from $path');
      } catch (e) {
        print('  ✗ Failed to load $path: $e');
      }
    }

    print('✓ Seeded $totalSeeded exercises');
  }

  /// Parse exercise JSON to appropriate Exercise subclass
  Exercise _parseExercise(Map<String, dynamic> json) {
    final type = json['type'] as String;

    switch (type) {
      case 'bodyweight':
        return BodyweightExercise.fromJson(json);
      case 'free_weight':
        return FreeWeightExercise.fromJson(json);
      case 'machine':
        return MachineExercise.fromJson(json);
      case 'isometric':
        return IsometricExercise.fromJson(json);
      case 'distance_cardio':
        return DistanceCardioExercise.fromJson(json);
      case 'duration_cardio':
        return DurationCardioExercise.fromJson(json);
      default:
        throw Exception('Unknown exercise type: $type');
    }
  }
}
