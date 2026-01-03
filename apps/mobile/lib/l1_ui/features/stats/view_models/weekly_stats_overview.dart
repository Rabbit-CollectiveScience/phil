/// Weekly attendance statistics view model
class WeeklyStatsOverview {
  final int daysTrained;
  final double avgSetsPerDay;

  const WeeklyStatsOverview({
    required this.daysTrained,
    required this.avgSetsPerDay,
  });

  factory WeeklyStatsOverview.fromMap(Map<String, dynamic> map) {
    return WeeklyStatsOverview(
      daysTrained: (map['daysTrained'] as num).toInt(),
      avgSetsPerDay: (map['avgSetsPerDay'] as num).toDouble(),
    );
  }

  factory WeeklyStatsOverview.empty() {
    return const WeeklyStatsOverview(daysTrained: 0, avgSetsPerDay: 0.0);
  }
}
