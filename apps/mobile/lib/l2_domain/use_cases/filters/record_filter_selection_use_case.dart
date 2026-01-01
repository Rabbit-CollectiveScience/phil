import '../../../l3_data/repositories/preferences_repository.dart';

// Use Case: Record Filter Selection
//
// Responsibility:
// - Saves user's filter selection with timestamp
// - Updates both filter ID and selection time
//
// Business Logic:
// - Uses current time if no timestamp provided
// - Stores selection for later retrieval by other use cases

class RecordFilterSelectionUseCase {
  final PreferencesRepository _preferencesRepository;

  RecordFilterSelectionUseCase(this._preferencesRepository);

  /// Record user's filter selection
  ///
  /// [filterId] - The selected filter ('chest', 'legs', 'all', etc.)
  /// [timestamp] - When selection was made (defaults to now)
  Future<void> execute(String filterId, {DateTime? timestamp}) async {
    final selectionTime = timestamp ?? DateTime.now();
    await _preferencesRepository.saveFilterSelection(filterId, selectionTime);
  }
}
