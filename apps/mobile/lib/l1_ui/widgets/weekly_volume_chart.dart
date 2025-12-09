import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../l2_domain/models/workout.dart';
import '../../l3_service/workout_stats_service.dart';

class WeeklyVolumeChart extends StatefulWidget {
  final List<Workout> allWorkouts;

  const WeeklyVolumeChart({super.key, required this.allWorkouts});

  @override
  State<WeeklyVolumeChart> createState() => _WeeklyVolumeChartState();
}

class _WeeklyVolumeChartState extends State<WeeklyVolumeChart> {
  int _weekOffset = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<({DateTime date, double volume})> _getWeekData(int weekOffset) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final monday = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    ).subtract(Duration(days: weekOffset * 7));

    final result = <({DateTime date, double volume})>[];

    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      final nextDay = date.add(const Duration(days: 1));

      final dayWorkouts = widget.allWorkouts.where((workout) {
        return workout.dateTime.isAfter(date) &&
            workout.dateTime.isBefore(nextDay);
      }).toList();

      double totalVolume = 0.0;
      for (final workout in dayWorkouts) {
        for (final exercise in workout.exercises) {
          if (exercise.category == 'strength') {
            totalVolume += WorkoutStatsService.calculateExerciseVolume(
              exercise,
            );
          }
        }
      }

      result.add((date: date, volume: totalVolume));
    }

    return result;
  }

  String _getWeekLabel(int weekOffset) {
    if (weekOffset == 0) return 'This Week';
    if (weekOffset == 1) return 'Last Week';

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final targetMonday = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    ).subtract(Duration(days: weekOffset * 7));
    final targetSunday = targetMonday.add(const Duration(days: 6));

    return '${_formatDateLabel(targetMonday)} - ${_formatDateLabel(targetSunday)}';
  }

  String _formatDateLabel(DateTime date) {
    const months = [
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
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekly Volume',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getWeekLabel(_weekOffset),
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.arrow_back_ios, color: Colors.grey[600], size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Swipe',
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[600],
                    size: 14,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: PageView.builder(
              controller: _pageController,
              reverse: true,
              onPageChanged: (page) {
                setState(() {
                  _weekOffset = page;
                });
              },
              itemBuilder: (context, index) {
                final weekData = _getWeekData(index);
                return _buildChart(weekData);
              },
            ),
          ),
          _buildSummaryStats(_getWeekData(_weekOffset)),
        ],
      ),
    );
  }

  Widget _buildChart(List<({DateTime date, double volume})> dailyData) {
    if (dailyData.isEmpty || dailyData.every((d) => d.volume == 0)) {
      return _buildEmptyState();
    }

    final maxVolume = dailyData.fold<double>(
      0,
      (max, data) => data.volume > max ? data.volume : max,
    );

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVolume > 0 ? maxVolume * 1.2 : 100,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => const Color(0xFF1A1A1A),
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final data = dailyData[group.x.toInt()];
              return BarTooltipItem(
                '${_formatTooltipDate(data.date)}\n${data.volume.toStringAsFixed(0)} kg',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= dailyData.length) {
                  return const Text('');
                }
                final data = dailyData[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _getWeekdayShort(data.date),
                    style: TextStyle(
                      color: _isToday(data.date)
                          ? Colors.white
                          : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: _isToday(data.date)
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxVolume > 0 ? maxVolume / 4 : 25,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey[800], strokeWidth: 0.5),
        ),
        borderData: FlBorderData(show: false),
        barGroups: dailyData.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          final isToday = _isToday(data.date);

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data.volume > 0 ? data.volume : 0,
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: isToday
                      ? [const Color(0xFF4A90E2), const Color(0xFF7AB8FF)]
                      : data.volume > 0
                      ? [const Color(0xFF3A7BC8), const Color(0xFF5A9BD8)]
                      : [Colors.grey[800]!, Colors.grey[700]!],
                ),
                width: isToday ? 28 : 24,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryStats(List<({DateTime date, double volume})> dailyData) {
    final totalVolume = dailyData.fold<double>(
      0,
      (sum, data) => sum + data.volume,
    );
    final daysWithWorkouts = dailyData.where((d) => d.volume > 0).length;
    final avgVolume = daysWithWorkouts > 0 ? totalVolume / daysWithWorkouts : 0;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', '${totalVolume.toStringAsFixed(0)} kg'),
          Container(width: 1, height: 30, color: Colors.grey[800]),
          _buildStatItem('Days', '$daysWithWorkouts'),
          Container(width: 1, height: 30, color: Colors.grey[800]),
          _buildStatItem('Avg/Day', '${avgVolume.toStringAsFixed(0)} kg'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_outlined, size: 40, color: Colors.grey[700]),
          const SizedBox(height: 8),
          Text(
            'No workouts',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _getWeekdayShort(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }

  String _formatTooltipDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
