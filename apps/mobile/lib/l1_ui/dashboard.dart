import 'package:flutter/material.dart';
import '../l2_domain/models/workout.dart';
import '../l3_service/workout_service.dart';
import '../l3_service/workout_stats_service.dart';
import 'workout_detail_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  final WorkoutService _workoutService = WorkoutService();
  List<Workout> _workouts = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayTab(),
          _buildThisWeekTab(),
        ],
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
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start logging to track your progress',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
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
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start logging to see your progress',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
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
