import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/providers/preferences_provider.dart';
import '../../../../l2_domain/use_cases/personal_records/get_all_prs_use_case.dart';
import '../../../../l2_domain/models/exercises/exercise.dart';
import '../../../../l2_domain/models/exercises/strength_exercise.dart';
import '../../../../l2_domain/models/exercises/cardio_exercise.dart';
import '../../../../l2_domain/models/common/muscle_group.dart';
import '../../../../l2_domain/models/workout_sets/workout_set.dart';
import '../../../../l2_domain/models/workout_sets/weighted_workout_set.dart';
import '../../../../l2_domain/models/workout_sets/bodyweight_workout_set.dart';
import '../../../../l2_domain/models/workout_sets/assisted_machine_workout_set.dart';
import '../../../../l2_domain/models/workout_sets/distance_cardio_workout_set.dart';
import '../../../../l2_domain/models/workout_sets/isometric_workout_set.dart';
import '../../../../l3_data/repositories/workout_set_repository.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPRs();
    });
  }

  Future<void> _loadPRs() async {
    setState(() => _isLoading = true);

    try {
      final useCase = GetIt.instance<GetAllPRsUseCase>();
      final allPRs = await useCase.execute();

      final workoutSetRepo = GetIt.instance<WorkoutSetRepository>();

      // Group PRs by muscle group and exercise
      final grouped = <String, Map<String, Map<String, dynamic>>>{};

      for (var pr in allPRs) {
        // Get muscle groups from exercise
        final muscleGroups = _getMuscleGroupsFromExercise(pr.exercise);
        if (muscleGroups.isEmpty) continue;

        // Calculate days ago
        final now = DateTime.now();
        final daysAgo = now.difference(pr.prRecord.achievedAt).inDays;

        // Fetch the WorkoutSet to get the actual values
        final workoutSet = await workoutSetRepo.getById(
          pr.prRecord.workoutSetId,
        );
        if (workoutSet == null) continue;

        // Format the value based on WorkoutSet type
        final formatters = context.read<PreferencesProvider>().formatters;
        final formattedValue = _formatWorkoutSetValue(workoutSet, formatters);

        // Add to each muscle group this exercise targets
        for (var muscleGroup in muscleGroups) {
          // Initialize muscle group if needed
          if (!grouped.containsKey(muscleGroup)) {
            grouped[muscleGroup] = {};
          }

          // Initialize exercise if needed
          if (!grouped[muscleGroup]!.containsKey(pr.exerciseName)) {
            grouped[muscleGroup]![pr.exerciseName] = {
              'exercise': pr.exerciseName,
              'value': formattedValue,
              'daysAgo': daysAgo,
            };
          }
        }
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
            exercises.add({
              'exercise': exerciseData['exercise'],
              'value': exerciseData['value'],
              'daysAgo': exerciseData['daysAgo'],
            });
          }

          // Sort by days ago (most recent first)
          exercises.sort((a, b) {
            final daysA = a['daysAgo'] as int;
            final daysB = b['daysAgo'] as int;
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

  String _formatWorkoutSetValue(WorkoutSet workoutSet, formatters) {
    final baseFormat = workoutSet.formatForDisplay();

    // Add units back based on workout set type
    if (workoutSet is WeightedWorkoutSet) {
      final weight = workoutSet.weight;
      if (weight != null) {
        final parts = baseFormat.split(' × ');
        if (parts.length == 2) {
          return '${formatters.formatWeight(weight)} × ${parts[1]}';
        }
      }
    } else if (workoutSet is BodyweightWorkoutSet) {
      final additionalWeight = workoutSet.additionalWeight;
      if (additionalWeight != null && additionalWeight.kg > 0) {
        final parts = baseFormat.split(' + ');
        if (parts.length == 2) {
          return '${parts[0]} + ${formatters.formatWeight(additionalWeight)}';
        }
      }
    } else if (workoutSet is AssistedMachineWorkoutSet) {
      final assistanceWeight = workoutSet.assistanceWeight;
      if (assistanceWeight != null) {
        final parts = baseFormat.split(' · ');
        if (parts.length == 2) {
          final assistanceParts = parts[1].split(' assistance');
          if (assistanceParts.length == 2) {
            return '${parts[0]} · ${formatters.formatWeight(assistanceWeight)} assistance';
          }
        }
      }
    } else if (workoutSet is DistanceCardioWorkoutSet) {
      final distance = workoutSet.distance;
      if (distance != null) {
        final parts = baseFormat.split(' · ');
        if (parts.length == 2) {
          return '${formatters.formatDistance(distance)} · ${parts[1]}';
        }
      }
    } else if (workoutSet is IsometricWorkoutSet) {
      // Format: "60 sec · 15" -> "60 sec · 15 kg"
      // or "60 sec · BW + 10" -> "60 sec · BW + 10 kg"
      final weight = workoutSet.weight;
      if (weight != null && weight.kg > 0) {
        final parts = baseFormat.split(' · ');
        if (parts.length == 2) {
          if (parts[1].startsWith('BW + ')) {
            return '${parts[0]} · BW + ${formatters.formatWeight(weight)}';
          } else {
            return '${parts[0]} · ${formatters.formatWeight(weight)}';
          }
        }
      }
    }

    return baseFormat;
  }

  List<String> _getMuscleGroupsFromExercise(Exercise exercise) {
    if (exercise is StrengthExercise) {
      return exercise.targetMuscles
          .map((muscle) {
            switch (muscle) {
              case MuscleGroup.chest:
                return 'CHEST';
              case MuscleGroup.back:
                return 'BACK';
              case MuscleGroup.legs:
                return 'LEGS';
              case MuscleGroup.shoulders:
                return 'SHOULDERS';
              case MuscleGroup.arms:
                return 'ARMS';
              case MuscleGroup.core:
                return 'CORE';
            }
          })
          .toSet()
          .toList();
    } else if (exercise is CardioExercise) {
      return ['CARDIO'];
    }
    return [];
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

                                  final formattedValue = pr['value'] ?? '—';

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
