import 'package:flutter/material.dart';
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
        // Create exercise with timestamps
        final exercise = WorkoutExercise(
          exerciseId: exerciseData['exerciseId'],
          name: exerciseData['name'],
          category: exerciseData['category'],
          muscleGroup: exerciseData['muscleGroup'],
          parameters: exerciseData['parameters'],
          // createdAt and updatedAt default to DateTime.now() in constructor
        );

        // Use auto-grouping to add to existing workout or create new one
        await workoutService.addExerciseWithAutoGrouping(exercise);

        if (context.mounted) {
          // Get updated workouts to check if grouped
          final workouts = await workoutService.getAllWorkouts();
          final addedToExisting =
              workouts.isNotEmpty &&
              workouts.first.exercises.length > 1 &&
              workouts.first.exercises.last.exerciseId == exercise.exerciseId;

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
