import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../widgets/stats_overview_card.dart';
import '../widgets/exercise_detail_card.dart';

class TodayView extends StatelessWidget {
  final int todaySets;
  final int todayExercises;
  final double totalVolume;
  final List<String> exerciseTypes;
  final List<Map<String, dynamic>> exerciseDetails;

  const TodayView({
    super.key,
    required this.todaySets,
    required this.todayExercises,
    required this.totalVolume,
    required this.exerciseTypes,
    required this.exerciseDetails,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview card
          StatsOverviewCard(
            setsCount: todaySets,
            exercisesCount: todayExercises,
            totalVolume: totalVolume,
            exerciseTypes: exerciseTypes,
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
          // Exercise details list
          ...exerciseDetails.map((exercise) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ExerciseDetailCard(
                exerciseName: exercise['name'],
                sets: exercise['sets'],
                volumeToday: exercise['volumeToday'],
                volumeBest: exercise['volumeBest'],
                maxWeightToday: exercise['maxWeightToday'],
                prMaxWeight: exercise['prMaxWeight'],
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
