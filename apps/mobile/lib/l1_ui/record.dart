import 'package:flutter/material.dart';
import 'browse_exercises_screen.dart';
import '../l3_service/gemini_service.dart';
import '../l3_service/tts_service.dart';
import '../l3_service/speech_service.dart';
import '../l2_domain/controller/workout_controller.dart';
import '../l2_domain/models/workout_exercise.dart';
import '../l2_domain/models/workout.dart';
import 'exercise_form_screen.dart';

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
  final WorkoutController _workoutController = WorkoutController();
  WorkoutExercise? _lastLoggedExercise;
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

    // Get AI response from Gemini with function calling
    String aiResponse;
    WorkoutExercise? loggedExercise;
    String? workoutId;

    try {
      final response = await GeminiService.getInstance()
          .sendMessageWithFunctions(text);
      aiResponse = response.message;

      // Check if an exercise was logged
      if (response.result != null && response.result!.success) {
        loggedExercise = response.result!.exercise;
        print('✅ Workout logged: ${loggedExercise?.name}');

        // Save to Hive using WorkoutController directly and capture workout reference
        final workout = await _workoutController
            .addExerciseToAppropriateWorkout(exercise: loggedExercise!);
        workoutId = workout.id;
        print(
          '💾 Saved to Hive: ${loggedExercise.name} in workout ${workoutId}',
        );
        _lastLoggedExercise = loggedExercise;
      }

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
      print('❌ Error in function calling: $e');
      // Check if cancelled during error handling
      if (_geminiSessionId != currentSessionId ||
          _chatState != ChatState.aiThinking) {
        return;
      }
      aiResponse =
          "Sorry, I'm having trouble connecting right now. Please try again.";
    }

    // If we got here, processing wasn't cancelled
    // Add messages: conversational bubble first, then success card if exercise logged
    setState(() {
      _chatState = ChatState.idle;

      // 1. Always add conversational response bubble
      _messages.add(
        ChatMessage(
          text: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
          isWorkoutLogged: false, // This is just conversation
          exercise: null,
        ),
      );

      // 2. If exercise was logged, add success card immediately after
      if (loggedExercise != null) {
        _messages.add(
          ChatMessage(
            text: '', // Success card doesn't need text, just exercise data
            isUser: false,
            timestamp: DateTime.now(),
            isWorkoutLogged: true, // This triggers green card rendering
            exercise: loggedExercise,
            workoutId: workoutId, // Store workout reference for edit/delete
          ),
        );
      }
    });
    _scrollToBottom();

    // Show success snackbar if workout was logged
    if (loggedExercise != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('✅ Logged: ${loggedExercise.name}')),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }

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
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF3A3A3A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A3A3A),
        elevation: 0,
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
                            const Spacer(flex: 1),

                            // Main title
                            const Text(
                              'Ready to train?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Pulsating coach bunny circle
                            GestureDetector(
                              onTap: _handleVoiceInput,
                              child: AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _pulseAnimation.value,
                                    child: Container(
                                      width: 160,
                                      height: 160,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.blue.withOpacity(0.3),
                                            Colors.blue.withOpacity(0.1),
                                          ],
                                        ),
                                        border: Border.all(
                                          color: Colors.blue,
                                          width: 3,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(
                                          'assets/images/coach_bunny.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Subtitle (moved before category bubbles)
                            const Text(
                              'Tap mic to start logging',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 24),

                            // Row of three smaller category icons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Cardio
                                GestureDetector(
                                  onTap: _handleVoiceInput,
                                  child: Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue.withOpacity(0.2),
                                      border: Border.all(
                                        color: Colors.blue.withOpacity(0.5),
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.directions_run,
                                      size: 35,
                                      color: Colors.blue.withOpacity(0.7),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 20),

                                // Weight
                                GestureDetector(
                                  onTap: _handleVoiceInput,
                                  child: Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue.withOpacity(0.2),
                                      border: Border.all(
                                        color: Colors.blue.withOpacity(0.5),
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.fitness_center,
                                      size: 35,
                                      color: Colors.blue.withOpacity(0.7),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 20),

                                // Flexibility
                                GestureDetector(
                                  onTap: _handleVoiceInput,
                                  child: Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue.withOpacity(0.2),
                                      border: Border.all(
                                        color: Colors.blue.withOpacity(0.5),
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.self_improvement,
                                      size: 35,
                                      color: Colors.blue.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Example prompts
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _buildExamplePrompt(
                                    '💬 "3 sets of bench press at 60kg"',
                                  ),
                                  const SizedBox(height: 8),
                                  _buildExamplePrompt(
                                    '💬 "Ran 5km in 30 minutes"',
                                  ),
                                  const SizedBox(height: 8),
                                  _buildExamplePrompt(
                                    '💬 "Yoga for 20 minutes"',
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(flex: 3),
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
                        // Text input toggle on the right
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showTextInput = !_showTextInput;
                            });
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _showTextInput
                                  ? Colors.blue[700]
                                  : Colors.grey[850],
                              border: Border.all(
                                color: _showTextInput
                                    ? Colors.blue
                                    : Colors.white24,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.text_fields,
                              color: _showTextInput
                                  ? Colors.white
                                  : Colors.white54,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
    // User messages - keep original style
    if (message.isUser) {
      return _buildUserBubble(message);
    }

    // AI messages with logged exercise - show green success card
    if (message.isWorkoutLogged && message.exercise != null) {
      return _buildSuccessCard(message, isFollowingConversation: true);
    }

    // Regular AI conversation - standard bubble
    return _buildConversationBubble(message);
  }

  Widget _buildUserBubble(ChatMessage message) {
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
              child: Text(
                message.text,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
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

  Widget _buildSuccessCard(
    ChatMessage message, {
    bool isFollowingConversation = false,
  }) {
    final exercise = message.exercise!;

    return Padding(
      padding: EdgeInsets.only(
        top: isFollowingConversation
            ? 4
            : 0, // Tight spacing when following conversation
        bottom: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Invisible spacer to match avatar width + spacing (32 + 8 = 40)
          const SizedBox(width: 40),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFC8E6C9,
                ), // More vibrant green (was E8F5E9)
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF66BB6A), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Color(0xFF2E7D32),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Exercise Logged',
                        style: TextStyle(
                          color: Color(0xFF1B5E20),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Exercise details
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildParameterGrid(exercise),
                  const SizedBox(height: 12),

                  // AI message
                  Text(
                    message.text,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),

                  // Quick action buttons
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _handleExerciseEdit(message),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1976D2),
                          side: const BorderSide(
                            color: Color(0xFF1976D2),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => _confirmDeleteExercise(message),
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD32F2F),
                          side: const BorderSide(
                            color: Color(0xFFD32F2F),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationBubble(ChatMessage message) {
    final isLastMessage = _messages.isNotEmpty && _messages.last == message;
    final showSpeakingIndicator =
        !message.isUser && isLastMessage && _chatState == ChatState.aiSpeaking;

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
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
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
        ],
      ),
    );
  }

  Widget _buildParameterGrid(WorkoutExercise exercise) {
    final params = exercise.parameters;
    final paramItems = <Map<String, String>>[];

    if (params.containsKey('sets')) {
      paramItems.add({
        'icon': '🔄',
        'value': '${params['sets']}',
        'label': 'sets',
      });
    }
    if (params.containsKey('reps')) {
      paramItems.add({
        'icon': '💪',
        'value': '${params['reps']}',
        'label': 'reps',
      });
    }
    if (params.containsKey('weight')) {
      paramItems.add({
        'icon': '⚖️',
        'value': '${params['weight']}',
        'label': 'kg',
      });
    }
    if (params.containsKey('duration')) {
      paramItems.add({
        'icon': '⏱️',
        'value': '${params['duration']}',
        'label': 'min',
      });
    }
    if (params.containsKey('distance')) {
      paramItems.add({
        'icon': '📏',
        'value': '${params['distance']}',
        'label': 'km',
      });
    }
    if (params.containsKey('holdDuration')) {
      paramItems.add({
        'icon': '⏸️',
        'value': '${params['holdDuration']}',
        'label': 's hold',
      });
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: List.generate(paramItems.length, (index) {
            final item = paramItems[index];
            return Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: index < paramItems.length - 1
                      ? Border(
                          right: BorderSide(
                            color: const Color(0xFF404040),
                            width: 1,
                          ),
                        )
                      : null,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item['icon']!, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 4),
                    Text(
                      item['value']!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      item['label']!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFB0B0B0),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  String _formatExerciseParameters(WorkoutExercise exercise) {
    final params = exercise.parameters;
    final parts = <String>[];

    if (params.containsKey('sets')) {
      parts.add('🔄 ${params['sets']} sets');
    }
    if (params.containsKey('reps')) {
      parts.add('💪 ${params['reps']} reps');
    }
    if (params.containsKey('weight')) {
      parts.add('⚖️ ${params['weight']}kg');
    }
    if (params.containsKey('duration')) {
      parts.add('⏱️ ${params['duration']} min');
    }
    if (params.containsKey('distance')) {
      parts.add('📏 ${params['distance']}km');
    }
    if (params.containsKey('holdDuration')) {
      parts.add('⏸️ ${params['holdDuration']}s hold');
    }

    return parts.join('  •  ');
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

  /// Handle exercise edit - Navigate to ExerciseFormScreen
  void _handleExerciseEdit(ChatMessage message) {
    final exercise = message.exercise;
    final workoutId = message.workoutId;

    if (exercise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot edit: Exercise data missing')),
      );
      return;
    }

    if (workoutId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot edit older messages')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseFormScreen(
          exerciseId: exercise.exerciseId,
          exerciseName: exercise.name,
          category: exercise.category,
          muscleGroup: exercise.muscleGroup,
          initialParameters: exercise.parameters,
          onSave: (updatedData) => _handleExerciseSave(message, updatedData),
          onDelete: () => _handleExerciseDelete(message),
        ),
      ),
    );
  }

  /// Handle exercise save after editing
  Future<void> _handleExerciseSave(
    ChatMessage message,
    Map<String, dynamic> updatedData,
  ) async {
    final originalExercise = message.exercise;
    final workoutId = message.workoutId;

    if (originalExercise == null || workoutId == null) return;

    try {
      // Fetch the workout
      final workout = await _workoutController.getWorkout(workoutId);

      if (workout == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workout no longer exists')),
          );
        }
        return;
      }

      // Create updated exercise
      final updatedExercise = WorkoutExercise(
        exerciseId: updatedData['exerciseId'],
        name: updatedData['name'],
        category: updatedData['category'],
        muscleGroup: updatedData['muscleGroup'],
        parameters: updatedData['parameters'],
        createdAt: originalExercise.createdAt,
        updatedAt: DateTime.now(),
      );

      // Replace in workout
      await _workoutController.replaceExercise(
        workout: workout,
        oldExercise: originalExercise,
        newExercise: updatedExercise,
      );

      // Update the message in chat
      setState(() {
        final messageIndex = _messages.indexOf(message);
        if (messageIndex != -1) {
          _messages[messageIndex] = ChatMessage(
            text: message.text,
            isUser: message.isUser,
            timestamp: message.timestamp,
            isWorkoutLogged: message.isWorkoutLogged,
            exercise: updatedExercise,
            workoutId: workoutId,
          );
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Updated: ${updatedExercise.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating exercise: $e')));
      }
    }
  }

  /// Show confirmation dialog before deleting
  void _confirmDeleteExercise(ChatMessage message) {
    final exercise = message.exercise;
    if (exercise == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Delete Exercise',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Remove "${exercise.name}" from your workout?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _handleExerciseDelete(message);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Handle exercise deletion
  Future<void> _handleExerciseDelete(ChatMessage message) async {
    final exercise = message.exercise;
    final workoutId = message.workoutId;

    if (exercise == null || workoutId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot delete: Missing data')),
        );
      }
      return;
    }

    try {
      // Fetch the workout
      final workout = await _workoutController.getWorkout(workoutId);

      if (workout == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workout no longer exists')),
          );
        }
        return;
      }

      // Remove exercise from workout
      final updatedExercises = workout.exercises
          .where((ex) => ex.createdAt != exercise.createdAt)
          .toList();

      final updatedWorkout = Workout(
        id: workout.id,
        dateTime: workout.dateTime,
        exercises: updatedExercises,
        durationMinutes: workout.durationMinutes,
      );

      await _workoutController.updateWorkout(updatedWorkout);

      // Find and remove both the conversation bubble and success card
      setState(() {
        final successCardIndex = _messages.indexOf(message);

        if (successCardIndex != -1) {
          // Remove the success card
          _messages.removeAt(successCardIndex);

          // Try to find and remove the conversation bubble immediately before it
          if (successCardIndex > 0) {
            final previousMessage = _messages[successCardIndex - 1];
            // Check if it's a conversation bubble from same time period
            if (!previousMessage.isUser &&
                !previousMessage.isWorkoutLogged &&
                message.timestamp
                        .difference(previousMessage.timestamp)
                        .inSeconds <
                    2) {
              _messages.removeAt(successCardIndex - 1);
            }
          }
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🗑️ Deleted: ${exercise.name}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting exercise: $e')));
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _speechService.dispose();
    super.dispose();
  }

  Widget _buildExamplePrompt(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontStyle: FontStyle.italic,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isWorkoutLogged;
  final WorkoutExercise? exercise;
  final String? workoutId;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isWorkoutLogged = false,
    this.exercise,
    this.workoutId,
  });
}
