import 'package:flutter/material.dart';
import '../../../l2_domain/use_cases/stats/get_today_stats_overview_use_case.dart';
import '../../../l2_domain/use_cases/stats/get_today_exercise_details_use_case.dart';
import '../../../main.dart';
import '../../shared/theme/app_colors.dart';
import 'views/today_view.dart';
import 'views/weekly_view.dart';
import 'views/log_view.dart';
import 'views/pr_view.dart';
import 'view_models/today_stats_overview.dart';
import 'view_models/exercise_detail_today.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key, this.initialSection = 1});

  final int initialSection;

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  late String _selectedSection;
  TodayStatsOverview? _todayOverview;
  List<ExerciseDetailToday>? _exerciseDetails;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final sections = ['PR', 'TODAY', 'WEEKLY', 'LOG', 'SETTING'];
    _selectedSection = sections[widget.initialSection];
    if (_selectedSection == 'TODAY') {
      _loadTodayData();
    }
  }

  Future<void> _loadTodayData() async {
    setState(() => _isLoading = true);

    try {
      final overviewUseCase = getIt<GetTodayStatsOverviewUseCase>();
      final detailsUseCase = getIt<GetTodayExerciseDetailsUseCase>();

      final overviewMap = await overviewUseCase.execute();
      final detailsList = await detailsUseCase.execute();

      setState(() {
        _todayOverview = TodayStatsOverview.fromMap(overviewMap);
        _exerciseDetails = detailsList
            .map((map) => ExerciseDetailToday.fromMap(map))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _todayOverview = TodayStatsOverview.empty();
        _exerciseDetails = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> sections = ['PR', 'TODAY', 'WEEKLY', 'LOG', 'SETTING'];

    return Scaffold(
      backgroundColor: AppColors.deepCharcoal,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and section selector
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.boldGrey,
                        borderRadius: BorderRadius.zero,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.pureBlack.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.offWhite,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'STATS',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.offWhite,
                            letterSpacing: 1.5,
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (selected) {
                            setState(() {
                              _selectedSection = selected;
                              if (selected == 'TODAY' &&
                                  _todayOverview == null) {
                                _loadTodayData();
                              }
                            });
                          },
                          offset: const Offset(0, 50),
                          color: AppColors.boldGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          itemBuilder: (context) {
                            return sections.map((section) {
                              return PopupMenuItem<String>(
                                value: section,
                                child: Text(
                                  section,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: section == _selectedSection
                                        ? AppColors.limeGreen
                                        : AppColors.offWhite,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.boldGrey,
                              borderRadius: BorderRadius.zero,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _selectedSection,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.limeGreen,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: AppColors.limeGreen,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content area
            Expanded(
              child: _selectedSection == 'TODAY'
                  ? _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: AppColors.limeGreen,
                            ),
                          )
                        : _todayOverview != null && _exerciseDetails != null
                        ? TodayView(
                            overview: _todayOverview!,
                            exerciseDetails: _exerciseDetails!,
                          )
                        : Center(
                            child: Text(
                              'Failed to load today stats',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.offWhite.withOpacity(0.5),
                              ),
                            ),
                          )
                  : _selectedSection == 'WEEKLY'
                  ? const WeeklyView()
                  : _selectedSection == 'LOG'
                  ? const LogView()
                  : _selectedSection == 'PR'
                  ? const PRView()
                  : Center(
                      child: Text(
                        '$_selectedSection coming soon',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.offWhite.withOpacity(0.5),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
