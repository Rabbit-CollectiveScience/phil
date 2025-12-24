import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import '../../config.dart';

/// Service for handling Google Cloud Text-to-Speech
class TTSService {
  static TTSService? _instance;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSpeaking = false;

  // Cache for available voices (loaded once per app session)
  Map<String, Map<String, String>> _voiceCache = {};
  bool _voicesLoaded = false;

  TTSService._();

  /// Get singleton instance
  static TTSService getInstance() {
    _instance ??= TTSService._();
    return _instance!;
  }

  /// Check if currently speaking
  bool get isSpeaking => _isSpeaking;

  /// Speak text using Google Cloud TTS
  /// Automatically detects language and selects best voice
  Future<void> speak(String text, {String? languageCode}) async {
    try {
      // Stop any ongoing speech
      await stop();

      // Load available voices on first use
      if (!_voicesLoaded) {
        await _loadAvailableVoices();
      }

      // Auto-detect language if not provided
      final detectedLang = languageCode ?? _detectLanguage(text);

      // Select appropriate voice based on quality preference
      final voiceName = _selectVoiceForLanguage(
        detectedLang,
        Config.ttsQualityPreference,
      );

      if (voiceName == null) {
        print('❌ No voice found for language: $detectedLang');
        return;
      }

      print('🔊 TTS: Speaking in $detectedLang with voice $voiceName');

      // Call Google Cloud TTS API
      final audioBytes = await _synthesizeSpeech(text, detectedLang, voiceName);

      // Save audio to temporary file (iOS requires file path, not bytes)
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.mp3',
      );
      await tempFile.writeAsBytes(audioBytes);

      // Play audio from file
      _isSpeaking = true;
      await _audioPlayer.play(DeviceFileSource(tempFile.path));

      // Wait for playback to complete or be stopped
      await _audioPlayer.onPlayerComplete.first;

      _isSpeaking = false;

      // Delete temp file after playing
      try {
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (e) {
        print('Failed to delete temp file: $e');
      }
    } catch (e) {
      print('❌ TTS Error: $e');
      _isSpeaking = false;
    }
  }

  /// Stop speaking
  Future<void> stop() async {
    _isSpeaking = false;
    try {
      // Don't await - just fire and forget to avoid timeout
      _audioPlayer.stop();
    } catch (e) {
      print('Error stopping TTS: $e');
    }
  }

  /// Detect if text is Thai or English
  String _detectLanguage(String text) {
    // Check if text contains Thai characters (Unicode range 0E00-0E7F)
    final thaiPattern = RegExp(r'[\u0E00-\u0E7F]');
    if (thaiPattern.hasMatch(text)) {
      return 'th-TH';
    }
    return 'en-US';
  }

  /// Call Google Cloud Text-to-Speech API
  Future<Uint8List> _synthesizeSpeech(
    String text,
    String languageCode,
    String voiceName,
  ) async {
    final url = Uri.parse(
      'https://texttospeech.googleapis.com/v1/text:synthesize?key=${Config.ttsApiKey}',
    );

    final requestBody = {
      'input': {'text': text},
      'voice': {'languageCode': languageCode, 'name': voiceName},
      'audioConfig': {
        'audioEncoding': 'MP3',
        'speakingRate': 1.0,
        'pitch': 0.0,
      },
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final audioContent = jsonResponse['audioContent'] as String;
      return base64Decode(audioContent);
    } else {
      throw Exception('TTS API Error: ${response.statusCode} ${response.body}');
    }
  }

  /// Load available voices from Google Cloud TTS API
  Future<void> _loadAvailableVoices() async {
    try {
      print('🔄 Loading available TTS voices...');

      final url = Uri.parse(
        'https://texttospeech.googleapis.com/v1/voices?key=${Config.ttsApiKey}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final voices = data['voices'] as List;

        // Build voice cache: languageCode -> {chirp3: voice, neural2: voice, standard: voice}
        for (var voice in voices) {
          final name = voice['name'] as String;
          final langCodes = voice['languageCodes'] as List;
          final gender = voice['ssmlGender'] as String;

          // Only cache voices matching preferred gender
          if (gender != Config.ttsGenderPreference) continue;

          for (var langCode in langCodes) {
            final lang = langCode as String;
            _voiceCache[lang] ??= {};

            // Categorize by quality tier
            if (name.contains('Chirp3-HD') &&
                !_voiceCache[lang]!.containsKey('chirp3')) {
              _voiceCache[lang]!['chirp3'] = name;
            } else if (name.contains('Neural2') &&
                !_voiceCache[lang]!.containsKey('neural2')) {
              _voiceCache[lang]!['neural2'] = name;
            } else if ((name.contains('Standard') ||
                    name.contains('Wavenet')) &&
                !_voiceCache[lang]!.containsKey('standard')) {
              _voiceCache[lang]!['standard'] = name;
            }
          }
        }

        _voicesLoaded = true;
        print('✅ Loaded ${_voiceCache.length} language voice mappings');
      } else {
        print('❌ Failed to load voices: ${response.statusCode}');
        // Set loaded to true anyway to avoid repeated failures
        _voicesLoaded = true;
      }
    } catch (e) {
      print('❌ Error loading voices: $e');
      _voicesLoaded = true; // Avoid infinite retry
    }
  }

  /// Select best voice for language and quality preference
  String? _selectVoiceForLanguage(String languageCode, String quality) {
    final voices = _voiceCache[languageCode];

    if (voices == null || voices.isEmpty) {
      print('⚠️ No voices for $languageCode, falling back to English');
      return _selectVoiceForLanguage('en-US', quality);
    }

    // Try to get requested quality, fallback to available options
    String? selectedVoice;

    switch (quality) {
      case 'chirp3':
        selectedVoice =
            voices['chirp3'] ?? voices['neural2'] ?? voices['standard'];
        break;
      case 'neural2':
        selectedVoice =
            voices['neural2'] ?? voices['chirp3'] ?? voices['standard'];
        break;
      case 'standard':
        selectedVoice =
            voices['standard'] ?? voices['neural2'] ?? voices['chirp3'];
        break;
      default:
        selectedVoice = voices.values.first;
    }

    return selectedVoice;
  }

  /// Dispose resources
  void dispose() {
    _audioPlayer.dispose();
  }
}
