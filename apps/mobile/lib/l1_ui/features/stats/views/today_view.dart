import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../widgets/stats_overview_card.dart';
import '../widgets/exercise_detail_card.dart';
import '../view_models/today_stats_overview.dart';
import '../view_models/exercise_detail_today.dart';

class TodayView extends StatefulWidget {
  final TodayStatsOverview overview;
  final List<ExerciseDetailToday> exerciseDetails;

  const TodayView({
    super.key,
    required this.overview,
    required this.exerciseDetails,
  });

  @override
  State<TodayView> createState() => _TodayViewState();
}

class _TodayViewState extends State<TodayView> {
  int _currentDayOffset = 0; // 0 = today, -1 = yesterday, etc.

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final DateTime targetDate = DateTime.now().add(Duration(days: _currentDayOffset));
    
    final String dateLabel = _currentDayOffset == 0
        ? 'Today'
        : _currentDayOffset == -1
        ? 'Yesterday'
        : _formatDate(targetDate);

    // Check if there's any data today
    final bool hasData = widget.overview.setsCount > 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentDayOffset--;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.boldGrey,
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    color: AppColors.offWhite,
                    size: 20,
                  ),
                ),
              ),
              Text(
                dateLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.offWhite,
                  letterSpacing: 1.2,
                ),
              ),
              GestureDetector(
                onTap: _currentDayOffset < 0
                    ? () {
                        setState(() {
                          _currentDayOffset++;
                        });
                      }
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _currentDayOffset < 0
                        ? AppColors.boldGrey
                        : AppColors.boldGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: _currentDayOffset < 0
                        ? AppColors.offWhite
                        : AppColors.offWhite.withOpacity(0.3),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Overview card
          StatsOverviewCard(
            setsCount: widget.overview.setsCount,
            exercisesCount: widget.overview.exercisesCount,
            totalVolume: widget.overview.totalVolume,
            exerciseTypes: widget.overview.exerciseTypes,
          ),
          const SizedBox(height: 32),
          // Section title
          Text(
            'TODAY\'S EXERCISES',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.offWhite,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          // Exercise details list or empty state
          if (!hasData)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'No workouts recorded today',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.offWhite.withOpacity(0.5),
                  ),
                ),
              ),
            )
          else
            ...widget.exerciseDetails.map((exercise) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ExerciseDetailCard(
                  exerciseName: exercise.name,
                  sets: exercise.sets,
                  volumeToday: exercise.volumeToday,
                  maxWeightToday: exercise.maxWeightToday,
                  prsToday: exercise.prsToday,
                ),
              );
            }).toList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
