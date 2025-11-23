/// Helper functions for locale/language display and formatting
class LocaleHelper {
  /// Converts locale ID to flag emoji
  /// Examples: en-US → 🇺🇸, th-TH → 🇹🇭, en-GB → 🇬🇧
  static String getFlag(String localeId) {
    // Extract country code from locale ID (e.g., en-US → US)
    final parts = localeId.split('-');
    if (parts.length >= 2) {
      final countryCode = parts[1].toUpperCase();
      // Convert country code to flag emoji
      // Each flag emoji is made of regional indicator symbols
      return countryCode.codeUnits
          .map((code) => String.fromCharCode(0x1F1E6 + (code - 0x41)))
          .join();
    }
    return '🌐'; // Fallback globe emoji
  }

  /// Extracts language code from locale ID
  /// Examples: en-US → EN, th-TH → TH, zh-CN → ZH
  static String getLanguageCode(String localeId) {
    final parts = localeId.split('-');
    return parts[0].toUpperCase();
  }

  /// Gets a short display string with flag and language code
  /// Examples: en-US → 🇺🇸 EN, th-TH → 🇹🇭 TH
  static String getShortDisplay(String localeId) {
    return '${getFlag(localeId)} ${getLanguageCode(localeId)}';
  }
}
