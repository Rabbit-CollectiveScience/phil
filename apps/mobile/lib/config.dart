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

  /// Google Cloud Text-to-Speech API configuration
  static const String ttsApiKey =
      'AIzaSyB0AYlGzVo-LgRg8bvfW0KjmostzuhVTew'; // Same key works for both

  /// TTS Quality Preference
  /// 'chirp3' = Chirp3-HD voices (highest quality, ~$200/1M chars)
  /// 'neural2' = Neural2 voices (high quality, $16/1M chars)
  /// 'standard' = Standard voices (basic quality, $4/1M chars)
  static const String ttsQualityPreference = 'chirp3';

  /// Voice gender preference
  static const String ttsGenderPreference = 'MALE'; // 'MALE' or 'FEMALE'

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
