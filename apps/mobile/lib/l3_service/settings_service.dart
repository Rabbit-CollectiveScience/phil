import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

/// Service for managing user preferences and settings
class SettingsService {
  static SettingsService? _instance;
  static SharedPreferences? _prefs;

  SettingsService._();

  /// Get singleton instance
  static Future<SettingsService> getInstance() async {
    if (_instance == null) {
      _instance = SettingsService._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // ============================================================================
  // Weight Unit Preference
  // ============================================================================

  /// Get current weight unit preference (lbs or kg)
  String get weightUnit =>
      _prefs?.getString(Config.weightUnitKey) ?? Config.defaultWeightUnit;

  /// Set weight unit preference
  Future<void> setWeightUnit(String unit) async {
    await _prefs?.setString(Config.weightUnitKey, unit);
  }

  // ============================================================================
  // Distance Unit Preference
  // ============================================================================

  /// Get current distance unit preference (miles or km)
  String get distanceUnit =>
      _prefs?.getString(Config.distanceUnitKey) ?? Config.defaultDistanceUnit;

  /// Set distance unit preference
  Future<void> setDistanceUnit(String unit) async {
    await _prefs?.setString(Config.distanceUnitKey, unit);
  }

  // ============================================================================
  // Reset Settings
  // ============================================================================

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    await _prefs?.setString(Config.weightUnitKey, Config.defaultWeightUnit);
    await _prefs?.setString(Config.distanceUnitKey, Config.defaultDistanceUnit);
  }
}
