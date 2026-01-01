import '../../../l3_data/repositories/workout_set_repository.dart';
import '../../../l3_data/repositories/personal_record_repository.dart';
import '../../../l3_data/repositories/exercise_repository.dart';
import '../personal_records/recalculate_prs_for_exercise_use_case.dart';

// Use Case: Remove a completed workout set
//
// Responsibility:
// - Delete a workout set from data store by ID
// - Repository handles the actual deletion
//
// Used by: CompletedListPage when user deletes a workout entry

class RemoveWorkoutSetUseCase {
  final WorkoutSetRepository _repository;
  final PersonalRecordRepository? _prRepository;
  final ExerciseRepository? _exerciseRepository;

  RemoveWorkoutSetUseCase(
    this._repository, {
    PersonalRecordRepository? prRepository,
    ExerciseRepository? exerciseRepository,
  }) : _prRepository = prRepository,
       _exerciseRepository = exerciseRepository;

  Future<void> execute(String workoutSetId) async {
    // Get the set before deleting to know which exercise it was for
    final allSets = await _repository.getWorkoutSets();
    final setToDelete = allSets.where((s) => s.id == workoutSetId).firstOrNull;
    final exerciseId = setToDelete?.exerciseId;

    // Delete the set
    await _repository.deleteWorkoutSet(workoutSetId);

    // Recalculate PRs for this exercise if repositories are provided
    if (exerciseId != null &&
        _prRepository != null &&
        _exerciseRepository != null) {
      final recalculateUseCase = RecalculatePRsForExerciseUseCase(
        _prRepository!,
        _repository,
        _exerciseRepository!,
      );
      await recalculateUseCase.execute(exerciseId);
    }
  }
}
