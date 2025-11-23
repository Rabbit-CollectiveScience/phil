import 'package:flutter/material.dart';
import 'browse_exercises_screen.dart';
import '../l3_service/speech_service.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage>
    with SingleTickerProviderStateMixin {
  final SpeechService _speechService = SpeechService();
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isAiSpeaking = false;
  bool _showTextInput = false;
  String _partialTranscription = '';
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    final initialized = await _speechService.initialize();
    if (!initialized && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition not available'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleUserInput(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      // Add user message
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
      _isProcessing = true;
    });

    _textController.clear();
    _scrollToBottom();

    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _isProcessing = false;
      _isAiSpeaking = true;
    });

    // Mock AI response
    String aiResponse = "Got it - Bench Press 3×10 @ 185 lbs. Correct?";

    setState(() {
      _messages.add(
        ChatMessage(text: aiResponse, isUser: false, timestamp: DateTime.now()),
      );
    });

    _scrollToBottom();

    // Simulate AI speaking duration (based on text length)
    int speakingDuration = (aiResponse.length * 50).clamp(1000, 5000);
    await Future.delayed(Duration(milliseconds: speakingDuration));

    setState(() {
      _isAiSpeaking = false;
    });
  }

  void _handleVoiceInput() async {
    if (_isAiSpeaking || _isProcessing) return;

    if (_isRecording) {
      // Stop recording
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      await _speechService.stopListening();

      // Wait a bit for final result
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _isProcessing = false;
      });
    } else {
      // Start recording
      setState(() {
        _isRecording = true;
        _partialTranscription = '';
      });

      await _speechService.startListening(
        onResult: (finalText) {
          // Final transcription received
          if (finalText.isNotEmpty) {
            _handleUserInput(finalText);
          }
          setState(() {
            _isRecording = false;
            _partialTranscription = '';
          });
        },
        onPartialResult: (partialText) {
          // Update partial transcription in real-time
          setState(() {
            _partialTranscription = partialText;
          });
        },
        onError: (error) {
          setState(() {
            _isRecording = false;
            _partialTranscription = '';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
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
      body: SafeArea(
        child: Column(
          children: [
            // Conversation Log
            Expanded(
              child: _messages.isEmpty
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
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageBubble(_messages[index]);
                      },
                    ),
            ),

            // Voice Button
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  // Show partial transcription while recording
                  if (_isRecording && _partialTranscription.isNotEmpty)
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
                  GestureDetector(
                    onTap: _handleVoiceInput,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isAiSpeaking ? _pulseAnimation.value : 1.0,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getButtonColor(),
                              boxShadow: [
                                BoxShadow(
                                  color: _getButtonColor().withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Icon(
                              _getButtonIcon(),
                              size: 40,
                              color: Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
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
              Container(
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
              )
            else
              const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
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
              child: const Icon(Icons.smart_toy, color: Colors.black, size: 18),
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
                  Text(
                    message.text,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
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
    if (_isRecording) return Colors.green;
    if (_isProcessing) return Colors.grey;
    if (_isAiSpeaking) return Colors.blue;
    return Colors.white;
  }

  IconData _getButtonIcon() {
    if (_isRecording) return Icons.stop;
    if (_isProcessing) return Icons.more_horiz;
    if (_isAiSpeaking) return Icons.smart_toy;
    return Icons.mic;
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _speechService.dispose();
    _pulseController.dispose();
    _textController.dispose();
    _scrollController.dispose();
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
