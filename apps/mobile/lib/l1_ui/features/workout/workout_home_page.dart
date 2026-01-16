import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/providers/preferences_provider.dart';
import 'view_models/card_model.dart';
import 'widgets/swipeable_card.dart';
import 'widgets/expandable_search_bar.dart';
import 'widgets/dashboard_icon_button.dart';
import 'widgets/completion_counter.dart';
import 'widgets/floating_card_entrance.dart';
import 'widgets/exercise_filter_type_button.dart';
import 'completed_list_page.dart';
import '../stats/stats_page.dart';
import '../settings/settings_page.dart';
import 'exercise_filter_type_page.dart';
import '../../../l2_domain/use_cases/exercises/get_recommended_exercises_use_case.dart';
import '../../../l2_domain/use_cases/workout_sets/record_workout_set_use_case.dart';
import '../../../l2_domain/use_cases/workout_sets/get_today_completed_count_use_case.dart';
import '../../../l2_domain/use_cases/filters/get_last_filter_selection_use_case.dart';
import '../../../l2_domain/use_cases/filters/record_filter_selection_use_case.dart';
import '../../../l2_domain/use_cases/filters/should_show_filter_page_use_case.dart';
import '../../../l2_domain/models/exercises/strength_exercise.dart';
import '../../../l2_domain/models/exercises/isometric_exercise.dart';
import '../../../l2_domain/models/exercises/bodyweight_exercise.dart';
import '../../../l2_domain/models/exercises/assisted_machine_exercise.dart';
import '../../../l2_domain/models/exercises/distance_cardio_exercise.dart';
import '../../../l2_domain/models/exercises/duration_cardio_exercise.dart';
import '../../../l2_domain/models/workout_sets/weighted_workout_set.dart';
import '../../../l2_domain/models/workout_sets/bodyweight_workout_set.dart';
import '../../../l2_domain/models/workout_sets/isometric_workout_set.dart';
import '../../../l2_domain/models/workout_sets/assisted_machine_workout_set.dart';
import '../../../l2_domain/models/workout_sets/distance_cardio_workout_set.dart';
import '../../../l2_domain/models/workout_sets/duration_cardio_workout_set.dart';
import '../../../l2_domain/models/common/weight.dart';
import 'package:uuid/uuid.dart';

class WorkoutHomePage extends StatefulWidget {
  const WorkoutHomePage({super.key});

  @override
  State<WorkoutHomePage> createState() => _WorkoutHomePageState();
}

