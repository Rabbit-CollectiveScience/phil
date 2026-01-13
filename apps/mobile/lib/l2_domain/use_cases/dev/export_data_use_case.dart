import 'dart:convert';
import '../../../l3_data/repositories/workout_set_repository.dart';
import '../../../l3_data/repositories/personal_record_repository.dart';
import '../../../l3_data/repositories/exercise_repository.dart';

/// Use case for exporting all user data to JSON format
/// Exports workout sets, personal records, and exercises
class ExportDataUseCase {
  final WorkoutSetRepository _workoutSetRepository;
  final PersonalRecordRepository _personalRecordRepository;
  final ExerciseRepository _exerciseRepository;

  ExportDataUseCase(
    this._workoutSetRepository,
    this._personalRecordRepository,
    this._exerciseRepository,
  );

  /// Execute: Export all data to JSON string
  /// Returns a JSON string containing all workout data
  Future<String> execute() async {
    // Get all data from repositories
    final workoutSets = await _workoutSetRepository.getAll();
    final personalRecords = await _personalRecordRepository.getAll();
    final exercises = await _exerciseRepository.getAll();

    // Convert to JSON
    final exportData = {
      'version': '1.0',
      'exportDate': DateTime.now().toIso8601String(),
      'workoutSets': workoutSets.map((set) => set.toJson()).toList(),
      'personalRecords': personalRecords.map((pr) => pr.toJson()).toList(),
      'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
    };

    return jsonEncode(exportData);
  }
}
