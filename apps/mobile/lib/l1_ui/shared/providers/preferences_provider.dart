import 'package:flutter/foundation.dart';
import '../../../l2_domain/models/user_preferences.dart';
import '../../../l2_domain/use_cases/preferences/get_user_preferences_use_case.dart';
import '../../../l2_domain/use_cases/preferences/update_user_preferences_use_case.dart';
import '../utils/unit_formatters.dart';

/// Provider for managing user preferences state across the app
class PreferencesProvider with ChangeNotifier {
  final GetUserPreferencesUseCase _getUserPreferencesUseCase;
  final UpdateUserPreferencesUseCase _updateUserPreferencesUseCase;

  UserPreferences? _preferences;
  UnitFormatters? _formatters;
  bool _isLoading = true;
  String? _error;

  PreferencesProvider({
    required GetUserPreferencesUseCase getUserPreferencesUseCase,
    required UpdateUserPreferencesUseCase updateUserPreferencesUseCase,
  }) : _getUserPreferencesUseCase = getUserPreferencesUseCase,
       _updateUserPreferencesUseCase = updateUserPreferencesUseCase;

  // Getters
  UserPreferences? get preferences => _preferences;
  UnitFormatters get formatters =>
      _formatters ?? UnitFormatters(MeasurementSystem.metric);
  bool get isLoading => _isLoading;
  String? get error => _error;
  MeasurementSystem get measurementSystem =>
      _preferences?.measurementSystem ?? MeasurementSystem.metric;

  /// Initialize preferences by loading from repository
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _preferences = await _getUserPreferencesUseCase();
      _formatters = UnitFormatters(_preferences!.measurementSystem);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load preferences: $e';
      _isLoading = false;
      // Fall back to default preferences
      _preferences = UserPreferences.defaultPreferences();
      _formatters = UnitFormatters(_preferences!.measurementSystem);
      notifyListeners();
    }
  }

  /// Update measurement system preference
  Future<bool> updateMeasurementSystem(MeasurementSystem system) async {
    try {
      final newPreferences = UserPreferences(measurementSystem: system);
      final success = await _updateUserPreferencesUseCase(newPreferences);

      if (success) {
        _preferences = newPreferences;
        _formatters = UnitFormatters(system);
        notifyListeners();
      }

      return success;
    } catch (e) {
      _error = 'Failed to update preferences: $e';
      notifyListeners();
      return false;
    }
  }

  /// Refresh preferences from repository
  Future<void> refresh() async {
    await initialize();
  }
}
