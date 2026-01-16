import 'package:shared_preferences/shared_preferences.dart';
import '../../l2_domain/models/user_preferences.dart';

/// Repository for managing user preferences storage
class UserPreferencesRepository {
  static const String _measurementSystemKey = 'measurement_system';

  /// Get the user's preferred measurement system
  ///
  /// Returns [MeasurementSystem.metric] as default if not set
  Future<MeasurementSystem> getMeasurementSystem() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_measurementSystemKey);

      if (value == null) {
        return MeasurementSystem.metric;
      }

      return MeasurementSystem.fromJson(value);
    } catch (e) {
      // If any error occurs, return safe default
      return MeasurementSystem.metric;
    }
  }

  /// Set the user's preferred measurement system
  Future<void> setMeasurementSystem(MeasurementSystem system) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_measurementSystemKey, system.toJson());
  }

  /// Get full user preferences
  Future<UserPreferences> getUserPreferences() async {
    final measurementSystem = await getMeasurementSystem();

    return UserPreferences(measurementSystem: measurementSystem);
  }

  /// Save full user preferences
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    await setMeasurementSystem(preferences.measurementSystem);
  }

  /// Clear all preferences (useful for testing or reset)
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_measurementSystemKey);
  }
}
