import 'package:flutter/material.dart';
import '../l2_domain/models/workout.dart';
import '../l3_service/workout_service.dart';
import '../l3_service/workout_stats_service.dart';
import 'workout_detail_screen.dart';
import 'widgets/weekly_volume_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  final WorkoutService _workoutService = WorkoutService();
  List<Workout> _workouts = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadWorkouts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload workouts when tab becomes visible
    _loadWorkouts();
  }

  // Public method to refresh dashboard data
  void refresh() {
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    setState(() => _isLoading = true);
    final workouts = await _workoutService.getAllWorkouts();
    setState(() {
      _workouts = workouts;
      _isLoading = false;
    });
  }

  Future<void> _deleteWorkout(String workoutId) async {
    await _workoutService.deleteWorkout(workoutId);
    await _loadWorkouts();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF3A3A3A),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF3A3A3A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A3A3A),
        elevation: 0,
        toolbarHeight: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[600],
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'This Week'),
            Tab(text: 'Records'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildTodayTab(), _buildThisWeekTab(), _buildRecordsTab()],
      ),
    );
  }

  Widget _buildTodayTab() {
    final todayStats = WorkoutStatsService.getTodayStats(_workouts);
    final todayWorkouts = WorkoutStatsService.getTodayWorkouts(_workouts);

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today's Summary Card
              _buildTodayCard(todayStats),

              const SizedBox(height: 30),

              // Today's Workouts Section
              const Text(
                'Today\'s Workouts',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Workout Cards
              if (todayWorkouts.isEmpty)
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        Icons.fitness_center_outlined,
                        size: 80,
                        color: Colors.grey[800],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No workouts today',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start logging to track your progress',
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                    ],
                  ),
                )
              else
                ...todayWorkouts.map(
                  (workout) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildWorkoutCard(context, workout),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThisWeekTab() {
    final weeklyStats = WorkoutStatsService.getWeeklyStats(_workouts);
    final thisWeekWorkouts = WorkoutStatsService.getThisWeekWorkouts(_workouts);

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weekly Volume Chart
              WeeklyVolumeChart(allWorkouts: _workouts),

              const SizedBox(height: 20),

              // This Week Stats Card
              _buildWeeklyCard(weeklyStats),

              const SizedBox(height: 30),

              // This Week's Workouts Section
              const Text(
                'This Week\'s Workouts',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Workout Cards
              if (thisWeekWorkouts.isEmpty)
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        Icons.fitness_center_outlined,
                        size: 80,
                        color: Colors.grey[800],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No workouts this week',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start logging to see your progress',
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                    ],
                  ),
                )
              else
                ...thisWeekWorkouts.map(
                  (workout) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildWorkoutCard(context, workout),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordsTab() {
    final records = _calculateRecords();

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Streaks Card
              _buildStreaksCard(records),

              const SizedBox(height: 16),

              // Personal Records Card
              _buildPersonalRecordsCard(records),

              const SizedBox(height: 16),

              // Volume Milestones Card
              _buildVolumeMilestonesCard(records),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateRecords() {
    // Current streak
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? lastWorkoutDate;

    final sortedWorkouts = List<Workout>.from(_workouts)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    for (final workout in sortedWorkouts) {
      final workoutDate = DateTime(
        workout.dateTime.year,
        workout.dateTime.month,
        workout.dateTime.day,
      );

      if (lastWorkoutDate == null) {
        tempStreak = 1;
      } else {
        final daysDiff = workoutDate.difference(lastWorkoutDate).inDays;
        if (daysDiff == 1) {
          tempStreak++;
        } else if (daysDiff > 1) {
          longestStreak = tempStreak > longestStreak
              ? tempStreak
              : longestStreak;
          tempStreak = 1;
        }
      }
      lastWorkoutDate = workoutDate;
    }

    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;

    // Check if streak is current
    if (lastWorkoutDate != null) {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final daysSinceLastWorkout = todayDate.difference(lastWorkoutDate).inDays;
      currentStreak = daysSinceLastWorkout <= 1 ? tempStreak : 0;
    }

    // Total stats
    int totalWorkouts = _workouts.length;
    int totalExercises = _workouts.fold(
      0,
      (sum, w) => sum + w.exercises.length,
    );
    double totalVolume = _workouts.fold(
      0.0,
      (sum, w) => sum + WorkoutStatsService.calculateWorkoutVolume(w),
    );

    // Exercise PRs (max weight per exercise)
    Map<String, Map<String, dynamic>> exercisePRs = {};
    for (final workout in _workouts) {
      for (final exercise in workout.exercises) {
        if (exercise.muscleGroup != 'cardio' &&
            exercise.muscleGroup != 'flexibility') {
          final weight = exercise.parameters['weight'] as num? ?? 0;
          final reps = exercise.parameters['reps'] as int? ?? 0;

          if (weight > 0) {
            if (!exercisePRs.containsKey(exercise.name) ||
                weight > (exercisePRs[exercise.name]!['weight'] as num)) {
              exercisePRs[exercise.name] = {
                'weight': weight,
                'reps': reps,
                'date': workout.dateTime,
              };
            }
          }
        }
      }
    }

    // Single workout records
    double maxWorkoutVolume = 0;
    Workout? maxVolumeWorkout;
    int maxExercisesInWorkout = 0;
    Workout? maxExercisesWorkout;

    for (final workout in _workouts) {
      final volume = WorkoutStatsService.calculateWorkoutVolume(workout);
      if (volume > maxWorkoutVolume) {
        maxWorkoutVolume = volume;
        maxVolumeWorkout = workout;
      }
      if (workout.exercises.length > maxExercisesInWorkout) {
        maxExercisesInWorkout = workout.exercises.length;
        maxExercisesWorkout = workout;
      }
    }

    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalWorkouts': totalWorkouts,
      'totalExercises': totalExercises,
      'totalVolume': totalVolume,
      'exercisePRs': exercisePRs,
      'maxWorkoutVolume': maxWorkoutVolume,
      'maxVolumeWorkout': maxVolumeWorkout,
      'maxExercisesInWorkout': maxExercisesInWorkout,
      'maxExercisesWorkout': maxExercisesWorkout,
    };
  }

  Widget _buildStreaksCard(Map<String, dynamic> records) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text(
                'Streaks & Milestones',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${records['currentStreak']}',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Current Streak',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 50, color: Colors.grey[700]),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${records['longestStreak']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Longest Streak',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.grey, height: 1),
          const SizedBox(height: 16),
          _buildStatRow('Total Workouts', '${records['totalWorkouts']}'),
          const SizedBox(height: 12),
          _buildStatRow('Total Exercises', '${records['totalExercises']}'),
        ],
      ),
    );
  }

  Widget _buildPersonalRecordsCard(Map<String, dynamic> records) {
    final exercisePRs =
        records['exercisePRs'] as Map<String, Map<String, dynamic>>;
    final topPRs = exercisePRs.entries.toList()
      ..sort(
        (a, b) =>
            (b.value['weight'] as num).compareTo(a.value['weight'] as num),
      );
    final displayPRs = topPRs.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text(
                'Personal Records',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (displayPRs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No records yet',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            )
          else
            ...displayPRs.map((entry) {
              final exerciseName = entry.key;
              final data = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exerciseName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(data['date']),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${data['weight']} kg × ${data['reps']}',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildVolumeMilestonesCard(Map<String, dynamic> records) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                'Volume Records',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            'Total Volume Lifted',
            '${_formatVolume(records['totalVolume'])} kg',
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.grey, height: 1),
          const SizedBox(height: 16),
          if (records['maxVolumeWorkout'] != null)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Best Single Workout',
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatDate(
                          (records['maxVolumeWorkout'] as Workout).dateTime,
                        ),
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${_formatVolume(records['maxWorkoutVolume'])} kg',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          if (records['maxVolumeWorkout'] != null) const SizedBox(height: 16),
          if (records['maxExercisesWorkout'] != null)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Most Exercises',
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatDate(
                          (records['maxExercisesWorkout'] as Workout).dateTime,
                        ),
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${records['maxExercisesInWorkout']} exercises',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
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

  Widget _buildTodayCard(
    ({
      int exerciseCount,
      int totalSets,
      int totalDuration,
      Map<String, int> setsPerMuscleGroup,
      Map<String, double> volumePerMuscleGroup,
      int cardioCount,
      int cardioDuration,
      double cardioDistance,
      int flexibilityCount,
      int flexibilityDuration,
    })
    stats,
  ) {
    return Container(
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
              const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                'Today - ${DateTime.now().toString().split(' ')[0]}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatColumn('${stats.exerciseCount}', 'Exercises'),
              _buildStatColumn('${stats.totalSets}', 'Sets'),
              _buildStatColumn('${stats.totalDuration}', 'Minutes'),
            ],
          ),
          if (stats.volumePerMuscleGroup.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.grey, height: 1),
            const SizedBox(height: 12),
            const Text(
              'Training Volume by Muscle Group',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ...stats.volumePerMuscleGroup.entries.map((entry) {
              final muscle = entry.key;
              final volume = entry.value;
              final sets = stats.setsPerMuscleGroup[muscle] ?? 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getMuscleGroupColor(muscle),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        WorkoutStatsService.capitalize(muscle),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      '$sets sets',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      WorkoutStatsService.formatVolume(volume),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
          if (stats.cardioCount > 0 || stats.flexibilityCount > 0) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.grey, height: 1),
            const SizedBox(height: 12),
            const Text(
              'Other Training',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            if (stats.cardioCount > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Cardio',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                    Text(
                      _formatCardioStats(
                        stats.cardioDuration,
                        stats.cardioDistance,
                        stats.cardioCount,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            if (stats.flexibilityCount > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.purpleAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Flexibility',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                    Text(
                      _formatFlexibilityStats(
                        stats.flexibilityDuration,
                        stats.flexibilityCount,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeeklyCard(
    ({
      int workoutCount,
      double totalVolume,
      int currentStreak,
      int daysTrained,
      int totalMinutes,
      Map<String, int> setsPerMuscleGroup,
      Map<String, double> volumePerMuscleGroup,
      int cardioCount,
      int cardioDuration,
      double cardioDistance,
      int flexibilityCount,
      int flexibilityDuration,
      int flexibilitySessions,
    })
    stats,
  ) {
    return Container(
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
              const Icon(Icons.fitness_center, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              const Text(
                'This Week',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatColumn('${stats.daysTrained}', 'Days'),
              _buildStatColumn('${stats.workoutCount}', 'Workouts'),
              _buildStatColumn('${stats.totalMinutes}', 'Minutes'),
            ],
          ),
          if (stats.volumePerMuscleGroup.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.grey, height: 1),
            const SizedBox(height: 12),
            const Text(
              'Training Volume by Muscle Group',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ...stats.volumePerMuscleGroup.entries.map((entry) {
              final muscle = entry.key;
              final volume = entry.value;
              final sets = stats.setsPerMuscleGroup[muscle] ?? 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getMuscleGroupColor(muscle),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        WorkoutStatsService.capitalize(muscle),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      '$sets sets',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      WorkoutStatsService.formatVolume(volume),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
          if (stats.cardioCount > 0 || stats.flexibilityCount > 0) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.grey, height: 1),
            const SizedBox(height: 12),
            const Text(
              'Other Training',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            if (stats.cardioCount > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Cardio',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                    Text(
                      _formatCardioStats(
                        stats.cardioDuration,
                        stats.cardioDistance,
                        stats.cardioCount,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            if (stats.flexibilityCount > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.purpleAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Flexibility',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                    Text(
                      _formatFlexibilityStats(
                        stats.flexibilityDuration,
                        stats.flexibilitySessions,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  String _formatCardioStats(int duration, double distance, int count) {
    final parts = <String>[];
    if (duration > 0) parts.add('$duration min');
    if (distance > 0) parts.add('${distance.toStringAsFixed(1)} km');
    if (parts.isEmpty) return '$count exercise${count == 1 ? '' : 's'}';
    return '${parts.join(' • ')} ($count exercise${count == 1 ? '' : 's'})';
  }

  String _formatFlexibilityStats(int duration, int sessions) {
    if (duration > 0) {
      return '$duration min ($sessions session${sessions == 1 ? '' : 's'})';
    }
    return '$sessions session${sessions == 1 ? '' : 's'}';
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
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

  Widget _buildWorkoutCard(BuildContext context, Workout workout) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutDetailScreen(
              workout: workout,
              onDelete: () => _deleteWorkout(workout.id),
            ),
          ),
        );
        // Reload workouts after returning from detail screen
        await _loadWorkouts();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and Duration Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.grey[500],
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      workout.formattedDate,
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: Colors.grey[500],
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${workout.durationMinutes} min',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Exercise Count
            Text(
              '${workout.totalExercises} exercises',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            // Exercise Preview
            Text(
              workout.exercisePreview,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // Muscle Groups Tags
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: workout.muscleGroups.map((muscleGroup) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getMuscleGroupColor(muscleGroup).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getMuscleGroupColor(muscleGroup).withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _capitalizeFirstLetter(muscleGroup),
                    style: TextStyle(
                      color: _getMuscleGroupColor(muscleGroup),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
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
