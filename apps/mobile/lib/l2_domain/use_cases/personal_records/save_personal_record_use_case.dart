import '../../models/personal_record.dart';
import '../../../l3_data/repositories/personal_record_repository.dart';

/// Use case to save a personal record
class SavePersonalRecordUseCase {
  final PersonalRecordRepository _repository;

  SavePersonalRecordUseCase(this._repository);

  Future<PersonalRecord> execute(PersonalRecord pr) async {
    await _repository.save(pr);
    return pr;
  }
}
