import 'package:hive/hive.dart';
import '../models/workout.dart';
import '../models/workout_exercise.dart';
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

/// Controller for orchestrating voice-based workout logging
/// Handles: audio → transcription → Gemini → function call → validation → save
class VoiceLoggingController {
  final GeminiService _geminiService = GeminiService.getInstance();
  
  /// Process voice transcription and log workout
  /// Returns result with success status, message, and logged exercise
  Future<VoiceLoggingResult> processVoiceInput(String transcription) async {
    try {
      // Send to Gemini with function calling
      final response = await _geminiService.sendMessageWithFunctions(transcription);
      
      // Check if function was executed
      if (response.result != null) {
        final executionResult = response.result!;
        
        if (executionResult.success && executionResult.exercise != null) {
          // Save to Hive
          await _saveExerciseToWorkout(executionResult.exercise!);
          
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

  /// Save exercise to today's workout (or create new workout)
  Future<void> _saveExerciseToWorkout(WorkoutExercise exercise) async {
    final workoutBox = await Hive.openBox<Workout>('workouts');
    
    // Find or create today's workout
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    Workout? todayWorkout;
    
    // Search for existing workout today
    for (final workout in workoutBox.values) {
      if (workout.dateTime.isAfter(todayStart) && 
          workout.dateTime.isBefore(todayEnd)) {
        todayWorkout = workout;
        break;
      }
    }
    
    if (todayWorkout == null) {
      // Create new workout for today
      todayWorkout = Workout(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dateTime: DateTime.now(),
        exercises: [exercise],
        durationMinutes: 0,
      );
      await workoutBox.add(todayWorkout);
    } else {
      // Add exercise to existing workout
      final updatedExercises = [...todayWorkout.exercises, exercise];
      final updatedWorkout = Workout(
        id: todayWorkout.id,
        dateTime: todayWorkout.dateTime,
        exercises: updatedExercises,
        durationMinutes: todayWorkout.durationMinutes,
      );
      
      // Find and update the workout
      final key = workoutBox.keys.firstWhere(
        (k) => workoutBox.get(k)?.id == todayWorkout!.id,
      );
      await workoutBox.put(key, updatedWorkout);
    }
  }

  /// Handle corrections (e.g., "actually it was 65kg not 60kg")
  Future<VoiceLoggingResult> processCorrection(
    String correctionText,
    WorkoutExercise originalExercise,
  ) async {
    try {
      // Build context for correction
      final contextMessage = '''
User wants to correct their last logged exercise:
Original: ${originalExercise.name} - ${originalExercise.parameters}
Correction: $correctionText

Please update the exercise with the corrected information.
''';
      
      final response = await _geminiService.sendMessageWithFunctions(contextMessage);
      
      if (response.result != null && response.result!.success) {
        final correctedExercise = response.result!.exercise!;
        
        // Update in Hive by removing old and adding new
        await _replaceExercise(originalExercise, correctedExercise);
        
        return VoiceLoggingResult(
          success: true,
          message: response.message,
          exercise: correctedExercise,
        );
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

  /// Replace an exercise in today's workout
  Future<void> _replaceExercise(
    WorkoutExercise oldExercise,
    WorkoutExercise newExercise,
  ) async {
    final workoutBox = await Hive.openBox<Workout>('workouts');
    
    // Find today's workout
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    for (final key in workoutBox.keys) {
      final workout = workoutBox.get(key);
      if (workout != null &&
          workout.dateTime.isAfter(todayStart) &&
          workout.dateTime.isBefore(todayEnd)) {
        // Find and replace the exercise
        final updatedExercises = workout.exercises.map((ex) {
          // Compare by creation time to find the exact exercise
          if (ex.createdAt == oldExercise.createdAt) {
            return newExercise;
          }
          return ex;
        }).toList();
        
        final updatedWorkout = Workout(
          id: workout.id,
          dateTime: workout.dateTime,
          exercises: updatedExercises,
          durationMinutes: workout.durationMinutes,
        );
        
        await workoutBox.put(key, updatedWorkout);
        break;
      }
    }
  }

  /// Clear conversation history (start fresh)
  void clearHistory() {
    // Note: This clears the regular chat, not the function-calling chat
    // Function-calling chat maintains its own history
    _geminiService.clearHistory();
  }
}
