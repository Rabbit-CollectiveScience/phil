import 'package:hive/hive.dart';
import '../../l2_domain/models/personal_records/personal_record.dart';
import '../../l2_domain/models/personal_records/weight_pr.dart';
import '../../l2_domain/models/personal_records/reps_pr.dart';
import '../../l2_domain/models/personal_records/volume_pr.dart';
import '../../l2_domain/models/personal_records/duration_pr.dart';
import '../../l2_domain/models/personal_records/distance_pr.dart';
import '../../l2_domain/models/personal_records/pace_pr.dart';

/// Repository for managing PersonalRecord entities using Hive storage
///
/// Uses single-table inheritance pattern where all PR types
/// are stored in one Hive box with type discriminators for polymorphism.
///
/// All PRs are reference-only (storing workoutSetId, not cached values)
/// to ensure data consistency.
class PersonalRecordRepository {
  static const String _boxName = 'personal_records';

  Box<Map<dynamic, dynamic>> get _box =>
      Hive.box<Map<dynamic, dynamic>>(_boxName);

  /// Deserialize JSON to the appropriate PersonalRecord subclass based on type field
  PersonalRecord _fromJson(Map<dynamic, dynamic> json) {
    final type = json['type'] as String;

    switch (type) {
      case 'weight':
        return WeightPR.fromJson(Map<String, dynamic>.from(json));
      case 'reps':
        return RepsPR.fromJson(Map<String, dynamic>.from(json));
      case 'volume':
        return VolumePR.fromJson(Map<String, dynamic>.from(json));
      case 'duration':
        return DurationPR.fromJson(Map<String, dynamic>.from(json));
      case 'distance':
        return DistancePR.fromJson(Map<String, dynamic>.from(json));
      case 'pace':
        return PacePR.fromJson(Map<String, dynamic>.from(json));
      default:
        throw Exception('Unknown personal record type: $type');
    }
  }

  /// Save or update a personal record
  Future<PersonalRecord> save(PersonalRecord pr) async {
    await _box.put(pr.id, pr.toJson());
    return pr;
  }

  /// Get all personal records
  Future<List<PersonalRecord>> getAll() async {
    return _box.values.map((json) => _fromJson(json)).toList();
  }

  /// Get personal record by ID
  Future<PersonalRecord?> getById(String id) async {
    final json = _box.get(id);
    if (json == null) return null;
    return _fromJson(json);
  }

  /// Get all PRs for a specific exercise
  Future<List<PersonalRecord>> getByExerciseId(String exerciseId) async {
    final all = await getAll();
    return all.where((pr) => pr.exerciseId == exerciseId).toList();
  }

  /// Get PRs by type for a specific exercise
  Future<List<T>> getByExerciseIdAndType<T extends PersonalRecord>(
    String exerciseId,
  ) async {
    final all = await getByExerciseId(exerciseId);
    return all.whereType<T>().toList();
  }

  /// Get the most recent PR for an exercise (by type)
  Future<T?> getMostRecentByType<T extends PersonalRecord>(
    String exerciseId,
  ) async {
    final prs = await getByExerciseIdAndType<T>(exerciseId);
    if (prs.isEmpty) return null;

    prs.sort((a, b) => b.achievedAt.compareTo(a.achievedAt));
    return prs.first;
  }

  /// Get all PRs for a specific workout set
  Future<List<PersonalRecord>> getByWorkoutSetId(String workoutSetId) async {
    final all = await getAll();
    return all.where((pr) => pr.workoutSetId == workoutSetId).toList();
  }

  /// Get PRs within a date range
  Future<List<PersonalRecord>> getByDateRange({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final all = await getAll();

    return all.where((pr) {
      if (startDate != null && pr.achievedAt.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && pr.achievedAt.isAfter(endDate)) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Get all strength PRs (weight, reps, volume)
  Future<List<PersonalRecord>> getStrengthPRs(String exerciseId) async {
    final all = await getByExerciseId(exerciseId);
    return all
        .where((pr) => pr is WeightPR || pr is RepsPR || pr is VolumePR)
        .toList();
  }

  /// Get all cardio PRs (duration, distance, pace)
  Future<List<PersonalRecord>> getCardioPRs(String exerciseId) async {
    final all = await getByExerciseId(exerciseId);
    return all
        .where((pr) => pr is DurationPR || pr is DistancePR || pr is PacePR)
        .toList();
  }

  /// Delete a personal record
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Delete all PRs for a specific exercise
  Future<void> deleteByExerciseId(String exerciseId) async {
    final prs = await getByExerciseId(exerciseId);
    for (final pr in prs) {
      await delete(pr.id);
    }
  }

  /// Delete all PRs for a specific workout set
  Future<void> deleteByWorkoutSetId(String workoutSetId) async {
    final prs = await getByWorkoutSetId(workoutSetId);
    for (final pr in prs) {
      await delete(pr.id);
    }
  }

  /// Delete all personal records
  Future<void> deleteAll() async {
    await _box.clear();
  }

  /// Get count of PRs
  Future<int> getCount({String? exerciseId}) async {
    if (exerciseId != null) {
      final prs = await getByExerciseId(exerciseId);
      return prs.length;
    }
    return _box.length;
  }

  /// Check if a workout set has any PRs
  Future<bool> hasPRs(String workoutSetId) async {
    final prs = await getByWorkoutSetId(workoutSetId);
    return prs.isNotEmpty;
  }
}
