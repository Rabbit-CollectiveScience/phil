import 'package:google_generative_ai/google_generative_ai.dart';
import 'custom_exercise_function_declarations.dart';

/// Function declarations for voice-based workout logging
/// Uses 3 separate functions based on exercise category for type-safe parameters
class WorkoutFunctionDeclarations {
  /// Get all function declarations for workout logging (includes custom exercise creation)
  static List<FunctionDeclaration> getDeclarations() {
    return [
      // Logging functions
      _logStrengthExercise(),
      _logCardioExercise(),
      _logFlexibilityExercise(),
      // Custom exercise creation functions
      ...CustomExerciseFunctionDeclarations.getDeclarations(),
    ];
  }

  /// Function declaration for logging strength exercises
  static FunctionDeclaration _logStrengthExercise() {
    return FunctionDeclaration(
      'log_strength_exercise',
      'Log a strength training exercise with sets, reps, and weight. Use this for any resistance training exercises like bench press, squats, curls, rows, etc. Valid exercises: Barbell Bench Press, Dumbbell Bench Press, Incline Barbell Bench Press, Incline Dumbbell Bench Press, Decline Barbell Bench Press, Decline Dumbbell Bench Press, Close Grip Bench Press, Wide Grip Bench Press, Dumbbell Chest Fly, Incline Dumbbell Fly, Cable Chest Fly, Low Cable Fly, High Cable Fly, Pec Deck, Chest Press Machine, Push-up, Wide Push-up, Diamond Push-up, Decline Push-up, Incline Push-up, Dip, Weighted Dip, Cable Crossover, Svend Press, Floor Press, Barbell Row, Dumbbell Row, T-Bar Row, Cable Row, Seated Cable Row, Pull-up, Chin-up, Wide Grip Pull-up, Weighted Pull-up, Lat Pulldown, Wide Grip Lat Pulldown, Close Grip Lat Pulldown, Deadlift, Sumo Deadlift, Romanian Deadlift, Trap Bar Deadlift, Rack Pull, Single Arm Dumbbell Row, Pendlay Row, Inverted Row, Face Pull, Shrug, Dumbbell Shrug, Barbell Shrug, Machine Row, Chest Supported Row, Meadows Row, Straight Arm Pulldown, Hyperextension, Good Morning, Barbell Shoulder Press, Dumbbell Shoulder Press, Seated Shoulder Press, Standing Shoulder Press, Military Press, Arnold Press, Push Press, Lateral Raise, Dumbbell Lateral Raise, Cable Lateral Raise, Front Raise, Barbell Front Raise, Rear Delt Fly, Cable Rear Delt Fly, Reverse Pec Deck, Upright Row, Cable Upright Row, Pike Push-up, Handstand Push-up, Overhead Press Machine, Barbell Curl, Dumbbell Curl, Hammer Curl, Preacher Curl, Concentration Curl, Cable Curl, EZ Bar Curl, Incline Dumbbell Curl, Reverse Curl, Spider Curl, Tricep Dip, Tricep Pushdown, Overhead Tricep Extension, Skull Crusher, Dumbbell Tricep Extension, Rope Pushdown, Cable Overhead Extension, Bench Dip, Kickback, Wrist Curl, Reverse Wrist Curl, Farmer Walk, Plate Pinch, Dead Hang, Zottman Curl, Barbell Squat, Front Squat, Goblet Squat, Bulgarian Split Squat, Pistol Squat, Hack Squat, Leg Press, Walking Lunge, Reverse Lunge, Lateral Lunge, Step Up, Leg Extension, Leg Curl, Seated Leg Curl, Nordic Curl, Glute Bridge, Hip Thrust, Single Leg Hip Thrust, Cable Kickback, Cable Pull Through, Adductor Machine, Abductor Machine, Standing Calf Raise, Seated Calf Raise, Calf Press, Box Jump, Jump Squat, Wall Sit, Sissy Squat, Jefferson Squat, Landmine Squat, Belt Squat, Zercher Squat, Sled Push, Sled Pull, Reverse Nordic, Tibialis Raise, Single Leg Deadlift, Curtsy Lunge, Plank, Side Plank, Ab Wheel Rollout, Crunch, Bicycle Crunch, Russian Twist, Leg Raise, Hanging Leg Raise, Knee Raise, Mountain Climber, Cable Crunch, Pallof Press, Dead Bug, Bird Dog, Hollow Body Hold, Toes to Bar, V-Up, Dragon Flag, Landmine Rotation, Woodchop, Oblique Crunch, Reverse Crunch, Sit-Up, Decline Sit-Up, L-Sit',
      Schema.object(
        properties: {
          'exercise_name': Schema.string(
            description:
                'The exact name of the strength exercise from the list above. Must match one of the valid exercises exactly.',
            nullable: false,
          ),
          'sets': Schema.integer(
            description: 'Number of sets performed (e.g., 3, 4, 5)',
            nullable: false,
          ),
          'reps': Schema.integer(
            description: 'Number of repetitions per set (e.g., 8, 10, 12)',
            nullable: false,
          ),
          'weight_kg': Schema.number(
            description:
                'Weight used in kilograms. Convert from pounds if needed (lbs × 0.453592). Use 0 for bodyweight exercises.',
            nullable: false,
          ),
          'to_failure': Schema.boolean(
            description:
                'Whether the set was taken to muscular failure. Default false if not mentioned.',
            nullable: true,
          ),
          'notes': Schema.string(
            description:
                'Optional notes about the exercise (e.g., "felt heavy", "new PR", "good form")',
            nullable: true,
          ),
        },
        requiredProperties: ['exercise_name', 'sets', 'reps', 'weight_kg'],
      ),
    );
  }

