import 'package:flutter/material.dart';
import 'browse_exercises_screen.dart';
import '../l3_service/gemini_service.dart';
import '../l3_service/tts_service.dart';
import '../l3_service/speech_service.dart';

// Chat state machine enum
enum ChatState {
  idle, // Ready to record
  recording, // Capturing audio
  transcribing, // Processing speech to text
  aiThinking, // Waiting for Gemini response
  aiSpeaking, // TTS playing
}

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage>
    with SingleTickerProviderStateMixin {
  ChatState _chatState = ChatState.idle;
  bool _showTextInput = false;
  bool _isTtsEnabled = true;
  String _partialTranscription = '';
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Session tracking for async operations
  int _recordingSessionId = 0;
  int _ttsSessionId = 0;
  int _geminiSessionId = 0;

  // Recording duration tracking
  DateTime? _recordingStartTime;
  static const _minRecordingDurationMs = 1000; // 1 second minimum

  // Speech service
  final SpeechService _speechService = SpeechService();
  bool _isSpeechInitialized = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Initialize speech service
    _initializeSpeech();
  }

  /// Initialize Google Cloud Speech-to-Text service
  Future<void> _initializeSpeech() async {
    try {
      await _speechService.initialize();
      setState(() {
        _isSpeechInitialized = true;
      });
      print('✅ Speech service ready');
    } catch (e) {
      print('❌ Speech initialization failed: $e');
      // Service remains uninitialized, microphone will show error when tapped
    }
  }

  /// Handle user message input and get AI response
  /// State flow: PROCESSING -> AI_SPEAKING (or IDLE if TTS disabled)
  void _handleUserInput(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message bubble immediately
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
    });
    _textController.clear();
    _scrollToBottom();

    // Enter AI_THINKING state
    final currentSessionId = ++_geminiSessionId;
    setState(() {
      _chatState = ChatState.aiThinking;
    });

    // Get AI response from Gemini
    String aiResponse;

    try {
      aiResponse = await GeminiService.getInstance().sendMessage(text);

      // Check if processing was cancelled while waiting for response
      if (_geminiSessionId != currentSessionId) {
        print('🚫 Gemini session cancelled (stale session $currentSessionId)');
        return;
      }

      if (_chatState != ChatState.aiThinking) {
        print('🚫 Processing was cancelled, ignoring response');
        return;
      }
    } catch (e) {
      // Check if cancelled during error handling
      if (_geminiSessionId != currentSessionId ||
          _chatState != ChatState.aiThinking) {
        return;
      }
      aiResponse =
          "Sorry, I'm having trouble connecting right now. Please try again.";
    }

    // If we got here, processing wasn't cancelled
    // Add AI text bubble BEFORE starting TTS
    setState(() {
      _chatState = ChatState.idle;
      _messages.add(
        ChatMessage(text: aiResponse, isUser: false, timestamp: DateTime.now()),
      );
    });
    _scrollToBottom();

    // Start TTS if enabled (non-blocking)
    if (_isTtsEnabled) {
      _startTTS(aiResponse);
    }
  }

  /// Start TTS playback in AI_SPEAKING state (non-blocking)
  void _startTTS(String text) async {
    final currentSessionId = ++_ttsSessionId;
    setState(() {
      _chatState = ChatState.aiSpeaking;
    });

    try {
      await TTSService.getInstance().speak(text);
    } catch (e) {
      print('❌ TTS Error: $e');
    }

    // Only return to idle if this is still the active TTS session
    // and we're still in speaking state
    if (_ttsSessionId == currentSessionId &&
        _chatState == ChatState.aiSpeaking) {
      setState(() {
        _chatState = ChatState.idle;
      });
    } else {
      print(
        '⚠️ TTS completed but state changed (session: $currentSessionId vs ${_ttsSessionId})',
      );
    }
  }

  /// Handle mic button tap - Clean state machine
  void _handleVoiceInput() async {
    // STATE: TRANSCRIBING - Cancel transcription and return to IDLE
    if (_chatState == ChatState.transcribing) {
      print('🚫 Cancelling transcription');
      _recordingSessionId++; // Invalidate current recording session
      // Note: stopListening() was already called, just cancel waiting for result
      setState(() {
        _chatState = ChatState.idle;
      });
      return;
    }

    // STATE: AI_THINKING - Cancel and return to IDLE
    if (_chatState == ChatState.aiThinking) {
      print('🚫 Cancelling AI request');
      _geminiSessionId++; // Invalidate current Gemini session
      setState(() {
        _chatState = ChatState.idle;
      });
      // The _handleUserInput method will check session ID and ignore response
      return;
    }

    // STATE: AI_SPEAKING - Stop TTS and return to IDLE
    if (_chatState == ChatState.aiSpeaking) {
      print('🛑 Stopping AI speech');
      _ttsSessionId++; // Invalidate current TTS session
      await TTSService.getInstance().stop();
      setState(() {
        _chatState = ChatState.idle;
      });
      // Return to IDLE (don't start recording)
      return;
    }

    // STATE: RECORDING - Stop and process
    if (_chatState == ChatState.recording) {
      print('⏹️ Stopping recording');

      // Check recording duration
      final recordingDuration = _recordingStartTime != null
          ? DateTime.now().difference(_recordingStartTime!).inMilliseconds
          : 0;

      if (recordingDuration < _minRecordingDurationMs) {
        print('⚠️ Recording too short (${recordingDuration}ms), discarding');
        // Silently cancel - no transcription, no API call
        try {
          await _speechService.stopListening();
        } catch (e) {
          print('❌ Error stopping speech: $e');
        }
        setState(() {
          _chatState = ChatState.idle;
          _partialTranscription = '';
        });
        return;
      }

      // Duration is valid, proceed with transcription
      setState(() {
        _chatState = ChatState.transcribing; // Show "transcribing..." indicator
      });

      // Force immediate scroll after state change (before async stopListening)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      });

      // Stop Google Cloud Speech-to-Text
      try {
        await _speechService.stopListening();
      } catch (e) {
        print('❌ Error stopping speech: $e');
        setState(() {
          _chatState = ChatState.idle;
        });
      }

      return;
    }

    // STATE: IDLE - Start recording
    print('🎤 Starting recording');

    // Check if speech service is initialized
    if (!_isSpeechInitialized) {
      print('❌ Speech service not initialized');
      // Could show a SnackBar here if desired
      return;
    }

    setState(() {
      _chatState = ChatState.recording;
      _partialTranscription = '';
      _recordingStartTime = DateTime.now();
    });

    // Start Google Cloud Speech-to-Text
    final currentSessionId = ++_recordingSessionId;
    try {
      await _speechService.startListening(
        onPartialResult: (text) {
          // Real-time transcription preview
          if (_recordingSessionId == currentSessionId) {
            setState(() {
              _partialTranscription = text;
            });
            print('📝 Partial: $text');
          }
        },
        onFinalResult: (text) {
          // Final transcription → send to Gemini
          print('✅ Final: $text (session $currentSessionId)');

          // Validate session and state before processing
          if (_recordingSessionId != currentSessionId) {
            print('⚠️ Ignoring stale transcription from old session');
            return;
          }

          // Only process if we're still in transcribing or recording state
          if (_chatState != ChatState.transcribing &&
              _chatState != ChatState.recording) {
            print('⚠️ Ignoring transcription - user cancelled');
            return;
          }

          setState(() {
            _chatState = ChatState.idle;
          });
          if (text.isNotEmpty) {
            _handleUserInput(text);
          }
        },
        onError: (error) {
          print('❌ Speech error: $error');
          if (_recordingSessionId == currentSessionId) {
            setState(() {
              _chatState = ChatState.idle;
              _partialTranscription = '';
            });
          }
        },
      );
    } catch (e) {
      print('❌ Error starting speech: $e');
      setState(() {
        _chatState = ChatState.idle;
      });
    }
  }

  void _scrollToBottom() {
    // Double post-frame callback to ensure ListView has rebuilt with new items
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  Widget _buildTtsBadge() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isTtsEnabled = !_isTtsEnabled;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isTtsEnabled ? 'Voice enabled 🔊' : 'Voice disabled (text only)',
            ),
            backgroundColor: _isTtsEnabled
                ? Colors.green[700]
                : Colors.orange[700],
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isTtsEnabled ? Colors.blue[700] : Colors.grey[850],
          border: Border.all(
            color: _isTtsEnabled ? Colors.blue : Colors.white24,
            width: 2,
          ),
        ),
        child: Icon(
          _isTtsEnabled ? Icons.volume_up : Icons.volume_off,
          color: _isTtsEnabled ? Colors.white : Colors.white54,
          size: 22,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3A3A3A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A3A3A),
        elevation: 0,
        title: const Text('Record', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BrowseExercisesScreen(),
                ),
              );
            },
            tooltip: 'Browse exercises',
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // Hide text input when tapping outside
          if (_showTextInput) {
            setState(() {
              _showTextInput = false;
            });
            // Also unfocus to dismiss keyboard
            FocusScope.of(context).unfocus();
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // Conversation Log
              Expanded(
                child:
                    _messages.isEmpty &&
                        _chatState != ChatState.transcribing &&
                        _chatState != ChatState.aiThinking
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 80,
                              color: Colors.grey[800],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Start logging your workout',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        itemCount:
                            _messages.length +
                            (_chatState == ChatState.transcribing ? 1 : 0) +
                            (_chatState == ChatState.aiThinking ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < _messages.length) {
                            return _buildMessageBubble(_messages[index]);
                          } else if (_chatState == ChatState.transcribing &&
                              index == _messages.length) {
                            // Show transcribing indicator first
                            return _buildTranscribingIndicator();
                          } else {
                            // Show thinking indicator
                            return _buildThinkingIndicator();
                          }
                        },
                      ),
              ),

              // Voice Button
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    // Show partial transcription while recording
                    if (_chatState == ChatState.recording &&
                        _partialTranscription.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _partialTranscription,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    // Microphone and control badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // TTS toggle on the left
                        _buildTtsBadge(),
                        const SizedBox(width: 16),
                        // Microphone button (centered)
                        GestureDetector(
                          onTap: _handleVoiceInput,
                          child: AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _chatState == ChatState.aiSpeaking
                                    ? _pulseAnimation.value
                                    : 1.0,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _getButtonColor(),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getButtonColor().withOpacity(
                                          0.3,
                                        ),
                                        blurRadius: 30,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: _chatState == ChatState.aiSpeaking
                                      ? ClipOval(
                                          child: Image.asset(
                                            'assets/images/bot_avatar_big.png',
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Icon(
                                          _getButtonIcon()!,
                                          size: 40,
                                          color: Colors.black,
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Language badge on the right
                        _buildTtsBadge(),
                      ],
                    ),
                  ],
                ),
              ),

              // Toggle Text Input Button
              TextButton(
                onPressed: () {
                  setState(() {
                    _showTextInput = !_showTextInput;
                  });
                },
                child: Text(
                  _showTextInput ? 'Use voice instead' : 'or tap to type',
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),

              // Text Input (Conditional)
              if (_showTextInput)
                GestureDetector(
                  onTap: () {
                    // Prevent tap from propagating to parent GestureDetector
                  },
                  child: Container(
                    color: Colors.black,
                    padding: const EdgeInsets.all(16),
                    child: SafeArea(
                      top: false,
                      child: TextField(
                        controller: _textController,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Type your workout...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.grey[900],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white54),
                            onPressed: () {
                              _handleUserInput(_textController.text);
                              setState(() {
                                _showTextInput = false;
                              });
                            },
                          ),
                        ),
                        onSubmitted: (value) {
                          _handleUserInput(value);
                          setState(() {
                            _showTextInput = false;
                          });
                        },
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTranscribingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(16),
              ),
              child: _buildAnimatedDots(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blue[700],
            radius: 16,
            child: const Icon(Icons.person, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDots() {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: 3),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return Text(
          '.' * ((value % 4) + 1),
          style: const TextStyle(color: Colors.white, fontSize: 15),
        );
      },
      onEnd: () {
        // Restart animation
        if (_chatState == ChatState.transcribing) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildThinkingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 16,
            child: ClipOval(
              child: Image.asset(
                'assets/images/bot_avatar.png',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Phil is thinking...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isLastMessage = _messages.isNotEmpty && _messages.last == message;
    final showSpeakingIndicator =
        !message.isUser && isLastMessage && _chatState == ChatState.aiSpeaking;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 16,
              child: ClipOval(
                child: Image.asset(
                  'assets/images/bot_avatar.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blue[700] : Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (showSpeakingIndicator) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.volume_up,
                          color: Colors.blue,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.blue[700],
              radius: 16,
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  Color _getButtonColor() {
    switch (_chatState) {
      case ChatState.recording:
        return Colors.green;
      case ChatState.transcribing:
      case ChatState.aiThinking:
        return Colors.grey;
      case ChatState.aiSpeaking:
        return Colors.blue;
      case ChatState.idle:
        return Colors.white;
    }
  }

  IconData? _getButtonIcon() {
    switch (_chatState) {
      case ChatState.recording:
        return Icons.stop;
      case ChatState.transcribing:
      case ChatState.aiThinking:
        return Icons.more_horiz;
      case ChatState.aiSpeaking:
        return null; // Will show bot avatar instead
      case ChatState.idle:
        return Icons.mic;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _speechService.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
