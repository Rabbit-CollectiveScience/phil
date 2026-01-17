import '../../../l3_data/repositories/personal_record_repository.dart';
import '../../../l3_data/repositories/workout_set_repository.dart';
import '../../models/exercises/exercise.dart';
import '../preferences/get_user_preferences_use_case.dart';

/// Calculates PR percentage values (100%, 90%, 80%, 50%) for an exercise
/// with smart weight rounding based on equipment type.
///
/// Returns null if no WeightPR exists for the exercise.
class CalculatePRPercentagesUseCase {
  final PersonalRecordRepository _prRepository;
  final WorkoutSetRepository _workoutSetRepository;
  final GetUserPreferencesUseCase _preferencesUseCase;

  CalculatePRPercentagesUseCase(
    this._prRepository,
    this._workoutSetRepository,
    this._preferencesUseCase,
  );

  /// Execute the use case for a given exercise
  /// Returns PRPercentages with rounded values, or null if no PR found
  Future<PRPercentages?> execute(Exercise exercise) async {
    // TODO: Phase 4 - Implement
    // 1. Find WeightPR for this exercise
    // 2. Fetch actual WorkoutSet to get weight value
    // 3. Get user's unit preference (metric/imperial)
    // 4. Calculate percentages and round using exercise.roundToNearest()
    // 5. Return PRPercentages object
    throw UnimplementedError('Phase 4: Implement use case logic');
  }
}

/// Value object containing pre-calculated and rounded PR percentages
class PRPercentages {
  final double percent100;
  final double percent90;
  final double percent80;
  final double percent50;
  final bool isMetric;

  const PRPercentages({
    required this.percent100,
    required this.percent90,
    required this.percent80,
    required this.percent50,
    required this.isMetric,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PRPercentages &&
          runtimeType == other.runtimeType &&
          percent100 == other.percent100 &&
          percent90 == other.percent90 &&
          percent80 == other.percent80 &&
          percent50 == other.percent50 &&
          isMetric == other.isMetric;

  @override
  int get hashCode =>
      percent100.hashCode ^
      percent90.hashCode ^
      percent80.hashCode ^
      percent50.hashCode ^
      isMetric.hashCode;

  @override
  String toString() =>
      'PRPercentages(100%: $percent100, 90%: $percent90, 80%: $percent80, 50%: $percent50, metric: $isMetric)';
}
