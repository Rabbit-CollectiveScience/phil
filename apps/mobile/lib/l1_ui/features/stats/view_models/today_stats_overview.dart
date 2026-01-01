class TodayStatsOverview {
  final int setsCount;
  final int exercisesCount;
  final double totalVolume;
  final List<String> exerciseTypes;

  TodayStatsOverview({
    required this.setsCount,
    required this.exercisesCount,
    required this.totalVolume,
    required this.exerciseTypes,
  });

  factory TodayStatsOverview.fromMap(Map<String, dynamic> map) {
    return TodayStatsOverview(
      setsCount: map['setsCount'] as int,
      exercisesCount: map['exercisesCount'] as int,
      totalVolume: (map['totalVolume'] as num).toDouble(),
      exerciseTypes: List<String>.from(map['exerciseTypes'] as List),
    );
  }

  factory TodayStatsOverview.empty() {
    return TodayStatsOverview(
      setsCount: 0,
      exercisesCount: 0,
      totalVolume: 0,
      exerciseTypes: [],
    );
  }
}
