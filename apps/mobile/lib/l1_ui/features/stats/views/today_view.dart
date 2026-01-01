import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../widgets/stats_overview_card.dart';
import '../widgets/exercise_detail_card.dart';
import '../view_models/today_stats_overview.dart';
import '../view_models/exercise_detail_today.dart';

class TodayView extends StatelessWidget {
  final TodayStatsOverview overview;
  final List<ExerciseDetailToday> exerciseDetails;

  const TodayView({
    super.key,
    required this.overview,
    required this.exerciseDetails,
  });

  @override
  Widget build(BuildContext context) {
    // Check if there's any data today
    final bool hasData = overview.setsCount > 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview card
          StatsOverviewCard(
            setsCount: overview.setsCount,
            exercisesCount: overview.exercisesCount,
            totalVolume: overview.totalVolume,
            exerciseTypes: overview.exerciseTypes,
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
            ...exerciseDetails.map((exercise) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ExerciseDetailCard(
                  exerciseName: exercise.name,
                  sets: exercise.sets,
                  volumeToday: exercise.volumeToday,
                  maxWeightToday: exercise.maxWeightToday,
                ),
              );
            }).toList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
