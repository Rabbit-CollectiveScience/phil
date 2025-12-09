import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeeklyVolumeChart extends StatelessWidget {
  final List<({DateTime date, double volume})> dailyData;

  const WeeklyVolumeChart({
    super.key,
    required this.dailyData,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyData.isEmpty) {
      return _buildEmptyState();
    }

    final maxVolume = dailyData.fold<double>(
      0,
      (max, data) => data.volume > max ? data.volume : max,
    );

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Volume',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last 7 days',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
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
                        '${_formatDate(data.date)}\n${data.volume.toStringAsFixed(0)} kg',
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
                        if (value.toInt() >= dailyData.length) return const Text('');
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
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey[800],
                    strokeWidth: 0.5,
                  ),
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
                              ? [
                                  const Color(0xFF4A90E2),
                                  const Color(0xFF7AB8FF),
                                ]
                              : data.volume > 0
                                  ? [
                                      const Color(0xFF3A7BC8),
                                      const Color(0xFF5A9BD8),
                                    ]
                                  : [
                                      Colors.grey[800]!,
                                      Colors.grey[700]!,
                                    ],
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
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryStats(),
        ],
      ),
    );
  }

  Widget _buildSummaryStats() {
    final totalVolume = dailyData.fold<double>(
      0,
      (sum, data) => sum + data.volume,
    );
    final daysWithWorkouts = dailyData.where((d) => d.volume > 0).length;
    final avgVolume = daysWithWorkouts > 0 ? totalVolume / daysWithWorkouts : 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('Total', '${totalVolume.toStringAsFixed(0)} kg'),
        Container(
          width: 1,
          height: 30,
          color: Colors.grey[800],
        ),
        _buildStatItem('Days', '$daysWithWorkouts'),
        Container(
          width: 1,
          height: 30,
          color: Colors.grey[800],
        ),
        _buildStatItem('Avg/Day', '${avgVolume.toStringAsFixed(0)} kg'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 60,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 16),
            Text(
              'No strength workouts this week',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getWeekdayShort(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
