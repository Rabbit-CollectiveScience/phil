import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

class PRView extends StatefulWidget {
  const PRView({super.key});

  @override
  State<PRView> createState() => _PRViewState();
}

class _PRViewState extends State<PRView> {
  // Mock PR data grouped by exercise type
  final Map<String, List<Map<String, dynamic>>> _prsByType = {
    'CHEST': [
      {
        'exercise': 'BENCH PRESS',
        'value': '120 kg',
        'date': 'Dec 28, 2025',
        'daysAgo': 4,
      },
      {
        'exercise': 'INCLINE BENCH',
        'value': '100 kg',
        'date': 'Dec 20, 2025',
        'daysAgo': 12,
      },
      {
        'exercise': 'DUMBBELL PRESS',
        'value': '45 kg',
        'date': 'Dec 15, 2025',
        'daysAgo': 17,
      },
      {
        'exercise': 'CABLE FLYES',
        'value': '30 kg × 15',
        'date': 'Dec 10, 2025',
        'daysAgo': 22,
      },
    ],
    'BACK': [
      {
        'exercise': 'DEADLIFT',
        'value': '180 kg',
        'date': 'Dec 25, 2025',
        'daysAgo': 7,
      },
      {
        'exercise': 'PULL-UPS',
        'value': 'BW+25 kg × 8',
        'date': 'Dec 22, 2025',
        'daysAgo': 10,
      },
      {
        'exercise': 'BARBELL ROW',
        'value': '110 kg',
        'date': 'Dec 18, 2025',
        'daysAgo': 14,
      },
      {
        'exercise': 'LAT PULLDOWN',
        'value': '90 kg × 10',
        'date': 'Dec 12, 2025',
        'daysAgo': 20,
      },
    ],
    'LEGS': [
      {
        'exercise': 'SQUAT',
        'value': '160 kg',
        'date': 'Dec 26, 2025',
        'daysAgo': 6,
      },
      {
        'exercise': 'FRONT SQUAT',
        'value': '120 kg',
        'date': 'Dec 19, 2025',
        'daysAgo': 13,
      },
      {
        'exercise': 'LEG PRESS',
        'value': '300 kg',
        'date': 'Dec 14, 2025',
        'daysAgo': 18,
      },
      {
        'exercise': 'ROMANIAN DEADLIFT',
        'value': '140 kg',
        'date': 'Dec 8, 2025',
        'daysAgo': 24,
      },
    ],
    'SHOULDERS': [
      {
        'exercise': 'OVERHEAD PRESS',
        'value': '80 kg',
        'date': 'Dec 23, 2025',
        'daysAgo': 9,
      },
      {
        'exercise': 'DUMBBELL SHOULDER PRESS',
        'value': '35 kg',
        'date': 'Dec 16, 2025',
        'daysAgo': 16,
      },
      {
        'exercise': 'LATERAL RAISE',
        'value': '20 kg × 12',
        'date': 'Dec 11, 2025',
        'daysAgo': 21,
      },
    ],
    'ARMS': [
      {
        'exercise': 'BARBELL CURL',
        'value': '50 kg',
        'date': 'Dec 21, 2025',
        'daysAgo': 11,
      },
      {
        'exercise': 'CLOSE GRIP BENCH',
        'value': '90 kg',
        'date': 'Dec 17, 2025',
        'daysAgo': 15,
      },
      {
        'exercise': 'HAMMER CURL',
        'value': '25 kg × 10',
        'date': 'Dec 9, 2025',
        'daysAgo': 23,
      },
    ],
  };

  Set<String> _expandedTypes = {};

  int get _totalPRs {
    return _prsByType.values.fold(0, (sum, list) => sum + list.length);
  }

  int get _daysSinceLastPR {
    int minDays = 999;
    for (var prs in _prsByType.values) {
      for (var pr in prs) {
        if (pr['daysAgo'] < minDays) {
          minDays = pr['daysAgo'];
        }
      }
    }
    return minDays;
  }

  List<Map<String, dynamic>> get _recentPRs {
    List<Map<String, dynamic>> allPRs = [];
    _prsByType.forEach((type, prs) {
      for (var pr in prs) {
        allPRs.add({...pr, 'type': type});
      }
    });
    allPRs.sort((a, b) => a['daysAgo'].compareTo(b['daysAgo']));
    return allPRs.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary stats
          _buildSummarySection(),
          const SizedBox(height: 24),

          // Recent PRs
          _buildRecentPRsSection(),
          const SizedBox(height: 24),

          // All PRs by type
          _buildAllPRsSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.zero,
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
            ),
            child: Column(
              children: [
                Text(
                  '$_totalPRs',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'TOTAL PRs',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkText.withOpacity(0.5),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.limeGreen,
              borderRadius: BorderRadius.zero,
            ),
            child: Column(
              children: [
                Text(
                  '$_daysSinceLastPR',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: AppColors.pureBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'DAYS AGO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.pureBlack.withOpacity(0.7),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentPRsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, size: 20, color: AppColors.limeGreen),
              const SizedBox(width: 8),
              Text(
                'RECENT PRs',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkText,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._recentPRs.map((pr) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.limeGreen,
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pr['exercise'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkText,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pr['date'],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    pr['value'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAllPRsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'ALL PERSONAL RECORDS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.offWhite,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ..._prsByType.entries.map((entry) {
          final type = entry.key;
          final prs = entry.value;
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.limeGreen.withOpacity(0.15),
                              borderRadius: BorderRadius.zero,
                            ),
                            child: Text(
                              '${prs.length}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
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
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: prs.map((pr) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pr['exercise'],
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.darkText,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        pr['date'],
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.darkText.withOpacity(
                                            0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    pr['value'],
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.darkText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAllPRsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'ALL PERSONAL RECORDS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.offWhite,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ..._summary.prsByCategory.entries.map((entry) {
          final type = entry.key;
          final prs = entry.value;
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.limeGreen.withOpacity(0.15),
                              borderRadius: BorderRadius.zero,
                            ),
                            child: Text(
                              '${prs.length}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
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
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: prs.map((pr) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pr['exercise'],
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.darkText,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        pr['date'],
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.darkText.withOpacity(
                                            0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    pr['value'],
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.darkText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
            ),
          );
        }).toList(),
      ],
    );
  }
}
