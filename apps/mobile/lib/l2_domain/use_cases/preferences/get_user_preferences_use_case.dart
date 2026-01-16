import '../../../l3_data/repositories/user_preferences_repository.dart';
import '../../models/user_preferences.dart';

/// Use case for retrieving user preferences
///
/// This use case fetches the user's preferences including their preferred
/// measurement system (metric or imperial).
class GetUserPreferencesUseCase {
  final UserPreferencesRepository _repository;

  GetUserPreferencesUseCase({required UserPreferencesRepository repository})
    : _repository = repository;

  /// Execute the use case to get user preferences
  ///
  /// Returns the user's preferences, defaulting to auto-detected values
  /// if no preferences have been saved yet.
  Future<UserPreferences> call() async {
    try {
      final preferences = await _repository.getUserPreferences();
      return preferences;
    } catch (e) {
      // If any error occurs, return safe defaults
      return UserPreferences.defaultPreferences();
    }
  }
}
