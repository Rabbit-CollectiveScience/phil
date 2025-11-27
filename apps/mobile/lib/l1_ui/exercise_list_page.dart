import 'package:flutter/material.dart';
import '../l3_service/workout_service.dart';
import 'exercise_detail_page.dart';

class ExerciseListPage extends StatefulWidget {
  const ExerciseListPage({super.key});

  @override
  State<ExerciseListPage> createState() => ExerciseListPageState();
}

class ExerciseListPageState extends State<ExerciseListPage> {
  final WorkoutService _workoutService = WorkoutService();
  Map<String, ExerciseSummary> _exerciseSummaries = {};
  List<ExerciseSummary> _filteredExercises = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void didUpdateWidget(ExerciseListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadExercises();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void refresh() {
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      setState(() => _isLoading = true);
      final workouts = await _workoutService.getAllWorkouts();

      // Group exercises and calculate summaries
      Map<String, ExerciseSummary> summaries = {};

      for (final workout in workouts) {
        for (final exercise in workout.exercises) {
          if (!summaries.containsKey(exercise.name)) {
            summaries[exercise.name] = ExerciseSummary(
              name: exercise.name,
              muscleGroup: exercise.muscleGroup,
              lastPerformed: workout.dateTime,
              totalSessions: 1,
            );
          } else {
            summaries[exercise.name]!.totalSessions++;
            if (workout.dateTime.isAfter(
              summaries[exercise.name]!.lastPerformed,
            )) {
              summaries[exercise.name]!.lastPerformed = workout.dateTime;
            }
          }

          // Track last weight/distance/duration
          if (exercise.muscleGroup == 'cardio') {
            final distance = exercise.parameters['distance'] as double? ?? 0.0;
            final duration = (exercise.parameters['duration'] is int ? exercise.parameters['duration'] as int : (exercise.parameters['duration'] as double?)?.round()) ?? 0;
            if (workout.dateTime == summaries[exercise.name]!.lastPerformed) {
              summaries[exercise.name]!.lastDistance = distance;
              summaries[exercise.name]!.lastDuration = duration;
            }
          } else if (exercise.muscleGroup == 'flexibility') {
            final duration = (exercise.parameters['duration'] is int ? exercise.parameters['duration'] as int : (exercise.parameters['duration'] as double?)?.round()) ?? 0;
            final reps = (exercise.parameters['sets'] is int ? exercise.parameters['sets'] as int : (exercise.parameters['sets'] as double?)?.round()) ?? 0;
            if (workout.dateTime == summaries[exercise.name]!.lastPerformed) {
              summaries[exercise.name]!.lastDuration = duration;
              summaries[exercise.name]!.lastReps = reps;
            }
          } else {
            final weight = exercise.parameters['weight'] as num? ?? 0;
            final currentMax = summaries[exercise.name]!.maxWeight;
            if (weight > currentMax) {
              summaries[exercise.name]!.maxWeight = weight.toDouble();
            }
          }
        }
      }

      final sortedExercises = summaries.values.toList()
        ..sort((a, b) => b.lastPerformed.compareTo(a.lastPerformed));

      setState(() {
        _exerciseSummaries = summaries;
        _filteredExercises = sortedExercises;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error loading exercises: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterExercises(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredExercises = _exerciseSummaries.values.toList()
          ..sort((a, b) => b.lastPerformed.compareTo(a.lastPerformed));
      } else {
        _filteredExercises =
            _exerciseSummaries.values
                .where(
                  (exercise) =>
                      exercise.name.toLowerCase().contains(query.toLowerCase()),
                )
                .toList()
              ..sort((a, b) => b.lastPerformed.compareTo(a.lastPerformed));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3A3A3A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A3A3A),
        title: const Text('Exercise History'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterExercises,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search exercises...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // Exercise List
                Expanded(
                  child: _filteredExercises.isEmpty
                      ? Center(
                          child: Text(
                            'No exercises found',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredExercises.length,
                          itemBuilder: (context, index) {
                            final exercise = _filteredExercises[index];
                            return _buildExerciseCard(exercise);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildExerciseCard(ExerciseSummary exercise) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseDetailPage(
              exerciseName: exercise.name,
              muscleGroup: exercise.muscleGroup,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    exercise.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getMuscleGroupColor(
                      exercise.muscleGroup,
                    ).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _capitalizeFirstLetter(exercise.muscleGroup),
                    style: TextStyle(
                      color: _getMuscleGroupColor(exercise.muscleGroup),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last performed',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(exercise.lastPerformed),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _getMetricLabel(exercise.muscleGroup),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getMetricValue(exercise),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Sessions',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${exercise.totalSessions}',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getMetricLabel(String muscleGroup) {
    if (muscleGroup == 'cardio') return 'Last distance';
    if (muscleGroup == 'flexibility') return 'Last duration';
    return 'Max weight';
  }

  String _getMetricValue(ExerciseSummary exercise) {
    if (exercise.muscleGroup == 'cardio') {
      return '${exercise.lastDistance.toStringAsFixed(1)} km';
    }
    if (exercise.muscleGroup == 'flexibility') {
      return '${exercise.lastDuration} min';
    }
    return '${exercise.maxWeight.toStringAsFixed(0)} kg';
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

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class ExerciseSummary {
  final String name;
  final String muscleGroup;
  DateTime lastPerformed;
  int totalSessions;
  double maxWeight;
  double lastDistance;
  int lastDuration;
  int lastReps;

  ExerciseSummary({
    required this.name,
    required this.muscleGroup,
    required this.lastPerformed,
    this.totalSessions = 0,
    this.maxWeight = 0.0,
    this.lastDistance = 0.0,
    this.lastDuration = 0,
    this.lastReps = 0,
  });
}
