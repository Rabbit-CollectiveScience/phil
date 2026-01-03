import 'package:flutter/material.dart';
import '../../../../main.dart';
import '../../../shared/theme/app_colors.dart';
import '../widgets/stat_column.dart';
import '../widgets/type_card.dart';
import '../view_models/weekly_stats_overview.dart';
import '../view_models/exercise_type_weekly_stats.dart';
import '../../../../l2_domain/use_cases/stats/get_weekly_stats_use_case.dart';

class WeeklyView extends StatefulWidget {
  const WeeklyView({super.key});

  @override
  State<WeeklyView> createState() => _WeeklyViewState();
}

class _WeeklyViewState extends State<WeeklyView> {
  int _currentWeekOffset = 0; // 0 = current week, -1 = last week, etc.
  WeeklyStatsOverview? _overview;
  List<ExerciseTypeWeeklyStats>? _typeStats;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final useCase = getIt<GetWeeklyStatsUseCase>();
      final result = await useCase.execute(weekOffset: _currentWeekOffset);

      setState(() {
        _overview = WeeklyStatsOverview.fromMap(result['attendance']);
        _typeStats = (result['exerciseTypes'] as List<Map<String, dynamic>>)
            .map((map) => ExerciseTypeWeeklyStats.fromMap(map))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _overview = WeeklyStatsOverview.empty();
        _typeStats = [];
        _isLoading = false;
      });
    }
  }

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
                    _loadData();
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
                          _loadData();
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
          // Loading state
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 100),
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
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
                  const SizedBox(height: 48),
                  Row(
                    children: [
                      Expanded(
                        child: StatColumn(
                          value: '${_overview?.daysTrained ?? 0}',
                          label: 'DAYS TRAINED',
                        ),
                      ),
                      Expanded(
                        child: StatColumn(
                          value: (_overview?.avgSetsPerDay ?? 0)
                              .toStringAsFixed(0),
                          label: 'AVG SETS/DAY',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
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
            // All exercise types
            ...(_typeStats ?? []).map((typeStat) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TypeCard(
                  type: typeStat.type,
                  exercises: typeStat.exercises,
                  sets: typeStat.sets,
                  volume: typeStat.volume,
                  duration: typeStat.duration,
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}
