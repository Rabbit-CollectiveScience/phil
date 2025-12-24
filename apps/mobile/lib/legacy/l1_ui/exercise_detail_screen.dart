import 'package:flutter/material.dart';
import '../l2_domain/models/workout_exercise.dart';
import '../l2_domain/controller/workout_controller.dart';
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
    final workoutController = WorkoutController();

    return ExerciseFormScreen(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      category: category,
      muscleGroup: muscleGroup,
      onSave: (exerciseData) async {
        // Create exercise with timestamps
        final exercise = WorkoutExercise(
          exerciseId: exerciseData['exerciseId'],
          name: exerciseData['name'],
          category: exerciseData['category'],
          muscleGroup: exerciseData['muscleGroup'],
          parameters: exerciseData['parameters'],
          // createdAt and updatedAt default to DateTime.now() in constructor
        );

        // Use auto-grouping to add to existing workout or create new one (1-hour threshold)
        final workout = await workoutController.addExerciseToAppropriateWorkout(
          exercise: exercise,
        );

        if (context.mounted) {
          // Check if this was added to existing workout or created new one
          final addedToExisting = workout.exercises.length > 1;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                addedToExisting
                    ? '✅ Added to current workout'
                    : '🆕 Started new workout',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Navigate back to dashboard
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      },
    );
  }
}
