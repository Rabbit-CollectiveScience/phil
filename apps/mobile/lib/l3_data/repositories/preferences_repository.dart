// Repository Interface: User preferences data operations
//
// Responsibility:
// - Abstract interface for user preference persistence
// - Stores simple key-value preferences (filter selections, timestamps)
//
// Implementation:
// - LocalPreferencesRepository uses SharedPreferences for on-device storage

abstract class PreferencesRepository {
  /// Get the last selected filter ID (e.g., 'chest', 'legs', 'all')
  Future<String?> getLastFilterId();

  /// Get the timestamp when filter was last selected
  Future<DateTime?> getLastFilterTimestamp();

  /// Save filter selection with timestamp
  Future<void> saveFilterSelection(String filterId, DateTime timestamp);
}
