// lib/config.dart

/// Application Configuration
///
/// This file contains all configuration values for the app.
/// Modify these values to match your project requirements.
class Config {
  // ============================================================================
  // API Configuration
  // ============================================================================

  /// Backend API base URL
  /// Development: localhost (use 10.0.2.2 for Android emulator, localhost for iOS simulator)
  /// Production: your production URL
  static const String apiBaseUrl = 'http://localhost:3000';

  /// Gemini API configuration
  static const String geminiApiKey = 'AIzaSyB0AYlGzVo-LgRg8bvfW0KjmostzuhVTew';
  static const String geminiModel = 'gemini-1.5-flash';
  static const int geminiMaxTokens = 150;

  // ============================================================================
  // App Configuration
  // ============================================================================

  /// App name
  static const String appName = 'Boilerplate App';

  /// App version
  static const String appVersion = '1.0.0';

  // ============================================================================
  // Feature Flags
  // ============================================================================

  /// Enable debug logging
  static const bool enableDebugLogging = true;

  /// Enable analytics
  static const bool enableAnalytics = false;

  // ============================================================================
  // Workout Configuration
  // ============================================================================

  /// Time window (in minutes) for auto-grouping exercises into same workout.
  /// Exercises added within this time from the last exercise will be grouped together.
  /// Rolling window based on last exercise's createdAt timestamp.
  static const int workoutSessionTimeoutMinutes = 60;

  // ============================================================================
  // Unit Preferences
  // ============================================================================

  /// Default weight unit (lbs or kg)
  static const String defaultWeightUnit = 'kg';

  /// Default distance unit (miles or km)
  static const String defaultDistanceUnit = 'km';

  /// Default speech language (null = use device default)
  static const String? defaultSpeechLanguage = null;

  /// SharedPreferences key for weight unit
  static const String weightUnitKey = 'weight_unit';

  /// SharedPreferences key for distance unit
  static const String distanceUnitKey = 'distance_unit';

  /// SharedPreferences key for speech language
  static const String speechLanguageKey = 'speech_language';

  // ============================================================================
  // TODO: Add your configuration values here
  // ============================================================================
}
