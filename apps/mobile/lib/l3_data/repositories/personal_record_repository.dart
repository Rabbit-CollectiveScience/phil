import '../../l2_domain/models/personal_record.dart';

/// Repository interface for Personal Records
abstract class PersonalRecordRepository {
  /// Save a personal record
  Future<void> save(PersonalRecord pr);

  /// Get the current best PR for an exercise and type
  Future<PersonalRecord?> getCurrentPR(String exerciseId, PRType type);

  /// Get all PRs for a specific exercise
  Future<List<PersonalRecord>> getPRsByExercise(String exerciseId);

  /// Delete all PRs for a specific exercise
  Future<void> deletePRsForExercise(String exerciseId);
}
