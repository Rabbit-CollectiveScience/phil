import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:ui' as ui;

/// Service for handling speech-to-text functionality
class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  /// Check if speech recognition is available
  bool get isInitialized => _isInitialized;

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Initialize speech recognition
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Initialize speech recognition (it handles permission request internally)
      _isInitialized = await _speech.initialize(
        onError: (error) => print('Speech recognition error: $error'),
        onStatus: (status) => print('Speech recognition status: $status'),
      );

      return _isInitialized;
    } catch (e) {
      print('Error initializing speech recognition: $e');
      return false;
    }
  }

  /// Get the device's current system locale
  Future<String?> getSystemLocale() async {
    if (!_isInitialized) {
      await initialize();
    }

    // Get device's actual locale from Flutter
    final deviceLocale = ui.PlatformDispatcher.instance.locale;
    print(
      '🔍 Device locale: ${deviceLocale.languageCode}_${deviceLocale.countryCode}',
    );

    // Convert to both formats (underscore and dash) for matching
    final deviceLocaleIdUnderscore =
        '${deviceLocale.languageCode}_${deviceLocale.countryCode}';
    final deviceLocaleIdDash =
        '${deviceLocale.languageCode}-${deviceLocale.countryCode}';

    // Check if this locale is available in speech recognition
    final locales = await getLocales();
    print(
      '🔍 Available locales: ${locales.map((l) => l.localeId).take(5).join(", ")}...',
    );

    // Try exact match first (both formats), then language-only match
    final matchingLocale = locales.firstWhere(
      (l) =>
          l.localeId == deviceLocaleIdUnderscore ||
          l.localeId == deviceLocaleIdDash ||
          l.localeId.toLowerCase() == deviceLocaleIdUnderscore.toLowerCase() ||
          l.localeId.toLowerCase() == deviceLocaleIdDash.toLowerCase(),
      orElse: () {
        // Fallback: find any locale with matching language code
        return locales.firstWhere(
          (l) =>
              l.localeId.toLowerCase().startsWith(
                '${deviceLocale.languageCode.toLowerCase()}-',
              ) ||
              l.localeId.toLowerCase().startsWith(
                '${deviceLocale.languageCode.toLowerCase()}_',
              ),
          orElse: () => locales.isNotEmpty
              ? locales.first
              : stt.LocaleName('en-US', 'English'),
        );
      },
    );

    print('🔍 Matched locale: ${matchingLocale.localeId}');
    return matchingLocale.localeId;
  }

  /// Start listening for speech input
  /// Returns a stream of transcribed text via the onResult callback
  /// [localeId] - Optional locale ID (e.g., 'en_US', 'th_TH'). If null, uses device default.
  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onPartialResult,
    Function(String)? onError,
    String? localeId,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        onError?.call('Speech recognition not available');
        return;
      }
    }

    if (_isListening) {
      print('Already listening');
      return;
    }

    try {
      _isListening = true;
      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
          } else {
            onPartialResult?.call(result.recognizedWords);
          }
        },
        localeId: localeId,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );
    } catch (e) {
      _isListening = false;
      onError?.call('Error starting speech recognition: $e');
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speech.stop();
      _isListening = false;
    } catch (e) {
      print('Error stopping speech recognition: $e');
    }
  }

  /// Cancel listening (without processing final result)
  Future<void> cancelListening() async {
    if (!_isListening) return;

    try {
      await _speech.cancel();
      _isListening = false;
    } catch (e) {
      print('Error canceling speech recognition: $e');
    }
  }

  /// Get available locales for speech recognition
  Future<List<stt.LocaleName>> getLocales() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _speech.locales();
  }

  /// Get user's preferred languages from device settings (ordered by preference)
  List<String> getPreferredLanguages() {
    // Get all preferred locales from device settings
    final preferredLocales = ui.PlatformDispatcher.instance.locales;

    print(
      '🔍 Raw preferred locales: ${preferredLocales.map((l) => "${l.languageCode}_${l.countryCode}").join(", ")}',
    );

    // Extract just the language codes (e.g., "en", "th", "zh")
    // We'll match by language code only, not specific country variants
    final preferredLanguageCodes = preferredLocales
        .map((locale) => locale.languageCode)
        .toList();

    print('🔍 User preferred languages: ${preferredLanguageCodes.join(", ")}');
    return preferredLanguageCodes;
  }

  /// Check if microphone permission is granted
  Future<bool> hasPermission() async {
    return _speech.hasPermission;
  }

  /// Dispose resources
  void dispose() {
    _speech.stop();
  }
}
