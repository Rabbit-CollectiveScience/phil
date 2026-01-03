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
      // 1. Get exercise info
      final exercise = await _exerciseRepository.getExerciseById(exerciseId);

      // 2. Get all workout sets for this exercise
      final allSets = await _workoutSetRepository.getWorkoutSets();
      final setsForExercise = allSets
          .where((set) => set.exerciseId == exerciseId)
          .toList();

      // 3. Delete all existing PRs for this exercise
      await _prRepository.deletePRsForExercise(exerciseId);

      // If no sets remain, we're done
      if (setsForExercise.isEmpty) return;

      // 4. Calculate max values for each field dynamically
      final maxValues = <String, Map<String, dynamic>>{};

      for (final set in setsForExercise) {
        if (set.values == null) continue;

        // Check each field defined in the exercise
        for (final field in exercise.fields) {
          final fieldName = field.name;
          final value = set.values![fieldName];

          if (value == null) continue;

          // Convert to double
          final numValue = (value as num?)?.toDouble();
          if (numValue == null || numValue <= 0) continue;

          // Track max value for this field
          final prType =
              'max${fieldName[0].toUpperCase()}${fieldName.substring(1)}';

          if (!maxValues.containsKey(prType) ||
              numValue > maxValues[prType]!['value']) {
            maxValues[prType] = {'value': numValue, 'date': set.completedAt};
          }
        }

        // Calculate derived PRs (like volume = weight × reps)
        final weight = (set.values!['weight'] as num?)?.toDouble();
        final reps = (set.values!['reps'] as num?)?.toDouble();

        if (weight != null && weight > 0 && reps != null && reps > 0) {
          final volume = weight * reps;
          if (!maxValues.containsKey('maxVolume') ||
              volume > maxValues['maxVolume']!['value']) {
            maxValues['maxVolume'] = {'value': volume, 'date': set.completedAt};
          }
        }
      }

      // 5. Create PR records for all max values found
      for (final entry in maxValues.entries) {
        final prType = entry.key;
        final data = entry.value;

        await _prRepository.save(
          PersonalRecord(
            id: 'pr_${exerciseId}_${prType}_${DateTime.now().millisecondsSinceEpoch}',
            exerciseId: exerciseId,
            type: prType,
            value: data['value'],
            achievedAt: data['date'],
          ),
        );
      }
    } catch (e) {
      // Exercise not found - skip recalculation
      return;
    }
  }
}
