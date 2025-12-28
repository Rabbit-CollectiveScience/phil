import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../l2_domain/use_cases/workout_use_cases/get_today_completed_list_use_case.dart';

class CompletedListPage extends StatefulWidget {
  const CompletedListPage({super.key});

  @override
  State<CompletedListPage> createState() => _CompletedListPageState();
}

class _CompletedListPageState extends State<CompletedListPage> {
  bool _isLoading = true;
  List<WorkoutSetWithDetails> _completedWorkouts = [];

  @override
  void initState() {
    super.initState();
    _loadCompletedWorkouts();
  }

  Future<void> _loadCompletedWorkouts() async {
    try {
      final useCase = GetIt.instance<GetTodayCompletedListUseCase>();
      final workouts = await useCase.execute();

      setState(() {
        _completedWorkouts = workouts;
        _isLoading = false;
      });

      debugPrint('✓ Loaded ${workouts.length} completed workouts');
    } catch (e) {
      debugPrint('Error loading completed workouts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        // Detect downward swipe
        if (details.primaryVelocity != null && details.primaryVelocity! > 500) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: Column(
          children: [
            // Counter circle at top to create connection illusion
            const SizedBox(height: 80),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFB9E479),
                  ),
                  child: Center(
                    child: Text(
                      '${_completedWorkouts.length}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Completed cards list
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFB9E479),
                      ),
                    )
                  : _completedWorkouts.isEmpty
                  ? const Center(
                      child: Text(
                        'No completed exercises yet',
                        style: TextStyle(fontSize: 18, color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: _completedWorkouts.length,
                      itemBuilder: (context, index) {
                        final workout = _completedWorkouts[index];
                        final values = workout.workoutSet.values;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A4A4A),
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      workout.exerciseName.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFFF2F2F2),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTime(
                                        workout.workoutSet.completedAt,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (values != null && values.isNotEmpty)
                                Row(
                                  children: values.entries.map((entry) {
                                    if (entry.key == 'unit')
                                      return const SizedBox.shrink();
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: Text(
                                        '${entry.value} ${entry.key}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300,
                                          color: Color(0xFFB9E479),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
