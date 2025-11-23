import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

/// Service for managing user preferences and settings
class SettingsService {
  static SettingsService? _instance;
  static SharedPreferences? _prefs;
  static final ValueNotifier<String?> speechLanguageNotifier =
      ValueNotifier<String?>(null);

  SettingsService._();

  /// Get singleton instance
  static Future<SettingsService> getInstance() async {
    if (_instance == null) {
      _instance = SettingsService._();
      _prefs = await SharedPreferences.getInstance();
      // Initialize notifier with current value
      speechLanguageNotifier.value = _prefs?.getString(
        Config.speechLanguageKey,
      );
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
  // Speech Language Preference
  // ============================================================================

  /// Get current speech language preference (locale ID like 'en_US', 'th_TH')
  /// Returns null if not set (will use device default)
  String? get speechLanguage => _prefs?.getString(Config.speechLanguageKey);

  /// Set speech language preference
  Future<void> setSpeechLanguage(String? localeId) async {
    if (localeId == null) {
      await _prefs?.remove(Config.speechLanguageKey);
    } else {
      await _prefs?.setString(Config.speechLanguageKey, localeId);
    }
    // Notify listeners of change
    speechLanguageNotifier.value = localeId;
  }

  // ============================================================================
  // Reset Settings
  // ============================================================================

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    await _prefs?.setString(Config.weightUnitKey, Config.defaultWeightUnit);
    await _prefs?.setString(Config.distanceUnitKey, Config.defaultDistanceUnit);
    await setSpeechLanguage(Config.defaultSpeechLanguage);
  }
}
