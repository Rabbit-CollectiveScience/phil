import 'package:shared_preferences/shared_preferences.dart';
import 'preferences_repository.dart';

// Implementation: SharedPreferences-based PreferencesRepository
//
// Responsibility:
// - Persists user preferences to local device storage using SharedPreferences
// - Handles serialization of DateTime to ISO 8601 string format
//
// Storage keys:
// - 'last_filter_id': String (e.g., 'chest', 'all')
// - 'last_filter_timestamp': String (ISO 8601 date format)

class LocalPreferencesRepository implements PreferencesRepository {
  final SharedPreferences _prefs;

  static const String _keyLastFilterId = 'last_filter_id';
  static const String _keyLastFilterTimestamp = 'last_filter_timestamp';

  LocalPreferencesRepository(this._prefs);

  @override
  Future<String?> getLastFilterId() async {
    return _prefs.getString(_keyLastFilterId);
  }

  @override
  Future<DateTime?> getLastFilterTimestamp() async {
    final timestampString = _prefs.getString(_keyLastFilterTimestamp);
    if (timestampString == null) return null;

    try {
      return DateTime.parse(timestampString);
    } catch (e) {
      // Invalid timestamp format, return null
      return null;
    }
  }

  @override
  Future<void> saveFilterSelection(String filterId, DateTime timestamp) async {
    await _prefs.setString(_keyLastFilterId, filterId);
    await _prefs.setString(
      _keyLastFilterTimestamp,
      timestamp.toIso8601String(),
    );
  }
}
