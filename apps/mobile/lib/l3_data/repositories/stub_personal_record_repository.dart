import '../../l2_domain/legacy_models/personal_record.dart';
import 'personal_record_repository.dart';

/// In-memory implementation of PersonalRecordRepository for testing
class StubPersonalRecordRepository implements PersonalRecordRepository {
  final List<PersonalRecord> _prs = [];

  @override
  Future<void> save(PersonalRecord pr) async {
    // Remove any existing PR with same id
    _prs.removeWhere((p) => p.id == pr.id);
    _prs.add(pr);
  }

  @override
  Future<PersonalRecord?> getCurrentPR(String exerciseId, String type) async {
    final prsForExercise = _prs
        .where((pr) => pr.exerciseId == exerciseId && pr.type == type)
        .toList();

    if (prsForExercise.isEmpty) return null;

    // Sort by value descending, then by date descending
    prsForExercise.sort((a, b) {
      final valueComparison = b.value.compareTo(a.value);
      if (valueComparison != 0) return valueComparison;
      return b.achievedAt.compareTo(a.achievedAt);
    });

    return prsForExercise.first;
  }

  @override
  Future<List<PersonalRecord>> getPRsByExercise(String exerciseId) async {
    return _prs.where((pr) => pr.exerciseId == exerciseId).toList();
  }

  @override
  Future<List<PersonalRecord>> getAllPRs() async {
    return List<PersonalRecord>.from(_prs);
  }

  @override
  Future<void> deletePRsForExercise(String exerciseId) async {
    _prs.removeWhere((pr) => pr.exerciseId == exerciseId);
  }

  // Helper methods for testing
  void clear() {
    _prs.clear();
  }

  int get count => _prs.length;

  List<PersonalRecord> get all => List.unmodifiable(_prs);
}
