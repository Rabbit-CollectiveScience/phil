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
  int _currentWeekOffset = 0; // 0 = current week, -1 = last week, etc.

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
                        color: AppColors.boldGrey,
                        borderRadius: BorderRadius.zero,
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
                            borderRadius: BorderRadius.zero,
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
                              borderRadius: BorderRadius.zero,
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
              child: _selectedSection == 'TODAY'
                  ? _buildTodayContent(
                      todaySets,
                      todayExercises,
                      totalVolume,
                      exerciseTypes,
                      exerciseDetails,
                    )
                  : _selectedSection == 'WEEKLY'
                  ? _buildWeeklyContent()
                  : Center(
                      child: Text(
                        '$_selectedSection coming soon',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.offWhite.withOpacity(0.5),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayContent(
    int todaySets,
    int todayExercises,
    double totalVolume,
    List<String> exerciseTypes,
    List<Map<String, dynamic>> exerciseDetails,
  ) {
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

  Widget _buildWeeklyContent() {
    // Mock weekly data
    final String weekLabel = _currentWeekOffset == 0
        ? 'This Week'
        : _currentWeekOffset == -1
        ? 'Last Week'
        : '${-_currentWeekOffset} Weeks Ago';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Week navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentWeekOffset--;
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
                weekLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.offWhite,
                  letterSpacing: 1.2,
                ),
              ),
              GestureDetector(
                onTap: _currentWeekOffset < 0
                    ? () {
                        setState(() {
                          _currentWeekOffset++;
                        });
                      }
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _currentWeekOffset < 0
                        ? AppColors.boldGrey
                        : AppColors.boldGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: _currentWeekOffset < 0
                        ? AppColors.offWhite
                        : AppColors.offWhite.withOpacity(0.3),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Attendance card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.zero,
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ATTENDANCE',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkText.withOpacity(0.5),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn('5', 'DAYS TRAINED'),
                    Container(
                      width: 1,
                      height: 50,
                      color: AppColors.darkGrey.withOpacity(0.2),
                    ),
                    _buildStatColumn('12', 'SESSIONS'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Effort by type title
          Text(
            'EFFORT BY TYPE',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.offWhite,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          // Exercise type breakdown
          _buildTypeEffortCard('CHEST', 8, 45, 3200),
          const SizedBox(height: 12),
          _buildTypeEffortCard('BACK', 6, 38, 2800),
          const SizedBox(height: 12),
          _buildTypeEffortCard('LEGS', 4, 28, 4500),
          const SizedBox(height: 24),
          // Notable outcomes
          Text(
            'NOTABLE OUTCOMES',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.offWhite,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildNotableOutcomeCard(
            'NEW PR',
            'BENCH PRESS',
            '110 kg',
            Icons.emoji_events,
          ),
          const SizedBox(height: 12),
          _buildNotableOutcomeCard(
            'BEST VOLUME',
            'SQUAT',
            '5,200 kg this week',
            Icons.trending_up,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: AppColors.darkText,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText.withOpacity(0.5),
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeEffortCard(
    String type,
    int exercises,
    int sets,
    double volume,
  ) {
    final typeKey = type.toLowerCase();
    final iconPath = 'assets/images/exercise_types/$typeKey.png';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                iconPath,
                width: 24,
                height: 24,
                color: AppColors.darkText,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.fitness_center,
                    size: 24,
                    color: AppColors.darkText,
                  );
                },
              ),
              const SizedBox(width: 12),
              Text(
                type,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkText,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem('$exercises', 'Exercises'),
              _buildMetricItem('$sets', 'Sets'),
              _buildMetricItem('${volume.toInt()}', 'kg'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.darkText,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildNotableOutcomeCard(
    String label,
    String exerciseName,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: AppColors.limeGreen, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.limeGreen.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.limeGreen,
              borderRadius: BorderRadius.zero,
            ),
            child: Icon(icon, color: AppColors.pureBlack, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkText.withOpacity(0.5),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exerciseName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkText,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
