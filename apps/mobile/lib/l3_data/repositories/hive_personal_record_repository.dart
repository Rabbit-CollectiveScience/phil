import 'package:hive/hive.dart';
import '../../l2_domain/legacy_models/personal_record.dart';
import 'personal_record_repository.dart';

/// Hive-based implementation of PersonalRecordRepository
/// Stores personal records in local Hive database
class HivePersonalRecordRepository implements PersonalRecordRepository {
  static const String _boxName = 'personal_records';
  Box<Map>? _box;

  Future<Box<Map>> get _getBox async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox<Map>(_boxName);
    return _box!;
  }

  String _makeKey(String exerciseId, String type) {
    return '${exerciseId}_$type';
  }

  @override
  Future<void> save(PersonalRecord pr) async {
    final box = await _getBox;
    final key = _makeKey(pr.exerciseId, pr.type);
    await box.put(key, pr.toJson());
  }

  @override
  Future<PersonalRecord?> getCurrentPR(String exerciseId, String type) async {
    final box = await _getBox;
    final key = _makeKey(exerciseId, type);
    final data = box.get(key);
    if (data == null) return null;
    return PersonalRecord.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<List<PersonalRecord>> getPRsByExercise(String exerciseId) async {
    final box = await _getBox;
    final prs = <PersonalRecord>[];

    // Check for standard PR types
    for (final type in ['maxWeight', 'maxReps', 'maxVolume']) {
      final key = _makeKey(exerciseId, type);
      final data = box.get(key);
      if (data != null) {
        prs.add(PersonalRecord.fromJson(Map<String, dynamic>.from(data)));
      }
    }

    return prs;
  }

  @override
  Future<List<PersonalRecord>> getAllPRs() async {
    final box = await _getBox;
    final prs = <PersonalRecord>[];

    for (var data in box.values) {
      prs.add(PersonalRecord.fromJson(Map<String, dynamic>.from(data)));
    }

    return prs;
  }

  @override
  Future<void> deletePRsForExercise(String exerciseId) async {
    final box = await _getBox;

    // Delete standard PR types
    for (final type in ['maxWeight', 'maxReps', 'maxVolume']) {
      final key = _makeKey(exerciseId, type);
      await box.delete(key);
    }
  }
}
