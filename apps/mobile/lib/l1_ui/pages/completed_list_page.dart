import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../l2_domain/use_cases/workout_use_cases/get_today_completed_list_use_case.dart';
import '../../l2_domain/models/exercise.dart';
import '../view_models/workout_group.dart';

class CompletedListPage extends StatefulWidget {
  const CompletedListPage({super.key});

  @override
  State<CompletedListPage> createState() => _CompletedListPageState();
}

class _CompletedListPageState extends State<CompletedListPage>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  List<WorkoutSetWithDetails> _completedWorkouts = [];
  List<WorkoutGroup> _workoutGroups = [];
  final Set<int> _expandedGroups = {};
  final Map<int, AnimationController> _controllers = {};
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

  Future<void> _loadCompletedWorkouts() async {
    try {
      final useCase = GetIt.instance<GetTodayCompletedListUseCase>();
      final workouts = await useCase.execute();

      // Group consecutive workouts
      final groups = WorkoutGroup.groupConsecutive(workouts);

      setState(() {
        _completedWorkouts = workouts;
        _workoutGroups = groups;
        _isLoading = false;
      });

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
    final controller = _getController(index);
    setState(() {
      if (_expandedGroups.contains(index)) {
        _expandedGroups.remove(index);
        controller.reverse();
      } else {
        _expandedGroups.add(index);
        controller.forward();
      }
    });
  }

  String _formatSetValues(Map<String, dynamic>? values, Exercise? exercise) {
    if (exercise == null) {
      return 'No data recorded';
    }

    // Dynamically format based on exercise fields
    // Show structure even if values are missing (use '-' placeholders)
    return exercise.fields
        .map((field) {
          final value = values?[field.name]?.toString() ?? '-';
          return '$value ${field.unit}'.trim();
        })
        .join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFB9E479)),
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
                                color: Color(0xFFB9E479),
                              ),
                              child: Center(
                                child: Text(
                                  '${_workoutGroups.fold<int>(0, (sum, group) => sum + group.setCount)}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1A1A1A),
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
                      ? const SliverFillRemaining(
                          child: Center(
                            child: Text(
                              'No completed exercises yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white54,
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
                              final isExpanded = _expandedGroups.contains(
                                index,
                              );

                              return Column(
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
                                            color: const Color(0xFF4A4A4A),
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
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      group
                                                          .getTimeRangeDisplay(),
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        color: Colors.white54,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: 32,
                                                height: 32,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFB9E479),
                                                  shape: BoxShape.circle,
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  '${group.setCount}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w900,
                                                    color: Color(0xFF1A1A1A),
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
                                        children: group.sets
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                              final setIndex = entry.key;
                                              final set = entry.value;
                                              final isLastSet =
                                                  setIndex ==
                                                  group.sets.length - 1;

                                              return Container(
                                                margin: EdgeInsets.only(
                                                  bottom: isLastSet ? 16 : 4,
                                                ),
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
                                                      BorderRadius.circular(0),
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
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 14,
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
                                                                .completedAt,
                                                          ),
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 12,
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
                                                        set.workoutSet.values,
                                                        set.exercise,
                                                      ),
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        color: Color(
                                                          0xFFF2F2F2,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            })
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              );
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
