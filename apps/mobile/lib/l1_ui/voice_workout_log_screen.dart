import 'package:flutter/material.dart';
import '../l2_domain/models/workout_exercise.dart';
import 'utils/voice_logging_helper.dart';

/// Screen for voice-based workout logging
class VoiceWorkoutLogScreen extends StatefulWidget {
  const VoiceWorkoutLogScreen({super.key});

  @override
  State<VoiceWorkoutLogScreen> createState() => _VoiceWorkoutLogScreenState();
}

class _VoiceWorkoutLogScreenState extends State<VoiceWorkoutLogScreen> {
  final VoiceLoggingHelper _helper = VoiceLoggingHelper();
  final TextEditingController _textController = TextEditingController();

  String _currentTranscription = '';
  String _aiResponse = '';
  WorkoutExercise? _lastLoggedExercise;
  bool _isProcessing = false;
  final List<Map<String, dynamic>> _conversationHistory = [];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// Process voice input (for now using text input as placeholder)
  Future<void> _processInput(String input) async {
    if (input.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
      _currentTranscription = input;
      _conversationHistory.add({
        'role': 'user',
        'message': input,
        'timestamp': DateTime.now(),
      });
    });

    try {
      final result = await _helper.processVoiceInput(input);

      setState(() {
        _aiResponse = result.message;
        _conversationHistory.add({
          'role': 'assistant',
          'message': result.message,
          'timestamp': DateTime.now(),
          'success': result.success,
          'exercise': result.exercise, // Store exercise for success cards
        });

        if (result.success && result.exercise != null) {
          _lastLoggedExercise = result.exercise;
        }

        _isProcessing = false;
      });

      // Clear input
      _textController.clear();
    } catch (e) {
      setState(() {
        _aiResponse = 'Error: $e';
        _isProcessing = false;
      });
    }
  }

  /// Handle correction of last logged exercise
  Future<void> _handleCorrection(String correctionText) async {
    if (_lastLoggedExercise == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await _helper.processCorrection(
        correctionText,
        _lastLoggedExercise!,
      );

      setState(() {
        _aiResponse = result.message;
        _conversationHistory.add({
          'role': 'assistant',
          'message': result.message,
          'timestamp': DateTime.now(),
          'success': result.success,
          'isCorrection': true,
        });

        if (result.success && result.exercise != null) {
          _lastLoggedExercise = result.exercise;
        }

        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _aiResponse = 'Error: $e';
        _isProcessing = false;
      });
    }
  }

  /// Clear conversation history
  void _clearHistory() {
    setState(() {
      _conversationHistory.clear();
      _currentTranscription = '';
      _aiResponse = '';
      _lastLoggedExercise = null;
    });
    _helper.clearHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Workout Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearHistory,
            tooltip: 'Clear conversation',
          ),
        ],
      ),
      body: Column(
        children: [
          // Conversation history
          Expanded(
            child: _conversationHistory.isEmpty
                ? _buildEmptyState()
                : _buildConversationList(),
          ),

          // Last logged exercise card (if any)
          if (_lastLoggedExercise != null) _buildLastExerciseCard(),

          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Voice Workout Logger',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Tell me what you did!\nExample: "3 sets of 10 bench press at 135 pounds"',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 24),
            _buildQuickExamples(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickExamples() {
    final examples = [
      '3 sets of 10 bench press at 60kg',
      'Ran 5K in 25 minutes',
      'Hamstring stretch for 30 seconds, 3 times',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Try these:',
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...examples.map(
          (example) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: OutlinedButton(
              onPressed: () => _processInput(example),
              child: Text(example),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConversationList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _conversationHistory.length,
      itemBuilder: (context, index) {
        final message = _conversationHistory[index];
        final isUser = message['role'] == 'user';
        final isSuccess = message['success'] == true;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: isUser
              ? _buildUserMessage(message)
              : isSuccess
              ? _buildSuccessCard(message)
              : _buildConversationBubble(message),
        );
      },
    );
  }

  /// Build user message bubble (right-aligned, primary color)
  Widget _buildUserMessage(Map<String, dynamic> message) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message['message'],
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  /// Build success card for logged exercises (green with exercise details)
  Widget _buildSuccessCard(Map<String, dynamic> message) {
    final exercise = message['exercise'] as WorkoutExercise?;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9), // Light green background
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF66BB6A), // Green border
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Color(0xFF2E7D32), // Dark green
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Exercise Logged',
                  style: TextStyle(
                    color: Color(0xFF1B5E20), // Darker green
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Exercise details (if available)
            if (exercise != null) ...[
              Text(
                exercise.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatExerciseParameters(exercise),
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
            ],

            // AI message
            Text(
              message['message'],
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),

            // Quick action buttons
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement edit functionality
                    print('Edit tapped');
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1976D2), // Blue
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
                  onPressed: () {
                    // TODO: Implement delete functionality
                    print('Delete tapped');
                  },
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD32F2F), // Red
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
    );
  }

  /// Build standard conversation bubble (gray, for non-success AI messages)
  Widget _buildConversationBubble(Map<String, dynamic> message) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message['message'],
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLastExerciseCard() {
    final exercise = _lastLoggedExercise!;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Last Logged',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            exercise.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _formatExerciseParameters(exercise),
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => _buildCorrectionDialog(),
              );
            },
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Correct this'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: const BorderSide(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  String _formatExerciseParameters(WorkoutExercise exercise) {
    final params = exercise.parameters;
    final parts = <String>[];

    if (params.containsKey('sets')) {
      parts.add('${params['sets']} sets');
    }
    if (params.containsKey('reps')) {
      parts.add('${params['reps']} reps');
    }
    if (params.containsKey('weight')) {
      parts.add('${params['weight']}kg');
    }
    if (params.containsKey('duration')) {
      parts.add('${params['duration']} min');
    }
    if (params.containsKey('distance')) {
      parts.add('${params['distance']}km');
    }
    if (params.containsKey('holdDuration')) {
      parts.add('${params['holdDuration']}s hold');
    }

    return parts.join(' • ');
  }

  Widget _buildCorrectionDialog() {
    final correctionController = TextEditingController();

    return AlertDialog(
      title: const Text('Correct Exercise'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('What would you like to correct?'),
          const SizedBox(height: 16),
          TextField(
            controller: correctionController,
            decoration: const InputDecoration(
              hintText: 'e.g., "Actually it was 65kg"',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final correction = correctionController.text.trim();
            if (correction.isNotEmpty) {
              Navigator.pop(context);
              _handleCorrection(correction);
            }
          },
          child: const Text('Correct'),
        ),
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // TODO: Replace with actual voice recording button
            IconButton(
              icon: const Icon(Icons.mic),
              onPressed: () {
                // Placeholder - would trigger voice recording
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Voice recording coming soon! Use text input for now.',
                    ),
                  ),
                );
              },
              tooltip: 'Voice input (coming soon)',
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Type workout here (voice coming soon)...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                onSubmitted: _processInput,
                enabled: !_isProcessing,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              onPressed: _isProcessing
                  ? null
                  : () => _processInput(_textController.text),
              tooltip: 'Send',
            ),
          ],
        ),
      ),
    );
  }
}
