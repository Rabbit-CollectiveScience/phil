import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:vibration/vibration.dart';
import '../../shared/theme/app_colors.dart';
import '../../../l2_domain/use_cases/workout_sets/get_today_completed_list_use_case.dart';
import '../../../l2_domain/use_cases/workout_sets/remove_workout_set_use_case.dart';
import '../../../l2_domain/models/workout_sets/workout_set.dart';
import '../../../l2_domain/models/workout_sets/weighted_workout_set.dart';
import '../../../l2_domain/models/workout_sets/bodyweight_workout_set.dart';
import '../../../l2_domain/models/workout_sets/assisted_machine_workout_set.dart';
import '../../../l2_domain/models/workout_sets/distance_cardio_workout_set.dart';
import '../../../l2_domain/models/workout_sets/duration_cardio_workout_set.dart';
import '../../../l2_domain/models/workout_sets/isometric_workout_set.dart';
import '../../../l2_domain/models/exercises/exercise.dart';
import '../../../l2_domain/models/exercises/isometric_exercise.dart';
import 'view_models/workout_group.dart';

class CompletedListPage extends StatefulWidget {
  const CompletedListPage({super.key});

  @override
  State<CompletedListPage> createState() => _CompletedListPageState();
}

class _CompletedListPageState extends State<CompletedListPage>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  List<WorkoutGroup> _workoutGroups = [];
  final Set<String> _expandedExerciseIds = {};
  final Map<int, AnimationController> _controllers = {};
  final Map<String, AnimationController> _deleteControllers = {};
  final Map<String, AnimationController> _groupDeleteControllers = {};
  final Set<String> _deletingSetIds = {};
  final Set<String> _deletingExerciseIds = {};
  final ScrollController _scrollController = ScrollController();
  bool _isPopping = false;

  @override
  void initState() {
    super.initState();
    _loadCompletedWorkouts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var controller in _deleteControllers.values) {
      controller.dispose();
    }
    for (var controller in _groupDeleteControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  AnimationController _getController(int index) {
    return _controllers.putIfAbsent(
      index,
      () => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );
  }

  AnimationController _getDeleteController(String setId) {
    return _deleteControllers.putIfAbsent(
      setId,
      () => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
        value: 1.0, // Start fully visible
      ),
    );
  }

  AnimationController _getGroupDeleteController(String exerciseId) {
    return _groupDeleteControllers.putIfAbsent(
      exerciseId,
      () => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
        value: 1.0, // Start fully visible
      ),
    );
  }

  Future<void> _loadCompletedWorkouts() async {
    try {
      final useCase = GetIt.instance<GetTodayCompletedListUseCase>();
      final workouts = await useCase.execute();

      // Group consecutive workouts
      final groups = WorkoutGroup.groupConsecutive(workouts);

      setState(() {
        _workoutGroups = groups;
        _isLoading = false;
      });

      // Restore expansion state for previously expanded groups
      for (int i = 0; i < _workoutGroups.length; i++) {
        final group = _workoutGroups[i];
        if (_expandedExerciseIds.contains(group.exerciseId)) {
          final controller = _getController(i);
          if (controller.value == 0) {
            controller.value = 1.0; // Set to fully expanded without animation
          }
        }
      }

      debugPrint(
        '✓ Loaded ${workouts.length} workouts in ${groups.length} groups',
      );
    } catch (e) {
      debugPrint('Error loading completed workouts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleGroup(int index) {
    final group = _workoutGroups[index];
    final exerciseId = group.exerciseId;
    final controller = _getController(index);
    setState(() {
      if (_expandedExerciseIds.contains(exerciseId)) {
        _expandedExerciseIds.remove(exerciseId);
        controller.reverse();
      } else {
        _expandedExerciseIds.add(exerciseId);
        controller.forward();
      }
    });
  }

  /// Format WorkoutSet values for display based on its type
  String _formatSetValues(WorkoutSet workoutSet, {Exercise? exercise}) {
    return workoutSet.formatForDisplay();
  }

  void _removeSetLocally(WorkoutSetWithDetails setToRemove) async {
    final setId = setToRemove.workoutSet.id;

    // Find which group this set belongs to and check if it's the last one
    int? groupIndex;
    String? exerciseId;
    bool isLastSetInGroup = false;
    for (int i = 0; i < _workoutGroups.length; i++) {
      final group = _workoutGroups[i];
      if (group.sets.any((s) => s.workoutSet.id == setId)) {
        groupIndex = i;
        exerciseId = group.exerciseId;
        isLastSetInGroup = group.sets.length == 1;
        break;
      }
    }

    // Mark as deleting and get controllers
    setState(() {
      _deletingSetIds.add(setId);
      if (isLastSetInGroup && exerciseId != null) {
        _deletingExerciseIds.add(exerciseId);
      }
    });

    final setController = _getDeleteController(setId);
    AnimationController? groupController;
    if (isLastSetInGroup && exerciseId != null) {
      groupController = _getGroupDeleteController(exerciseId);
    }

    // Animate out both (reverse from 1.0 to 0.0)
    await Future.wait([
      setController.reverse(),
      if (groupController != null) groupController.reverse(),
    ]);

    // After animation completes, delete from database
    try {
      final removeUseCase = GetIt.instance<RemoveWorkoutSetUseCase>();
      await removeUseCase.execute(setId);

      // Clean up animation state
      setState(() {
        _deletingSetIds.remove(setId);
        if (isLastSetInGroup && exerciseId != null) {
          _deletingExerciseIds.remove(exerciseId);
          _expandedExerciseIds.remove(exerciseId);
        }
      });

      // Clean up controllers
      _deleteControllers.remove(setId)?.dispose();
      if (exerciseId != null) {
        _groupDeleteControllers.remove(exerciseId)?.dispose();
      }
      if (groupIndex != null) {
        _controllers.remove(groupIndex)?.dispose();
      }

      // Reload data from database
      await _loadCompletedWorkouts();

      // Show feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Set deleted',
              style: TextStyle(color: AppColors.offWhite),
            ),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error deleting workout set: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete set'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepCharcoal,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.limeGreen),
            )
          : NotificationListener<ScrollUpdateNotification>(
              onNotification: (notification) {
                // Track overscroll when at the top
                if (!_isPopping &&
                    _scrollController.hasClients &&
                    _scrollController.position.pixels <= 0) {
                  if (notification.metrics.pixels < -150) {
                    _isPopping = true;
                    Navigator.of(context).pop();
                    return true;
                  }
                }
                return false;
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  // Counter at top (scrolls with content)
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 80),
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.limeGreen,
                              ),
                              child: Center(
                                child: Text(
                                  '${_workoutGroups.fold<int>(0, (sum, group) => sum + group.setCount)}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.deepCharcoal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                  // Completed cards list
                  _workoutGroups.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Text(
                              'No completed exercises yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.offWhite.withOpacity(0.54),
                              ),
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final group = _workoutGroups[index];
                              final isGroupDeleting = _deletingExerciseIds
                                  .contains(group.exerciseId);

                              Widget groupContent = Column(
                                children: [
                                  // Group Header (always visible)
                                  AnimatedBuilder(
                                    animation: _getController(index),
                                    builder: (context, child) {
                                      final progress = _getController(
                                        index,
                                      ).value;
                                      double bottomMargin;

                                      if (progress == 0) {
                                        // Fully collapsed
                                        bottomMargin = 16;
                                      } else if (progress < 0.25) {
                                        // Collapsing: animate from 4 to 16
                                        bottomMargin =
                                            4 + (1 - progress / 0.25) * 12;
                                      } else if (progress < 0.75) {
                                        // Expanding or staying: margin = 0
                                        bottomMargin = 0;
                                      } else {
                                        // Last 25% of expansion: animate from 0 to 4
                                        bottomMargin =
                                            ((progress - 0.75) / 0.25) * 4;
                                      }

                                      return GestureDetector(
                                        onTap: () => _toggleGroup(index),
                                        child: Container(
                                          margin: EdgeInsets.only(
                                            bottom: bottomMargin,
                                          ),
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: AppColors.boldGrey,
                                            borderRadius: BorderRadius.circular(
                                              0,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      group.exerciseName
                                                          .toUpperCase(),
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: Color(
                                                          0xFFF2F2F2,
                                                        ),
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: 32,
                                                height: 32,
                                                decoration: const BoxDecoration(
                                                  color: AppColors.limeGreen,
                                                  shape: BoxShape.circle,
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  '${group.setCount}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w900,
                                                    color:
                                                        AppColors.deepCharcoal,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  // Expanded Set Details with Size + Slide Animation
                                  SizeTransition(
                                    sizeFactor: CurvedAnimation(
                                      parent: _getController(index),
                                      curve: Curves.easeInOut,
                                    ),
                                    axisAlignment: -1.0,
                                    child: SlideTransition(
                                      position:
                                          Tween<Offset>(
                                            begin: const Offset(0, -1.5),
                                            end: Offset.zero,
                                          ).animate(
                                            CurvedAnimation(
                                              parent: _getController(index),
                                              curve: Curves.easeOut,
                                            ),
                                          ),
                                      child: Column(
                                        children: group.sets.asMap().entries.map((
                                          entry,
                                        ) {
                                          final setIndex = entry.key;
                                          final set = entry.value;
                                          final isLastSet =
                                              setIndex == group.sets.length - 1;

                                          final setId = set.workoutSet.id;
                                          final isDeleting = _deletingSetIds
                                              .contains(setId);

                                          return Container(
                                            margin: EdgeInsets.only(
                                              bottom: isLastSet ? 16 : 4,
                                            ),
                                            child: AnimatedBuilder(
                                              animation: isDeleting
                                                  ? _getDeleteController(setId)
                                                  : const AlwaysStoppedAnimation(
                                                      1.0,
                                                    ),
                                              builder: (context, child) {
                                                final deleteProgress =
                                                    isDeleting
                                                    ? _getDeleteController(
                                                        setId,
                                                      ).value
                                                    : 1.0;

                                                return SizeTransition(
                                                  sizeFactor:
                                                      AlwaysStoppedAnimation(
                                                        deleteProgress,
                                                      ),
                                                  axisAlignment: -1.0,
                                                  child: SlideTransition(
                                                    position:
                                                        Tween<Offset>(
                                                          begin: const Offset(
                                                            0,
                                                            -0.5,
                                                          ),
                                                          end: Offset.zero,
                                                        ).animate(
                                                          CurvedAnimation(
                                                            parent:
                                                                AlwaysStoppedAnimation(
                                                                  deleteProgress,
                                                                ),
                                                            curve:
                                                                Curves.easeOut,
                                                          ),
                                                        ),
                                                    child: FadeTransition(
                                                      opacity:
                                                          AlwaysStoppedAnimation(
                                                            deleteProgress,
                                                          ),
                                                      child: Slidable(
                                                        key: Key(setId),
                                                        endActionPane: ActionPane(
                                                          motion:
                                                              const ScrollMotion(),
                                                          extentRatio: 0.25,
                                                          children: [
                                                            CustomSlidableAction(
                                                              onPressed: (context) async {
                                                                // Vibrate when delete is tapped
                                                                if (await Vibration.hasVibrator() ==
                                                                    true) {
                                                                  Vibration.vibrate(
                                                                    duration:
                                                                        50,
                                                                  );
                                                                }
                                                                _removeSetLocally(
                                                                  set,
                                                                );
                                                              },
                                                              backgroundColor:
                                                                  AppColors
                                                                      .error,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .zero,
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              child: const Icon(
                                                                Icons.delete,
                                                                color: Colors
                                                                    .white,
                                                                size: 24,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 20,
                                                                vertical: 14,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: const Color(
                                                              0xFF3E3E3E,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  0,
                                                                ),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    'Set ${setIndex + 1}',
                                                                    style: const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: Color(
                                                                        0xFFB9E479,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 4,
                                                                  ),
                                                                  Text(
                                                                    _formatTime(
                                                                      set
                                                                          .workoutSet
                                                                          .timestamp,
                                                                    ),
                                                                    style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w300,
                                                                      color: Colors
                                                                          .white54,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Text(
                                                                _formatSetValues(
                                                                  set.workoutSet,
                                                                  exercise: set
                                                                      .exercise,
                                                                ),
                                                                style: const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                  color: Color(
                                                                    0xFFF2F2F2,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              );

                              // Wrap with delete animation if needed
                              if (isGroupDeleting) {
                                return AnimatedBuilder(
                                  animation: _getGroupDeleteController(
                                    group.exerciseId,
                                  ),
                                  builder: (context, child) {
                                    final deleteProgress =
                                        _getGroupDeleteController(
                                          group.exerciseId,
                                        ).value;

                                    return SizeTransition(
                                      sizeFactor: AlwaysStoppedAnimation(
                                        deleteProgress,
                                      ),
                                      axisAlignment: -1.0,
                                      child: SlideTransition(
                                        position:
                                            Tween<Offset>(
                                              begin: const Offset(0, -0.5),
                                              end: Offset.zero,
                                            ).animate(
                                              CurvedAnimation(
                                                parent: AlwaysStoppedAnimation(
                                                  deleteProgress,
                                                ),
                                                curve: Curves.easeOut,
                                              ),
                                            ),
                                        child: FadeTransition(
                                          opacity: AlwaysStoppedAnimation(
                                            deleteProgress,
                                          ),
                                          child: child,
                                        ),
                                      ),
                                    );
                                  },
                                  child: groupContent,
                                );
                              }

                              return groupContent;
                            }, childCount: _workoutGroups.length),
                          ),
                        ),
                ],
              ),
            ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
