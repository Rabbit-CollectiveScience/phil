import 'package:hive/hive.dart';
import '../../l2_domain/models/exercises/exercise.dart';
import '../../l2_domain/models/exercises/strength_exercise.dart';
import '../../l2_domain/models/exercises/cardio_exercise.dart';
import '../../l2_domain/models/exercises/bodyweight_exercise.dart';
import '../../l2_domain/models/exercises/free_weight_exercise.dart';
import '../../l2_domain/models/exercises/machine_exercise.dart';
import '../../l2_domain/models/exercises/isometric_exercise.dart';
import '../../l2_domain/models/exercises/distance_cardio_exercise.dart';
import '../../l2_domain/models/exercises/duration_cardio_exercise.dart';

/// Repository for managing Exercise entities using Hive storage
///
/// Uses single-table inheritance pattern where all exercise types
/// are stored in one Hive box with type discriminators for polymorphism.
class ExerciseRepository {
  static const String _boxName = 'exercises';

  Box<Map<dynamic, dynamic>> get _box =>
      Hive.box<Map<dynamic, dynamic>>(_boxName);

  /// Deserialize JSON to the appropriate Exercise subclass based on type field
  Exercise _fromJson(Map<dynamic, dynamic> json) {
    final type = json['type'] as String;

    switch (type) {
      case 'bodyweight':
        return BodyweightExercise.fromJson(Map<String, dynamic>.from(json));
      case 'free_weight':
        return FreeWeightExercise.fromJson(Map<String, dynamic>.from(json));
      case 'machine':
        return MachineExercise.fromJson(Map<String, dynamic>.from(json));
      case 'isometric':
        return IsometricExercise.fromJson(Map<String, dynamic>.from(json));
      case 'distance_cardio':
        return DistanceCardioExercise.fromJson(Map<String, dynamic>.from(json));
      case 'duration_cardio':
        return DurationCardioExercise.fromJson(Map<String, dynamic>.from(json));
      default:
        throw Exception('Unknown exercise type: $type');
    }
  }

  /// Save or update an exercise
  Future<Exercise> save(Exercise exercise) async {
    await _box.put(exercise.id, exercise.toJson());
    return exercise;
  }

  /// Get all exercises
  Future<List<Exercise>> getAll() async {
    return _box.values.map((json) => _fromJson(json)).toList();
  }

  /// Get exercise by ID
  Future<Exercise?> getById(String id) async {
    final json = _box.get(id);
    if (json == null) return null;
    return _fromJson(json);
  }

  /// Get all strength exercises
  Future<List<StrengthExercise>> getAllStrengthExercises() async {
    final all = await getAll();
    return all.whereType<StrengthExercise>().toList();
  }

  /// Get all cardio exercises
  Future<List<CardioExercise>> getAllCardioExercises() async {
    final all = await getAll();
    return all.whereType<CardioExercise>().toList();
  }

  /// Search exercises by name or description
  Future<List<Exercise>> search(String query) async {
    final all = await getAll();
    final lowercaseQuery = query.toLowerCase();

    return all.where((exercise) {
      return exercise.name.toLowerCase().contains(lowercaseQuery) ||
          exercise.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Get custom exercises only
  Future<List<Exercise>> getCustomExercises() async {
    final all = await getAll();
    return all.where((exercise) => exercise.isCustom).toList();
  }

  /// Get preset exercises only
  Future<List<Exercise>> getPresetExercises() async {
    final all = await getAll();
    return all.where((exercise) => !exercise.isCustom).toList();
  }

  /// Delete an exercise
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Delete all exercises
  Future<void> deleteAll() async {
    await _box.clear();
  }

  /// Check if exercise exists
  Future<bool> exists(String id) async {
    return _box.containsKey(id);
  }

  /// Get count of all exercises
  Future<int> getCount() async {
    return _box.length;
  }
}
