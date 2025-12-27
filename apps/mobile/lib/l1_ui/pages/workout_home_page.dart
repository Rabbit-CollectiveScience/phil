import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../view_models/card_model.dart';
import '../widgets/swipeable_card.dart';
import '../widgets/expandable_search_bar.dart';
import '../widgets/dashboard_icon_button.dart';
import '../widgets/completion_counter.dart';
import 'completed_list_page.dart';
import 'stats_page.dart';
import '../../l2_domain/use_cases/workout_use_cases/get_recommended_exercises_use_case.dart';
import '../../l3_data/repositories/stub_exercise_repository.dart';

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

  late List<CardModel> _cards;
  late List<int> _cardOrder;
  final List<CardModel> _completedCards = [];
  final GlobalKey<ExpandableSearchBarState> _searchBarKey = GlobalKey();
  final GlobalKey _counterKey = GlobalKey();
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

  @override
  void initState() {
    super.initState();
    _loadExercises();
    _tokenController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _tokenAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _tokenController, curve: Curves.easeInCubic),
        );
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

  Future<void> _loadExercises() async {
    try {
      final repository = StubExerciseRepository();
      final useCase = GetRecommendedExercisesUseCase(repository);
      final exercises = await useCase.execute();

      // Bold Studio theme - pronounced grey cards on deep charcoal background
      const cardColor = Color(0xFF4A4A4A);

      setState(() {
        _cards = exercises
            .map((exercise) => CardModel(exercise: exercise, color: cardColor))
            .toList();
        _cardOrder = List.generate(_cards.length, (index) => index);
        _isLoading = false;
      });
    } catch (e) {
      // Handle error - could show error UI
      debugPrint('Error loading exercises: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initializeCards() {
    // Deprecated - now using _loadExercises()
    // Keeping method for potential fallback
    _cards = [];
    _cardOrder = [];
  }

  void _removeTopCard() {
    setState(() {
      if (_cardOrder.isNotEmpty) {
        // Rotate the order: move first card to back
        final topIndex = _cardOrder.removeAt(0);
        _cardOrder.add(topIndex);
      }
    });
  }

  void _completeTopCard(
    Offset buttonPosition,
    VoidCallback onAnimationComplete,
  ) {
    if (_isTokenAnimating) return; // Prevent multiple animations

    // Vibrate when token starts moving to counter
    Vibration.vibrate(duration: 50);

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

    _tokenController.forward(from: 0.0).then((_) {
      // Animation complete - update visual counter now
      setState(() {
        _isTokenAnimating = false;
        _visualCounterValue = _completedCards.length;
      });
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
          // Token reached counter zone, update visual counter
          setState(() {
            _visualCounterValue = _completedCards.length;
          });
          _completeTopCard(position, () {
            // No callback needed for drag completion
          });
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
    if (query.isEmpty) {
      setState(() {
        _cardOrder = List.generate(_cards.length, (index) => index);
      });
      return;
    }

    setState(() {
      final queryLower = query.toLowerCase();
      final matches = <int>[];

      // First pass: starts with query
      for (int i = 0; i < _cards.length; i++) {
        if (_cards[i].exerciseName.toLowerCase().startsWith(queryLower)) {
          matches.add(i);
        }
      }

      // Second pass: contains query
      for (int i = 0; i < _cards.length; i++) {
        if (!matches.contains(i) &&
            _cards[i].exerciseName.toLowerCase().contains(queryLower)) {
          matches.add(i);
        }
      }

      // Third pass: remaining cards
      for (int i = 0; i < _cards.length; i++) {
        if (!matches.contains(i)) {
          matches.add(i);
        }
      }

      _cardOrder = matches;
    });
  }

  void _navigateToViewCards() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return CompletedListPage(completedCards: _completedCards);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _cards.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'All cards swiped!',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _resetCards,
                    child: const Text('Reset'),
                  ),
                ],
              )
            : GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _searchBarKey.currentState?.collapse();
                },
                child: Stack(
                  children: [
                    // Main card area
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          for (
                            int i = min(_cardOrder.length - 1, 2);
                            i >= 0;
                            i--
                          )
                            Padding(
                              padding: EdgeInsets.only(
                                top: i * 10.0,
                                right: i * 5.0,
                              ),
                              child: i == 0
                                  ? SwipeableCard(
                                      key: ValueKey(
                                        'card_${_cardOrder[0]}_${_completedCards.length}',
                                      ),
                                      card: _cards[_cardOrder[0]],
                                      onSwipedAway: _removeTopCard,
                                      onCompleted: _completeTopCard,
                                      onTokenDrag: _handleTokenDrag,
                                      zetCount: _completedCards.length + 1,
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
                                          zetCount: _completedCards.length + 1,
                                          onCardUpdate: (updatedCard) =>
                                              _updateCard(
                                                _cardOrder[i],
                                                updatedCard,
                                              ),
                                        ),
                                      ),
                                    ),
                            ),
                        ],
                      ),
                    ),
                    // Search bar at top left
                    Positioned(
                      top: _topIconsPadding,
                      left: _iconPadding,
                      child: ExpandableSearchBar(
                        key: _searchBarKey,
                        availableWidth: _getSearchBarWidth(context),
                        iconSize: _iconSize,
                        onExpand: () {},
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
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const StatsPage(),
                            ),
                          );
                        },
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
                                color: Color(0xFFB9E479),
                              ),
                              child: const Center(
                                child: Text(
                                  'ZET',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.0,
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
                            color: Color(0xFFB9E479),
                          ),
                          child: const Center(
                            child: Text(
                              'ZET',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
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
