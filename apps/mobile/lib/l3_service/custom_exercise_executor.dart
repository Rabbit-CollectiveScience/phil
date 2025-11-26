import '../l2_domain/models/custom_exercise.dart';
import '../l3_data/repositories/custom_exercise_repository.dart';
import 'exercise_validator.dart';

class CustomExerciseExecutor {
  final CustomExerciseRepository _repository = CustomExerciseRepository();
  final ExerciseValidator _validator = ExerciseValidator.getInstance();

  /// Execute custom exercise creation function calls
  Future<Map<String, dynamic>> executeFunction(
    String functionName,
    Map<String, dynamic> args,
  ) async {
    try {
      switch (functionName) {
        case 'add_custom_strength_exercise':
          return await _executeAddStrengthExercise(args);
        case 'add_custom_cardio_exercise':
          return await _executeAddCardioExercise(args);
        case 'add_custom_flexibility_exercise':
          return await _executeAddFlexibilityExercise(args);
        default:
          return {
            'success': false,
            'error': 'Unknown function: $functionName',
          };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error executing function: $e',
      };
    }
  }

  Future<Map<String, dynamic>> _executeAddStrengthExercise(
    Map<String, dynamic> args,
  ) async {
    final name = args['name'] as String?;
    final muscleGroup = args['muscle_group'] as String?;
    final equipment = args['equipment'] as String?;
    final movementPattern = args['movement_pattern'] as String?;

    if (name == null || name.isEmpty) {
      return {
        'success': false,
        'error': 'Exercise name is required',
      };
    }

    // Check for duplicates in canonical database
    final canonicalMatch = await _validator.findExerciseByName(name);
    if (canonicalMatch != null) {
      return {
        'success': false,
        'error': 'Exercise "$name" already exists in the database',
        'existingExercise': canonicalMatch,
      };
    }

    // Check for duplicates in custom exercises
    final customExists = await _repository.exists(name);
    if (customExists) {
      return {
        'success': false,
        'error': 'You already created an exercise called "$name"',
      };
    }

    // Check for similar exercises using fuzzy matching
    final similarMatch = await _validator.findClosestMatch(name);
    if (similarMatch != null && similarMatch.similarity >= 0.8) {
      return {
        'success': false,
        'error':
            'Exercise "$name" is very similar to existing exercise "${similarMatch.exercise!['name']}". Did you mean that one?',
        'suggestedExercise': similarMatch.exercise,
      };
    }

    // Generate unique ID
    final id = _generateExerciseId(name);

    // Create custom exercise
    final exercise = CustomExercise(
      id: id,
      name: name,
      category: 'strength',
      muscleGroup: muscleGroup,
      equipment: equipment,
      movementPattern: movementPattern,
    );

    await _repository.create(exercise);

    return {
      'success': true,
      'message': 'Created custom strength exercise: $name',
      'exercise': exercise.toMap(),
    };
  }

  Future<Map<String, dynamic>> _executeAddCardioExercise(
    Map<String, dynamic> args,
  ) async {
    final name = args['name'] as String?;
    final activityType = args['activity_type'] as String?;
    final intensityLevel = args['intensity_level'] as String?;

    if (name == null || name.isEmpty) {
      return {
        'success': false,
        'error': 'Exercise name is required',
      };
    }

    // Check for duplicates in canonical database
    final canonicalMatch = await _validator.findExerciseByName(name);
    if (canonicalMatch != null) {
      return {
        'success': false,
        'error': 'Exercise "$name" already exists in the database',
        'existingExercise': canonicalMatch,
      };
    }

    // Check for duplicates in custom exercises
    final customExists = await _repository.exists(name);
    if (customExists) {
      return {
        'success': false,
        'error': 'You already created an exercise called "$name"',
      };
    }

    // Check for similar exercises
    final similarMatch = await _validator.findClosestMatch(name);
    if (similarMatch != null && similarMatch.similarity >= 0.8) {
      return {
        'success': false,
        'error':
            'Exercise "$name" is very similar to existing exercise "${similarMatch.exercise!['name']}". Did you mean that one?',
        'suggestedExercise': similarMatch.exercise,
      };
    }

    // Generate unique ID
    final id = _generateExerciseId(name);

    // Create custom exercise
    final exercise = CustomExercise(
      id: id,
      name: name,
      category: 'cardio',
      activityType: activityType,
      intensityLevel: intensityLevel,
    );

    await _repository.create(exercise);

    return {
      'success': true,
      'message': 'Created custom cardio exercise: $name',
      'exercise': exercise.toMap(),
    };
  }

  Future<Map<String, dynamic>> _executeAddFlexibilityExercise(
    Map<String, dynamic> args,
  ) async {
    final name = args['name'] as String?;
    final targetArea = args['target_area'] as String?;
    final stretchType = args['stretch_type'] as String?;

    if (name == null || name.isEmpty) {
      return {
        'success': false,
        'error': 'Exercise name is required',
      };
    }

    // Check for duplicates in canonical database
    final canonicalMatch = await _validator.findExerciseByName(name);
    if (canonicalMatch != null) {
      return {
        'success': false,
        'error': 'Exercise "$name" already exists in the database',
        'existingExercise': canonicalMatch,
      };
    }

    // Check for duplicates in custom exercises
    final customExists = await _repository.exists(name);
    if (customExists) {
      return {
        'success': false,
        'error': 'You already created an exercise called "$name"',
      };
    }

    // Check for similar exercises
    final similarMatch = await _validator.findClosestMatch(name);
    if (similarMatch != null && similarMatch.similarity >= 0.8) {
      return {
        'success': false,
        'error':
            'Exercise "$name" is very similar to existing exercise "${similarMatch.exercise!['name']}". Did you mean that one?',
        'suggestedExercise': similarMatch.exercise,
      };
    }

    // Generate unique ID
    final id = _generateExerciseId(name);

    // Create custom exercise
    final exercise = CustomExercise(
      id: id,
      name: name,
      category: 'flexibility',
      targetArea: targetArea,
      stretchType: stretchType,
    );

    await _repository.create(exercise);

    return {
      'success': true,
      'message': 'Created custom flexibility exercise: $name',
      'exercise': exercise.toMap(),
    };
  }

  /// Generate a unique exercise ID from name
  String _generateExerciseId(String name) {
    final normalized = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'custom-$normalized-$timestamp';
  }
}
