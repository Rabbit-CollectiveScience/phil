import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class LogView extends StatefulWidget {
  const LogView({super.key});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  DateTime _selectedDate = DateTime.now();
  final Set<int> _expandedCards = {};

  // Mock data
  final List<Map<String, dynamic>> _mockSets = [
    {
      'exerciseName': 'BENCH PRESS',
      'sets': 3,
      'totalVolume': 225.0,
      'reps': [10, 8, 6],
      'weights': [80.0, 80.0, 85.0],
      'time': '12:34 PM',
    },
    {
      'exerciseName': 'SQUAT',
      'sets': 4,
      'totalVolume': 400.0,
      'reps': [12, 10, 10, 8],
      'weights': [100.0, 100.0, 100.0, 100.0],
      'time': '12:15 PM',
    },
    {
      'exerciseName': 'SHOULDER PRESS',
      'sets': 3,
      'totalVolume': 180.0,
      'reps': [12, 10, 8],
      'weights': [60.0, 60.0, 60.0],
      'time': '11:45 AM',
    },
    {
      'exerciseName': 'CABLE FLYES',
      'sets': 3,
      'totalVolume': 120.0,
      'reps': [15, 12, 10],
      'weights': [40.0, 40.0, 40.0],
      'time': '11:20 AM',
    },
  ];

  String _formatDate(DateTime date) {
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final selectedDay = DateTime(date.year, date.month, date.day);

    if (selectedDay == today) {
      return 'Today - ${monthNames[date.month - 1]} ${date.day}, ${date.year}';
    } else if (selectedDay == yesterday) {
      return 'Yesterday - ${monthNames[date.month - 1]} ${date.day}, ${date.year}';
    } else {
      return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _nextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
  }

  bool _isToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    return selected == today;
  }

  @override
  Widget build(BuildContext context) {
    final hasSets = _mockSets.isNotEmpty;

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
                onTap: _previousDay,
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
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.dark(
                            primary: AppColors.limeGreen,
                            onPrimary: AppColors.pureBlack,
                            surface: AppColors.boldGrey,
                            onSurface: AppColors.offWhite,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: Text(
                  _formatDate(_selectedDate),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.offWhite,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _isToday() ? null : _nextDay,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isToday()
                        ? AppColors.boldGrey.withOpacity(0.3)
                        : AppColors.boldGrey,
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: _isToday()
                        ? AppColors.offWhite.withOpacity(0.3)
                        : AppColors.offWhite,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Sets list or empty state
          if (hasSets)
            ...List.generate(_mockSets.length, (index) {
              final set = _mockSets[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSetCard(set, index),
              );
            })
          else
            _buildEmptyState(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSetCard(Map<String, dynamic> set, int index) {
    final repsString = (set['reps'] as List<int>).join('/');
    final isExpanded = _expandedCards.contains(index);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedCards.remove(index);
          } else {
            _expandedCards.add(index);
          }
        });
      },
      child: Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  set['exerciseName'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkText,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  set['time'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${set['sets']} sets • ${set['totalVolume'].toInt()} kg • $repsString reps',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText.withOpacity(0.7),
              ),
            ),
            if (isExpanded) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.darkText.withOpacity(0.05),
                  borderRadius: BorderRadius.zero,
                ),
                child: Column(
                  children: List.generate(set['sets'], (setIndex) {
                    final reps = (set['reps'] as List<int>)[setIndex];
                    final weight = (set['weights'] as List<double>)[setIndex];
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: setIndex < set['sets'] - 1 ? 8 : 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Set ${setIndex + 1}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkText.withOpacity(0.6),
                            ),
                          ),
                          Text(
                            '$reps reps × ${weight.toInt()} kg',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkText,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 64,
              color: AppColors.offWhite.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No sets logged for this day',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.offWhite.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
