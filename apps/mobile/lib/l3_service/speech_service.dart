import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:sound_stream/sound_stream.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for Google Cloud Speech-to-Text V2 API with Chirp 3 model
/// Supports code-switching between Thai and English
class SpeechService {
  static const String _region = 'us';
  static const String _projectId = 'phil-479202';

  AutoRefreshingAuthClient? _authClient;
  RecorderStream? _recorder;
  StreamSubscription<List<int>>? _audioSubscription;
  bool _isListening = false;

  final List<int> _audioBuffer = [];

  // Callbacks
  Function(String)? _onPartialResult;
  Function(String)? _onFinalResult;
  Function(String)? _onError;

  /// Initialize the speech service with V2 API authentication
  Future<void> initialize() async {
    try {
      print('🔧 Loading Google Cloud credentials for V2 API...');

      // Load service account JSON from assets
      final serviceAccountJson = await rootBundle.loadString(
        'assets/phil-479202-d4e78adb0eea.json',
      );

      // Parse credentials
      final credentials = ServiceAccountCredentials.fromJson(
        json.decode(serviceAccountJson),
      );

      // Create authenticated client
      _authClient = await clientViaServiceAccount(
        credentials,
        ['https://www.googleapis.com/auth/cloud-platform'],
      );

      print('✅ Speech service initialized (V2 API + Chirp 3)');
    } catch (e) {
      print('❌ Failed to initialize speech service: $e');
      rethrow;
    }
  }

  /// Start listening to microphone and streaming to Google Cloud V2 API with Chirp 3
  Future<void> startListening({
    required Function(String) onPartialResult,
    required Function(String) onFinalResult,
    required Function(String) onError,
  }) async {
    if (_isListening) {
      print('⚠️ Already listening');
      return;
    }

    if (_authClient == null) {
      final error = 'Speech service not initialized. Call initialize() first.';
      print('❌ $error');
      onError(error);
      return;
    }

    // Try to request microphone permission
    print('🔍 Checking microphone permission...');
    try {
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        status = await Permission.microphone.request();
      }

      if (status.isGranted) {
        print('✅ Microphone permission granted');
      } else {
        print('⚠️ Permission: $status, trying anyway');
      }
    } catch (e) {
      print('⚠️ Permission error: $e (proceeding anyway)');
    }

    try {
      print('🎤 Starting Chirp 3 speech recognition...');

      _onPartialResult = onPartialResult;
      _onFinalResult = onFinalResult;
      _onError = onError;

      // Initialize audio recorder
      _recorder = RecorderStream();
      _audioBuffer.clear();

      // Start recording
      await _recorder!.start();

      // Listen to audio stream and buffer it - no sending until stop
      _audioSubscription = _recorder!.audioStream.listen(
        (audioData) {
          _audioBuffer.addAll(audioData);
        },
        onError: (error) {
          print('❌ Audio stream error: $error');
          _onError?.call('Audio error: $error');
        },
      );

      _isListening = true;
      print('✅ Listening started (Chirp 3: th-TH + en-US code-switching)');
    } catch (e) {
      print('❌ Error starting listening: $e');
      _onError?.call('Failed to start: $e');
      await stopListening();
    }
  }

  /// Send buffered audio to Google Cloud Speech-to-Text V2 API with Chirp 3
  Future<void> _sendAudioToChirp3({bool isFinal = false}) async {
    if (_audioBuffer.isEmpty || _authClient == null) return;

    try {
      // Keep buffer for accumulation, just read it
      final audioToSend = List<int>.from(_audioBuffer);
      
      // Only clear buffer on final send
      if (isFinal) {
        _audioBuffer.clear();
      }

      // Encode as base64
      final audioContent = base64Encode(audioToSend);

      // Build V2 API request with explicit encoding
      final requestBody = {
        'config': {
          'explicitDecodingConfig': {
            'encoding': 'LINEAR16',
            'sampleRateHertz': 16000,
            'audioChannelCount': 1,
          },
          'languageCodes': ['th-TH', 'en-US'], // Code-switching support
          'model': 'chirp_3', // Chirp 3 model
          'features': {
            'enableAutomaticPunctuation': true,
          },
        },
        'content': audioContent,
      };

      // Send to V2 API
      final recognizer =
          'projects/$_projectId/locations/$_region/recognizers/_';
      final url = Uri.parse(
        'https://$_region-speech.googleapis.com/v2/$recognizer:recognize',
      );

      final response = await _authClient!.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        _handleV2Response(result, isFinal: isFinal);
      } else {
        print('⚠️ API error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error sending audio: $e');
    }
  }

  /// Handle V2 API response
  void _handleV2Response(Map<String, dynamic> response, {bool isFinal = false}) {
    try {
      final results = response['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) return;

      // Concatenate all alternatives to get full transcript
      final transcripts = <String>[];
      for (final result in results) {
        final alternatives = result['alternatives'] as List<dynamic>?;
        if (alternatives != null && alternatives.isNotEmpty) {
          final transcript = alternatives[0]['transcript'] as String? ?? '';
          if (transcript.isNotEmpty) {
            transcripts.add(transcript);
          }
        }
      }

      if (transcripts.isEmpty) return;
      
      final fullTranscript = transcripts.join(' ');

      if (isFinal) {
        print('✅ Final result: $fullTranscript');
        _onFinalResult?.call(fullTranscript);
      } else {
        print('📝 Partial result: $fullTranscript');
        _onPartialResult?.call(fullTranscript);
      }
    } catch (e) {
      print('❌ Error parsing response: $e');
    }
  }

  /// Stop listening and clean up
  Future<void> stopListening() async {
    if (!_isListening) return;

    print('⏹️ Stopping speech recognition...');

    try {
      // Stop audio capture first
      await _audioSubscription?.cancel();
      await _recorder?.stop();

      // Now send all accumulated audio as final result
      if (_audioBuffer.isNotEmpty) {
        print('📤 Sending ${_audioBuffer.length} bytes to Chirp 3...');
        await _sendAudioToChirp3(isFinal: true);
      }

      _audioSubscription = null;
      _recorder = null;
      _audioBuffer.clear();
      _isListening = false;

      print('✅ Listening stopped');
    } catch (e) {
      print('❌ Error stopping listening: $e');
    }
  }

  /// Dispose and clean up all resources
  void dispose() {
    stopListening();
    _authClient?.close();
    _onPartialResult = null;
    _onFinalResult = null;
    _onError = null;
  }

  /// Check if currently listening
  bool get isListening => _isListening;
}
