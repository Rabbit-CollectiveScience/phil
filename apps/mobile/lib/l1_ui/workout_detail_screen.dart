import 'package:flutter/material.dart';
import '../l2_domain/models/workout.dart';
import '../l2_domain/models/workout_exercise.dart';
import '../l3_service/workout_service.dart';
import '../l3_service/settings_service.dart';
import 'exercise_form_screen.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;
  final VoidCallback? onDelete;

  const WorkoutDetailScreen({super.key, required this.workout, this.onDelete});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  final WorkoutService _workoutService = WorkoutService();
  late List<WorkoutExercise> _exercises;
  String _weightUnit = 'lbs';
  String _distanceUnit = 'miles';

  @override
  void initState() {
    super.initState();
    _exercises = List.from(widget.workout.exercises);
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final settings = await SettingsService.getInstance();
    setState(() {
      _weightUnit = settings.weightUnit;
      _distanceUnit = settings.distanceUnit;
    });
  }

  Future<void> _updateExercise(
    int index,
    Map<String, dynamic> exerciseData,
  ) async {
    final updatedExercise = WorkoutExercise(
      exerciseId: exerciseData['exerciseId'],
      name: exerciseData['name'],
      category: exerciseData['category'],
      muscleGroup: exerciseData['muscleGroup'],
      parameters: exerciseData['parameters'],
    );

    setState(() {
      _exercises[index] = updatedExercise;
    });

    // Save updated workout to database
    final updatedWorkout = Workout(
      id: widget.workout.id,
      dateTime: widget.workout.dateTime,
      exercises: _exercises,
      durationMinutes: widget.workout.durationMinutes,
    );
    await _workoutService.updateWorkout(updatedWorkout);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exercise updated'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteExercise(int index) async {
    setState(() {
      _exercises.removeAt(index);
    });

    // Save updated workout to database
    final updatedWorkout = Workout(
      id: widget.workout.id,
      dateTime: widget.workout.dateTime,
      exercises: List.from(_exercises),
      durationMinutes: widget.workout.durationMinutes,
    );
    await _workoutService.updateWorkout(updatedWorkout);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exercise removed from workout'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Delete Workout',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this workout? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              // Delete the workout first
              await _workoutService.deleteWorkout(widget.workout.id);
              if (mounted) {
                Navigator.pop(context); // Close detail screen
                // Show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Workout deleted'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3A3A3A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A3A3A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Workout Details',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _confirmDelete,
            tooltip: 'Delete workout',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Workout Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.workout.formattedDate,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn('${_exercises.length}', 'Exercises'),
                          _buildStatColumn(
                            '${widget.workout.durationMinutes}',
                            'Minutes',
                          ),
                          _buildStatColumn(
                            '${_exercises.map((e) => e.muscleGroup).toSet().length}',
                            'Muscle Groups',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Exercises Section
                const Text(
                  'Exercises',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Exercise List
                if (_exercises.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'No exercises in this workout',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    ),
                  )
                else
                  ..._exercises.asMap().entries.map((entry) {
                    final index = entry.key;
                    final exercise = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildExerciseCard(exercise, index + 1, index),
                    );
                  }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(WorkoutExercise exercise, int number, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseFormScreen(
              exerciseId: exercise.exerciseId,
              exerciseName: exercise.name,
              category: exercise.category,
              muscleGroup: exercise.muscleGroup,
              initialParameters: exercise.parameters,
              exerciseNumber: number,
              workoutDateTime: widget.workout.dateTime,
              onDateTimeChanged: (newDateTime) async {
                // Update workout with new datetime
                final updatedWorkout = Workout(
                  id: widget.workout.id,
                  dateTime: newDateTime,
                  exercises: _exercises,
                  durationMinutes: widget.workout.durationMinutes,
                );

                await _workoutService.updateWorkout(updatedWorkout);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Workout date/time updated'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              onSave: (exerciseData) => _updateExercise(index, exerciseData),
              onDelete: () => _deleteExercise(index),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!, width: 1),
        ),
        child: Row(
          children: [
            // Exercise Number Badge
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getMuscleGroupColor(exercise.muscleGroup),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Exercise Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _capitalizeFirstLetter(exercise.muscleGroup),
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    exercise.formattedParametersWithPreferences(
                      _weightUnit,
                      _distanceUnit,
                    ),
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey[600], size: 20),
          ],
        ),
      ),
    );
  }

  Color _getMuscleGroupColor(String muscleGroup) {
    switch (muscleGroup.toLowerCase()) {
      case 'chest':
        return Colors.blue;
      case 'back':
        return Colors.green;
      case 'shoulders':
        return Colors.orange;
      case 'arms':
        return Colors.red;
      case 'legs':
        return Colors.purple;
      case 'core':
        return Colors.yellow.shade700;
      case 'cardio':
        return Colors.pink;
      case 'flexibility':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
