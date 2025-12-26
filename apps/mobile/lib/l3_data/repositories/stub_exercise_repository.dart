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

    // Load chest exercises JSON
    final jsonString = await rootBundle.loadString(
      'assets/data/exercises/strength_chest_exercises.json',
    );

    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

    _cachedExercises = jsonList
        .map(
          (exerciseJson) =>
              Exercise.fromJson(exerciseJson as Map<String, dynamic>),
        )
        .toList();

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
