import '../../../l3_data/repositories/preferences_repository.dart';

// Use Case: Get Last Filter Selection
//
// Responsibility:
// - Retrieves the last selected exercise filter ID
// - Provides default value when no selection exists
//
// Business Logic:
// - Returns null if user has never selected a filter
// - Can return 'all' as default for UI convenience

class GetLastFilterSelectionUseCase {
  final PreferencesRepository _preferencesRepository;

  GetLastFilterSelectionUseCase(this._preferencesRepository);

  /// Get last selected filter ID, returns null if never selected
  Future<String?> execute() async {
    return await _preferencesRepository.getLastFilterId();
  }

  /// Get last selected filter ID, returns 'all' as default if never selected
  Future<String> executeWithDefault() async {
    final filterId = await _preferencesRepository.getLastFilterId();
    return filterId ?? 'all';
  }
}
