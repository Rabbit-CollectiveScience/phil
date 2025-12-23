import 'dart:math';
import 'package:flutter/material.dart';
import '../l2_card_model/card_model.dart';
import 'widgets/swipeable_card.dart';

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
                  // Completed counter at bottom
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Center(
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
                ],
              ),
      ),
    );
  }
}
