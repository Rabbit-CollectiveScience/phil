import '../../models/personal_record.dart';
import '../../models/exercise.dart';
import '../../models/field_type_enum.dart';
import '../../../l3_data/repositories/personal_record_repository.dart';

/// Result of checking for a new PR
class PRCheckResult {
  final bool isNewPR;
  final String prType;
  final double? oldValue;
  final double newValue;

  PRCheckResult({
    required this.isNewPR,
    required this.prType,
    this.oldValue,
    required this.newValue,
  });
}

/// Use case to check if a workout set represents a new PR
/// Now supports dynamic PR checking for any numeric field
class CheckForNewPRUseCase {
  final PersonalRecordRepository _repository;

  CheckForNewPRUseCase(this._repository);

  Future<List<PRCheckResult>> execute({
    required String exerciseId,
    required Exercise exercise,
    required Map<String, dynamic>? values,
  }) async {
    if (values == null || values.isEmpty) {
      return [];
    }

    final results = <PRCheckResult>[];

    // Check for PRs on all numeric fields
    for (final field in exercise.fields) {
      // Only track PRs for numeric fields
      if (field.type != FieldTypeEnum.number) continue;

      final fieldValue = values[field.name];
      if (fieldValue == null) continue;

      final numericValue = (fieldValue as num).toDouble();
      if (numericValue <= 0) continue;

      // Check if this is a new PR for this field
      final prType = 'max${_capitalize(field.name)}';
      final currentPR = await _repository.getCurrentPR(exerciseId, prType);

      if (currentPR == null || numericValue > currentPR.value) {
        results.add(
          PRCheckResult(
            isNewPR: true,
            prType: prType,
            oldValue: currentPR?.value,
            newValue: numericValue,
          ),
        );
      }
    }

    // Check for derived PRs (combinations of fields)
    await _checkDerivedPRs(exerciseId, exercise, values, results);

    return results;
  }

  /// Check for derived PRs like volume (weight * reps)
  Future<void> _checkDerivedPRs(
    String exerciseId,
    Exercise exercise,
    Map<String, dynamic> values,
    List<PRCheckResult> results,
  ) async {
    // Check for volume PR (weight * reps)
    final hasWeight = exercise.fields.any((f) => f.name == 'weight');
    final hasReps = exercise.fields.any((f) => f.name == 'reps');

    if (hasWeight && hasReps) {
      final weight = (values['weight'] as num?)?.toDouble();
      final reps = (values['reps'] as num?)?.toDouble();

      if (weight != null && weight > 0 && reps != null && reps > 0) {
        final volume = weight * reps;
        final currentPR = await _repository.getCurrentPR(exerciseId, 'maxVolume');

        if (currentPR == null || volume > currentPR.value) {
          results.add(
            PRCheckResult(
              isNewPR: true,
              prType: 'maxVolume',
              oldValue: currentPR?.value,
              newValue: volume,
            ),
          );
        }
      }
    }
  }

  String _capitalize(String str) {
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1);
  }
}
