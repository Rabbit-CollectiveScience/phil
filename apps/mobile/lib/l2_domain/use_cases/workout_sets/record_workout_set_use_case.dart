import '../../models/workout_sets/workout_set.dart';
import '../../../l3_data/repositories/workout_set_repository.dart';
import '../../../l3_data/repositories/personal_record_repository.dart';
import '../../../l3_data/repositories/exercise_repository.dart';
import '../personal_records/recalculate_prs_for_exercise_use_case.dart';

// Use Case: Record a completed workout set
//
// Responsibility:
// - Save a WorkoutSet (already constructed by UI) to data store
// - Trigger PR recalculation for the exercise
//
// Used by: SwipeableCard when user completes exercise (presses ZET button)
// Note: UI is responsible for constructing the correct WorkoutSet subtype

class RecordWorkoutSetUseCase {
  final WorkoutSetRepository _repository;
  final PersonalRecordRepository? _prRepository;
  final ExerciseRepository? _exerciseRepository;

  RecordWorkoutSetUseCase(
    this._repository, {
    PersonalRecordRepository? prRepository,
    ExerciseRepository? exerciseRepository,
  }) : _prRepository = prRepository,
       _exerciseRepository = exerciseRepository;

  Future<WorkoutSet> execute({required WorkoutSet workoutSet}) async {
    // Save to repository
    final savedSet = await _repository.save(workoutSet);

    // Recalculate PRs for this exercise if repositories are provided
    if (_prRepository != null && _exerciseRepository != null) {
      try {
        final recalculateUseCase = RecalculatePRsForExerciseUseCase(
          _prRepository,
          _repository,
          _exerciseRepository,
        );
        await recalculateUseCase.execute(workoutSet.exerciseId);
      } catch (e) {
        // Exercise not found or PR recalculation failed - continue anyway
      }
    }

    return savedSet;
  }
}
