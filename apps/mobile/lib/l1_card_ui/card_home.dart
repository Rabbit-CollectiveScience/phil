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

  @override
  void initState() {
    super.initState();
    _initializeCards();
  }

  void _initializeCards() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.deepOrange,
      Colors.lime,
      Colors.brown,
      Colors.blueGrey,
      Colors.deepPurple,
    ];

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
        color: colors[index % colors.length],
      ),
    );
  }

  void _removeTopCard() {
    setState(() {
      if (_cards.isNotEmpty) {
        final topCard = _cards.removeAt(0);
        _cards.add(topCard);
      }
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
      appBar: AppBar(
        title: const Text('Card Interface POC'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetCards,
            tooltip: 'Reset Cards',
          ),
        ],
      ),
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
                alignment: Alignment.center,
                children: [
                  // Pre-build up to 3 cards for smooth transitions
                  for (int i = min(_cards.length - 1, 2); i >= 0; i--)
                    Padding(
                      padding: EdgeInsets.only(top: i * 10.0, left: i * 5.0),
                      child: i == 0
                          ? SwipeableCard(
                              key: ValueKey(_cards[0].exerciseName),
                              card: _cards[0],
                              onSwipedAway: _removeTopCard,
                            )
                          : IgnorePointer(
                              child: RepaintBoundary(
                                child: SwipeableCard(
                                  key: ValueKey(_cards[i].exerciseName),
                                  card: _cards[i],
                                  onSwipedAway: () {},
                                ),
                              ),
                            ),
                    ),
                ],
              ),
      ),
    );
  }

  int min(int a, int b) => a < b ? a : b;
}
