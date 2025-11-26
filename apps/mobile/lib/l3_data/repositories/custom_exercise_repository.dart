import 'package:hive/hive.dart';
import '../../l2_domain/models/custom_exercise.dart';

class CustomExerciseRepository {
  static const String _boxName = 'customExercises';
  Box<CustomExercise>? _box;

  /// Initialize the Hive box
  Future<void> initialize() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<CustomExercise>(_boxName);
    }
  }

  /// Ensure box is initialized before operations
  Future<Box<CustomExercise>> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      await initialize();
    }
    return _box!;
  }

  /// Create a new custom exercise
  Future<void> create(CustomExercise exercise) async {
    final box = await _getBox();
    await box.put(exercise.id, exercise);
  }

  /// Get all custom exercises
  Future<List<CustomExercise>> getAll() async {
    final box = await _getBox();
    return box.values.toList();
  }

  /// Find exercise by exact name match
  Future<CustomExercise?> findByName(String name) async {
    final box = await _getBox();
    return box.values.firstWhere(
      (exercise) => exercise.name.toLowerCase() == name.toLowerCase(),
      orElse: () => throw StateError('Not found'),
    );
  }

  /// Find exercises by category
  Future<List<CustomExercise>> findByCategory(String category) async {
    final box = await _getBox();
    return box.values
        .where((exercise) => exercise.category == category)
        .toList();
  }

  /// Check if exercise exists by name
  Future<bool> exists(String name) async {
    final box = await _getBox();
    return box.values.any(
      (exercise) => exercise.name.toLowerCase() == name.toLowerCase(),
    );
  }

  /// Check if exercise exists by ID
  Future<bool> existsById(String id) async {
    final box = await _getBox();
    return box.containsKey(id);
  }

  /// Delete a custom exercise by ID
  Future<void> delete(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  /// Delete all custom exercises
  Future<void> deleteAll() async {
    final box = await _getBox();
    await box.clear();
  }

  /// Get exercise by ID
  Future<CustomExercise?> getById(String id) async {
    final box = await _getBox();
    return box.get(id);
  }

  /// Get count of custom exercises
  Future<int> count() async {
    final box = await _getBox();
    return box.length;
  }

  /// Search exercises by partial name match
  Future<List<CustomExercise>> searchByName(String query) async {
    final box = await _getBox();
    final lowerQuery = query.toLowerCase();
    return box.values
        .where((exercise) => exercise.name.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
