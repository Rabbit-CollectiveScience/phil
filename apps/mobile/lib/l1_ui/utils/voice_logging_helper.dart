import '../../l2_domain/models/workout_exercise.dart';
import '../../l2_domain/controller/workout_controller.dart';
import '../../l3_service/gemini_service.dart';

/// Result of voice logging attempt
class VoiceLoggingResult {
  final bool success;
  final String message;
  final WorkoutExercise? exercise;
  final String? error;

  VoiceLoggingResult({
    required this.success,
    required this.message,
    this.exercise,
    this.error,
  });
}

/// UI utility for voice-based workout logging
/// Handles: voice transcription → Gemini parsing → workout saving
/// This is a presentation layer helper that coordinates between UI and domain logic
class VoiceLoggingHelper {
  final GeminiService _geminiService = GeminiService.getInstance();
  final WorkoutController _workoutController = WorkoutController();

  /// Process voice transcription and log workout
  /// Returns result with success status, message, and logged exercise
  Future<VoiceLoggingResult> processVoiceInput(String transcription) async {
    try {
      // Send to Gemini with function calling
      final response = await _geminiService.sendMessageWithFunctions(
        transcription,
      );

      // Check if function was executed
      if (response.result != null) {
        final executionResult = response.result!;

        if (executionResult.success && executionResult.exercise != null) {
          // Save using WorkoutController (respects 1-hour grouping rule)
          await _workoutController.addExerciseToAppropriateWorkout(
            exercise: executionResult.exercise!,
          );

          return VoiceLoggingResult(
            success: true,
            message: response.message,
            exercise: executionResult.exercise,
          );
        } else {
          // Function execution failed
          return VoiceLoggingResult(
            success: false,
            message: response.message,
            error: executionResult.message,
          );
        }
      }

      // No function called - just conversational response
      return VoiceLoggingResult(
        success: false,
        message: response.message,
        error: 'No workout logged - just conversation',
      );
    } catch (e) {
      return VoiceLoggingResult(
        success: false,
        message: 'Error processing voice input',
        error: e.toString(),
      );
    }
  }

  /// Handle corrections (e.g., "actually it was 65kg not 60kg")
  Future<VoiceLoggingResult> processCorrection(
    String correctionText,
    WorkoutExercise originalExercise,
  ) async {
    try {
      // Build context for correction
      final contextMessage =
          '''
User wants to correct their last logged exercise:
Original: ${originalExercise.name} - ${originalExercise.parameters}
Correction: $correctionText

Please update the exercise with the corrected information.
''';

      final response = await _geminiService.sendMessageWithFunctions(
        contextMessage,
      );

      if (response.result != null && response.result!.success) {
        final correctedExercise = response.result!.exercise!;

        // Find today's workout containing the original exercise
        final recentWorkout = await _workoutController
            .getTodaysMostRecentWorkout();

        if (recentWorkout != null) {
          // Replace the exercise using WorkoutController
          await _workoutController.replaceExercise(
            workout: recentWorkout,
            oldExercise: originalExercise,
            newExercise: correctedExercise,
          );

          return VoiceLoggingResult(
            success: true,
            message: response.message,
            exercise: correctedExercise,
          );
        }
      }

      return VoiceLoggingResult(
        success: false,
        message: response.message,
        error: 'Could not process correction',
      );
    } catch (e) {
      return VoiceLoggingResult(
        success: false,
        message: 'Error processing correction',
        error: e.toString(),
      );
    }
  }

  /// Clear conversation history (start fresh)
  void clearHistory() {
    // Note: This clears the regular chat, not the function-calling chat
    // Function-calling chat maintains its own history
    _geminiService.clearHistory();
  }
}
