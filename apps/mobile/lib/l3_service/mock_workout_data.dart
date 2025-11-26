import '../l2_domain/models/workout.dart';
import '../l2_domain/models/workout_exercise.dart';

/// Mock workout data with all weights in kg and distances in km (base units)
class MockWorkoutData {
  static final List<Workout> mockWorkouts = [
    // Push Day - Nov 20, 2025
    Workout(
      id: '1732115400000', // Nov 20, 2025 14:30
      dateTime: DateTime(2025, 11, 20, 14, 30),
      durationMinutes: 52,
      exercises: [
        WorkoutExercise(
          exerciseId: 'barbell-bench-press',
          name: 'Barbell Bench Press',
          category: 'strength',
          muscleGroup: 'chest',
          parameters: {
            'sets': 4,
            'reps': 8,
            'weight': 83.91, // 185 lbs → kg
            'restBetweenSets': 120,
          },
          createdAt: DateTime(2025, 11, 20, 14, 30),
          updatedAt: DateTime(2025, 11, 20, 14, 30),
        ),
        WorkoutExercise(
          exerciseId: 'incline-dumbbell-bench-press',
          name: 'Incline Dumbbell Bench Press',
          category: 'strength',
          muscleGroup: 'chest',
          parameters: {
            'sets': 3,
            'reps': 10,
            'weight': 29.48, // 65 lbs → kg
            'restBetweenSets': 90,
          },
          createdAt: DateTime(2025, 11, 20, 14, 40),
          updatedAt: DateTime(2025, 11, 20, 14, 40),
        ),
        WorkoutExercise(
          exerciseId: 'dumbbell-shoulder-press',
          name: 'Dumbbell Shoulder Press',
          category: 'strength',
          muscleGroup: 'shoulders',
          parameters: {
            'sets': 3,
            'reps': 12,
            'weight': 22.68, // 50 lbs → kg
            'restBetweenSets': 90,
          },
          createdAt: DateTime(2025, 11, 20, 14, 50),
          updatedAt: DateTime(2025, 11, 20, 14, 50),
        ),
        WorkoutExercise(
          exerciseId: 'lateral-raise',
          name: 'Lateral Raise',
          category: 'strength',
          muscleGroup: 'shoulders',
          parameters: {
            'sets': 3,
            'reps': 15,
            'weight': 9.07, // 20 lbs → kg
            'restBetweenSets': 60,
          },
          createdAt: DateTime(2025, 11, 20, 15, 0),
          updatedAt: DateTime(2025, 11, 20, 15, 0),
        ),
        WorkoutExercise(
          exerciseId: 'tricep-pushdown',
          name: 'Tricep Pushdown',
          category: 'strength',
          muscleGroup: 'arms',
          parameters: {
            'sets': 3,
            'reps': 12,
            'weight': 31.75, // 70 lbs → kg
            'restBetweenSets': 60,
          },
          createdAt: DateTime(2025, 11, 20, 15, 10),
          updatedAt: DateTime(2025, 11, 20, 15, 10),
        ),
      ],
    ),

    // Pull Day - Nov 18, 2025
    Workout(
      id: '1731931740000', // Nov 18, 2025 10:15
      dateTime: DateTime(2025, 11, 18, 10, 15),
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
            'weight': 124.74, // 275 lbs → kg
            'restBetweenSets': 180,
          },
          createdAt: DateTime(2025, 11, 18, 10, 15),
          updatedAt: DateTime(2025, 11, 18, 10, 15),
        ),
        WorkoutExercise(
          exerciseId: 'pull-up',
          name: 'Pull-up',
          category: 'strength',
          muscleGroup: 'back',
          parameters: {
            'sets': 4,
            'reps': 10,
            'bodyweight': true,
            'restBetweenSets': 120,
          },
          createdAt: DateTime(2025, 11, 18, 10, 27),
          updatedAt: DateTime(2025, 11, 18, 10, 27),
        ),
        WorkoutExercise(
          exerciseId: 'barbell-row',
          name: 'Barbell Row',
          category: 'strength',
          muscleGroup: 'back',
          parameters: {
            'sets': 3,
            'reps': 10,
            'weight': 70.31, // 155 lbs → kg
            'restBetweenSets': 90,
          },
          createdAt: DateTime(2025, 11, 18, 10, 35),
          updatedAt: DateTime(2025, 11, 18, 10, 35),
        ),
        WorkoutExercise(
          exerciseId: 'barbell-curl',
          name: 'Barbell Curl',
          category: 'strength',
          muscleGroup: 'arms',
          parameters: {
            'sets': 3,
            'reps': 12,
            'weight': 31.75, // 70 lbs → kg
            'restBetweenSets': 60,
          },
          createdAt: DateTime(2025, 11, 18, 10, 45),
          updatedAt: DateTime(2025, 11, 18, 10, 45),
        ),
        WorkoutExercise(
          exerciseId: 'hammer-curl',
          name: 'Hammer Curl',
          category: 'strength',
          muscleGroup: 'arms',
          parameters: {
            'sets': 3,
            'reps': 12,
            'weight': 15.88, // 35 lbs → kg
            'restBetweenSets': 60,
          },
          createdAt: DateTime(2025, 11, 18, 10, 53),
          updatedAt: DateTime(2025, 11, 18, 10, 53),
        ),
      ],
    ),

    // Leg Day - Nov 16, 2025
    Workout(
      id: '1731754800000', // Nov 16, 2025 9:00
      dateTime: DateTime(2025, 11, 16, 9, 0),
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
            'weight': 102.06, // 225 lbs → kg
            'restBetweenSets': 150,
          },
          createdAt: DateTime(2025, 11, 16, 9, 0),
          updatedAt: DateTime(2025, 11, 16, 9, 0),
        ),
        WorkoutExercise(
          exerciseId: 'romanian-deadlift',
          name: 'Romanian Deadlift',
          category: 'strength',
          muscleGroup: 'legs',
          parameters: {
            'sets': 3,
            'reps': 10,
            'weight': 83.91, // 185 lbs → kg
            'restBetweenSets': 120,
          },
          createdAt: DateTime(2025, 11, 16, 9, 12),
          updatedAt: DateTime(2025, 11, 16, 9, 12),
        ),
        WorkoutExercise(
          exerciseId: 'leg-press',
          name: 'Leg Press',
          category: 'strength',
          muscleGroup: 'legs',
          parameters: {
            'sets': 3,
            'reps': 12,
            'weight': 142.88, // 315 lbs → kg
            'restBetweenSets': 90,
          },
          createdAt: DateTime(2025, 11, 16, 9, 23),
          updatedAt: DateTime(2025, 11, 16, 9, 23),
        ),
        WorkoutExercise(
          exerciseId: 'leg-curl',
          name: 'Leg Curl',
          category: 'strength',
          muscleGroup: 'legs',
          parameters: {
            'sets': 3,
            'reps': 12,
            'weight': 40.82, // 90 lbs → kg
            'restBetweenSets': 60,
          },
          createdAt: DateTime(2025, 11, 16, 9, 33),
          updatedAt: DateTime(2025, 11, 16, 9, 33),
        ),
        WorkoutExercise(
          exerciseId: 'standing-calf-raise',
          name: 'Standing Calf Raise',
          category: 'strength',
          muscleGroup: 'legs',
          parameters: {
            'sets': 4,
            'reps': 15,
            'weight': 61.23, // 135 lbs → kg
            'restBetweenSets': 60,
          },
          createdAt: DateTime(2025, 11, 16, 9, 43),
          updatedAt: DateTime(2025, 11, 16, 9, 43),
        ),
      ],
    ),

    // Cardio & Core - Nov 14, 2025
    Workout(
      id: '1731601500000', // Nov 14, 2025 17:45
      dateTime: DateTime(2025, 11, 14, 17, 45),
      durationMinutes: 35,
      exercises: [
        WorkoutExercise(
          exerciseId: 'running',
          name: 'Running',
          category: 'cardio',
          muscleGroup: 'cardio',
          parameters: {
            'duration': 20,
            'distance': 4.02, // 2.5 miles → km
            'pace': '8:00',
          },
          createdAt: DateTime(2025, 11, 14, 17, 45),
          updatedAt: DateTime(2025, 11, 14, 17, 45),
        ),
        WorkoutExercise(
          exerciseId: 'plank',
          name: 'Plank',
          category: 'strength',
          muscleGroup: 'core',
          parameters: {'sets': 3, 'holdDuration': 60, 'restBetweenSets': 60},
          createdAt: DateTime(2025, 11, 14, 18, 5),
          updatedAt: DateTime(2025, 11, 14, 18, 5),
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
            'restBetweenSets': 60,
          },
          createdAt: DateTime(2025, 11, 14, 18, 10),
          updatedAt: DateTime(2025, 11, 14, 18, 10),
        ),
        WorkoutExercise(
          exerciseId: 'russian-twist',
          name: 'Russian Twist',
          category: 'strength',
          muscleGroup: 'core',
          parameters: {
            'sets': 3,
            'reps': 20,
            'weight': 11.34, // 25 lbs → kg
            'restBetweenSets': 45,
          },
          createdAt: DateTime(2025, 11, 14, 18, 15),
          updatedAt: DateTime(2025, 11, 14, 18, 15),
        ),
      ],
    ),

    // Full Body - Nov 12, 2025
    Workout(
      id: '1731419580000', // Nov 12, 2025 13:20
      dateTime: DateTime(2025, 11, 12, 13, 20),
      durationMinutes: 45,
      exercises: [
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
          createdAt: DateTime(2025, 11, 12, 13, 20),
          updatedAt: DateTime(2025, 11, 12, 13, 20),
        ),
        WorkoutExercise(
          exerciseId: 'goblet-squat',
          name: 'Goblet Squat',
          category: 'strength',
          muscleGroup: 'legs',
          parameters: {
            'sets': 3,
            'reps': 15,
            'weight': 22.68, // 50 lbs → kg
            'restBetweenSets': 90,
          },
          createdAt: DateTime(2025, 11, 12, 13, 28),
          updatedAt: DateTime(2025, 11, 12, 13, 28),
        ),
        WorkoutExercise(
          exerciseId: 'dumbbell-row',
          name: 'Dumbbell Row',
          category: 'strength',
          muscleGroup: 'back',
          parameters: {
            'sets': 3,
            'reps': 12,
            'weight': 27.22, // 60 lbs → kg
            'restBetweenSets': 90,
          },
          createdAt: DateTime(2025, 11, 12, 13, 38),
          updatedAt: DateTime(2025, 11, 12, 13, 38),
        ),
        WorkoutExercise(
          exerciseId: 'dumbbell-shoulder-press',
          name: 'Dumbbell Shoulder Press',
          category: 'strength',
          muscleGroup: 'shoulders',
          parameters: {
            'sets': 3,
            'reps': 10,
            'weight': 20.41, // 45 lbs → kg
            'restBetweenSets': 90,
          },
          createdAt: DateTime(2025, 11, 12, 13, 48),
          updatedAt: DateTime(2025, 11, 12, 13, 48),
        ),
        WorkoutExercise(
          exerciseId: 'plank',
          name: 'Plank',
          category: 'strength',
          muscleGroup: 'core',
          parameters: {'sets': 3, 'holdDuration': 45, 'restBetweenSets': 60},
          createdAt: DateTime(2025, 11, 12, 13, 58),
          updatedAt: DateTime(2025, 11, 12, 13, 58),
        ),
      ],
    ),
  ];
}
