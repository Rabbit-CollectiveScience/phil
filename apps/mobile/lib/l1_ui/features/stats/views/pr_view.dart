import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../../l2_domain/use_cases/personal_records/get_all_prs_use_case.dart';
import '../../../../l2_domain/models/pr_item_with_exercise.dart';
import '../view_models/pr_summary.dart';

class PRView extends StatefulWidget {
  const PRView({super.key});

  @override
  State<PRView> createState() => _PRViewState();
}

class _PRViewState extends State<PRView> {
  PRSummary _summary = PRSummary.empty();
  bool _isLoading = true;
  Set<String> _expandedTypes = {};

  @override
  void initState() {
    super.initState();
    _loadPRs();
  }

  Future<void> _loadPRs() async {
    setState(() => _isLoading = true);

    try {
      final useCase = GetIt.instance<GetAllPRsUseCase>();
      final allPRs = await useCase.execute();

      setState(() {
        _summary = PRSummary.fromPRList(allPRs);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading PRs: $e');
      setState(() {
        _summary = PRSummary.empty();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.limeGreen),
      );
    }

    if (_summary.totalPRs == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: AppColors.offWhite.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'NO PERSONAL RECORDS YET',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.offWhite.withOpacity(0.5),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete workouts to set your first PRs',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.offWhite.withOpacity(0.3),
              ),
            ),
          ],
        ),
      );
    }

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
    return IntrinsicHeight(
      child: Row(
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 36,
                    child: Align(
                      alignment: Alignment(0, 0.3),
                      child: Text(
                        '${_summary.totalPRs}',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkText,
                          height: 1.0,
                        ),
                      ),
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 36,
                    child: Align(
                      alignment: Alignment(0, 0.3),
                      child: Text(
                        _summary.lastPRDate,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.pureBlack,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'MOST RECENT PR',
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
      ),
    );
  }

  Widget _buildRecentPRsSection() {
    // Group PRs by exercise
    final groupedPRs = <String, List<PRItemWithExercise>>{};
    for (var pr in _summary.recentPRs) {
      if (!groupedPRs.containsKey(pr.exerciseName)) {
        groupedPRs[pr.exerciseName] = [];
      }
      groupedPRs[pr.exerciseName]!.add(pr);
    }

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
          ...groupedPRs.entries.map((entry) {
            final exerciseName = entry.key;
            final prs = entry.value;
            final firstPR = prs.first;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: prs.length > 1 ? 60.0 : 44.0,
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
                          exerciseName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkText,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          firstPR.formattedDate,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText.withOpacity(0.5),
                          ),
                        ),
                        if (prs.length > 1) const SizedBox(height: 8),
                        if (prs.length > 1)
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: prs.map((pr) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.limeGreen.withOpacity(0.15),
                                  borderRadius: BorderRadius.zero,
                                ),
                                child: Text(
                                  pr.formattedType,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.darkText,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: prs.map((pr) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (prs.length > 1)
                              Text(
                                '${pr.formattedType} ',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkText.withOpacity(0.4),
                                ),
                              ),
                            Text(
                              pr.formattedValue,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppColors.darkText,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
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
                        children: () {
                          // Group PRs by exercise within this category
                          final groupedPRs = <String, List<PRItemWithExercise>>{};
                          for (var pr in prs) {
                            if (!groupedPRs.containsKey(pr.exerciseName)) {
                              groupedPRs[pr.exerciseName] = [];
                            }
                            groupedPRs[pr.exerciseName]!.add(pr);
                          }

                          return groupedPRs.entries.map((exerciseEntry) {
                            final exerciseName = exerciseEntry.key;
                            final exercisePRs = exerciseEntry.value;
                            final firstPR = exercisePRs.first;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exerciseName.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.darkText,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          firstPR.formattedDate,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.darkText
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: exercisePRs.map((pr) {
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (exercisePRs.length > 1)
                                                Text(
                                                  '${pr.formattedType} ',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.darkText
                                                        .withOpacity(0.4),
                                                  ),
                                                ),
                                              Text(
                                                pr.formattedValue,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w900,
                                                  color: AppColors.darkText,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList();
                        }(),
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
}
