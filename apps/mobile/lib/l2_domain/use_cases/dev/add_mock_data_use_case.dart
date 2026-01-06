import '../../../l3_data/repositories/workout_set_repository.dart';
import '../../../l3_data/repositories/exercise_repository.dart';
import '../personal_records/recalculate_prs_for_exercise_use_case.dart';
import 'mock_data_generator.dart';

/// Use case for adding mock workout data to the database
/// Used for development and testing purposes
class AddMockDataUseCase {
  final WorkoutSetRepository _workoutSetRepository;
  final ExerciseRepository _exerciseRepository;
  final RecalculatePRsForExerciseUseCase _recalculatePRsUseCase;

  AddMockDataUseCase(
    this._workoutSetRepository,
    this._exerciseRepository,
    this._recalculatePRsUseCase,
  );

  /// Execute: Generate and save comprehensive mock workout data
  /// Returns the number of workout sets added
  Future<int> execute() async {
    // Get all available exercises
    final exercises = await _exerciseRepository.getAll();

    if (exercises.isEmpty) {
      throw Exception('No exercises available to generate mock data');
    }

    // Generate mock workout sets
    final mockSets = MockDataGenerator.generateMockWorkoutSets(exercises);

    // Save all workout sets
    int savedCount = 0;
    final Set<String> exerciseIds = {};

    for (final workoutSet in mockSets) {
      try {
        await _workoutSetRepository.save(workoutSet);
        savedCount++;
        exerciseIds.add(workoutSet.exerciseId);
      } catch (e) {
        // Continue even if some sets fail
        print('Failed to save workout set: $e');
      }
    }

    // Recalculate PRs for all exercises that had sets added
    print('Recalculating PRs for ${exerciseIds.length} exercises...');
    for (final exerciseId in exerciseIds) {
      try {
        await _recalculatePRsUseCase.execute(exerciseId);
      } catch (e) {
        print('Failed to recalculate PRs for exercise $exerciseId: $e');
      }
    }

    return savedCount;
  }
}
