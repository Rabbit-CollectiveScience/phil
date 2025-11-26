import 'package:google_generative_ai/google_generative_ai.dart';
import '../l2_domain/models/workout_exercise.dart';
import 'exercise_validator.dart';
import 'custom_exercise_executor.dart';

/// Result of a function execution
class FunctionExecutionResult {
  final bool success;
  final WorkoutExercise? exercise;
  final String message;
  final Map<String, dynamic>? functionResponse;
  final bool isCustomExerciseCreation; // Flag to distinguish creation vs logging

  FunctionExecutionResult({
    required this.success,
    this.exercise,
    required this.message,
    this.functionResponse,
    this.isCustomExerciseCreation = false,
  });
}

/// Executes workout logging functions and validates parameters
class WorkoutFunctionExecutor {
  final ExerciseValidator _validator = ExerciseValidator.getInstance();
  final CustomExerciseExecutor _customExecutor = CustomExerciseExecutor();

  /// Execute a function call from Gemini
  Future<FunctionExecutionResult> executeFunction(
    FunctionCall functionCall,
  ) async {
    // Ensure validator is initialized
    if (!_validator.isInitialized) {
      await _validator.initialize();
    }

    final functionName = functionCall.name;
    final args = functionCall.args;

    try {
      // Route to custom exercise executor if it's a creation function
      if (functionName.startsWith('add_custom_')) {
        return await _executeCustomExerciseCreation(functionName, args);
      }

      // Otherwise handle as a logging function
      switch (functionName) {
        case 'log_strength_exercise':
          return await _executeStrengthLog(args);
        case 'log_cardio_exercise':
          return await _executeCardioLog(args);
        case 'log_flexibility_exercise':
          return await _executeFlexibilityLog(args);
        default:
          return FunctionExecutionResult(
            success: false,
            message: 'Unknown function: $functionName',
            functionResponse: {'error': 'Unknown function'},
          );
      }
    } catch (e) {
      return FunctionExecutionResult(
        success: false,
        message: 'Error executing function: $e',
        functionResponse: {'error': e.toString()},
      );
    }
  }

  /// Execute custom exercise creation
  Future<FunctionExecutionResult> _executeCustomExerciseCreation(
    String functionName,
    Map<String, dynamic> args,
  ) async {
    final result = await _customExecutor.executeFunction(functionName, args);

    return FunctionExecutionResult(
      success: result['success'] as bool,
      message: result['message'] as String? ?? result['error'] as String? ?? '',
      functionResponse: result,
      isCustomExerciseCreation: true,
    );
  }

