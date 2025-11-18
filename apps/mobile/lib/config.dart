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
  // TODO: Add your configuration values here
  // ============================================================================
}
