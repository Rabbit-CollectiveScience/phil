import 'package:flutter/material.dart';
import '../../../../l2_domain/models/exercise.dart';

class CardModel {
  final Exercise exercise;
  final Color color;
  final bool isFlipped;
  final Map<String, String> fieldValues;

  CardModel({
    required this.exercise,
    required this.color,
    this.isFlipped = false,
    Map<String, String>? fieldValues,
  }) : fieldValues = fieldValues ?? _initializeFieldValues(exercise);

  // Convenience getters
  String get exerciseName => exercise.name;
  String get description => exercise.description;

  // Initialize empty values for all fields
  static Map<String, String> _initializeFieldValues(Exercise exercise) {
    return {for (var field in exercise.fields) field.name: ''};
  }

  CardModel copyWith({
    Exercise? exercise,
    Color? color,
    bool? isFlipped,
    Map<String, String>? fieldValues,
  }) {
    return CardModel(
      exercise: exercise ?? this.exercise,
      color: color ?? this.color,
      isFlipped: isFlipped ?? this.isFlipped,
      fieldValues: fieldValues ?? Map<String, String>.from(this.fieldValues),
    );
  }

  // Helper method to update a single field value
  CardModel updateFieldValue(String fieldName, String value) {
    final updatedValues = Map<String, String>.from(fieldValues);
    updatedValues[fieldName] = value;
    return copyWith(fieldValues: updatedValues);
  }
}
