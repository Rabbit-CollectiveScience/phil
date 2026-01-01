import 'package:uuid/uuid.dart';
import '../../models/workout_set.dart';
import '../../../l3_data/repositories/workout_set_repository.dart';
import '../../../l3_data/repositories/personal_record_repository.dart';
import '../../../l3_data/repositories/exercise_repository.dart';
import '../personal_records/check_for_new_pr_use_case.dart';
import '../personal_records/save_personal_record_use_case.dart';
import '../../models/personal_record.dart';

// Use Case: Record a completed workout set
//
// Responsibility:
// - Create WorkoutSet with exercise data and completion timestamp
// - Validate set data based on exercise type (optional validation)
// - Save set to data store
// - Update workout session progress
//
// Used by: SwipeableCard when user completes exercise (presses ZET button)

class RecordWorkoutSetUseCase {
  final WorkoutSetRepository _repository;
  final PersonalRecordRepository? _prRepository;
  final ExerciseRepository? _exerciseRepository;
  final _uuid = const Uuid();

  RecordWorkoutSetUseCase(
    this._repository, {
    PersonalRecordRepository? prRepository,
    ExerciseRepository? exerciseRepository,
  }) : _prRepository = prRepository,
       _exerciseRepository = exerciseRepository;

  Future<WorkoutSet> execute({
    required String exerciseId,
    Map<String, dynamic>? values,
    DateTime? completedAt,
  }) async {
    // Create WorkoutSet with specified timestamp or current time
    final workoutSet = WorkoutSet(
      id: _uuid.v4(),
      exerciseId: exerciseId,
      completedAt: completedAt ?? DateTime.now(),
      values: values,
    );

    // Save to repository
    final savedSet = await _repository.saveWorkoutSet(workoutSet);

    // Check for new PRs if repositories are provided
    if (_prRepository != null && _exerciseRepository != null) {
      await _checkAndSavePRs(exerciseId, values, completedAt ?? DateTime.now());
    }

    return savedSet;
  }

  Future<void> _checkAndSavePRs(
    String exerciseId,
    Map<String, dynamic>? values,
    DateTime achievedAt,
  ) async {
    if (_prRepository == null || _exerciseRepository == null) return;

    try {
      // Get exercise info for dynamic PR checking
      final exercise = await _exerciseRepository!.getExerciseById(exerciseId);

      // Check for new PRs using dynamic field-based logic
      final checkUseCase = CheckForNewPRUseCase(_prRepository!);
      final prCheckResults = await checkUseCase.execute(
        exerciseId: exerciseId,
        exercise: exercise,
        values: values,
      );

      // Save new PRs
      if (prCheckResults.isNotEmpty) {
        final saveUseCase = SavePersonalRecordUseCase(_prRepository!);
        for (final result in prCheckResults) {
          if (result.isNewPR) {
            final pr = PersonalRecord(
              id: 'pr_${exerciseId}_${result.prType}_${DateTime.now().millisecondsSinceEpoch}',
              exerciseId: exerciseId,
              type: result.prType,
              value: result.newValue,
              achievedAt: achievedAt,
            );
            await saveUseCase.execute(pr);
          }
        }
      }
    } catch (e) {
      // Exercise not found - skip PR checking
      return;
    }
  }
}
