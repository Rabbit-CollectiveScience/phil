import 'package:flutter/material.dart';
import '../../../../l2_domain/models/exercises/exercise.dart';

/// Model representing an exercise card in the workout UI
/// Holds exercise data and user input values for completing a workout set
class CardModel {
  final Exercise exercise;
  final Color color;
  final bool isFlipped;
  /// Generic storage for user input data (weight, reps, distance, duration, etc.)
  /// Keys are field names, values are user inputs as strings
  final Map<String, String> userData;

  CardModel({
    required this.exercise,
    required this.color,
    this.isFlipped = false,
    Map<String, String>? userData,
  }) : userData = userData ?? {};

  // Convenience getters
  String get exerciseName => exercise.name;
  String get description => exercise.description;

  CardModel copyWith({
    Exercise? exercise,
    Color? color,
    bool? isFlipped,
    Map<String, String>? userData,
  }) {
    return CardModel(
      exercise: exercise ?? this.exercise,
      color: color ?? this.color,
      isFlipped: isFlipped ?? this.isFlipped,
      userData: userData ?? Map<String, String>.from(this.userData),
    );
  }

  // Helper method to update a single field value
  CardModel updateFieldValue(String fieldName, String value) {
    final updatedValues = Map<String, String>.from(userData);
    updatedValues[fieldName] = value;
    return copyWith(userData: updatedValues);
  }
}

