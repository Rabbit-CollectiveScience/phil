import 'package:flutter/material.dart';
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
    return ExerciseFormScreen(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      category: category,
      muscleGroup: muscleGroup,
      onSave: (exerciseData) {
        // TODO: Save to workout session
        debugPrint('Exercise data: $exerciseData');
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercise added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to dashboard
        Navigator.popUntil(context, (route) => route.isFirst);
      },
    );
  }
}
