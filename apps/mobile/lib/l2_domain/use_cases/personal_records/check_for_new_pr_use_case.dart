import '../../models/personal_record.dart';
import '../../../l3_data/repositories/personal_record_repository.dart';

/// Result of checking for a new PR
class PRCheckResult {
  final bool isNewPR;
  final PRType prType;
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
class CheckForNewPRUseCase {
  final PersonalRecordRepository _repository;

  CheckForNewPRUseCase(this._repository);

  Future<List<PRCheckResult>> execute({
    required String exerciseId,
    required Map<String, dynamic>? values,
    required bool hasWeight,
  }) async {
    if (values == null || values.isEmpty) {
      return [];
    }

    final results = <PRCheckResult>[];
    
    // Convert to double, handling both int and double types
    final weight = (values['weight'] as num?)?.toDouble();
    final reps = (values['reps'] as num?)?.toDouble();

    // Check maxWeight PR (for exercises with weight)
    if (hasWeight && weight != null && weight > 0) {
      final currentPR = await _repository.getCurrentPR(exerciseId, PRType.maxWeight);
      if (currentPR == null || weight > currentPR.value) {
        results.add(PRCheckResult(
          isNewPR: true,
          prType: PRType.maxWeight,
          oldValue: currentPR?.value,
          newValue: weight,
        ));
      }
    }

    // Check maxReps PR (for bodyweight exercises)
    if (!hasWeight && reps != null && reps > 0) {
      final currentPR = await _repository.getCurrentPR(exerciseId, PRType.maxReps);
      if (currentPR == null || reps > currentPR.value) {
        results.add(PRCheckResult(
          isNewPR: true,
          prType: PRType.maxReps,
          oldValue: currentPR?.value,
          newValue: reps,
        ));
      }
    }

    // Check maxVolume PR (weight * reps)
    if (hasWeight && weight != null && weight > 0 && reps != null && reps > 0) {
      final volume = weight * reps;
      final currentPR = await _repository.getCurrentPR(exerciseId, PRType.maxVolume);
      if (currentPR == null || volume > currentPR.value) {
        results.add(PRCheckResult(
          isNewPR: true,
          prType: PRType.maxVolume,
          oldValue: currentPR?.value,
          newValue: volume,
        ));
      }
    }

    return results;
  }
}