class _WorkoutHomePageState extends State<WorkoutHomePage>
    with SingleTickerProviderStateMixin {
  // UI Constants
  static const double _iconSize = 44.0;
  static const double _iconPadding = 20.0;
  static const double _topIconsPadding = 60.0;
  static const double _dashboardSpacing = 20.0;
  static const double _counterSize = 60.0;
  static const double _counterBottomPadding = 40.0;

  List<CardModel> _cards = [];
  List<int> _cardOrder = [];
  final List<CardModel> _completedCards = [];
  final GlobalKey<ExpandableSearchBarState> _searchBarKey = GlobalKey();
  final GlobalKey _counterKey = GlobalKey();
  GlobalKey<SwipeableCardState>? _topCardKey;
  int _visualCounterValue = 0;

  // Token animation
  bool _isTokenAnimating = false;
  Offset _tokenStart = Offset.zero;
  Offset _tokenEnd = Offset.zero;
  late AnimationController _tokenController;
  late Animation<Offset> _tokenAnimation;

  // Token dragging
  bool _isTokenDragging = false;
  Offset _tokenDragPosition = Offset.zero;

  // Loading state
  bool _isLoading = true;
  String? _errorMessage;

  // Card transition animation
  bool _isTransitioningCards = false;

  // Filter state
  String _selectedFilterId = 'all';
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _initialize();
    _tokenController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _tokenAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _tokenController, curve: Curves.easeInCubic),
        );
  }

  Future<void> _initialize() async {
    // Load filter first, then load exercises with correct filter
    await _loadLastFilterSelection();
    _loadExercises();
    _checkAndShowFilterPage();
    _loadTodayCount();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  double _getSearchBarWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth - (_iconPadding * 2) - _iconSize - _dashboardSpacing;
  }

  Future<void> _loadExercises({String? searchQuery}) async {
    try {
      // Get use case from dependency injection - L1 never knows about L3
      final useCase = GetIt.instance<GetRecommendedExercisesUseCase>();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        debugPrint('🔍 _loadExercises: Searching for "$searchQuery"');
      } else {
        debugPrint(
          '🔍 _loadExercises: Loading with filter = $_selectedFilterId',
        );
      }

      // Use case handles search or filter logic
      final exercises = await useCase.execute(
        filterCategory: _selectedFilterId,
        searchQuery: searchQuery,
      );

      debugPrint('🔍 _loadExercises: Got ${exercises.length} exercises');

      // Bold Studio theme - pronounced grey cards on deep charcoal background
      final cardColor = AppColors.boldGrey;

      setState(() {
        _cards = exercises
            .map((exercise) => CardModel(exercise: exercise, color: cardColor))
            .toList();
        _cardOrder = List.generate(_cards.length, (index) => index);
        _isLoading = false;
        // Initialize key for top card
        _topCardKey = GlobalKey<SwipeableCardState>();
      });
    } catch (e) {
      // Show error to user instead of silent failure
      debugPrint('Error loading exercises: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load exercises: ${e.toString()}';
      });
    }
  }

  Future<void> _loadTodayCount() async {
    try {
      // Load today's completed workout count from database
      final countUseCase = GetIt.instance<GetTodayCompletedCountUseCase>();
      final count = await countUseCase.execute();

      setState(() {
        _visualCounterValue = count;
      });

      debugPrint('✓ Loaded today\'s workout count: $count');
    } catch (e) {
      debugPrint('Error loading today\'s count: $e');
    }
  }

  Future<void> _loadLastFilterSelection() async {
    try {
      final useCase = GetIt.instance<GetLastFilterSelectionUseCase>();
      final filterId = await useCase.executeWithDefault();

      debugPrint('✓ Loaded last filter selection: $filterId');

      setState(() {
        _selectedFilterId = filterId;
      });

      debugPrint('✓ _selectedFilterId is now: $_selectedFilterId');
    } catch (e) {
      debugPrint('Error loading last filter selection: $e');
    }
  }

  Future<void> _checkAndShowFilterPage() async {
    try {
      final useCase = GetIt.instance<ShouldShowFilterPageUseCase>();
      final shouldShow = await useCase.execute();

      if (shouldShow) {
        // Wait for first frame to be rendered before showing filter page
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showFilterModal();
          }
        });
      }
    } catch (e) {
      debugPrint('Error checking if should show filter page: $e');
    }
  }

  void _initializeCards() {
    // Deprecated - now using _loadExercises()
    // Keeping method for potential fallback
    _cards = [];
    _cardOrder = [];
  }

  void _removeTopCard() {
    // Reorder cards and end transition
    setState(() {
      if (_cardOrder.isNotEmpty) {
        // Rotate the order: move first card to back
        final topIndex = _cardOrder.removeAt(0);
        // Reset flip state before adding to back
        _cards[topIndex] = _cards[topIndex].copyWith(isFlipped: false);
        _cardOrder.add(topIndex);
      }
      _isTransitioningCards = false;
      // Create new key for new top card
      _topCardKey = GlobalKey<SwipeableCardState>();
    });
  }

  void _completeTopCard(
    Offset buttonPosition,
    VoidCallback onAnimationComplete,
    BuildContext context,
  ) async {
    if (_isTokenAnimating) return; // Prevent multiple animations

    // Vibrate when token starts moving to counter
    Vibration.vibrate(duration: 50);

    // Record workout set to database before updating UI
    if (_cardOrder.isNotEmpty) {
      final topIndex = _cardOrder[0];
      final completedCard = _cards[topIndex];

      try {
        // Get formatters from context
        final formatters = context.read<PreferencesProvider>().formatters;
        // Extract field values from card
        final fieldValues = _topCardKey?.currentState?.getFieldValues();
        final exercise = completedCard.exercise;

        // Get use case from dependency injection
        final recordUseCase = GetIt.instance<RecordWorkoutSetUseCase>();
        final uuid = const Uuid();

        // Construct appropriate WorkoutSet based on exercise type
        if (exercise is IsometricExercise) {
          // Parse duration and weight (allow nulls)
          final durationStr = fieldValues?['duration'];
          final weightStr = fieldValues?['weight'];

          final durationSeconds = durationStr != null
              ? int.tryParse(durationStr)
              : null;
          final weight = weightStr != null ? double.tryParse(weightStr) : null;

          final workoutSet = IsometricWorkoutSet(
            id: uuid.v4(),
            exerciseId: exercise.id,
            timestamp: DateTime.now(),
            duration: durationSeconds != null
                ? Duration(seconds: durationSeconds)
                : null,
            weight: weight != null && weight > 0 ? Weight(weight) : null,
            isBodyweightBased: exercise.isBodyweightBased,
          );
          await recordUseCase.execute(workoutSet: workoutSet);
        } else if (exercise is AssistedMachineExercise) {
          // Parse assistance weight and reps
          final assistanceWeightStr = fieldValues?['assistanceWeight'];
          final repsStr = fieldValues?['reps'];

          final assistanceWeight = assistanceWeightStr != null
              ? double.tryParse(assistanceWeightStr)
              : null;
          final reps = repsStr != null ? int.tryParse(repsStr) : null;

          final workoutSet = AssistedMachineWorkoutSet(
            id: uuid.v4(),
            exerciseId: exercise.id,
            timestamp: DateTime.now(),
            assistanceWeight: assistanceWeight != null
                ? Weight(assistanceWeight)
                : null,
            reps: reps,
          );
          await recordUseCase.execute(workoutSet: workoutSet);
        } else if (exercise is StrengthExercise) {
          // Parse values (allow nulls for missing data)
          final weightStr = fieldValues?['weight'];
          final repsStr = fieldValues?['reps'];

          final weight = weightStr != null ? double.tryParse(weightStr) : null;
          final reps = repsStr != null ? int.tryParse(repsStr) : null;

          // Determine if it's weighted or bodyweight
          if (exercise is BodyweightExercise &&
              (weight == null || weight == 0)) {
            // Pure bodyweight (or no weight specified)
            final workoutSet = BodyweightWorkoutSet(
              id: uuid.v4(),
              exerciseId: exercise.id,
              timestamp: DateTime.now(),
              reps: reps,
              additionalWeight: weight != null && weight > 0
                  ? Weight(weight)
                  : null,
            );
            await recordUseCase.execute(workoutSet: workoutSet);
          } else {
            // Weighted (free weight, machine, or bodyweight with added weight)
            final workoutSet = WeightedWorkoutSet(
              id: uuid.v4(),
              exerciseId: exercise.id,
              timestamp: DateTime.now(),
              weight: weight != null ? Weight(weight) : null,
              reps: reps,
            );
            await recordUseCase.execute(workoutSet: workoutSet);
          }
        } else if (exercise is DistanceCardioExercise) {
          // Parse distance and duration (allow nulls)
          final distanceStr = fieldValues?['distance'];
          final durationStr = fieldValues?['duration'];

          final distance = distanceStr != null
              ? formatters.parseDistance(distanceStr)
              : null;
          final durationMinutes = durationStr != null
              ? double.tryParse(durationStr)
              : null;

          final workoutSet = DistanceCardioWorkoutSet(
            id: uuid.v4(),
            exerciseId: exercise.id,
            timestamp: DateTime.now(),
            distance: distance,
            duration: durationMinutes != null
                ? Duration(minutes: durationMinutes.toInt())
                : null,
          );
          await recordUseCase.execute(workoutSet: workoutSet);
        } else if (exercise is DurationCardioExercise) {
          // Parse duration only (allow null)
          final durationStr = fieldValues?['duration'];
          final durationMinutes = durationStr != null
              ? double.tryParse(durationStr)
              : null;

          final workoutSet = DurationCardioWorkoutSet(
            id: uuid.v4(),
            exerciseId: exercise.id,
            timestamp: DateTime.now(),
            duration: durationMinutes != null
                ? Duration(minutes: durationMinutes.toInt())
                : null,
          );
          await recordUseCase.execute(workoutSet: workoutSet);
        }

        debugPrint(
          '✓ Workout set recorded: ${completedCard.exercise.name} with values: $fieldValues',
        );
      } catch (e) {
        debugPrint('Error recording workout set: $e');
        // Continue with UI update even if save fails
      }
    }

    // Increment counter immediately so button updates
    setState(() {
      if (_cardOrder.isNotEmpty) {
        final topIndex = _cardOrder[0];
        _completedCards.add(_cards[topIndex]);
      }
    });

    // Get counter's actual position
    final RenderBox? counterBox =
        _counterKey.currentContext?.findRenderObject() as RenderBox?;
    if (counterBox == null) return;

    final Offset counterPosition = counterBox.localToGlobal(Offset.zero);
    final Offset counterCenter = Offset(
      counterPosition.dx + counterBox.size.width / 2,
      counterPosition.dy + counterBox.size.height / 2,
    );

    setState(() {
      _isTokenAnimating = true;
      _tokenStart = buttonPosition;
      _tokenEnd = counterCenter;

      _tokenAnimation = Tween<Offset>(begin: _tokenStart, end: _tokenEnd)
          .animate(
            CurvedAnimation(
              parent: _tokenController,
              curve: Curves.easeInCubic,
            ),
          );
    });

    _tokenController.forward(from: 0.0).then((_) async {
      // Animation complete - reload counter from database
      setState(() {
        _isTokenAnimating = false;
      });
      // Reload actual count from database
      await _loadTodayCount();
      // Notify card that animation is complete
      onAnimationComplete();
    });
  }

  void _handleTokenDrag(Offset position, bool isDragging) async {
    if (!isDragging) {
      // Drag ended, check if token reached counter level
      final RenderBox? counterBox =
          _counterKey.currentContext?.findRenderObject() as RenderBox?;
      if (counterBox != null) {
        final Offset counterPosition = counterBox.localToGlobal(Offset.zero);
        final double counterTop = counterPosition.dy;

        // Token center position >= counter top - 90px (30px half token + 60px buffer)
        // Registers one button width (60px) before visual contact
        if (position.dy >= counterTop - 90) {
          // Token reached counter zone, reload count from database
          await _loadTodayCount();
          _completeTopCard(position, () {
            // No callback needed for drag completion
          }, context);
        }
      }

      // Reset drag state
      setState(() {
        _isTokenDragging = false;
      });
    } else {
      // Update drag position
      setState(() {
        _isTokenDragging = true;
        _tokenDragPosition = position;
      });
    }
  }

  void _updateCard(int index, CardModel updatedCard) {
    setState(() {
      _cards[index] = updatedCard;
    });
  }

  void _resetCards() {
    setState(() {
      _initializeCards();
    });
  }

  void _onSearchChanged(String query) {
    // Update search expanded state based on query
    setState(() {
      _isSearchExpanded = query.isNotEmpty;
    });

    // If search is cleared, return to filtered view
    if (query.isEmpty) {
      _loadExercises();
      return;
    }

    // Search all exercises via use case (overrides filter)
    _loadExercises(searchQuery: query);
  }

  Widget _buildEmptyState() {
    // Check if we have an active search or filter
    final searchText = _searchBarKey.currentState?.searchText ?? '';
    final hasActiveSearch = searchText.isNotEmpty;
    final hasActiveFilter = _selectedFilterId != 'all';

    if (hasActiveSearch || hasActiveFilter) {
      // No results for current search/filter
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: AppColors.offWhite30),
          const SizedBox(height: 20),
          Text(
            'No exercises found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.offWhite70,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            hasActiveSearch
                ? 'Try a different search term'
                : 'Try selecting a different category',
            style: TextStyle(fontSize: 16, color: AppColors.offWhite50),
          ),
        ],
      );
    } else {
      // All cards completed
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('All cards swiped!', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _resetCards, child: const Text('Reset')),
        ],
      );
    }
  }

  void _navigateToViewCards() async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const CompletedListPage();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // New page slides up from bottom
          const beginIncoming = Offset(0.0, 1.0);
          const endIncoming = Offset.zero;
          const curve = Curves.easeOutCubic;

          var incomingTween = Tween(
            begin: beginIncoming,
            end: endIncoming,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(incomingTween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );

    // User returned - reload counter from database
    await _loadTodayCount();
  }

  void _showFilterModal() async {
    final selectedFilterId = await Navigator.of(context).push<String>(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return ExerciseFilterTypePage(selectedFilterId: _selectedFilterId);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Slide in from top
          const begin = Offset(0.0, -1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );

    if (selectedFilterId != null) {
      // Record filter selection (even if same as current)
      try {
        final recordUseCase = GetIt.instance<RecordFilterSelectionUseCase>();
        await recordUseCase.execute(selectedFilterId);
        debugPrint('✓ Recorded filter selection: $selectedFilterId');
      } catch (e) {
        debugPrint('Error recording filter selection: $e');
      }

      if (selectedFilterId != _selectedFilterId) {
        setState(() {
          _selectedFilterId = selectedFilterId;
        });
        // Reload exercises with new filter
        _loadExercises();
        debugPrint('Filter selected: $selectedFilterId');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _errorMessage != null
            ? Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 60),
                    const SizedBox(height: 20),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: AppColors.error),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                        _loadExercises();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _searchBarKey.currentState?.collapse();
                },
                child: Stack(
                  children: [
                    // Main card area - conditional content
                    Center(
                      child: _cards.isEmpty
                          ? _buildEmptyState()
                          : Stack(
                              alignment: Alignment.center,
                              children: [
                                for (
                                  int i = min(_cardOrder.length - 1, 2);
                                  i >= 0;
                                  i--
                                )
                                  FloatingCardEntrance(
                                    index: i,
                                    child: AnimatedPadding(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeOut,
                                      padding: EdgeInsets.only(
                                        top: (_isTransitioningCards && i > 0)
                                            ? (i - 1) * 10.0
                                            : i * 10.0,
                                        right: (_isTransitioningCards && i > 0)
                                            ? (i - 1) * 5.0
                                            : i * 5.0,
                                      ),
                                      child: i == 0
                                          ? SwipeableCard(
                                              key: _topCardKey,
                                              card: _cards[_cardOrder[0]],
                                              onSwipedAway: _removeTopCard,
                                              onStartSwipeAway: () {
                                                setState(() {
                                                  _isTransitioningCards = true;
                                                });
                                              },
                                              onCompleted:
                                                  (position, callback) =>
                                                      _completeTopCard(
                                                        position,
                                                        callback,
                                                        context,
                                                      ),
                                              onTokenDrag: _handleTokenDrag,
                                              onInteractionStart: () {
                                                _searchBarKey.currentState
                                                    ?.collapse();
                                              },
                                              zetCount:
                                                  _completedCards.length + 1,
                                              onCardUpdate: (updatedCard) =>
                                                  _updateCard(
                                                    _cardOrder[0],
                                                    updatedCard,
                                                  ),
                                            )
                                          : IgnorePointer(
                                              child: RepaintBoundary(
                                                child: SwipeableCard(
                                                  key: ValueKey(
                                                    'card_${_cardOrder[i]}',
                                                  ),
                                                  card: _cards[_cardOrder[i]],
                                                  onSwipedAway: () {},
                                                  onCompleted:
                                                      (
                                                        Offset _,
                                                        VoidCallback callback,
                                                      ) {},
                                                  zetCount:
                                                      _completedCards.length +
                                                      1,
                                                  onCardUpdate: (updatedCard) =>
                                                      _updateCard(
                                                        _cardOrder[i],
                                                        updatedCard,
                                                      ),
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                    // Filter button at top center (rendered first, behind search)
                    Positioned(
                      top: _topIconsPadding,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: IgnorePointer(
                          ignoring: _isSearchExpanded,
                          child: Opacity(
                            opacity: _isSearchExpanded ? 0.0 : 1.0,
                            child: ExerciseFilterTypeButton(
                              selectedFilterId: _selectedFilterId,
                              onTap: _showFilterModal,
                              size: _iconSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Search bar at top left (rendered after, covers filter)
                    Positioned(
                      top: _topIconsPadding,
                      left: _iconPadding,
                      child: ExpandableSearchBar(
                        key: _searchBarKey,
                        availableWidth: _getSearchBarWidth(context),
                        iconSize: _iconSize,
                        onExpand: () {
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (mounted) {
                              setState(() {
                                _isSearchExpanded = true;
                              });
                            }
                          });
                        },
                        onCollapse: () {
                          setState(() {
                            _isSearchExpanded = false;
                          });
                        },
                        onSearchChanged: _onSearchChanged,
                        onDismissKeyboard: () {},
                      ),
                    ),
                    // Dashboard icon at top right
                    Positioned(
                      top: _topIconsPadding,
                      right: _iconPadding,
                      child: DashboardIconButton(
                        size: _iconSize,
                        onTap: () async {
                          // Always navigate to first section (TODAY)
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const StatsPage(initialSection: 0),
                            ),
                          );

                          // User returned - reload counter from database
                          await _loadTodayCount();
                        },
                      ),
                    ),
                    // Settings icon below dashboard icon
                    Positioned(
                      top: _topIconsPadding + _iconSize + 16,
                      right: _iconPadding,
                      child: GestureDetector(
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SettingsPage(),
                            ),
                          );
                          // Reload counter in case data was cleared/imported
                          await _loadTodayCount();
                        },
                        child: Container(
                          width: _iconSize,
                          height: _iconSize,
                          decoration: BoxDecoration(
                            color: AppColors.boldGrey,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.pureBlack.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.settings,
                            color: AppColors.offWhite,
                            size: _iconSize * 0.5,
                          ),
                        ),
                      ),
                    ),
                    // Completion counter at bottom
                    Positioned(
                      bottom: _counterBottomPadding,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: CompletionCounter(
                          key: _counterKey,
                          count: _visualCounterValue,
                          size: _counterSize,
                          onTap: _navigateToViewCards,
                          onSwipeUp: _navigateToViewCards,
                        ),
                      ),
                    ),
                    // Falling token animation
                    if (_isTokenAnimating)
                      AnimatedBuilder(
                        animation: _tokenAnimation,
                        builder: (context, child) {
                          return Positioned(
                            left: _tokenAnimation.value.dx - 30,
                            top: _tokenAnimation.value.dy - 30,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.limeGreen,
                              ),
                              child: const Center(
                                child: Text(
                                  'Z',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    // Dragging token
                    if (_isTokenDragging)
                      Positioned(
                        left: _tokenDragPosition.dx - 30,
                        top: _tokenDragPosition.dy - 30,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.limeGreen,
                          ),
                          child: const Center(
                            child: Text(
                              'Z',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
