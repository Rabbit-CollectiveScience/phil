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
  late List<CardModel> _cards;
  late List<int> _cardOrder; // Tracks which card index is at which position
  final List<CardModel> _completedCards = []; // Track completed cards

  @override
  void initState() {
    super.initState();
    _initializeCards();
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
            : Stack(
                children: [
                  // Main card area
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Build cards dynamically with stable keys
                        for (int i = min(_cardOrder.length - 1, 2); i >= 0; i--)
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
                                        _updateCard(_cardOrder[0], updatedCard),
                                  )
                                : IgnorePointer(
                                    child: RepaintBoundary(
                                      child: SwipeableCard(
                                        key: ValueKey('card_${_cardOrder[i]}'),
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
                  // Search icon at top left
                  Positioned(
                    top: 60,
                    left: 20,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Colors.white70,
                        size: 24,
                      ),
                    ),
                  ),
                  // Stats icon at top right
                  Positioned(
                    top: 60,
                    right: 20,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const DashboardPage(),
                          ),
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
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
                    bottom: 40,
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
                          width: 60,
                          height: 60,
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
    );
  }
}
