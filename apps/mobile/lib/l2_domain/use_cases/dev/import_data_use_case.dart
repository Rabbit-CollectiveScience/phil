import 'dart:convert';
import 'package:hive/hive.dart';
import 'clear_all_data_use_case.dart';

/// Use case for importing data from JSON format
/// Validates, clears existing data, and imports new data
class ImportDataUseCase {
  final ClearAllDataUseCase _clearAllDataUseCase;

  ImportDataUseCase(
    this._clearAllDataUseCase,
  );

  /// Execute: Import data from JSON string
  /// Returns a map with import summary: {workoutSets: count, personalRecords: count, exercises: count}
  Future<Map<String, int>> execute(String jsonString) async {
    // Parse JSON
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Invalid JSON format: ${e.toString()}');
    }

    // Validate structure
    if (!data.containsKey('workoutSets') ||
        !data.containsKey('personalRecords') ||
        !data.containsKey('exercises')) {
      throw Exception('Invalid data format: missing required fields');
    }

    // Parse data
    final List<dynamic> workoutSetsJson = data['workoutSets'] as List<dynamic>;
    final List<dynamic> personalRecordsJson =
        data['personalRecords'] as List<dynamic>;
    final List<dynamic> exercisesJson = data['exercises'] as List<dynamic>;

    // Clear all existing data first
    await _clearAllDataUseCase.execute();

    // Get Hive boxes
    final exerciseBox = Hive.box<Map<dynamic, dynamic>>('exercises');
    final workoutSetBox = Hive.box<Map<dynamic, dynamic>>('workout_sets');
    final prBox = Hive.box<Map<dynamic, dynamic>>('personal_records');

    // Import exercises first (workout sets reference them)
    int exerciseCount = 0;
    for (final exerciseJson in exercisesJson) {
      try {
        final jsonMap = exerciseJson as Map<String, dynamic>;
        final id = jsonMap['id'] as String;
        await exerciseBox.put(id, jsonMap);
        exerciseCount++;
      } catch (e) {
        print('Failed to import exercise: $e');
      }
    }

    // Import workout sets
    int workoutSetCount = 0;
    for (final setJson in workoutSetsJson) {
      try {
        final jsonMap = setJson as Map<String, dynamic>;
        final id = jsonMap['id'] as String;
        await workoutSetBox.put(id, jsonMap);
        workoutSetCount++;
      } catch (e) {
        print('Failed to import workout set: $e');
      }
    }

    // Import personal records
    int prCount = 0;
    for (final prJson in personalRecordsJson) {
      try {
        final jsonMap = prJson as Map<String, dynamic>;
        final id = jsonMap['id'] as String;
        await prBox.put(id, jsonMap);
        prCount++;
      } catch (e) {
        print('Failed to import personal record: $e');
      }
    }

    return {
      'workoutSets': workoutSetCount,
      'personalRecords': prCount,
      'exercises': exerciseCount,
    };
  }
}
