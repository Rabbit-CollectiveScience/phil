import '../../../l3_data/repositories/preferences_repository.dart';

// Use Case: Should Show Filter Page
//
// Responsibility:
// - Determines if filter selection page should be shown to user
// - Implements the 2-hour rule for auto-showing filter
//
// Business Logic:
// - Show if user has never selected a filter (first time)
// - Show if last selection was more than 2 hours ago
// - Don't show if last selection was within 2 hours

class ShouldShowFilterPageUseCase {
  final PreferencesRepository _preferencesRepository;

  // 2-hour threshold for re-showing filter page
  static const Duration _threshold = Duration(hours: 2);

  ShouldShowFilterPageUseCase(this._preferencesRepository);

  /// Check if filter page should be shown
  ///
  /// Returns true if:
  /// - No previous selection exists (first time user)
  /// - Last selection was more than 2 hours ago (exactly 2 hours = false)
  Future<bool> execute() async {
    final lastTimestamp = await _preferencesRepository.getLastFilterTimestamp();

    // No previous selection - show filter page
    if (lastTimestamp == null) {
      return true;
    }

    // Check if more than 2 hours have passed
    final now = DateTime.now();
    final timeSinceLastSelection = now.difference(lastTimestamp);

    // Use >= to include microseconds, making exactly 2 hours evaluate to false
    return timeSinceLastSelection.inMicroseconds > _threshold.inMicroseconds;
  }
}
