import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../../l2_domain/use_cases/personal_records/get_all_prs_use_case.dart';

class PRView extends StatefulWidget {
  const PRView({super.key});

  @override
  State<PRView> createState() => _PRViewState();
}

class _PRViewState extends State<PRView> {
  Map<String, List<Map<String, dynamic>>> _prsByMuscleGroup = {};
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

      // Group PRs by muscle group and exercise
      final grouped = <String, Map<String, Map<String, dynamic>>>{};

      for (var pr in allPRs) {
        // Map category to muscle group
        final muscleGroup = _mapCategoryToMuscleGroup(pr.exerciseCategories);
        if (muscleGroup == null) continue;

        // Initialize muscle group if needed
        if (!grouped.containsKey(muscleGroup)) {
          grouped[muscleGroup] = {};
        }

        // Initialize exercise if needed
        if (!grouped[muscleGroup]!.containsKey(pr.exerciseName)) {
          grouped[muscleGroup]![pr.exerciseName] = {
            'exercise': pr.exerciseName,
            'value': null,
            'daysAgo': null,
            'hasWeight': false,
          };
        }

        final exercise = grouped[muscleGroup]![pr.exerciseName]!;

        // Determine if this is a weighted exercise
        if (pr.prRecord.type == 'maxWeight') {
          exercise['hasWeight'] = true;
        }

        // Choose which PR to display: maxWeight for weighted, maxReps for bodyweight
        if (pr.prRecord.type == 'maxWeight') {
          exercise['value'] = pr.formattedValue;
          exercise['daysAgo'] = pr.daysAgo;
        } else if (pr.prRecord.type == 'maxReps' && !exercise['hasWeight']) {
          exercise['value'] = pr.formattedValue;
          exercise['daysAgo'] = pr.daysAgo;
        }
      }

      // Convert to list format and sort
      final result = <String, List<Map<String, dynamic>>>{};

      // Always include all muscle groups
      final allMuscleGroups = [
        'CHEST',
        'BACK',
        'LEGS',
        'SHOULDERS',
        'ARMS',
        'CORE',
        'CARDIO',
        'FLEXIBILITY',
      ];

      for (var muscleGroup in allMuscleGroups) {
        if (grouped.containsKey(muscleGroup)) {
          final exercises = grouped[muscleGroup]!.values
              .where((ex) => ex['value'] != null) // Only exercises with PRs
              .toList();

          // Sort by days ago (most recent first)
          exercises.sort((a, b) {
            final daysA = a['daysAgo'] as int?;
            final daysB = b['daysAgo'] as int?;
            if (daysA == null && daysB == null) return 0;
            if (daysA == null) return 1;
            if (daysB == null) return -1;
            return daysA.compareTo(daysB);
          });

          result[muscleGroup] = exercises;
        } else {
          // Empty list for muscle groups without any PRs
          result[muscleGroup] = [];
        }
      }

      // Expand only groups with data
      final expandedGroups = result.entries
          .where((entry) => entry.value.isNotEmpty)
          .map((entry) => entry.key)
          .toSet();

      setState(() {
        _prsByMuscleGroup = result;
        _expandedTypes = expandedGroups;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading PRs: $e');
      setState(() {
        _prsByMuscleGroup = {};
        _isLoading = false;
      });
    }
  }

  String? _mapCategoryToMuscleGroup(List<String> categories) {
    // Map exercise categories to muscle groups
    if (categories.contains('chest')) return 'CHEST';
    if (categories.contains('back')) return 'BACK';
    if (categories.contains('legs')) return 'LEGS';
    if (categories.contains('shoulders')) return 'SHOULDERS';
    if (categories.contains('arms')) return 'ARMS';
    if (categories.contains('core')) return 'CORE';
    if (categories.contains('cardio')) return 'CARDIO';
    if (categories.contains('flexibility')) return 'FLEXIBILITY';
    return null; // Skip 'strength' category as it's redundant
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.limeGreen),
      );
    }

    if (_prsByMuscleGroup.isEmpty) {
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
          const SizedBox(height: 12),
          // PRs by muscle group
          ..._prsByMuscleGroup.entries.map((entry) {
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
                      if (prs.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'NO PRs YET',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppColors.darkText.withOpacity(0.3),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        )
                      else
                        Column(
                          children: prs.asMap().entries.map((entry) {
                            final index = entry.key;
                            final pr = entry.value;
                            final daysAgo = pr['daysAgo'];
                            final daysText = daysAgo == null
                                ? ''
                                : '$daysAgo ${daysAgo == 1 ? 'day' : 'days'} ago';

                            return Container(
                              color: index.isEven
                                  ? Colors.transparent
                                  : AppColors.darkText.withOpacity(0.075),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      pr['exercise'],
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.darkText,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        pr['value'] ?? '—',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.darkText,
                                        ),
                                      ),
                                      if (daysText.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          daysText,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.darkText
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
