import '../../../l3_data/repositories/workout_set_repository.dart';
import '../../../l3_data/repositories/personal_record_repository.dart';

/// Use case for clearing all user workout data from the database
/// Used for development and testing purposes
class ClearAllDataUseCase {
  final WorkoutSetRepository _workoutSetRepository;
  final PersonalRecordRepository _personalRecordRepository;

  ClearAllDataUseCase(
    this._workoutSetRepository,
    this._personalRecordRepository,
  );

  /// Execute: Delete all workout sets and personal records
  /// Returns a map with counts of deleted items
  Future<Map<String, int>> execute() async {
    // Get counts before deletion
    final workoutSets = await _workoutSetRepository.getAll();
    final personalRecords = await _personalRecordRepository.getAll();

    final workoutSetCount = workoutSets.length;
    final prCount = personalRecords.length;

    // Delete all data
    await _workoutSetRepository.deleteAll();
    await _personalRecordRepository.deleteAll();

    return {
      'workoutSets': workoutSetCount,
      'personalRecords': prCount,
    };
  }
}
