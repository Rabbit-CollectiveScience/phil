import 'package:flutter/material.dart';
import '../view_models/card_model.dart';

class CompletedListPage extends StatelessWidget {
  final List<CardModel> completedCards;

  const CompletedListPage({super.key, required this.completedCards});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        // Detect downward swipe
        if (details.primaryVelocity != null && details.primaryVelocity! > 500) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: Column(
          children: [
            // Counter circle at top to create connection illusion
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
                      '${completedCards.length}',
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
            // Completed cards list
            Expanded(
              child: completedCards.isEmpty
                  ? const Center(
                      child: Text(
                        'No completed exercises yet',
                        style: TextStyle(fontSize: 18, color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: completedCards.length,
                      itemBuilder: (context, index) {
                        final card = completedCards[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A4A4A),
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  card.exerciseName.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  ...card.exercise.fields.map((field) {
                                    final value =
                                        card.fieldValues[field.name] ?? '';
                                    if (value.isEmpty)
                                      return const SizedBox.shrink();
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: Text(
                                        '$value ${field.unit}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300,
                                          color: Color(0xFFB9E479),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
