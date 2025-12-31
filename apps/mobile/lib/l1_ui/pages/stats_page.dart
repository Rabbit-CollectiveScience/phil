import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/stats_overview_card.dart';
import '../widgets/exercise_detail_card.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String _selectedSection = 'TODAY';

  @override
  Widget build(BuildContext context) {
    // Fake data for UI preview
    final int todaySets = 35;
    final int todayExercises = 12;
    final double totalVolume = 2000;
    final List<String> exerciseTypes = ['CHEST', 'SHOULDER', 'CARDIO'];

    // Navigation sections
    final List<String> sections = ['TODAY', 'WEEKLY', 'TREND', 'HISTORY'];

    final List<Map<String, dynamic>> exerciseDetails = [
      {
        'name': 'BENCH PRESS',
        'sets': 5,
        'volumeToday': 500.0,
        'volumeBest': 620.0,
        'maxWeightToday': 100.0,
        'prMaxWeight': 110.0,
      },
      {
        'name': 'SHOULDER PRESS',
        'sets': 4,
        'volumeToday': 320.0,
        'volumeBest': 400.0,
        'maxWeightToday': 80.0,
        'prMaxWeight': 80.0, // New PR!
      },
      {
        'name': 'CABLE FLYES',
        'sets': 3,
        'volumeToday': 180.0,
        'volumeBest': 220.0,
        'maxWeightToday': 60.0,
        'prMaxWeight': 65.0,
      },
      {
        'name': 'RUNNING',
        'sets': 1,
        'volumeToday': 0.0,
        'volumeBest': 0.0,
        'maxWeightToday': 0.0,
        'prMaxWeight': 0.0,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.deepCharcoal,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.boldGrey,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.pureBlack.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.offWhite,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'STATS',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.offWhite,
                            letterSpacing: 1.5,
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (selected) {
                            setState(() {
                              _selectedSection = selected;
                            });
                          },
                          offset: const Offset(0, 50),
                          color: AppColors.boldGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          itemBuilder: (context) {
                            return sections.map((section) {
                              return PopupMenuItem<String>(
                                value: section,
                                child: Text(
                                  section,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: section == _selectedSection
                                        ? AppColors.limeGreen
                                        : AppColors.offWhite,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.boldGrey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _selectedSection,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.limeGreen,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: AppColors.limeGreen,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content area
            Expanded(
              child: SingleChildScrollView(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
