import '../l2_domain/models/workout.dart';
import '../l2_domain/models/workout_exercise.dart';

class MockWorkoutData {
  static final List<Workout> mockWorkouts = [
    // Push Day - Nov 20, 2025
    Workout(
      id: '1',
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
            'weight': 185,
            'weightUnit': 'lbs',
            'restBetweenSets': 120,
          },
        ),
        WorkoutExercise(
          exerciseId: 'incline-dumbbell-bench-press',
          name: 'Incline Dumbbell Bench Press',
          category: 'strength',
          muscleGroup: 'chest',
          parameters: {
            'sets': 3,
            'reps': 10,
            'weight': 65,
            'weightUnit': 'lbs',
            'restBetweenSets': 90,
          },
        ),
        WorkoutExercise(
          exerciseId: 'dumbbell-shoulder-press',
          name: 'Dumbbell Shoulder Press',
          category: 'strength',
          muscleGroup: 'shoulders',
          parameters: {
            'sets': 3,
            'reps': 12,
            'weight': 50,
            'weightUnit': 'lbs',
            'restBetweenSets': 90,
          },
        ),
        WorkoutExercise(
          exerciseId: 'lateral-raise',
          name: 'Lateral Raise',
          category: 'strength',
          muscleGroup: 'shoulders',
          parameters: {
            'sets': 3,
            'reps': 15,
            'weight': 20,
            'weightUnit': 'lbs',
            'restBetweenSets': 60,
          },
        ),
        WorkoutExercise(
          exerciseId: 'tricep-pushdown',
          name: 'Tricep Pushdown',
          category: 'strength',
          muscleGroup: 'arms',
          parameters: {
            'sets': 3,
            'reps': 12,
            'weight': 70,
            'weightUnit': 'lbs',
            'restBetweenSets': 60,
          },
        ),
      ],
    ),

    // Pull Day - Nov 18, 2025
    Workout(
      id: '2',
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
            'weight': 275,
            'weightUnit': 'lbs',
            'restBetweenSets': 180,
          },
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
        ),
        WorkoutExercise(
          exerciseId: 'barbell-row',
          name: 'Barbell Row',
          category: 'strength',
          muscleGroup: 'back',
          parameters: {
            'sets': 3,
            'reps': 10,
            'weight': 155,
            'weightUnit': 'lbs',
            'restBetweenSets': 90,
          },
        ),
        WorkoutExercise(
          exerciseId: 'barbell-curl',
          name: 'Barbell Curl',
          category: 'strength',
          muscleGroup: 'arms',
          parameters: {
            'sets': 3,
            'reps': 12,
            'weight': 70,
            'weightUnit': 'lbs',
            'restBetweenSets': 60,
          },
        ),
        WorkoutExercise(
          exerciseId: 'hammer-curl',
          name: 'Hammer Curl',
          category: 'strength',
          muscleGroup: 'arms',
          parameters: {
            'sets': 3,
            'reps': 12,
            'weight': 35,
            'weightUnit': 'lbs',
            'restBetweenSets': 60,
          },
        ),
      ],
    ),

    // Leg Day - Nov 16, 2025
    Workout(
      id: '3',
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
            'weight': 225,
            'weightUnit': 'lbs',
            'restBetweenSets': 150,
          },
        ),
        WorkoutExercise(
          exerciseId: 'romanian-deadlift',
          name: 'Romanian Deadlift',
          category: 'strength',
          muscleGroup: 'legs',
          parameters: {
            'sets': 3,
            'reps': 10,
            'weight': 185,
            'weightUnit': 'lbs',
            'restBetweenSets': 120,
          },
        ),
        WorkoutExercise(
          exerciseId: 'leg-press',
          name: 'Leg Press',
          category: 'strength',
          muscleGroup: 'legs',
          parameters: {
            'sets': 3,
            'reps': 12,
            'weight': 315,
            'weightUnit': 'lbs',
            'restBetweenSets': 90,
          },
        ),
        WorkoutExercise(
          exerciseId: 'leg-curl',
          name: 'Leg Curl',
          category: 'strength',
          muscleGroup: 'legs',
          parameters: {
            'sets': 3,
            'reps': 12,
            'weight': 90,
            'weightUnit': 'lbs',
            'restBetweenSets': 60,
          },
        ),
        WorkoutExercise(
          exerciseId: 'standing-calf-raise',
          name: 'Standing Calf Raise',
          category: 'strength',
          muscleGroup: 'legs',
          parameters: {
            'sets': 4,
            'reps': 15,
            'weight': 135,
            'weightUnit': 'lbs',
            'restBetweenSets': 60,
          },
        ),
      ],
    ),

    // Cardio & Core - Nov 14, 2025
    Workout(
      id: '4',
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
            'distance': 2.5,
            'distanceUnit': 'miles',
            'pace': '8:00',
          },
        ),
        WorkoutExercise(
          exerciseId: 'plank',
          name: 'Plank',
          category: 'strength',
          muscleGroup: 'core',
          parameters: {'sets': 3, 'holdDuration': 60, 'restBetweenSets': 60},
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
        ),
        WorkoutExercise(
          exerciseId: 'russian-twist',
          name: 'Russian Twist',
          category: 'strength',
          muscleGroup: 'core',
          parameters: {
            'sets': 3,
            'reps': 20,
            'weight': 25,
            'weightUnit': 'lbs',
            'restBetweenSets': 45,
          },
        ),
      ],
    ),

    // Full Body - Nov 12, 2025
    Workout(
      id: '5',
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
        ),
        WorkoutExercise(
          exerciseId: 'goblet-squat',
          name: 'Goblet Squat',
          category: 'strength',
          muscleGroup: 'legs',
          parameters: {
            'sets': 3,
            'reps': 15,
            'weight': 50,
            'weightUnit': 'lbs',
            'restBetweenSets': 90,
          },
        ),
        WorkoutExercise(
          exerciseId: 'dumbbell-row',
          name: 'Dumbbell Row',
          category: 'strength',
          muscleGroup: 'back',
          parameters: {
            'sets': 3,
            'reps': 12,
            'weight': 60,
            'weightUnit': 'lbs',
            'restBetweenSets': 90,
          },
        ),
        WorkoutExercise(
          exerciseId: 'dumbbell-shoulder-press',
          name: 'Dumbbell Shoulder Press',
          category: 'strength',
          muscleGroup: 'shoulders',
          parameters: {
            'sets': 3,
            'reps': 10,
            'weight': 45,
            'weightUnit': 'lbs',
            'restBetweenSets': 90,
          },
        ),
        WorkoutExercise(
          exerciseId: 'plank',
          name: 'Plank',
          category: 'strength',
          muscleGroup: 'core',
          parameters: {'sets': 3, 'holdDuration': 45, 'restBetweenSets': 60},
        ),
      ],
    ),
  ];
}
