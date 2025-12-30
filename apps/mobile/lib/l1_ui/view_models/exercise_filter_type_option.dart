import 'package:flutter/material.dart';

/// UI model for exercise filter type options
/// Used in the filter grid modal for display
class ExerciseFilterTypeOption {
  final String id;
  final String label;
  final IconData icon;

  const ExerciseFilterTypeOption({
    required this.id,
    required this.label,
    required this.icon,
  });

  /// All available filter type options
  static const List<ExerciseFilterTypeOption> allOptions = [
    ExerciseFilterTypeOption(id: 'chest', label: 'Chest', icon: Icons.shield),
    ExerciseFilterTypeOption(
      id: 'back',
      label: 'Back',
      icon: Icons.accessibility_new,
    ),
    ExerciseFilterTypeOption(
      id: 'legs',
      label: 'Legs',
      icon: Icons.directions_run,
    ),
    ExerciseFilterTypeOption(
      id: 'arms',
      label: 'Arms',
      icon: Icons.fitness_center,
    ),
    ExerciseFilterTypeOption(
      id: 'shoulders',
      label: 'Shoulders',
      icon: Icons.arrow_upward,
    ),
    ExerciseFilterTypeOption(
      id: 'core',
      label: 'Core',
      icon: Icons.crisis_alert,
    ),
    ExerciseFilterTypeOption(
      id: 'cardio',
      label: 'Cardio',
      icon: Icons.favorite,
    ),
    ExerciseFilterTypeOption(
      id: 'flexibility',
      label: 'Flexibility',
      icon: Icons.self_improvement,
    ),
    ExerciseFilterTypeOption(
      id: 'all',
      label: 'All',
      icon: Icons.border_all,
    ),
  ];

  /// Get option by ID
  static ExerciseFilterTypeOption getById(String id) {
    return allOptions.firstWhere(
      (option) => option.id == id,
      orElse: () => allOptions.first, // Default to "All"
    );
  }
}
