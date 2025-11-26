import 'package:google_generative_ai/google_generative_ai.dart';

class CustomExerciseFunctionDeclarations {
  static List<FunctionDeclaration> getDeclarations() {
    return [
      _createStrengthExerciseDeclaration(),
      _createCardioExerciseDeclaration(),
      _createFlexibilityExerciseDeclaration(),
    ];
  }

  static FunctionDeclaration _createStrengthExerciseDeclaration() {
    return FunctionDeclaration(
      'add_custom_strength_exercise',
      'Creates a new custom strength training exercise when the user mentions an exercise that is not in the database. Use this function to add user-defined strength exercises like bodyweight movements, weighted exercises, or resistance training that are not recognized.',
      Schema(
        SchemaType.object,
        properties: {
          'name': Schema(
            SchemaType.string,
            description:
                'The name of the strength exercise (e.g., "Wall Sit", "Bodyweight Squat", "Dragon Flag"). Use proper capitalization and spelling.',
          ),
          'muscle_group': Schema(
            SchemaType.string,
            description:
                'Primary muscle group targeted by this exercise. Valid values: chest, back, shoulders, biceps, triceps, forearms, abs, legs, glutes, calves, full-body',
            enumValues: [
              'chest',
              'back',
              'shoulders',
              'biceps',
              'triceps',
              'forearms',
              'abs',
              'legs',
              'glutes',
              'calves',
              'full-body',
            ],
          ),
          'equipment': Schema(
            SchemaType.string,
            description:
                'Equipment required for this exercise. Valid values: bodyweight, barbell, dumbbell, kettlebell, machine, cable, resistance-band, other',
            enumValues: [
              'bodyweight',
              'barbell',
              'dumbbell',
              'kettlebell',
              'machine',
              'cable',
              'resistance-band',
              'other',
            ],
          ),
          'movement_pattern': Schema(
            SchemaType.string,
            description:
                'Primary movement pattern of the exercise. Valid values: push, pull, squat, hinge, lunge, carry, rotation, isometric',
            enumValues: [
              'push',
              'pull',
              'squat',
              'hinge',
              'lunge',
              'carry',
              'rotation',
              'isometric',
            ],
          ),
        },
        requiredProperties: ['name', 'muscle_group', 'equipment', 'movement_pattern'],
      ),
    );
  }

  static FunctionDeclaration _createCardioExerciseDeclaration() {
    return FunctionDeclaration(
      'add_custom_cardio_exercise',
      'Creates a new custom cardiovascular exercise when the user mentions a cardio activity that is not in the database. Use this function to add user-defined cardio exercises like sports, outdoor activities, or cardio machines not recognized.',
      Schema(
        SchemaType.object,
        properties: {
          'name': Schema(
            SchemaType.string,
            description:
                'The name of the cardio exercise (e.g., "Trail Running", "Mountain Biking", "Jump Rope Double Unders"). Use proper capitalization and spelling.',
          ),
          'activity_type': Schema(
            SchemaType.string,
            description:
                'Type of cardiovascular activity. Valid values: running, cycling, swimming, rowing, jumping, hiking, sports, dancing, other',
            enumValues: [
              'running',
              'cycling',
              'swimming',
              'rowing',
              'jumping',
              'hiking',
              'sports',
              'dancing',
              'other',
            ],
          ),
          'intensity_level': Schema(
            SchemaType.string,
            description:
                'Typical intensity level of this cardio exercise. Valid values: low (easy walking, gentle cycling), moderate (brisk walking, steady jogging), high (sprinting, HIIT, competitive sports)',
            enumValues: ['low', 'moderate', 'high'],
          ),
        },
        requiredProperties: ['name', 'activity_type', 'intensity_level'],
      ),
    );
  }

  static FunctionDeclaration _createFlexibilityExerciseDeclaration() {
    return FunctionDeclaration(
      'add_custom_flexibility_exercise',
      'Creates a new custom flexibility or mobility exercise when the user mentions a stretch or mobility drill that is not in the database. Use this function to add user-defined stretches, yoga poses, or mobility work not recognized.',
      Schema(
        SchemaType.object,
        properties: {
          'name': Schema(
            SchemaType.string,
            description:
                'The name of the flexibility exercise (e.g., "Couch Stretch", "90/90 Hip Stretch", "World\'s Greatest Stretch"). Use proper capitalization and spelling.',
          ),
          'target_area': Schema(
            SchemaType.string,
            description:
                'Primary body area targeted by this stretch or mobility drill. Valid values: hamstrings, quadriceps, hips, shoulders, back, chest, calves, neck, wrists, ankles, full-body',
            enumValues: [
              'hamstrings',
              'quadriceps',
              'hips',
              'shoulders',
              'back',
              'chest',
              'calves',
              'neck',
              'wrists',
              'ankles',
              'full-body',
            ],
          ),
          'stretch_type': Schema(
            SchemaType.string,
            description:
                'Type of stretching technique. Valid values: static (holding a position), dynamic (moving through range of motion), mobility (active movement drills)',
            enumValues: ['static', 'dynamic', 'mobility'],
          ),
        },
        requiredProperties: ['name', 'target_area', 'stretch_type'],
      ),
    );
  }
}
