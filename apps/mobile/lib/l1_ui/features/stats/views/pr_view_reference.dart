import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

class PRView extends StatefulWidget {
  const PRView({super.key});

  @override
  State<PRView> createState() => _PRViewState();
}

class _PRViewState extends State<PRView> {
  // Mock PR data grouped by exercise type (muscle groups only, no "strength")
  final Map<String, List<Map<String, dynamic>>> _prsByType = {
    'CHEST': [
      {'exercise': 'Barbell Bench Press', 'value': '120 kg', 'daysAgo': 4},
      {'exercise': 'Incline Bench Press', 'value': '100 kg', 'daysAgo': 12},
      {'exercise': 'Dumbbell Press', 'value': '45 kg', 'daysAgo': 17},
      {'exercise': 'Push-Up', 'value': '—', 'daysAgo': null},
    ],
    'BACK': [
      {'exercise': 'Deadlift', 'value': '180 kg', 'daysAgo': 7},
      {'exercise': 'Pull-Up', 'value': '25 kg', 'daysAgo': 10},
      {'exercise': 'Barbell Row', 'value': '110 kg', 'daysAgo': 14},
      {'exercise': 'Lat Pulldown', 'value': '90 kg', 'daysAgo': 20},
    ],
    'LEGS': [
      {'exercise': 'Squat', 'value': '160 kg', 'daysAgo': 6},
      {'exercise': 'Front Squat', 'value': '120 kg', 'daysAgo': 13},
      {'exercise': 'Leg Press', 'value': '300 kg', 'daysAgo': 18},
      {'exercise': 'Romanian Deadlift', 'value': '140 kg', 'daysAgo': 24},
    ],
    'SHOULDERS': [
      {'exercise': 'Overhead Press', 'value': '80 kg', 'daysAgo': 9},
      {'exercise': 'Dumbbell Shoulder Press', 'value': '35 kg', 'daysAgo': 16},
      {'exercise': 'Lateral Raise', 'value': '20 kg', 'daysAgo': 21},
    ],
    'ARMS': [
      {'exercise': 'Barbell Curl', 'value': '50 kg', 'daysAgo': 11},
      {'exercise': 'Close Grip Bench', 'value': '90 kg', 'daysAgo': 15},
      {'exercise': 'Hammer Curl', 'value': '25 kg', 'daysAgo': 23},
    ],
  };

  Set<String> _expandedTypes = {'CHEST', 'BACK', 'LEGS', 'SHOULDERS', 'ARMS'};

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          // All PRs by muscle group
          ..._prsByType.entries.map((entry) {
            final type = entry.key;
            final prs = List<Map<String, dynamic>>.from(entry.value);
            // Sort by days ago (most recent first, nulls last)
            prs.sort((a, b) {
              final daysA = a['daysAgo'];
              final daysB = b['daysAgo'];
              if (daysA == null && daysB == null) return 0;
              if (daysA == null) return 1;
              if (daysB == null) return -1;
              return daysA.compareTo(daysB);
            });
            final isExpanded = _expandedTypes.contains(type);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.zero,
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedTypes.remove(type);
                          } else {
                            _expandedTypes.add(type);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/exercise_types/${type.toLowerCase()}.png',
                              width: 24,
                              height: 24,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.fitness_center,
                                  size: 24,
                                  color: AppColors.darkText,
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                type,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.darkText,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: AppColors.darkText,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded) ...[
                      Container(height: 1, color: const Color(0xFFE0E0E0)),
                      Column(
                        children: prs.asMap().entries.map((entry) {
                          final index = entry.key;
                          final pr = entry.value;
                          final daysAgo = pr['daysAgo'];
                          final daysText = daysAgo == null
                              ? ''
                              : '$daysAgo ${daysAgo == 1 ? 'day' : 'days'} ago';

                          return Container(
                            color: index.isEven
                                ? Colors.transparent
                                : AppColors.darkText.withOpacity(0.075),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    pr['exercise'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.darkText,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      pr['value'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.darkText,
                                      ),
                                    ),
                                    if (daysText.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        daysText,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.darkText.withOpacity(
                                            0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
