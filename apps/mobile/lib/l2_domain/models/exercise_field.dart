import 'field_type_enum.dart';

// Model: Metadata about a field that an exercise tracks
//
// Purpose:
// - Defines what data an exercise collects (weight, reps, duration, etc.)
// - Provides UI rendering hints (label, unit, type)
// - Optional default value for new workout sessions
//
// Used by:
// - Exercise model to define its trackable fields
// - UI to dynamically render input fields

class ExerciseField {
  final String
  name; // Internal field name (e.g., "weight", "reps", "durationInSeconds")
  final String
  label; // Display label for UI (e.g., "Weight", "Reps", "Duration")
  final String
  unit; // Unit of measurement (e.g., "kg", "reps", "seconds", "mph")
  final FieldTypeEnum type; // Input type for UI rendering
  final dynamic defaultValue; // Optional default/suggested starting value

  ExerciseField({
    required this.name,
    required this.label,
    required this.unit,
    required this.type,
    this.defaultValue,
  });

  factory ExerciseField.fromJson(Map<String, dynamic> json) {
    return ExerciseField(
      name: json['name'] as String,
      label: json['label'] as String,
      unit: json['unit'] as String,
      type: _parseFieldType(json['type'] as String),
      defaultValue: json['defaultValue'],
    );
  }

  static FieldTypeEnum _parseFieldType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'number':
        return FieldTypeEnum.number;
      case 'duration':
        return FieldTypeEnum.duration;
      case 'text':
        return FieldTypeEnum.text;
      case 'boolean':
        return FieldTypeEnum.boolean;
      default:
        return FieldTypeEnum.number; // Default fallback
    }
  }
}
