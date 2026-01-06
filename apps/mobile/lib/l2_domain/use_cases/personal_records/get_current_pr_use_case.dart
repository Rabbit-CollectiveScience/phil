import '../../legacy_models/personal_record.dart';
import '../../../l3_data/repositories/personal_record_repository.dart';

/// Use case to get the current best PR for an exercise and type
class GetCurrentPRUseCase {
  final PersonalRecordRepository _repository;

  GetCurrentPRUseCase(this._repository);

  Future<PersonalRecord?> execute(String exerciseId, String type) async {
    return await _repository.getCurrentPR(exerciseId, type);
  }
}