  /// Function declaration for logging cardio exercises
  static FunctionDeclaration _logCardioExercise() {
    return FunctionDeclaration(
      'log_cardio_exercise',
      'Log a cardio/aerobic exercise with duration and optionally distance. Use this for running, cycling, rowing, swimming, etc. Valid exercises: Running, Treadmill Run, Cycling, Stationary Bike, Rowing, Rowing Machine, Swimming, Elliptical, Stair Climber, Jump Rope, Burpee, Battle Rope, Assault Bike, Ski Erg, Sprints, Hill Sprints, Interval Training, HIIT, Tabata, Walking, Incline Walk, Shadowboxing, Heavy Bag, Kettlebell Swing, Sled Drag, Prowler Push, Tire Flip, Bear Crawl, Crab Walk',
      Schema.object(
        properties: {
          'exercise_name': Schema.string(
            description:
                'The exact name of the cardio exercise from the list above. Must match one of the valid exercises exactly.',
            nullable: false,
          ),
          'duration_minutes': Schema.number(
            description:
                'Duration of the cardio session in minutes (e.g., 30, 45.5, 60)',
            nullable: false,
          ),
          'distance_km': Schema.number(
            description:
                'Distance covered in kilometers. Convert from miles if needed (miles × 1.60934). Omit if not applicable (e.g., burpees, battle rope).',
            nullable: true,
          ),
          'pace_min_per_km': Schema.number(
            description:
                'Pace in minutes per kilometer (e.g., 5.5 for 5:30/km). Convert from min/mile if needed (min/mile × 0.621371). Omit if not applicable.',
            nullable: true,
          ),
          'notes': Schema.string(
            description:
                'Optional notes about the workout (e.g., "felt strong", "outdoor run", "new route")',
            nullable: true,
          ),
        },
        requiredProperties: ['exercise_name', 'duration_minutes'],
      ),
    );
  }

  /// Function declaration for logging flexibility exercises
  static FunctionDeclaration _logFlexibilityExercise() {
    return FunctionDeclaration(
      'log_flexibility_exercise',
      'Log a flexibility/stretching exercise with hold duration. Use this for static stretches, yoga poses, mobility work. Valid exercises: Hamstring Stretch, Quad Stretch, Hip Flexor Stretch, Pigeon Pose, Butterfly Stretch, Calf Stretch, Chest Stretch, Shoulder Stretch, Tricep Stretch, Cat-Cow, Child\'s Pose, Cobra Stretch, Downward Dog, Spinal Twist, Seated Forward Fold',
      Schema.object(
        properties: {
          'exercise_name': Schema.string(
            description:
                'The exact name of the flexibility exercise from the list above. Must match one of the valid exercises exactly.',
            nullable: false,
          ),
          'hold_duration_seconds': Schema.integer(
            description:
                'How long the stretch was held in seconds (e.g., 30, 60, 90)',
            nullable: false,
          ),
          'sets': Schema.integer(
            description:
                'Number of times the stretch was repeated. Default 1 if not mentioned.',
            nullable: true,
          ),
          'notes': Schema.string(
            description:
                'Optional notes about the stretch (e.g., "felt tight", "good release", "left side")',
            nullable: true,
          ),
        },
        requiredProperties: ['exercise_name', 'hold_duration_seconds'],
      ),
    );
  }
}
