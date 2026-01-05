/// UI model for exercise filter type options
/// Used in the filter grid modal for display
class ExerciseFilterTypeOption {
  final String id;
  final String label;
  final String imagePath;

  const ExerciseFilterTypeOption({
    required this.id,
    required this.label,
    required this.imagePath,
  });

  /// All available filter type options
  static const List<ExerciseFilterTypeOption> allOptions = [
    ExerciseFilterTypeOption(
      id: 'chest',
      label: 'Chest',
      imagePath: 'assets/images/exercise_types/chest.png',
    ),
    ExerciseFilterTypeOption(
      id: 'back',
      label: 'Back',
      imagePath: 'assets/images/exercise_types/back.png',
    ),
    ExerciseFilterTypeOption(
      id: 'legs',
      label: 'Legs',
      imagePath: 'assets/images/exercise_types/legs.png',
    ),
    ExerciseFilterTypeOption(
      id: 'arms',
      label: 'Arms',
      imagePath: 'assets/images/exercise_types/arms.png',
    ),
    ExerciseFilterTypeOption(
      id: 'shoulders',
      label: 'Shoulders',
      imagePath: 'assets/images/exercise_types/shoulders.png',
    ),
    ExerciseFilterTypeOption(
      id: 'core',
      label: 'Core',
      imagePath: 'assets/images/exercise_types/core.png',
    ),
    ExerciseFilterTypeOption(
      id: 'cardio',
      label: 'Cardio',
      imagePath: 'assets/images/exercise_types/cardio.png',
    ),
    ExerciseFilterTypeOption(
      id: 'all',
      label: 'All',
      imagePath: 'assets/images/exercise_types/all.png',
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
