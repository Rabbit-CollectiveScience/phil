import '../../legacy_models/personal_record.dart';
import '../../legacy_models/pr_item_with_exercise.dart';
import '../../legacy_models/exercise.dart';
import '../../../l3_data/repositories/personal_record_repository.dart';
import '../../../l3_data/repositories/exercise_repository.dart';

/// Use case to get all PRs with exercise details
/// Returns PRs sorted by date (newest first) with exercise metadata joined
class GetAllPRsUseCase {
  final PersonalRecordRepository _prRepository;
  final ExerciseRepository _exerciseRepository;

  GetAllPRsUseCase(this._prRepository, this._exerciseRepository);

  Future<List<PRItemWithExercise>> execute() async {
    // Get all PRs
    final allPRs = await _prRepository.getAllPRs();

    // Get all exercises
    final allExercises = await _exerciseRepository.getAllExercises();

    // Create a map for quick exercise lookup
    final exerciseMap = <String, Exercise>{};
    for (var exercise in allExercises) {
      exerciseMap[exercise.id] = exercise;
    }

    // Join PRs with exercise data
    final enrichedPRs = <PRItemWithExercise>[];
    for (var pr in allPRs) {
      final exercise = exerciseMap[pr.exerciseId];

      // Skip PRs for deleted exercises
      if (exercise == null) continue;

      enrichedPRs.add(
        PRItemWithExercise(
          prRecord: pr,
          exerciseName: exercise.name,
          exerciseCategories: exercise.categories,
        ),
      );
    }

    // Sort by date descending (newest first)
    enrichedPRs.sort(
      (a, b) => b.prRecord.achievedAt.compareTo(a.prRecord.achievedAt),
    );

    return enrichedPRs;
  }
}
