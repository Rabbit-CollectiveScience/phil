import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../widgets/stat_column.dart';
import '../widgets/type_card.dart';

class WeeklyView extends StatefulWidget {
  const WeeklyView({super.key});

  @override
  State<WeeklyView> createState() => _WeeklyViewState();
}

class _WeeklyViewState extends State<WeeklyView> {
  int _currentWeekOffset = 0; // 0 = current week, -1 = last week, etc.

  @override
  Widget build(BuildContext context) {
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
                    StatColumn(value: '5', label: 'DAYS TRAINED'),
                    Container(
                      width: 1,
                      height: 50,
                      color: AppColors.darkGrey.withOpacity(0.2),
                    ),
                    StatColumn(value: '12', label: 'SESSIONS'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Exercise type breakdown title
          Text(
            'BY EXERCISE TYPE',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.offWhite,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          // All exercise types with integrated notable outcomes
          TypeCard(
            type: 'CHEST',
            exercises: 8,
            sets: 45,
            volume: 3200,
            prExercise: 'BENCH PRESS',
            prValue: '110 kg',
          ),
          const SizedBox(height: 12),
          TypeCard(type: 'BACK', exercises: 6, sets: 38, volume: 2800),
          const SizedBox(height: 12),
          TypeCard(
            type: 'LEGS',
            exercises: 4,
            sets: 28,
            volume: 4500,
            bestVolumeExercise: 'SQUAT',
            bestVolumeValue: '5,200 kg',
          ),
          const SizedBox(height: 12),
          TypeCard(type: 'SHOULDERS', exercises: 0, sets: 0, volume: 0),
          const SizedBox(height: 12),
          TypeCard(type: 'ARMS', exercises: 0, sets: 0, volume: 0),
          const SizedBox(height: 12),
          TypeCard(type: 'CORE', exercises: 0, sets: 0, volume: 0),
          const SizedBox(height: 12),
          TypeCard(type: 'CARDIO', exercises: 0, sets: 0, volume: 0),
          const SizedBox(height: 12),
          TypeCard(type: 'FLEXIBILITY', exercises: 0, sets: 0, volume: 0),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
