import 'package:flutter/material.dart';
import '../../../../main.dart';
import '../../../shared/theme/app_colors.dart';
import '../widgets/stats_overview_card.dart';
import '../widgets/exercise_detail_card.dart';
import '../view_models/today_stats_overview.dart';
import '../view_models/exercise_detail_today.dart';
import '../../../../l2_domain/use_cases/stats/get_today_stats_overview_use_case.dart';
import '../../../../l2_domain/use_cases/stats/get_today_exercise_details_use_case.dart';

class TodayView extends StatefulWidget {
  const TodayView({super.key});

  @override
  State<TodayView> createState() => _TodayViewState();
}

class _TodayViewState extends State<TodayView> {
  int _currentDayOffset = 0; // 0 = today, -1 = yesterday, etc.
  TodayStatsOverview? _overview;
  List<ExerciseDetailToday>? _exerciseDetails;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final targetDate = DateTime.now().add(Duration(days: _currentDayOffset));
    setState(() => _isLoading = true);

    try {
      final overviewUseCase = getIt<GetTodayStatsOverviewUseCase>();
      final detailsUseCase = getIt<GetTodayExerciseDetailsUseCase>();

      final overviewMap = await overviewUseCase.execute(date: targetDate);
      final detailsList = await detailsUseCase.execute(date: targetDate);

      setState(() {
        _overview = TodayStatsOverview.fromMap(overviewMap);
        _exerciseDetails = detailsList
            .map((map) => ExerciseDetailToday.fromMap(map))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _overview = TodayStatsOverview.empty();
        _exerciseDetails = [];
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final DateTime targetDate = DateTime.now().add(
      Duration(days: _currentDayOffset),
    );

    final String dateLabel = _currentDayOffset == 0
        ? 'Today'
        : _currentDayOffset == -1
        ? 'Yesterday'
        : _formatDate(targetDate);

    // Check if there's any data
    final bool hasData = _overview != null && _overview!.setsCount > 0;

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
                onTap: () {
                  setState(() {
                    _currentDayOffset--;
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
                dateLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.offWhite,
                  letterSpacing: 1.2,
                ),
              ),
              GestureDetector(
                onTap: _currentDayOffset < 0
                    ? () {
                        setState(() {
                          _currentDayOffset++;
                          _loadData();
                        });
                      }
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _currentDayOffset < 0
                        ? AppColors.boldGrey
                        : AppColors.boldGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: _currentDayOffset < 0
                        ? AppColors.offWhite
                        : AppColors.offWhite.withOpacity(0.3),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Loading state
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 100),
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
            // Overview card
            StatsOverviewCard(
              setsCount: _overview?.setsCount ?? 0,
              exercisesCount: _overview?.exercisesCount ?? 0,
              totalVolume: _overview?.totalVolume ?? 0.0,
              avgReps: _overview?.avgReps ?? 0.0,
              exerciseTypes: _overview?.exerciseTypes ?? [],
            ),
            const SizedBox(height: 32),
            // Section title
            Text(
              'TODAY\'S EXERCISES',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.offWhite,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            // Exercise details list or empty state
            if (!hasData)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    'No workouts recorded',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.offWhite.withOpacity(0.5),
                    ),
                  ),
                ),
              )
            else
              ...(_exerciseDetails ?? []).map((exercise) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ExerciseDetailCard(
                    exerciseName: exercise.name,
                    sets: exercise.sets,
                    volumeToday: exercise.volumeToday,
                    maxWeightToday: exercise.maxWeightToday,
                    maxReps: exercise.maxReps,
                    maxDuration: exercise.maxDuration,
                    maxDistance: exercise.maxDistance,
                    maxAdditionalWeight: exercise.maxAdditionalWeight,
                    prsToday: exercise.prsToday,
                    exercise: exercise.exercise,
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
