import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class LogView extends StatefulWidget {
  const LogView({super.key});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  DateTime _selectedDate = DateTime.now();

  // Mock data - flattened to individual sets for swipeable rows
  final List<Map<String, dynamic>> _mockSets = [
    {
      'exerciseName': 'BENCH PRESS',
      'time': '12:34 PM',
      'setNumber': 1,
      'reps': 10,
      'weight': 80.0,
    },
    {
      'exerciseName': 'BENCH PRESS',
      'time': '12:34 PM',
      'setNumber': 2,
      'reps': 8,
      'weight': 80.0,
    },
    {
      'exerciseName': 'BENCH PRESS',
      'time': '12:34 PM',
      'setNumber': 3,
      'reps': 6,
      'weight': 85.0,
    },
    {
      'exerciseName': 'SQUAT',
      'time': '12:15 PM',
      'setNumber': 1,
      'reps': 12,
      'weight': 100.0,
    },
    {
      'exerciseName': 'SQUAT',
      'time': '12:15 PM',
      'setNumber': 2,
      'reps': 10,
      'weight': 100.0,
    },
    {
      'exerciseName': 'SQUAT',
      'time': '12:15 PM',
      'setNumber': 3,
      'reps': 10,
      'weight': 100.0,
    },
    {
      'exerciseName': 'SQUAT',
      'time': '12:15 PM',
      'setNumber': 4,
      'reps': 8,
      'weight': 100.0,
    },
    {
      'exerciseName': 'SHOULDER PRESS',
      'time': '11:45 AM',
      'setNumber': 1,
      'reps': 12,
      'weight': 60.0,
    },
    {
      'exerciseName': 'SHOULDER PRESS',
      'time': '11:45 AM',
      'setNumber': 2,
      'reps': 10,
      'weight': 60.0,
    },
    {
      'exerciseName': 'SHOULDER PRESS',
      'time': '11:45 AM',
      'setNumber': 3,
      'reps': 8,
      'weight': 60.0,
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
          if (hasSets) ...[
            ..._buildGroupedSets(),
            const SizedBox(height: 20),
            _buildAddButton(),
          ] else
            _buildEmptyState(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedSets() {
    final List<Widget> widgets = [];
    String? currentExercise;

    for (int i = 0; i < _mockSets.length; i++) {
      final set = _mockSets[i];
      final exerciseName = set['exerciseName'];
      final time = set['time'];

      // Add exercise header if this is a new exercise
      if (exerciseName != currentExercise) {
        if (currentExercise != null) {
          widgets.add(const SizedBox(height: 20));
        }
        widgets.add(_buildExerciseHeader(exerciseName, time));
        widgets.add(const SizedBox(height: 8));
        currentExercise = exerciseName;
      }

      // Add set row
      widgets.add(_buildSetRow(set, i));
    }

    return widgets;
  }

  Widget _buildExerciseHeader(String exerciseName, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        exerciseName,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: AppColors.offWhite,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSetRow(Map<String, dynamic> set, int index) {
    return Dismissible(
      key: Key('set_$index'),
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.blue[400],
          borderRadius: BorderRadius.zero,
        ),
        alignment: Alignment.centerLeft,
        child: Icon(Icons.edit, color: Colors.white, size: 20),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.zero,
        ),
        alignment: Alignment.centerRight,
        child: Icon(Icons.delete, color: Colors.white, size: 20),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Delete - show confirmation
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: AppColors.boldGrey,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                title: Text(
                  'Delete Set',
                  style: TextStyle(
                    color: AppColors.offWhite,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                content: Text(
                  'Are you sure you want to delete this set?',
                  style: TextStyle(color: AppColors.offWhite),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.offWhite),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      'Delete',
                      style: TextStyle(color: Colors.red[300]),
                    ),
                  ),
                ],
              );
            },
          );
        } else {
          // Edit - just return false to not dismiss
          // TODO: Open edit dialog
          return false;
        }
      },
      onDismissed: (direction) {
        // TODO: Handle actual deletion
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.zero,
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.limeGreen.withOpacity(0.15),
                borderRadius: BorderRadius.zero,
              ),
              alignment: Alignment.center,
              child: Text(
                '${set['setNumber']}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkText,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '${set['reps']} reps × ${set['weight'].toInt()} kg',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        // TODO: Open add set dialog
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.limeGreen,
          borderRadius: BorderRadius.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.pureBlack, size: 20),
            const SizedBox(width: 8),
            Text(
              'Add Set',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.pureBlack,
                letterSpacing: 0.5,
              ),
            ),
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
