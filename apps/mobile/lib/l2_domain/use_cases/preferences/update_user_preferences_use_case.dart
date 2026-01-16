import '../../../l3_data/repositories/user_preferences_repository.dart';
import '../../models/user_preferences.dart';

/// Use case for updating user preferences
///
/// This use case saves the user's preferences including their preferred
/// measurement system (metric or imperial).
class UpdateUserPreferencesUseCase {
  final UserPreferencesRepository _repository;

  UpdateUserPreferencesUseCase({required UserPreferencesRepository repository})
    : _repository = repository;

  /// Execute the use case to update user preferences
  ///
  /// [preferences] The new preferences to save
  /// Returns true if the update was successful, false otherwise
  Future<bool> call(UserPreferences preferences) async {
    try {
      await _repository.saveUserPreferences(preferences);
      return true;
    } catch (e) {
      return false;
    }
  }
}
