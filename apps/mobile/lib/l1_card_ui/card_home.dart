import 'dart:math';
import 'package:flutter/material.dart';
import '../l2_card_model/card_model.dart';
import 'widgets/swipeable_card.dart';
import 'view_cards.dart';
import 'dashboard.dart';

class CardHomePage extends StatefulWidget {
  const CardHomePage({super.key});

  @override
  State<CardHomePage> createState() => _CardHomePageState();
}

class _CardHomePageState extends State<CardHomePage> {
  // UI Constants
  static const double _iconSize = 44.0;
  static const double _iconPadding = 20.0;
  static const double _topIconsPadding = 60.0; // Distance from top edge
  static const double _searchBarRightGap =
      84.0; // 20 padding + 44 icon + 20 gap
  static const double _counterSize = 60.0;
  static const double _counterBottomPadding = 40.0;
  static const Duration _searchAnimationDuration = Duration(milliseconds: 300);

  late List<CardModel> _cards;
  late List<int> _cardOrder; // Tracks which card index is at which position
  final List<CardModel> _completedCards = []; // Track completed cards
  bool _showSearchOverlay = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeCards();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _initializeCards() {
    // Bold Studio theme - pronounced grey cards on deep charcoal background
    const cardColor = Color(0xFF4A4A4A);

    final exercises = [
      // Compound exercises
      'Squat',
      'Deadlift',
      'Bench Press',
      'Overhead Press',
      'Barbell Row',
      'Pull Up',
      'Dip',
      'Lunge',
      'Romanian Deadlift',
      'Front Squat',
      // Isolation exercises
      'Bicep Curl',
      'Tricep Extension',
      'Lateral Raise',
      'Leg Curl',
      'Leg Extension',
      'Calf Raise',
      'Face Pull',
      'Cable Fly',
      'Preacher Curl',
      'Skull Crusher',
    ];

    _cards = List.generate(
      exercises.length,
      (index) => CardModel(
        exerciseName: exercises[index],
        color: cardColor,
        weight: '10',
        reps: '10',
      ),
    );

    // Initialize card order (0 is front, 1 is second, etc.)
    _cardOrder = List.generate(_cards.length, (index) => index);
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

  void _completeTopCard() {
    setState(() {
      if (_cardOrder.isNotEmpty) {
        final topIndex = _cardOrder.removeAt(0);
        _completedCards.add(_cards[topIndex]);
      }
    });
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

  void _showSearch() {
    setState(() {
      _showSearchOverlay = true;
    });
    // Delay focus to allow overlay to build
    Future.delayed(const Duration(milliseconds: 100), () {
      _searchFocusNode.requestFocus();
    });
  }

  void _hideSearch() {
    _searchFocusNode.unfocus();
    setState(() {
      _showSearchOverlay = false;
      _searchController.clear();
      // Reset to original order
      _cardOrder = List.generate(_cards.length, (index) => index);
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
      // Filter and sort cards by relevance
      final queryLower = query.toLowerCase();
      final matches = <int>[];

      // First pass: exact matches at start
      for (int i = 0; i < _cards.length; i++) {
        if (_cards[i].exerciseName.toLowerCase().startsWith(queryLower)) {
          matches.add(i);
        }
      }

      // Second pass: contains matches
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
          return ViewCardsPage(completedCards: _completedCards);
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
        child: _cards.isEmpty
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
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (_showSearchOverlay) {
                    _hideSearch();
                  }
                },
                child: Stack(
                  children: [
                    // Main card area
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Build cards dynamically with stable keys
                          for (
                            int i = min(_cardOrder.length - 1, 2);
                            i >= 0;
                            i--
                          )
                            Padding(
                              padding: EdgeInsets.only(
                                top: i * 10.0,
                                left: i * 5.0,
                              ),
                              child: i == 0
                                  ? SwipeableCard(
                                      key: ValueKey('card_${_cardOrder[0]}'),
                                      card: _cards[_cardOrder[0]],
                                      onSwipedAway: _removeTopCard,
                                      onCompleted: _completeTopCard,
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
                                          onCompleted: () {},
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
                    // Search icon/bar at top left
                    Positioned(
                      top: _topIconsPadding,
                      left: _iconPadding,
                      child: GestureDetector(
                        onTap: () {
                          if (_showSearchOverlay) {
                            // Tap on expanded bar does nothing (handled by close icon)
                          } else {
                            _showSearch();
                          }
                        },
                        behavior: HitTestBehavior.translucent,
                        child: AnimatedContainer(
                          duration: _searchAnimationDuration,
                          curve: Curves.easeOutCubic,
                          width: _showSearchOverlay
                              ? MediaQuery.of(context).size.width -
                                  _iconPadding -
                                  _searchBarRightGap
                              : _iconSize,
                          height: _iconSize,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            color: _showSearchOverlay
                                ? const Color(0xFF2A2A2A)
                                : Colors.white.withOpacity(0.15),
                          ),
                          child: ClipRect(
                            clipBehavior: Clip.hardEdge,
                            child: _showSearchOverlay
                                ? OverflowBox(
                                    alignment: Alignment.centerLeft,
                                    minWidth: 0,
                                    maxWidth: MediaQuery.of(context).size.width,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                      const Padding(
                                        padding: EdgeInsets.only(
                                          left: 12,
                                          right: 8,
                                        ),
                                        child: Icon(
                                          Icons.search,
                                          color: Color(0xFFB9E479),
                                          size: 24,
                                        ),
                                      ),
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          focusNode: _searchFocusNode,
                                          onChanged: _onSearchChanged,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          decoration: const InputDecoration(
                                            hintText: 'TYPE TO FILTER',
                                            hintStyle: TextStyle(
                                              color: Colors.white38,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 1.0,
                                            ),
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: _hideSearch,
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.white70,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : const Center(
                                    child: Icon(
                                      Icons.search,
                                      color: Colors.white70,
                                      size: 24,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    // Stats icon at top right
                    Positioned(
                      top: _topIconsPadding,
                      right: _iconPadding,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const DashboardPage(),
                            ),
                          );
                        },
                        child: Container(
                          width: _iconSize,
                          height: _iconSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.15),
                          ),
                          child: const Icon(
                            Icons.bar_chart_rounded,
                            color: Colors.white70,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    // Completed counter at bottom
                    Positioned(
                      bottom: _counterBottomPadding,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: _navigateToViewCards,
                          onVerticalDragEnd: (details) {
                            // Detect upward swipe from counter
                            if (details.primaryVelocity != null &&
                                details.primaryVelocity! < -500) {
                              _navigateToViewCards();
                            }
                          },
                          child: Container(
                            width: _counterSize,
                            height: _counterSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF4A4A4A),
                              border: Border.all(
                                color: const Color(0xFFB9E479),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${_completedCards.length}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFB9E479),
                                ),
                              ),
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