  /// Execute strength exercise logging
  Future<FunctionExecutionResult> _executeStrengthLog(
    Map<String, dynamic> args,
  ) async {
    // Extract and validate parameters
    final exerciseName = args['exercise_name'] as String?;
    final sets = args['sets'] as int?;
    final reps = args['reps'] as int?;
    final weightKg = (args['weight_kg'] as num?)?.toDouble();
    final toFailure = args['to_failure'] as bool? ?? false;
    final notes = args['notes'] as String?;

    // Validate required parameters
    if (exerciseName == null ||
        sets == null ||
        reps == null ||
        weightKg == null) {
      return FunctionExecutionResult(
        success: false,
        message: 'Missing required parameters for strength exercise',
        functionResponse: {'error': 'Missing required parameters'},
      );
    }

    // Find exercise in database
    var exercise = await _validator.findExerciseByName(exerciseName);

    // If not found, try fuzzy matching
    if (exercise == null) {
      final match = await _validator.findClosestMatch(
        exerciseName,
        category: 'strength',
      );
      if (match != null) {
        exercise = match.exercise;
      }
    }

    if (exercise == null) {
      return FunctionExecutionResult(
        success: false,
        message: 'Exercise not found: $exerciseName',
        functionResponse: {
          'error': 'Exercise not found',
          'suggestion': 'Try a different exercise name or check spelling',
        },
      );
    }

    // Validate category
    if (exercise['category'] != 'strength') {
      return FunctionExecutionResult(
        success: false,
        message:
            '${exercise['name']} is not a strength exercise. It\'s a ${exercise['category']} exercise.',
        functionResponse: {
          'error': 'Wrong category',
          'actual_category': exercise['category'],
        },
      );
    }

    // Create WorkoutExercise
    final workoutExercise = WorkoutExercise(
      exerciseId: exercise['id'] as String,
      name: exercise['name'] as String,
      category: exercise['category'] as String,
      muscleGroup: exercise['muscleGroup'] as String,
      parameters: {
        'sets': sets,
        'reps': reps,
        'weight': weightKg,
        'toFailure': toFailure,
        if (notes != null) 'notes': notes,
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return FunctionExecutionResult(
      success: true,
      exercise: workoutExercise,
      message:
          'Logged: $sets sets of $reps reps ${exercise['name']} at ${weightKg}kg',
      functionResponse: {
        'success': true,
        'exercise': exercise['name'],
        'sets': sets,
        'reps': reps,
        'weight_kg': weightKg,
      },
    );
  }

  /// Execute cardio exercise logging
  Future<FunctionExecutionResult> _executeCardioLog(
    Map<String, dynamic> args,
  ) async {
    // Extract and validate parameters
    final exerciseName = args['exercise_name'] as String?;
    final durationMinutes = (args['duration_minutes'] as num?)?.toDouble();
    final distanceKm = (args['distance_km'] as num?)?.toDouble();
    final paceMinPerKm = (args['pace_min_per_km'] as num?)?.toDouble();
    final notes = args['notes'] as String?;

    // Validate required parameters
    if (exerciseName == null || durationMinutes == null) {
      return FunctionExecutionResult(
        success: false,
        message: 'Missing required parameters for cardio exercise',
        functionResponse: {'error': 'Missing required parameters'},
      );
    }

    // Find exercise in database
    var exercise = await _validator.findExerciseByName(exerciseName);

    // If not found, try fuzzy matching
    if (exercise == null) {
      final match = await _validator.findClosestMatch(
        exerciseName,
        category: 'cardio',
      );
      if (match != null) {
        exercise = match.exercise;
      }
    }

    if (exercise == null) {
      return FunctionExecutionResult(
        success: false,
        message: 'Exercise not found: $exerciseName',
        functionResponse: {
          'error': 'Exercise not found',
          'suggestion': 'Try a different exercise name or check spelling',
        },
      );
    }

    // Validate category
    if (exercise['category'] != 'cardio') {
      return FunctionExecutionResult(
        success: false,
        message:
            '${exercise['name']} is not a cardio exercise. It\'s a ${exercise['category']} exercise.',
        functionResponse: {
          'error': 'Wrong category',
          'actual_category': exercise['category'],
        },
      );
    }

    // Create WorkoutExercise
    final workoutExercise = WorkoutExercise(
      exerciseId: exercise['id'] as String,
      name: exercise['name'] as String,
      category: exercise['category'] as String,
      muscleGroup: exercise['muscleGroup'] as String,
      parameters: {
        'duration': durationMinutes,
        if (distanceKm != null) 'distance': distanceKm,
        if (paceMinPerKm != null) 'pace': paceMinPerKm,
        if (notes != null) 'notes': notes,
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Build message
    final distanceStr = distanceKm != null ? ', ${distanceKm}km' : '';
    final paceStr = paceMinPerKm != null
        ? ', ${paceMinPerKm.toStringAsFixed(1)} min/km'
        : '';

    return FunctionExecutionResult(
      success: true,
      exercise: workoutExercise,
      message:
          'Logged: ${durationMinutes} min ${exercise['name']}$distanceStr$paceStr',
      functionResponse: {
        'success': true,
        'exercise': exercise['name'],
        'duration_minutes': durationMinutes,
        if (distanceKm != null) 'distance_km': distanceKm,
        if (paceMinPerKm != null) 'pace_min_per_km': paceMinPerKm,
      },
    );
  }

  /// Execute flexibility exercise logging
  Future<FunctionExecutionResult> _executeFlexibilityLog(
    Map<String, dynamic> args,
  ) async {
    // Extract and validate parameters
    final exerciseName = args['exercise_name'] as String?;
    final holdDurationSeconds = args['hold_duration_seconds'] as int?;
    final sets = args['sets'] as int? ?? 1;
    final notes = args['notes'] as String?;

    // Validate required parameters
    if (exerciseName == null || holdDurationSeconds == null) {
      return FunctionExecutionResult(
        success: false,
        message: 'Missing required parameters for flexibility exercise',
        functionResponse: {'error': 'Missing required parameters'},
      );
    }

    // Find exercise in database
    var exercise = await _validator.findExerciseByName(exerciseName);

    // If not found, try fuzzy matching
    if (exercise == null) {
      final match = await _validator.findClosestMatch(
        exerciseName,
        category: 'flexibility',
      );
      if (match != null) {
        exercise = match.exercise;
      }
    }

    if (exercise == null) {
      return FunctionExecutionResult(
        success: false,
        message: 'Exercise not found: $exerciseName',
        functionResponse: {
          'error': 'Exercise not found',
          'suggestion': 'Try a different exercise name or check spelling',
        },
      );
    }

    // Validate category
    if (exercise['category'] != 'flexibility') {
      return FunctionExecutionResult(
        success: false,
        message:
            '${exercise['name']} is not a flexibility exercise. It\'s a ${exercise['category']} exercise.',
        functionResponse: {
          'error': 'Wrong category',
          'actual_category': exercise['category'],
        },
      );
    }

    // Create WorkoutExercise
    final workoutExercise = WorkoutExercise(
      exerciseId: exercise['id'] as String,
      name: exercise['name'] as String,
      category: exercise['category'] as String,
      muscleGroup: exercise['muscleGroup'] as String,
      parameters: {
        'holdDuration': holdDurationSeconds,
        'sets': sets,
        if (notes != null) 'notes': notes,
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return FunctionExecutionResult(
      success: true,
      exercise: workoutExercise,
      message:
          'Logged: ${exercise['name']} held for ${holdDurationSeconds}s (${sets}x)',
      functionResponse: {
        'success': true,
        'exercise': exercise['name'],
        'hold_duration_seconds': holdDurationSeconds,
        'sets': sets,
      },
    );
  }
}
