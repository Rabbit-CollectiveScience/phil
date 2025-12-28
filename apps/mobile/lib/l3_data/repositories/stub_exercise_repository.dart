import 'dart:convert';
import 'package:flutter/services.dart';
import '../../l2_domain/models/exercise.dart';
import 'exercise_repository.dart';

// Strategy: Stub implementation of ExerciseRepository
//
// Responsibility:
// - Loads exercise data from JSON assets for development/testing
// - Returns predefined exercise list from chest exercises
// - Strategy Pattern: JSON file data strategy
//
// Usage: For initial development and testing without real data source

class StubExerciseRepository implements ExerciseRepository {
  List<Exercise>? _cachedExercises;

  @override
  Future<List<Exercise>> getAllExercises() async {
    if (_cachedExercises != null) {
      return _cachedExercises!;
    }

    // Load all exercise JSON files
    final exerciseFiles = [
      'assets/data/exercises/strength_legs_exercises.json',
      'assets/data/exercises/strength_chest_exercises.json',
      'assets/data/exercises/strength_back_exercises.json',
      'assets/data/exercises/strength_shoulders_exercises.json',
      'assets/data/exercises/strength_arms_exercises.json',
      'assets/data/exercises/strength_core_exercises.json',
      'assets/data/exercises/cardio_exercises.json',
      'assets/data/exercises/flexibility_exercises.json',
    ];

    final List<Exercise> allExercises = [];

    for (final file in exerciseFiles) {
      try {
        final jsonString = await rootBundle.loadString(file);
        final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
        final exercises = jsonList
            .map(
              (exerciseJson) =>
                  Exercise.fromJson(exerciseJson as Map<String, dynamic>),
            )
            .toList();
        allExercises.addAll(exercises);
      } catch (e) {
        // Log error but continue loading other files
        print('Error loading $file: $e');
      }
    }

    if (allExercises.isEmpty) {
      throw Exception('Failed to load any exercises from assets');
    }

    _cachedExercises = allExercises;
    return _cachedExercises!;
  }

  @override
  Future<Exercise> getExerciseById(String id) async {
    final exercises = await getAllExercises();
    return exercises.firstWhere(
      (exercise) => exercise.id == id,
      orElse: () => throw Exception('Exercise with id $id not found'),
    );
  }

  @override
  Future<List<Exercise>> searchExercises(String query) async {
    final exercises = await getAllExercises();
    final lowercaseQuery = query.toLowerCase();

    return exercises.where((exercise) {
      return exercise.name.toLowerCase().contains(lowercaseQuery) ||
          exercise.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  @override
  Future<Exercise> updateExercise(Exercise exercise) async {
    // Stub implementation - just return the exercise as-is
    // In real implementation, this would persist to storage
    return exercise;
  }
}
