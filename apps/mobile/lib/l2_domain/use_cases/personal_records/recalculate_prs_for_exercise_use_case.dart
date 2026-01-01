import '../../models/personal_record.dart';
import '../../../l3_data/repositories/personal_record_repository.dart';
import '../../../l3_data/repositories/workout_set_repository.dart';
import '../../../l3_data/repositories/exercise_repository.dart';

/// Use case to recalculate PRs for an exercise after a workout set is deleted
class RecalculatePRsForExerciseUseCase {
  final PersonalRecordRepository _prRepository;
  final WorkoutSetRepository _workoutSetRepository;
  final ExerciseRepository _exerciseRepository;

  RecalculatePRsForExerciseUseCase(
    this._prRepository,
    this._workoutSetRepository,
    this._exerciseRepository,
  );

  Future<void> execute(String exerciseId) async {
    try {
      // 1. Get exercise info to determine hasWeight
      final exercise = await _exerciseRepository.getExerciseById(exerciseId);

      // Check if exercise has a weight field
      final hasWeight = exercise.fields.any((field) => field.name == 'weight');

      // 2. Get all workout sets for this exercise
      final allSets = await _workoutSetRepository.getWorkoutSets();
      final setsForExercise = allSets
          .where((set) => set.exerciseId == exerciseId)
          .toList();

      // 3. Delete all existing PRs for this exercise
      await _prRepository.deletePRsForExercise(exerciseId);

      // If no sets remain, we're done
      if (setsForExercise.isEmpty) return;

      // 4. Calculate max values
      double? maxWeight;
      DateTime? maxWeightDate;
      double? maxReps;
      DateTime? maxRepsDate;
      double? maxVolume;
      DateTime? maxVolumeDate;

      for (final set in setsForExercise) {
        if (set.values == null) continue;

        // Convert to double, handling both int and double types
        final weight = (set.values!['weight'] as num?)?.toDouble();
        final reps = (set.values!['reps'] as num?)?.toDouble();

        // Track maxWeight for weighted exercises
        if (hasWeight && weight != null && weight > 0) {
          if (maxWeight == null || weight > maxWeight) {
            maxWeight = weight;
            maxWeightDate = set.completedAt;
          }
        }

        // Track maxReps for bodyweight exercises
        if (!hasWeight && reps != null && reps > 0) {
          if (maxReps == null || reps > maxReps) {
            maxReps = reps;
            maxRepsDate = set.completedAt;
          }
        }

        // Track maxVolume for weighted exercises
        if (hasWeight &&
            weight != null &&
            weight > 0 &&
            reps != null &&
            reps > 0) {
          final volume = weight * reps;
          if (maxVolume == null || volume > maxVolume) {
            maxVolume = volume;
            maxVolumeDate = set.completedAt;
          }
        }
      }

      // 5. Create new PRs based on max values found
      if (maxWeight != null && maxWeightDate != null) {
        await _prRepository.save(
          PersonalRecord(
            id: 'pr_${exerciseId}_maxWeight_${DateTime.now().millisecondsSinceEpoch}',
            exerciseId: exerciseId,
            type: PRType.maxWeight,
            value: maxWeight,
            achievedAt: maxWeightDate,
          ),
        );
      }

      if (maxReps != null && maxRepsDate != null) {
        await _prRepository.save(
          PersonalRecord(
            id: 'pr_${exerciseId}_maxReps_${DateTime.now().millisecondsSinceEpoch}',
            exerciseId: exerciseId,
            type: PRType.maxReps,
            value: maxReps,
            achievedAt: maxRepsDate,
          ),
        );
      }

      if (maxVolume != null && maxVolumeDate != null) {
        await _prRepository.save(
          PersonalRecord(
            id: 'pr_${exerciseId}_maxVolume_${DateTime.now().millisecondsSinceEpoch}',
            exerciseId: exerciseId,
            type: PRType.maxVolume,
            value: maxVolume,
            achievedAt: maxVolumeDate,
          ),
        );
      }
    } catch (e) {
      // Exercise not found - skip recalculation
      return;
    }
  }
}
