import 'package:flutter/material.dart';
import '../l2_domain/models/workout.dart';
import '../l2_domain/models/workout_exercise.dart';
import '../l3_service/workout_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'exercise_form_screen.dart';

class ExerciseDetailPage extends StatefulWidget {
  final String exerciseName;
  final String muscleGroup;

  const ExerciseDetailPage({
    super.key,
    required this.exerciseName,
    required this.muscleGroup,
  });

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage>
    with SingleTickerProviderStateMixin {
  final WorkoutService _workoutService = WorkoutService();
  List<ExerciseSession> _sessions = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final tabCount = _getTabCount();
    _tabController = TabController(length: tabCount, vsync: this);
    _loadExerciseSessions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _getTabCount() {
    if (widget.muscleGroup == 'cardio') return 2; // Distance, Duration
    if (widget.muscleGroup == 'flexibility') return 2; // Duration, Reps
    return 2; // Volume, Max
  }

  Future<void> _loadExerciseSessions() async {
    try {
      setState(() => _isLoading = true);

      final allWorkouts = await _workoutService.getAllWorkouts();
      List<ExerciseSession> sessions = [];

      for (final workout in allWorkouts) {
        final exercises = workout.exercises
            .where((e) => e.name == widget.exerciseName)
            .toList();

        if (exercises.isNotEmpty) {
          // Use the exercise's createdAt time, not the workout's dateTime
          sessions.add(
            ExerciseSession(
              workoutDate: exercises.first.createdAt,
              exercises: exercises,
              workout: workout,
            ),
          );
        }
      }

      // Sort by date (oldest first for chart)
      sessions.sort((a, b) => a.workoutDate.compareTo(b.workoutDate));

      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error loading exercise sessions: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF3A3A3A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF3A3A3A),
          title: Text(widget.exerciseName),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF3A3A3A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A3A3A),
        title: Text(widget.exerciseName),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[600],
          tabs: _buildTabs(),
        ),
      ),
      body: TabBarView(controller: _tabController, children: _buildTabViews()),
    );
  }

  List<Widget> _buildTabs() {
    if (widget.muscleGroup == 'cardio') {
      return const [Tab(text: 'Distance'), Tab(text: 'Duration')];
    }
    if (widget.muscleGroup == 'flexibility') {
      return const [Tab(text: 'Duration'), Tab(text: 'Reps')];
    }
    return const [Tab(text: 'Volume'), Tab(text: 'Max')];
  }

  List<Widget> _buildTabViews() {
    if (widget.muscleGroup == 'cardio') {
      return [_buildChartView('distance'), _buildChartView('duration')];
    }
    if (widget.muscleGroup == 'flexibility') {
      return [_buildChartView('duration'), _buildChartView('reps')];
    }
    return [_buildChartView('volume'), _buildChartView('max')];
  }

  Widget _buildChartView(String metricType) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart
            _buildChart(metricType),

            const SizedBox(height: 30),

            // History Header
            Text(
              'History (${_sessions.length} workouts)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Session Cards
            ..._sessions.reversed.map(
              (session) => _buildSessionCard(session, metricType),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(String metricType) {
    if (_sessions.isEmpty) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No data to display',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ),
      );
    }

    final dataPoints = _getDataPoints(metricType);
    final maxY = dataPoints.map((p) => p.y).reduce((a, b) => a > b ? a : b);
    final minY = dataPoints.map((p) => p.y).reduce((a, b) => a < b ? a : b);
    final yRange = maxY - minY;
    final interval = yRange > 0 ? yRange / 5 : 1.0;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey[800]!, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  _formatYAxisValue(value, metricType),
                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < _sessions.length) {
                    final date = _sessions[value.toInt()].workoutDate;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${date.month}/${date.day}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          minY: minY * 0.9,
          maxY: maxY * 1.1,
          lineBarsData: [
            LineChartBarData(
              spots: dataPoints,
              isCurved: true,
              color: _getChartColor(metricType),
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: 4,
                      color: _getChartColor(metricType),
                      strokeWidth: 2,
                      strokeColor: Colors.grey[900]!,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: _getChartColor(metricType).withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getDataPoints(String metricType) {
    List<FlSpot> points = [];

    for (int i = 0; i < _sessions.length; i++) {
      final session = _sessions[i];
      double value = 0;

      switch (metricType) {
        case 'volume':
          value = _calculateSessionVolume(session);
          break;
        case 'max':
          value = _calculateSessionMaxWeight(session);
          break;
        case 'distance':
          value = _calculateSessionTotalDistance(session);
          break;
        case 'duration':
          value = _calculateSessionTotalDuration(session).toDouble();
          break;
        case 'reps':
          value = _calculateSessionTotalReps(session).toDouble();
          break;
      }

      points.add(FlSpot(i.toDouble(), value));
    }

    return points;
  }

  double _calculateSessionVolume(ExerciseSession session) {
    double total = 0;
    for (final exercise in session.exercises) {
      final sets =
          (exercise.parameters['sets'] is int
              ? exercise.parameters['sets'] as int
              : (exercise.parameters['sets'] as double?)?.round()) ??
          0;
      final reps =
          (exercise.parameters['reps'] is int
              ? exercise.parameters['reps'] as int
              : (exercise.parameters['reps'] as double?)?.round()) ??
          0;
      final weight = exercise.parameters['weight'] as num? ?? 0;
      total += sets * reps * weight.toDouble();
    }
    return total;
  }

  double _calculateSessionMaxWeight(ExerciseSession session) {
    double max = 0;
    for (final exercise in session.exercises) {
      final weight = exercise.parameters['weight'] as num? ?? 0;
      if (weight > max) max = weight.toDouble();
    }
    return max;
  }

  double _calculateSessionTotalDistance(ExerciseSession session) {
    double total = 0;
    for (final exercise in session.exercises) {
      total += exercise.parameters['distance'] as double? ?? 0.0;
    }
    return total;
  }

  int _calculateSessionTotalDuration(ExerciseSession session) {
    int total = 0;
    for (final exercise in session.exercises) {
      total +=
          (exercise.parameters['duration'] is int
              ? exercise.parameters['duration'] as int
              : (exercise.parameters['duration'] as double?)?.round()) ??
          0;
    }
    return total;
  }

  int _calculateSessionTotalReps(ExerciseSession session) {
    int total = 0;
    for (final exercise in session.exercises) {
      final sets =
          (exercise.parameters['sets'] is int
              ? exercise.parameters['sets'] as int
              : (exercise.parameters['sets'] as double?)?.round()) ??
          0;
      final reps =
          (exercise.parameters['reps'] is int
              ? exercise.parameters['reps'] as int
              : (exercise.parameters['reps'] as double?)?.round()) ??
          0;
      total += sets * reps;
    }
    return total;
  }

  Color _getChartColor(String metricType) {
    switch (metricType) {
      case 'volume':
        return Colors.blue;
      case 'max':
        return Colors.orange;
      case 'distance':
        return Colors.pink;
      case 'duration':
        return Colors.teal;
      case 'reps':
        return Colors.purple;
      default:
        return Colors.white;
    }
  }

  String _formatYAxisValue(double value, String metricType) {
    if (metricType == 'volume') {
      if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}k';
      return value.toStringAsFixed(0);
    }
    if (metricType == 'distance') {
      return value.toStringAsFixed(1);
    }
    return value.toStringAsFixed(0);
  }

  Widget _buildSessionCard(ExerciseSession session, String metricType) {
    return GestureDetector(
      onTap: () async {
        // Find the exercise in this session that matches the current exercise name
        final exerciseIndex = session.workout.exercises.indexWhere(
          (e) => e.name == widget.exerciseName,
        );

        if (exerciseIndex == -1) return;

        final exercise = session.workout.exercises[exerciseIndex];

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseFormScreen(
              exerciseId: exercise.exerciseId,
              exerciseName: exercise.name,
              category: exercise.category,
              muscleGroup: exercise.muscleGroup,
              initialParameters: exercise.parameters,
              exerciseNumber: exerciseIndex + 1,
              workoutDateTime: exercise.createdAt,
              onDateTimeChanged: (newDateTime) async {
                // Update this exercise's createdAt time
                final updatedExercise = exercise.copyWith(
                  createdAt: newDateTime,
                  updatedAt: DateTime.now(),
                );
                
                final exercises = List<WorkoutExercise>.from(
                  session.workout.exercises,
                );
                exercises[exerciseIndex] = updatedExercise;
                
                final updatedWorkout = Workout(
                  id: session.workout.id,
                  dateTime: session.workout.dateTime,
                  exercises: exercises,
                  durationMinutes: session.workout.durationMinutes,
                );

                await _workoutService.updateWorkout(updatedWorkout);
                await _loadExerciseSessions();
              },
              onSave: (exerciseData) async {
                // Update the exercise in the workout
                final updatedExercise = WorkoutExercise(
                  exerciseId: exerciseData['exerciseId'],
                  name: exerciseData['name'],
                  category: exerciseData['category'],
                  muscleGroup: exerciseData['muscleGroup'],
                  parameters: exerciseData['parameters'],
                );

                final exercises = List<WorkoutExercise>.from(
                  session.workout.exercises,
                );
                exercises[exerciseIndex] = updatedExercise;

                final updatedWorkout = Workout(
                  id: session.workout.id,
                  dateTime: session.workout.dateTime,
                  exercises: exercises,
                  durationMinutes: session.workout.durationMinutes,
                );

                await _workoutService.updateWorkout(updatedWorkout);
                await _loadExerciseSessions();
              },
              onDelete: () async {
                // Remove this exercise from the workout
                final exercises = List<WorkoutExercise>.from(
                  session.workout.exercises,
                );
                exercises.removeAt(exerciseIndex);

                final updatedWorkout = Workout(
                  id: session.workout.id,
                  dateTime: session.workout.dateTime,
                  exercises: exercises,
                  durationMinutes: session.workout.durationMinutes,
                );

                await _workoutService.updateWorkout(updatedWorkout);
                await _loadExerciseSessions();
              },
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(session.workoutDate),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _getSessionSummary(session, metricType),
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                ],
              ),
            ),
            Text(
              _getSessionMetricValue(session, metricType),
              style: TextStyle(
                color: _getChartColor(metricType),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSessionSummary(ExerciseSession session, String metricType) {
    final count = session.exercises.length;
    if (widget.muscleGroup == 'cardio') {
      return '$count ${count == 1 ? 'set' : 'sets'}';
    }
    if (widget.muscleGroup == 'flexibility') {
      return '$count ${count == 1 ? 'set' : 'sets'}';
    }

    int totalSets = 0;
    int totalReps = 0;
    for (final exercise in session.exercises) {
      totalSets +=
          (exercise.parameters['sets'] is int
              ? exercise.parameters['sets'] as int
              : (exercise.parameters['sets'] as double?)?.round()) ??
          0;
      totalReps +=
          (exercise.parameters['reps'] is int
              ? exercise.parameters['reps'] as int
              : (exercise.parameters['reps'] as double?)?.round()) ??
          0;
    }
    return '$totalSets sets • $totalReps total reps';
  }

  String _getSessionMetricValue(ExerciseSession session, String metricType) {
    switch (metricType) {
      case 'volume':
        return '${_formatVolume(_calculateSessionVolume(session))} kg';
      case 'max':
        return '${_calculateSessionMaxWeight(session).toStringAsFixed(0)} kg';
      case 'distance':
        return '${_calculateSessionTotalDistance(session).toStringAsFixed(1)} km';
      case 'duration':
        return '${_calculateSessionTotalDuration(session)} min';
      case 'reps':
        return '${_calculateSessionTotalReps(session)} reps';
      default:
        return '';
    }
  }

  String _formatVolume(double volume) {
    if (volume >= 1000) {
      return (volume / 1000).toStringAsFixed(1) + 'k';
    }
    return volume.toStringAsFixed(0);
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

class ExerciseSession {
  final DateTime workoutDate;
  final List<WorkoutExercise> exercises;
  final Workout workout;

  ExerciseSession({
    required this.workoutDate,
    required this.exercises,
    required this.workout,
  });
}
