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
  Set<String> _showingAllExercises =
      {}; // Track which groups show all exercises

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
            'prs': <String, Map<String, dynamic>>{}, // Store all PR types
          };
        }

        final exercise = grouped[muscleGroup]![pr.exerciseName]!;
        final prs = exercise['prs'] as Map<String, Map<String, dynamic>>;

        // Store this PR type
        prs[pr.prRecord.type] = {
          'value': pr.formattedValue,
          'daysAgo': pr.daysAgo,
        };
      }

      // Convert to list format and select best PR to display
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
      ];

      for (var muscleGroup in allMuscleGroups) {
        if (grouped.containsKey(muscleGroup)) {
          final exercises = <Map<String, dynamic>>[];

          for (var exerciseData in grouped[muscleGroup]!.values) {
            final prs =
                exerciseData['prs'] as Map<String, Map<String, dynamic>>;

            // Select best PR to display using priority order
            final selectedPR = _selectBestPR(prs);

            if (selectedPR != null) {
              exercises.add({
                'exercise': exerciseData['exercise'],
                'value': selectedPR['value'],
                'daysAgo': selectedPR['daysAgo'],
                'prType': selectedPR['type'],
              });
            }
          }

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

  /// Select the best PR to display based on priority order
  Map<String, dynamic>? _selectBestPR(Map<String, Map<String, dynamic>> prs) {
    if (prs.isEmpty) return null;

    // Priority order for PR types
    final priorityOrder = [
      'maxWeight', // Weighted strength exercises
      'maxReps', // Bodyweight strength exercises
      'maxDurationInSeconds', // Time-based cardio
      'maxDistance', // Distance-based cardio
      'maxSpeed', // Speed-based cardio
      'maxResistance', // Resistance-based cardio
      'maxIncline', // Incline-based cardio
    ];

    // Try priority order first
    for (var prType in priorityOrder) {
      if (prs.containsKey(prType)) {
        final prData = prs[prType]!;
        return {
          'value': prData['value'],
          'daysAgo': prData['daysAgo'],
          'type': prType,
        };
      }
    }

    // Fallback: return first available PR
    final firstEntry = prs.entries.first;
    return {
      'value': firstEntry.value['value'],
      'daysAgo': firstEntry.value['daysAgo'],
      'type': firstEntry.key,
    };
  }

  /// Format PR value based on type
  String _formatPRValue(String prType, String rawValue) {
    // Try to parse the raw value
    final numValue = double.tryParse(rawValue);
    if (numValue == null) return rawValue;

    switch (prType) {
      case 'maxDurationInSeconds':
        // Convert seconds to minutes
        final minutes = (numValue / 60).floor();
        final seconds = (numValue % 60).round();
        if (minutes > 0 && seconds > 0) {
          return '$minutes min $seconds sec';
        } else if (minutes > 0) {
          return '$minutes min';
        } else {
          return '$seconds sec';
        }

      case 'maxDistance':
        return '${numValue.toStringAsFixed(1)} km';

      case 'maxSpeed':
        return '${numValue.toStringAsFixed(1)} km/h';

      case 'maxResistance':
        return 'Level ${numValue.round()}';

      case 'maxIncline':
        return '${numValue.toStringAsFixed(1)}%';

      case 'maxWeight':
        return '${numValue.toStringAsFixed(1)} kg';

      case 'maxReps':
        return '${numValue.round()} reps';

      case 'maxVolume':
        return '${numValue.toStringAsFixed(0)} kg';

      default:
        // Unknown type, return raw value
        return rawValue;
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
                    Container(
                      padding: const EdgeInsets.all(16),
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
                          Text(
                            type,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.darkText,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
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
                          children: [
                            Column(
                              children: (() {
                                final showingAll = _showingAllExercises
                                    .contains(type);
                                final displayPRs = showingAll
                                    ? prs
                                    : prs.take(3).toList();

                                return displayPRs.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final pr = entry.value;
                                  final daysAgo = pr['daysAgo'];
                                  final daysText = daysAgo == null
                                      ? ''
                                      : '$daysAgo ${daysAgo == 1 ? 'day' : 'days'} ago';

                                  // Format the value based on PR type
                                  final rawValue = pr['value'] ?? '—';
                                  final prType = pr['prType'] ?? '';
                                  final formattedValue = prType.isNotEmpty
                                      ? _formatPRValue(prType, rawValue)
                                      : rawValue;

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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              formattedValue,
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
                                }).toList();
                              })(),
                            ),
                            if (prs.length > 3) ...[
                              Container(
                                height: 1,
                                color: const Color(0xFFE0E0E0),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (_showingAllExercises.contains(type)) {
                                      _showingAllExercises.remove(type);
                                    } else {
                                      _showingAllExercises.add(type);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  color: Colors.transparent,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _showingAllExercises.contains(type)
                                            ? 'SHOW LESS'
                                            : 'SHOW ${prs.length - 3} MORE',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.darkText.withOpacity(
                                            0.5,
                                          ),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        _showingAllExercises.contains(type)
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        size: 16,
                                        color: AppColors.darkText.withOpacity(
                                          0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
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
