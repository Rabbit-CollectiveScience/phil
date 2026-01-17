import '../../../l3_data/repositories/personal_record_repository.dart';
import '../../../l3_data/repositories/workout_set_repository.dart';
import '../../models/exercises/exercise.dart';
import '../../models/exercises/strength_exercise.dart';
import '../../models/personal_records/weight_pr.dart';
import '../../models/workout_sets/weighted_workout_set.dart';
import '../../models/common/equipment_type.dart';
import '../preferences/get_user_preferences_use_case.dart';
import '../../models/user_preferences.dart';

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
    // Only handle strength exercises with equipment type
    if (exercise is! StrengthExercise) return null;
    
    // 1. Find WeightPR for this exercise
    final allPRs = await _prRepository.getByExerciseId(exercise.id);
    final weightPRs = allPRs.whereType<WeightPR>().toList();
    
    if (weightPRs.isEmpty) return null;
    
    // 2. Get most recent WeightPR
    weightPRs.sort((a, b) => b.achievedAt.compareTo(a.achievedAt));
    final latestPR = weightPRs.first;
    
    // 3. Fetch actual WorkoutSet to get weight value
    final workoutSet = await _workoutSetRepository.getById(latestPR.workoutSetId);
    if (workoutSet == null) return null;
    if (workoutSet is! WeightedWorkoutSet) return null;
    
    final weight = workoutSet.weight;
    if (weight == null) return null;
    final prWeight = weight.kg;
    if (prWeight <= 0) return null;
    
    // 4. Get user's unit preference (metric/imperial)
    final prefs = await _preferencesUseCase.call();
    final isMetric = prefs.measurementSystem == MeasurementSystem.metric;
    
    // 5. Calculate percentages and round using exercise.equipmentType
    final strengthExercise = exercise as StrengthExercise;
    final percent100 = strengthExercise.equipmentType.roundToNearest(prWeight * 1.0, isMetric);
    final percent90 = strengthExercise.equipmentType.roundToNearest(prWeight * 0.9, isMetric);
    final percent80 = strengthExercise.equipmentType.roundToNearest(prWeight * 0.8, isMetric);
    final percent50 = strengthExercise.equipmentType.roundToNearest(prWeight * 0.5, isMetric);
    
    // 6. Return PRPercentages object
    return PRPercentages(
      percent100: percent100,
      percent90: percent90,
      percent80: percent80,
      percent50: percent50,
      isMetric: isMetric,
    );
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
