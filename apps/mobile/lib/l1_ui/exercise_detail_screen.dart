import 'package:flutter/material.dart';
import '../l2_domain/models/workout.dart';
import '../l2_domain/models/workout_exercise.dart';
import '../l3_service/workout_service.dart';
import 'exercise_form_screen.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final String exerciseId;
  final String exerciseName;
  final String category;
  final String muscleGroup;

  const ExerciseDetailScreen({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    required this.category,
    required this.muscleGroup,
  });

  @override
  Widget build(BuildContext context) {
    final workoutService = WorkoutService();

    return ExerciseFormScreen(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      category: category,
      muscleGroup: muscleGroup,
      onSave: (exerciseData) async {
        // Create a new workout with this exercise
        final exercise = WorkoutExercise(
          exerciseId: exerciseData['exerciseId'],
          name: exerciseData['name'],
          category: exerciseData['category'],
          muscleGroup: exerciseData['muscleGroup'],
          parameters: exerciseData['parameters'],
        );

        final workout = Workout(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          dateTime: DateTime.now(),
          exercises: [exercise],
          durationMinutes: 0, // Will be updated when workout completes
        );

        await workoutService.saveWorkout(workout);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Exercise added successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to dashboard
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      },
    );
  }
}
