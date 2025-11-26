import '../l2_domain/models/workout.dart';
import '../l2_domain/models/workout_exercise.dart';

/// Mock workout data with 4 weeks of comprehensive training
/// Covers all muscle groups, cardio, and flexibility
/// All weights in kg and distances in km (base units)
class MockWorkoutData {
  static final List<Workout> mockWorkouts = [
    // === WEEK 4 (Current Week: Nov 25-27) ===

    // Push Day - Nov 27, 2025
    Workout(
      id: '1732720200000', // Nov 27, 2025 14:30
      dateTime: DateTime(2025, 11, 27, 14, 30),
      durationMinutes: 55,
      exercises: [
        WorkoutExercise(
          exerciseId: 'barbell-bench-press',
          name: 'Barbell Bench Press',
          category: 'strength',
          muscleGroup: 'chest',
          parameters: {
            'sets': 4,
            'reps': 8,
            'weight': 85.0,
            'restBetweenSets': 120,
          },
          createdAt: DateTime(2025, 11, 27, 14, 30),
          updatedAt: DateTime(2025, 11, 27, 14, 30),
        ),
        WorkoutExercise(
          exerciseId: 'incline-dumbbell-press',
          name: 'Incline Dumbbell Press',
          category: 'strength',
          muscleGroup: 'chest',
          parameters: {
            'sets': 3,
            'reps': 10,
            'weight': 30.0,
            'restBetweenSets': 90,
          },
          createdAt: DateTime(2025, 11, 27, 14, 45),
          updatedAt: DateTime(2025, 11, 27, 14, 45),
        ),
        WorkoutExercise(
          exerciseId: 'dumbbell-shoulder-press',
          name: 'Dumbbell Shoulder Press',
          category: 'strength',
          muscleGroup: 'shoulders',
          parameters: {
            'sets': 4,
            'reps': 10,
            'weight': 24.0,
            'restBetweenSets': 90,
          },
          createdAt: DateTime(2025, 11, 27, 15, 0),
          updatedAt: DateTime(2025, 11, 27, 15, 0),
        ),
        WorkoutExercise(
          exerciseId: 'lateral-raise',
          name: 'Lateral Raise',
          category: 'strength',
          muscleGroup: 'shoulders',
          parameters: {
            'sets': 3,
            'reps': 15,
            'weight': 10.0,
            'restBetweenSets': 60,
          },
          createdAt: DateTime(2025, 11, 27, 15, 12),
          updatedAt: DateTime(2025, 11, 27, 15, 12),
        ),
        WorkoutExercise(
          exerciseId: 'tricep-dips',
          name: 'Tricep Dips',
          category: 'strength',
          muscleGroup: 'arms',
          parameters: {
            'sets': 3,
            'reps': 12,
            'bodyweight': true,
            'restBetweenSets': 90,
          },
          createdAt: DateTime(2025, 11, 27, 15, 20),
          updatedAt: DateTime(2025, 11, 27, 15, 20),
        ),
      ],
    ),

    // Yoga & Flexibility - Nov 26, 2025
    Workout(
      id: '1732631400000', // Nov 26, 2025 18:30
      dateTime: DateTime(2025, 11, 26, 18, 30),
      durationMinutes: 40,
      exercises: [
        WorkoutExercise(
          exerciseId: 'yoga-flow',
          name: 'Yoga Flow',
          category: 'flexibility',
          muscleGroup: 'flexibility',
          parameters: {'duration': 25, 'style': 'Vinyasa'},
          createdAt: DateTime(2025, 11, 26, 18, 30),
          updatedAt: DateTime(2025, 11, 26, 18, 30),
        ),
        WorkoutExercise(
          exerciseId: 'pigeon-pose',
          name: 'Pigeon Pose',
          category: 'flexibility',
          muscleGroup: 'flexibility',
          parameters: {'sets': 2, 'holdDuration': 90, 'restBetweenSets': 30},
          createdAt: DateTime(2025, 11, 26, 18, 55),
          updatedAt: DateTime(2025, 11, 26, 18, 55),
        ),
        WorkoutExercise(
          exerciseId: 'seated-forward-fold',
          name: 'Seated Forward Fold',
          category: 'flexibility',
          muscleGroup: 'flexibility',
          parameters: {'sets': 2, 'holdDuration': 60, 'restBetweenSets': 30},
          createdAt: DateTime(2025, 11, 26, 19, 0),
          updatedAt: DateTime(2025, 11, 26, 19, 0),
        ),
      ],
    ),

    // Pull Day - Nov 25, 2025
    Workout(
      id: '1732536600000', // Nov 25, 2025 10:30
      dateTime: DateTime(2025, 11, 25, 10, 30),
      durationMinutes: 50,
      exercises: [
        WorkoutExercise(
          exerciseId: 'deadlift',
          name: 'Deadlift',
          category: 'strength',
          muscleGroup: 'back',
          parameters: {
            'sets': 4,
            'reps': 6,
            'weight': 130.0,
            'restBetweenSets': 180,
          },
          createdAt: DateTime(2025, 11, 25, 10, 30),
          updatedAt: DateTime(2025, 11, 25, 10, 30),
        ),
        WorkoutExercise(
          exerciseId: 'pull-ups',
          name: 'Pull-ups',
          category: 'strength',
          muscleGroup: 'back',
          parameters: {
            'sets': 4,
            'reps': 10,
            'bodyweight': true,
            'restBetweenSets': 120,
          },
          createdAt: DateTime(2025, 11, 25, 10, 45),
          updatedAt: DateTime(2025, 11, 25, 10, 45),
        ),
        WorkoutExercise(
          exerciseId: 'barbell-row',
          name: 'Barbell Row',
          category: 'strength',
          muscleGroup: 'back',
          parameters: {
            'sets': 3,
            'reps': 10,
            'weight': 75.0,
            'restBetweenSets': 90,
          },
          createdAt: DateTime(2025, 11, 25, 11, 0),
          updatedAt: DateTime(2025, 11, 25, 11, 0),
        ),
        WorkoutExercise(
          exerciseId: 'barbell-curl',
          name: 'Barbell Curl',
          category: 'strength',
          muscleGroup: 'arms',
          parameters: {
            'sets': 3,
            'reps': 12,
            'weight': 35.0,
            'restBetweenSets': 60,
          },
          createdAt: DateTime(2025, 11, 25, 11, 12),
          updatedAt: DateTime(2025, 11, 25, 11, 12),
        ),
      ],
    ),

    // === WEEK 3 (Nov 18-24) ===

    // HIIT Cardio - Nov 23, 2025
    Workout(
      id: '1732369800000', // Nov 23, 2025 16:30
      dateTime: DateTime(2025, 11, 23, 16, 30),
      durationMinutes: 30,
      exercises: [
        WorkoutExercise(
          exerciseId: 'burpees',
          name: 'Burpees',
          category: 'cardio',
          muscleGroup: 'cardio',
          parameters: {'sets': 5, 'reps': 15, 'restBetweenSets': 45},
          createdAt: DateTime(2025, 11, 23, 16, 30),
          updatedAt: DateTime(2025, 11, 23, 16, 30),
        ),
        WorkoutExercise(
          exerciseId: 'jump-rope',
          name: 'Jump Rope',
          category: 'cardio',
          muscleGroup: 'cardio',
          parameters: {'sets': 5, 'duration': 2, 'restBetweenSets': 30},
          createdAt: DateTime(2025, 11, 23, 16, 40),
          updatedAt: DateTime(2025, 11, 23, 16, 40),
        ),
        WorkoutExercise(
          exerciseId: 'mountain-climbers',
          name: 'Mountain Climbers',
          category: 'cardio',
          muscleGroup: 'cardio',
          parameters: {'sets': 4, 'reps': 30, 'restBetweenSets': 45},
          createdAt: DateTime(2025, 11, 23, 16, 50),
          updatedAt: DateTime(2025, 11, 23, 16, 50),
        ),
      ],
    ),

    // Leg Day - Nov 21, 2025
    Workout(
      id: '1732199400000', // Nov 21, 2025 9:30
      dateTime: DateTime(2025, 11, 21, 9, 30),
      durationMinutes: 60,
      exercises: [
        WorkoutExercise(
          exerciseId: 'barbell-squat',
          name: 'Barbell Squat',
          category: 'strength',
          muscleGroup: 'legs',
          parameters: {
            'sets': 4,
            'reps': 8,
            'weight': 105.0,
            'restBetweenSets': 150,
          },
          createdAt: DateTime(2025, 11, 21, 9, 30),
          updatedAt: DateTime(2025, 11, 21, 9, 30),
        ),
        WorkoutExercise(
          exerciseId: 'romanian-deadlift',
          name: 'Romanian Deadlift',
          category: 'strength',
          muscleGroup: 'legs',
          parameters: {
            'sets': 3,
            'reps': 10,
            'weight': 85.0,
            'restBetweenSets': 120,
          },
          createdAt: DateTime(2025, 11, 21, 9, 45),
          updatedAt: DateTime(2025, 11, 21, 9, 45),
        ),
        WorkoutExercise(
          exerciseId: 'leg-press',
          name: 'Leg Press',
          category: 'strength',
          muscleGroup: 'legs',
          parameters: {
            'sets': 3,
            'reps': 12,
            'weight': 150.0,
            'restBetweenSets': 90,
          },
          createdAt: DateTime(2025, 11, 21, 10, 0),
          updatedAt: DateTime(2025, 11, 21, 10, 0),
        ),
        WorkoutExercise(
          exerciseId: 'leg-curl',
          name: 'Leg Curl',
          category: 'strength',
          muscleGroup: 'legs',
          parameters: {
            'sets': 3,
            'reps': 12,
            'weight': 45.0,
            'restBetweenSets': 60,
          },
          createdAt: DateTime(2025, 11, 21, 10, 15),
          updatedAt: DateTime(2025, 11, 21, 10, 15),
        ),
        WorkoutExercise(
          exerciseId: 'calf-raise',
          name: 'Calf Raise',
          category: 'strength',
          muscleGroup: 'legs',
          parameters: {
            'sets': 4,
            'reps': 15,
            'weight': 65.0,
            'restBetweenSets': 60,
          },
          createdAt: DateTime(2025, 11, 21, 10, 25),
          updatedAt: DateTime(2025, 11, 21, 10, 25),
        ),
      ],
    ),

    // Upper Body - Nov 19, 2025
    Workout(
      id: '1732023000000', // Nov 19, 2025 15:30
      dateTime: DateTime(2025, 11, 19, 15, 30),
      durationMinutes: 52,
      exercises: [
        WorkoutExercise(
          exerciseId: 'overhead-press',
          name: 'Overhead Press',
          category: 'strength',
          muscleGroup: 'shoulders',
          parameters: {
            'sets': 4,
            'reps': 8,
            'weight': 50.0,
            'restBetweenSets': 120,
          },
          createdAt: DateTime(2025, 11, 19, 15, 30),
          updatedAt: DateTime(2025, 11, 19, 15, 30),
        ),
        WorkoutExercise(
          exerciseId: 'dumbbell-bench-press',
          name: 'Dumbbell Bench Press',
          category: 'strength',
          muscleGroup: 'chest',
          parameters: {
            'sets': 3,
            'reps': 10,
            'weight': 32.0,
            'restBetweenSets': 90,
          },
          createdAt: DateTime(2025, 11, 19, 15, 45),
          updatedAt: DateTime(2025, 11, 19, 15, 45),
        ),
        WorkoutExercise(
          exerciseId: 'cable-row',
          name: 'Cable Row',
          category: 'strength',
          muscleGroup: 'back',
          parameters: {
            'sets': 3,
            'reps': 12,
            'weight': 60.0,
            'restBetweenSets': 90,
          },
          createdAt: DateTime(2025, 11, 19, 16, 0),
          updatedAt: DateTime(2025, 11, 19, 16, 0),
        ),
        WorkoutExercise(
          exerciseId: 'hammer-curl',
          name: 'Hammer Curl',
          category: 'strength',
          muscleGroup: 'arms',
          parameters: {
            'sets': 3,
            'reps': 12,
            'weight': 18.0,
            'restBetweenSets': 60,
          },
          createdAt: DateTime(2025, 11, 19, 16, 12),
          updatedAt: DateTime(2025, 11, 19, 16, 12),
        ),
      ],
    ),

    // Stretching & Mobility - Nov 18, 2025
    Workout(
      id: '1731938400000', // Nov 18, 2025 11:00
      dateTime: DateTime(2025, 11, 18, 11, 0),
      durationMinutes: 35,
      exercises: [
        WorkoutExercise(
          exerciseId: 'dynamic-stretching',
          name: 'Dynamic Stretching',
          category: 'flexibility',
          muscleGroup: 'flexibility',
          parameters: {'duration': 15},
          createdAt: DateTime(2025, 11, 18, 11, 0),
          updatedAt: DateTime(2025, 11, 18, 11, 0),
        ),
        WorkoutExercise(
          exerciseId: 'hip-flexor-stretch',
          name: 'Hip Flexor Stretch',
          category: 'flexibility',
          muscleGroup: 'flexibility',
          parameters: {'sets': 2, 'holdDuration': 60, 'restBetweenSets': 30},
          createdAt: DateTime(2025, 11, 18, 11, 15),
          updatedAt: DateTime(2025, 11, 18, 11, 15),
        ),
        WorkoutExercise(
          exerciseId: 'shoulder-mobility',
          name: 'Shoulder Mobility',
          category: 'flexibility',
          muscleGroup: 'flexibility',
          parameters: {'sets': 3, 'reps': 10, 'restBetweenSets': 45},
          createdAt: DateTime(2025, 11, 18, 11, 20),
          updatedAt: DateTime(2025, 11, 18, 11, 20),
        ),
      ],
    ),

    // === WEEK 2 (Nov 11-17) ===

    // Core & Abs - Nov 16, 2025
    Workout(
      id: '1731768600000', // Nov 16, 2025 13:30
      dateTime: DateTime(2025, 11, 16, 13, 30),
      durationMinutes: 30,
      exercises: [
        WorkoutExercise(
          exerciseId: 'plank',
          name: 'Plank',
          category: 'strength',
          muscleGroup: 'core',
          parameters: {'sets': 4, 'holdDuration': 60, 'restBetweenSets': 45},
          createdAt: DateTime(2025, 11, 16, 13, 30),
          updatedAt: DateTime(2025, 11, 16, 13, 30),
        ),
        WorkoutExercise(
          exerciseId: 'russian-twist',
          name: 'Russian Twist',
          category: 'strength',
          muscleGroup: 'core',
          parameters: {
            'sets': 3,
            'reps': 25,
            'weight': 12.0,
            'restBetweenSets': 60,
          },
          createdAt: DateTime(2025, 11, 16, 13, 40),
          updatedAt: DateTime(2025, 11, 16, 13, 40),
        ),
        WorkoutExercise(
          exerciseId: 'hanging-leg-raise',
          name: 'Hanging Leg Raise',
          category: 'strength',
          muscleGroup: 'core',
          parameters: {
            'sets': 3,
            'reps': 15,
            'bodyweight': true,
            'restBetweenSets': 90,
          },
          createdAt: DateTime(2025, 11, 16, 13, 50),
          updatedAt: DateTime(2025, 11, 16, 13, 50),
        ),
        WorkoutExercise(
          exerciseId: 'bicycle-crunch',
          name: 'Bicycle Crunch',
          category: 'strength',
          muscleGroup: 'core',
          parameters: {'sets': 3, 'reps': 30, 'restBetweenSets': 60},
          createdAt: DateTime(2025, 11, 16, 14, 0),
          updatedAt: DateTime(2025, 11, 16, 14, 0),
        ),
      ],
    ),

    // Running & Cardio - Nov 14, 2025
    Workout(
      id: '1731595200000', // Nov 14, 2025 17:00
      dateTime: DateTime(2025, 11, 14, 17, 0),
      durationMinutes: 45,
      exercises: [
        WorkoutExercise(
          exerciseId: 'running',
          name: 'Running',
          category: 'cardio',
          muscleGroup: 'cardio',
          parameters: {'duration': 30, 'distance': 5.0, 'pace': '6:00'},
          createdAt: DateTime(2025, 11, 14, 17, 0),
          updatedAt: DateTime(2025, 11, 14, 17, 0),
        ),
        WorkoutExercise(
          exerciseId: 'sprint-intervals',
          name: 'Sprint Intervals',
          category: 'cardio',
          muscleGroup: 'cardio',
          parameters: {'sets': 6, 'duration': 1, 'restBetweenSets': 90},
          createdAt: DateTime(2025, 11, 14, 17, 30),
          updatedAt: DateTime(2025, 11, 14, 17, 30),
        ),
      ],
    ),

    // Push Day - Nov 13, 2025
    Workout(
      id: '1731501000000', // Nov 13, 2025 14:30
      dateTime: DateTime(2025, 11, 13, 14, 30),
      durationMinutes: 50,
      exercises: [
        WorkoutExercise(
          exerciseId: 'barbell-bench-press',
          name: 'Barbell Bench Press',
          category: 'strength',
          muscleGroup: 'chest',
          parameters: {
            'sets': 4,
            'reps': 8,
            'weight': 82.5,
            'restBetweenSets': 120,
          },
          createdAt: DateTime(2025, 11, 13, 14, 30),
          updatedAt: DateTime(2025, 11, 13, 14, 30),
        ),
        WorkoutExercise(
          exerciseId: 'cable-fly',
          name: 'Cable Fly',
          category: 'strength',
          muscleGroup: 'chest',
          parameters: {
            'sets': 3,
            'reps': 12,
            'weight': 25.0,
            'restBetweenSets': 90,
          },
          createdAt: DateTime(2025, 11, 13, 14, 45),
          updatedAt: DateTime(2025, 11, 13, 14, 45),
        ),
        WorkoutExercise(
          exerciseId: 'arnold-press',
          name: 'Arnold Press',
          category: 'strength',
          muscleGroup: 'shoulders',
          parameters: {
            'sets': 3,
            'reps': 10,
            'weight': 20.0,
            'restBetweenSets': 90,
          },
          createdAt: DateTime(2025, 11, 13, 15, 0),
          updatedAt: DateTime(2025, 11, 13, 15, 0),
        ),
        WorkoutExercise(
          exerciseId: 'tricep-extension',
          name: 'Tricep Extension',
          category: 'strength',
          muscleGroup: 'arms',
          parameters: {
            'sets': 3,
            'reps': 12,
            'weight': 28.0,
            'restBetweenSets': 60,
          },
          createdAt: DateTime(2025, 11, 13, 15, 12),
          updatedAt: DateTime(2025, 11, 13, 15, 12),
        ),
      ],
    ),

    // Pull Day - Nov 11, 2025
    Workout(
      id: '1731330600000', // Nov 11, 2025 10:30
      dateTime: DateTime(2025, 11, 11, 10, 30),
      durationMinutes: 48,
      exercises: [
        WorkoutExercise(
          exerciseId: 'deadlift',
          name: 'Deadlift',
          category: 'strength',
          muscleGroup: 'back',
          parameters: {
            'sets': 4,
            'reps': 5,
            'weight': 125.0,
            'restBetweenSets': 180,
          },
          createdAt: DateTime(2025, 11, 11, 10, 30),
          updatedAt: DateTime(2025, 11, 11, 10, 30),
        ),
        WorkoutExercise(
          exerciseId: 'lat-pulldown',
          name: 'Lat Pulldown',
          category: 'strength',
          muscleGroup: 'back',
          parameters: {
            'sets': 3,
            'reps': 10,
            'weight': 70.0,
            'restBetweenSets': 90,
          },
          createdAt: DateTime(2025, 11, 11, 10, 48),
          updatedAt: DateTime(2025, 11, 11, 10, 48),
        ),
        WorkoutExercise(
          exerciseId: 'face-pull',
          name: 'Face Pull',
          category: 'strength',
          muscleGroup: 'back',
          parameters: {
            'sets': 3,
            'reps': 15,
            'weight': 30.0,
            'restBetweenSets': 60,
          },
          createdAt: DateTime(2025, 11, 11, 11, 0),
          updatedAt: DateTime(2025, 11, 11, 11, 0),
        ),
        WorkoutExercise(
          exerciseId: 'preacher-curl',
          name: 'Preacher Curl',
          category: 'strength',
          muscleGroup: 'arms',
          parameters: {
            'sets': 3,
            'reps': 12,
            'weight': 30.0,
            'restBetweenSets': 60,
          },
          createdAt: DateTime(2025, 11, 11, 11, 10),
          updatedAt: DateTime(2025, 11, 11, 11, 10),
        ),
      ],
    ),

    // === WEEK 1 (Nov 4-10) ===

    // Full Body - Nov 9, 2025
    Workout(
      id: '1731168600000', // Nov 9, 2025 16:30
      dateTime: DateTime(2025, 11, 9, 16, 30),
      durationMinutes: 55,
      exercises: [
        WorkoutExercise(
          exerciseId: 'front-squat',
          name: 'Front Squat',
          category: 'strength',
          muscleGroup: 'legs',
          parameters: {
            'sets': 4,
            'reps': 8,
            'weight': 75.0,
            'restBetweenSets': 120,
          },
          createdAt: DateTime(2025, 11, 9, 16, 30),
          updatedAt: DateTime(2025, 11, 9, 16, 30),
        ),
        WorkoutExercise(
          exerciseId: 'push-up',
          name: 'Push-up',
          category: 'strength',
          muscleGroup: 'chest',
          parameters: {
            'sets': 4,
            'reps': 20,
            'bodyweight': true,
            'restBetweenSets': 60,
          },
          createdAt: DateTime(2025, 11, 9, 16, 45),
          updatedAt: DateTime(2025, 11, 9, 16, 45),
        ),
        WorkoutExercise(
          exerciseId: 'bent-over-row',
          name: 'Bent Over Row',
          category: 'strength',
          muscleGroup: 'back',
          parameters: {
            'sets': 3,
            'reps': 10,
            'weight': 65.0,
            'restBetweenSets': 90,
          },
          createdAt: DateTime(2025, 11, 9, 16, 58),
          updatedAt: DateTime(2025, 11, 9, 16, 58),
        ),
        WorkoutExercise(
          exerciseId: 'plank',
          name: 'Plank',
          category: 'strength',
          muscleGroup: 'core',
          parameters: {'sets': 3, 'holdDuration': 50, 'restBetweenSets': 60},
          createdAt: DateTime(2025, 11, 9, 17, 10),
          updatedAt: DateTime(2025, 11, 9, 17, 10),
        ),
      ],
    ),

    // Yoga Flow - Nov 7, 2025
    Workout(
      id: '1730999400000', // Nov 7, 2025 19:30
      dateTime: DateTime(2025, 11, 7, 19, 30),
      durationMinutes: 45,
      exercises: [
        WorkoutExercise(
          exerciseId: 'sun-salutation',
          name: 'Sun Salutation',
          category: 'flexibility',
          muscleGroup: 'flexibility',
          parameters: {'sets': 5, 'reps': 1, 'restBetweenSets': 30},
          createdAt: DateTime(2025, 11, 7, 19, 30),
          updatedAt: DateTime(2025, 11, 7, 19, 30),
        ),
        WorkoutExercise(
          exerciseId: 'warrior-pose',
          name: 'Warrior Pose',
          category: 'flexibility',
          muscleGroup: 'flexibility',
          parameters: {'sets': 4, 'holdDuration': 45, 'restBetweenSets': 20},
          createdAt: DateTime(2025, 11, 7, 19, 45),
          updatedAt: DateTime(2025, 11, 7, 19, 45),
        ),
        WorkoutExercise(
          exerciseId: 'child-pose',
          name: "Child's Pose",
          category: 'flexibility',
          muscleGroup: 'flexibility',
          parameters: {'sets': 2, 'holdDuration': 90, 'restBetweenSets': 30},
          createdAt: DateTime(2025, 11, 7, 20, 0),
          updatedAt: DateTime(2025, 11, 7, 20, 0),
        ),
      ],
    ),

    // Leg Day - Nov 6, 2025
    Workout(
      id: '1730908800000', // Nov 6, 2025 9:00
      dateTime: DateTime(2025, 11, 6, 9, 0),
      durationMinutes: 58,
      exercises: [
        WorkoutExercise(
          exerciseId: 'barbell-squat',
          name: 'Barbell Squat',
          category: 'strength',
          muscleGroup: 'legs',
          parameters: {
            'sets': 4,
            'reps': 8,
            'weight': 100.0,
            'restBetweenSets': 150,
          },
          createdAt: DateTime(2025, 11, 6, 9, 0),
          updatedAt: DateTime(2025, 11, 6, 9, 0),
        ),
        WorkoutExercise(
          exerciseId: 'walking-lunge',
          name: 'Walking Lunge',
          category: 'strength',
          muscleGroup: 'legs',
          parameters: {
            'sets': 3,
            'reps': 20,
            'weight': 20.0,
            'restBetweenSets': 90,
          },
          createdAt: DateTime(2025, 11, 6, 9, 15),
          updatedAt: DateTime(2025, 11, 6, 9, 15),
        ),
        WorkoutExercise(
          exerciseId: 'leg-extension',
          name: 'Leg Extension',
          category: 'strength',
          muscleGroup: 'legs',
          parameters: {
            'sets': 3,
            'reps': 15,
            'weight': 55.0,
            'restBetweenSets': 60,
          },
          createdAt: DateTime(2025, 11, 6, 9, 30),
          updatedAt: DateTime(2025, 11, 6, 9, 30),
        ),
        WorkoutExercise(
          exerciseId: 'seated-calf-raise',
          name: 'Seated Calf Raise',
          category: 'strength',
          muscleGroup: 'legs',
          parameters: {
            'sets': 4,
            'reps': 20,
            'weight': 40.0,
            'restBetweenSets': 60,
          },
          createdAt: DateTime(2025, 11, 6, 9, 45),
          updatedAt: DateTime(2025, 11, 6, 9, 45),
        ),
      ],
    ),

    // Swimming - Nov 5, 2025
    Workout(
      id: '1730829000000', // Nov 5, 2025 18:30
      dateTime: DateTime(2025, 11, 5, 18, 30),
      durationMinutes: 40,
      exercises: [
        WorkoutExercise(
          exerciseId: 'freestyle-swimming',
          name: 'Freestyle Swimming',
          category: 'cardio',
          muscleGroup: 'cardio',
          parameters: {'duration': 20, 'distance': 1.0},
          createdAt: DateTime(2025, 11, 5, 18, 30),
          updatedAt: DateTime(2025, 11, 5, 18, 30),
        ),
        WorkoutExercise(
          exerciseId: 'backstroke',
          name: 'Backstroke',
          category: 'cardio',
          muscleGroup: 'cardio',
          parameters: {'duration': 10, 'distance': 0.5},
          createdAt: DateTime(2025, 11, 5, 18, 50),
          updatedAt: DateTime(2025, 11, 5, 18, 50),
        ),
        WorkoutExercise(
          exerciseId: 'water-treading',
          name: 'Water Treading',
          category: 'cardio',
          muscleGroup: 'cardio',
          parameters: {'duration': 10},
          createdAt: DateTime(2025, 11, 5, 19, 0),
          updatedAt: DateTime(2025, 11, 5, 19, 0),
        ),
      ],
    ),

    // Upper Body - Nov 4, 2025
    Workout(
      id: '1730739000000', // Nov 4, 2025 14:30
      dateTime: DateTime(2025, 11, 4, 14, 30),
      durationMinutes: 50,
      exercises: [
        WorkoutExercise(
          exerciseId: 'barbell-bench-press',
          name: 'Barbell Bench Press',
          category: 'strength',
          muscleGroup: 'chest',
          parameters: {
            'sets': 4,
            'reps': 10,
            'weight': 80.0,
            'restBetweenSets': 120,
          },
          createdAt: DateTime(2025, 11, 4, 14, 30),
          updatedAt: DateTime(2025, 11, 4, 14, 30),
        ),
        WorkoutExercise(
          exerciseId: 't-bar-row',
          name: 'T-Bar Row',
          category: 'strength',
          muscleGroup: 'back',
          parameters: {
            'sets': 3,
            'reps': 10,
            'weight': 55.0,
            'restBetweenSets': 90,
          },
          createdAt: DateTime(2025, 11, 4, 14, 45),
          updatedAt: DateTime(2025, 11, 4, 14, 45),
        ),
        WorkoutExercise(
          exerciseId: 'military-press',
          name: 'Military Press',
          category: 'strength',
          muscleGroup: 'shoulders',
          parameters: {
            'sets': 3,
            'reps': 8,
            'weight': 45.0,
            'restBetweenSets': 120,
          },
          createdAt: DateTime(2025, 11, 4, 15, 0),
          updatedAt: DateTime(2025, 11, 4, 15, 0),
        ),
        WorkoutExercise(
          exerciseId: 'concentration-curl',
          name: 'Concentration Curl',
          category: 'strength',
          muscleGroup: 'arms',
          parameters: {
            'sets': 3,
            'reps': 12,
            'weight': 15.0,
            'restBetweenSets': 60,
          },
          createdAt: DateTime(2025, 11, 4, 15, 15),
          updatedAt: DateTime(2025, 11, 4, 15, 15),
        ),
      ],
    ),
  ];
}
