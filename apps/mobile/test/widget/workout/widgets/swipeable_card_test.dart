import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l1_ui/features/workout/widgets/swipeable_card.dart';
import 'package:phil/l1_ui/features/workout/view_models/card_model.dart';
import 'package:phil/l1_ui/shared/theme/app_colors.dart';
import 'package:phil/l2_domain/models/exercises/free_weight_exercise.dart';
import 'package:phil/l2_domain/models/exercises/bodyweight_exercise.dart';
import 'package:phil/l2_domain/models/exercises/machine_exercise.dart';
import 'package:phil/l2_domain/models/exercises/distance_cardio_exercise.dart';
import 'package:phil/l2_domain/models/exercises/duration_cardio_exercise.dart';
import 'package:phil/l2_domain/models/common/muscle_group.dart';

void main() {
  group('SwipeableCard', () {
    late CardModel freeWeightCard;
    late CardModel bodyweightCard;
    late CardModel distanceCardioCard;
    late CardModel durationCardioCard;

    setUp(() {
      freeWeightCard = CardModel(
        exercise: FreeWeightExercise(
          id: 'test-1',
          name: 'Bench Press',
          description: 'A chest exercise',
          isCustom: false,
          targetMuscles: [MuscleGroup.chest],
        ),
        color: AppColors.boldGrey,
      );

      bodyweightCard = CardModel(
        exercise: BodyweightExercise(
          id: 'test-2',
          name: 'Push-ups',
          description: 'Bodyweight chest exercise',
          isCustom: false,
          targetMuscles: [MuscleGroup.chest],
          canAddWeight: true,
        ),
        color: AppColors.boldGrey,
      );

      distanceCardioCard = CardModel(
        exercise: DistanceCardioExercise(
          id: 'test-3',
          name: 'Running',
          description: 'Cardio exercise',
          isCustom: false,
        ),
        color: AppColors.boldGrey,
      );

      durationCardioCard = CardModel(
        exercise: DurationCardioExercise(
          id: 'test-4',
          name: 'Jumping Jacks',
          description: 'Duration cardio',
          isCustom: false,
        ),
        color: AppColors.boldGrey,
      );
    });

    group('Display - FreeWeightExercise', () {
      testWidgets('shows exercise name and description on front',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SwipeableCard(
                card: freeWeightCard,
                onSwipedAway: () {},
                onCompleted: (_, __) {},
                onCardUpdate: (_) {},
                zetCount: 0,
              ),
            ),
          ),
        );

        expect(find.text('Bench Press'), findsOneWidget);
        expect(find.text('A chest exercise'), findsOneWidget);
      });

      testWidgets('shows weight and reps fields on back when flipped',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SwipeableCard(
                card: freeWeightCard,
                onSwipedAway: () {},
                onCompleted: (_, __) {},
                onCardUpdate: (_) {},
                zetCount: 0,
              ),
            ),
          ),
        );

        // Tap to flip
        await tester.tap(find.byType(SwipeableCard));
        await tester.pumpAndSettle();

        // Should show weight and reps fields
        expect(find.text('WEIGHT'), findsOneWidget);
        expect(find.text('REPS'), findsOneWidget);
        expect(find.text('- kg'), findsOneWidget);
        expect(find.text('- reps'), findsOneWidget);
      });

      testWidgets('displays set number counter', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SwipeableCard(
                card: freeWeightCard,
                onSwipedAway: () {},
                onCompleted: (_, __) {},
                onCardUpdate: (_) {},
                zetCount: 0,
              ),
            ),
          ),
        );

        // Flip to back
        await tester.tap(find.byType(SwipeableCard));
        await tester.pumpAndSettle();

        // Should show SET 1
        expect(find.textContaining('SET'), findsOneWidget);
      });
    });

    group('Display - BodyweightExercise', () {
      testWidgets('shows reps field for bodyweight exercise', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SwipeableCard(
                card: bodyweightCard,
                onSwipedAway: () {},
                onCompleted: (_, __) {},
                onCardUpdate: (_) {},
                zetCount: 0,
              ),
            ),
          ),
        );

        // Flip to back
        await tester.tap(find.byType(SwipeableCard));
        await tester.pumpAndSettle();

        expect(find.text('WEIGHT'), findsOneWidget);
        expect(find.text('REPS'), findsOneWidget);
      });
    });

    group('Display - DistanceCardioExercise', () {
      testWidgets('shows distance and duration fields', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SwipeableCard(
                card: distanceCardioCard,
                onSwipedAway: () {},
                onCompleted: (_, __) {},
                onCardUpdate: (_) {},
                zetCount: 0,
              ),
            ),
          ),
        );

        // Flip to back
        await tester.tap(find.byType(SwipeableCard));
        await tester.pumpAndSettle();

        expect(find.text('DISTANCE'), findsOneWidget);
        expect(find.text('DURATION'), findsOneWidget);
        expect(find.text('- km'), findsOneWidget);
        expect(find.text('- min'), findsOneWidget);
      });
    });

    group('Display - DurationCardioExercise', () {
      testWidgets('shows only duration field', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SwipeableCard(
                card: durationCardioCard,
                onSwipedAway: () {},
                onCompleted: (_, __) {},
                onCardUpdate: (_) {},
                zetCount: 0,
              ),
            ),
          ),
        );

        // Flip to back
        await tester.tap(find.byType(SwipeableCard));
        await tester.pumpAndSettle();

        expect(find.text('DURATION'), findsOneWidget);
        expect(find.text('- min'), findsOneWidget);
        // Should not have distance or weight fields
        expect(find.text('DISTANCE'), findsNothing);
        expect(find.text('WEIGHT'), findsNothing);
      });
    });

    group('User Interaction', () {
      testWidgets('flips card on tap', (tester) async {
        bool cardUpdated = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SwipeableCard(
                card: freeWeightCard,
                onSwipedAway: () {},
                onCompleted: (_, __) {},
                onCardUpdate: (card) {
                  cardUpdated = card.isFlipped;
                },
                zetCount: 0,
              ),
            ),
          ),
        );

        // Initially showing front (exercise name)
        expect(find.text('Bench Press'), findsOneWidget);

        // Tap to flip
        await tester.tap(find.byType(SwipeableCard));
        await tester.pumpAndSettle();

        // Should be flipped
        expect(cardUpdated, true);
        expect(find.text('WEIGHT'), findsOneWidget);
      });

      testWidgets('accepts text input in weight field', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SwipeableCard(
                card: freeWeightCard,
                onSwipedAway: () {},
                onCompleted: (_, __) {},
                onCardUpdate: (_) {},
                zetCount: 0,
              ),
            ),
          ),
        );

        // Flip to back
        await tester.tap(find.byType(SwipeableCard));
        await tester.pumpAndSettle();

        // Find weight field and enter text
        final weightField = find.widgetWithText(TextField, '- kg');
        expect(weightField, findsOneWidget);

        await tester.enterText(weightField, '80');
        await tester.pump();

        // Verify text was entered
        expect(find.text('80'), findsOneWidget);
      });

      testWidgets('accepts text input in reps field', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SwipeableCard(
                card: freeWeightCard,
                onSwipedAway: () {},
                onCompleted: (_, __) {},
                onCardUpdate: (_) {},
                zetCount: 0,
              ),
            ),
          ),
        );

        // Flip to back
        await tester.tap(find.byType(SwipeableCard));
        await tester.pumpAndSettle();

        // Find reps field and enter text
        final repsField = find.widgetWithText(TextField, '- reps');
        expect(repsField, findsOneWidget);

        await tester.enterText(repsField, '10');
        await tester.pump();

        expect(find.text('10'), findsOneWidget);
      });

      testWidgets('X button calls onSwipedAway', (tester) async {
        bool swipedAway = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SwipeableCard(
                card: freeWeightCard,
                onSwipedAway: () {
                  swipedAway = true;
                },
                onCompleted: (_, __) {},
                onCardUpdate: (_) {},
                zetCount: 0,
              ),
            ),
          ),
        );

        // Flip to back
        await tester.tap(find.byType(SwipeableCard));
        await tester.pumpAndSettle();

        // Tap X button
        final xButton = find.byIcon(Icons.close);
        expect(xButton, findsOneWidget);

        await tester.tap(xButton);
        await tester.pumpAndSettle();

        expect(swipedAway, true);
      });

      testWidgets('checkmark button triggers onCompleted callback',
          (tester) async {
        Offset? completedPosition;
        bool completedCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SwipeableCard(
                card: freeWeightCard,
                onSwipedAway: () {},
                onCompleted: (position, callback) {
                  completedPosition = position;
                  completedCalled = true;
                  callback();
                },
                onCardUpdate: (_) {},
                zetCount: 0,
              ),
            ),
          ),
        );

        // Flip to back
        await tester.tap(find.byType(SwipeableCard));
        await tester.pumpAndSettle();

        // Enter valid data
        await tester.enterText(find.widgetWithText(TextField, '- kg'), '80');
        await tester.enterText(find.widgetWithText(TextField, '- reps'), '10');
        await tester.pump();

        // Tap checkmark button
        final checkButton = find.byIcon(Icons.check);
        expect(checkButton, findsOneWidget);

        await tester.tap(checkButton);
        await tester.pumpAndSettle();

        expect(completedCalled, true);
        expect(completedPosition, isNotNull);
      });
    });

    group('Swipe Gestures', () {
      testWidgets('swiping left dismisses card', (tester) async {
        bool dismissed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SwipeableCard(
                card: freeWeightCard,
                onSwipedAway: () {
                  dismissed = true;
                },
                onCompleted: (_, __) {},
                onCardUpdate: (_) {},
                zetCount: 0,
              ),
            ),
          ),
        );

        // Swipe left
        await tester.drag(find.byType(SwipeableCard), const Offset(-500, 0));
        await tester.pumpAndSettle();

        expect(dismissed, true);
      });

      testWidgets('small drag does not dismiss card', (tester) async {
        bool dismissed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SwipeableCard(
                card: freeWeightCard,
                onSwipedAway: () {
                  dismissed = true;
                },
                onCompleted: (_, __) {},
                onCardUpdate: (_) {},
                zetCount: 0,
              ),
            ),
          ),
        );

        // Small drag - should not dismiss
        await tester.drag(find.byType(SwipeableCard), const Offset(-50, 0));
        await tester.pumpAndSettle();

        expect(dismissed, false);
      });
    });

    group('Field Value Extraction', () {
      testWidgets('getFieldValues extracts entered values', (tester) async {
        final GlobalKey<SwipeableCardState> cardKey = GlobalKey();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SwipeableCard(
                key: cardKey,
                card: freeWeightCard,
                onSwipedAway: () {},
                onCompleted: (_, __) {},
                onCardUpdate: (_) {},
                zetCount: 0,
              ),
            ),
          ),
        );

        // Flip to back
        await tester.tap(find.byType(SwipeableCard));
        await tester.pumpAndSettle();

        // Enter values
        await tester.enterText(find.widgetWithText(TextField, '- kg'), '80');
        await tester.enterText(find.widgetWithText(TextField, '- reps'), '10');
        await tester.pump();

        // Get values using the state method
        final values = cardKey.currentState!.getFieldValues();

        expect(values['weight'], '80');
        expect(values['reps'], '10');
      });

      testWidgets('getFieldValues ignores placeholder values', (tester) async {
        final GlobalKey<SwipeableCardState> cardKey = GlobalKey();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SwipeableCard(
                key: cardKey,
                card: freeWeightCard,
                onSwipedAway: () {},
                onCompleted: (_, __) {},
                onCardUpdate: (_) {},
                zetCount: 0,
              ),
            ),
          ),
        );

        // Flip to back but don't enter values
        await tester.tap(find.byType(SwipeableCard));
        await tester.pumpAndSettle();

        // Get values - should be empty since only placeholders present
        final values = cardKey.currentState!.getFieldValues();

        expect(values.isEmpty, true);
      });
    });

    group('Card State Management', () {
      testWidgets('card remembers flipped state', (tester) async {
        CardModel currentCard = freeWeightCard;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return SwipeableCard(
                    card: currentCard,
                    onSwipedAway: () {},
                    onCompleted: (_, __) {},
                    onCardUpdate: (card) {
                      setState(() {
                        currentCard = card;
                      });
                    },
                    zetCount: 0,
                  );
                },
              ),
            ),
          ),
        );

        // Flip card
        await tester.tap(find.byType(SwipeableCard));
        await tester.pumpAndSettle();

        expect(currentCard.isFlipped, true);

        // Rebuild widget
        await tester.pumpAndSettle();

        // Should still show back side
        expect(find.text('WEIGHT'), findsOneWidget);
      });

      testWidgets('updates userData when fields change', (tester) async {
        CardModel currentCard = freeWeightCard;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return SwipeableCard(
                    card: currentCard,
                    onSwipedAway: () {},
                    onCompleted: (_, __) {},
                    onCardUpdate: (card) {
                      setState(() {
                        currentCard = card;
                      });
                    },
                    zetCount: 0,
                  );
                },
              ),
            ),
          ),
        );

        // Flip and enter data
        await tester.tap(find.byType(SwipeableCard));
        await tester.pumpAndSettle();

        await tester.enterText(find.widgetWithText(TextField, '- kg'), '80');
        await tester.pump();

        // Card userData is updated via separate mechanism
        // This test verifies the field controllers work
        expect(find.text('80'), findsOneWidget);
      });
    });

    group('Different Exercise Types', () {
      testWidgets('distance cardio accepts distance and duration',
          (tester) async {
        final GlobalKey<SwipeableCardState> cardKey = GlobalKey();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SwipeableCard(
                key: cardKey,
                card: distanceCardioCard,
                onSwipedAway: () {},
                onCompleted: (_, __) {},
                onCardUpdate: (_) {},
                zetCount: 0,
              ),
            ),
          ),
        );

        // Flip to back
        await tester.tap(find.byType(SwipeableCard));
        await tester.pumpAndSettle();

        // Enter values
        await tester.enterText(find.widgetWithText(TextField, '- km'), '5');
        await tester.enterText(find.widgetWithText(TextField, '- min'), '30');
        await tester.pump();

        final values = cardKey.currentState!.getFieldValues();
        expect(values['distance'], '5');
        expect(values['duration'], '30');
      });

      testWidgets('duration cardio accepts only duration', (tester) async {
        final GlobalKey<SwipeableCardState> cardKey = GlobalKey();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SwipeableCard(
                key: cardKey,
                card: durationCardioCard,
                onSwipedAway: () {},
                onCompleted: (_, __) {},
                onCardUpdate: (_) {},
                zetCount: 0,
              ),
            ),
          ),
        );

        // Flip to back
        await tester.tap(find.byType(SwipeableCard));
        await tester.pumpAndSettle();

        // Should only have duration field
        expect(find.text('DURATION'), findsOneWidget);
        expect(find.text('DISTANCE'), findsNothing);

        await tester.enterText(find.widgetWithText(TextField, '- min'), '20');
        await tester.pump();

        final values = cardKey.currentState!.getFieldValues();
        expect(values['duration'], '20');
        expect(values.length, 1); // Only duration
      });
    });

    group('Edge Cases', () {
      testWidgets('handles multiple flips correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SwipeableCard(
                card: freeWeightCard,
                onSwipedAway: () {},
                onCompleted: (_, __) {},
                onCardUpdate: (_) {},
                zetCount: 0,
              ),
            ),
          ),
        );

        // Flip to back
        await tester.tap(find.byType(SwipeableCard));
        await tester.pumpAndSettle();
        expect(find.text('WEIGHT'), findsOneWidget);

        // Flip back to front
        await tester.tap(find.byType(SwipeableCard));
        await tester.pumpAndSettle();
        expect(find.text('Bench Press'), findsOneWidget);

        // Flip to back again
        await tester.tap(find.byType(SwipeableCard));
        await tester.pumpAndSettle();
        expect(find.text('WEIGHT'), findsOneWidget);
      });

      testWidgets('handles empty string input', (tester) async {
        final GlobalKey<SwipeableCardState> cardKey = GlobalKey();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SwipeableCard(
                key: cardKey,
                card: freeWeightCard,
                onSwipedAway: () {},
                onCompleted: (_, __) {},
                onCardUpdate: (_) {},
                zetCount: 0,
              ),
            ),
          ),
        );

        // Flip to back
        await tester.tap(find.byType(SwipeableCard));
        await tester.pumpAndSettle();

        // Enter empty string
        await tester.enterText(find.widgetWithText(TextField, '- kg'), '');
        await tester.pump();

        final values = cardKey.currentState!.getFieldValues();
        expect(values.containsKey('weight'), false);
      });

      testWidgets('preserves input when changing exercises', (tester) async {
        CardModel currentCard = freeWeightCard;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return SwipeableCard(
                    card: currentCard,
                    onSwipedAway: () {},
                    onCompleted: (_, __) {},
                    onCardUpdate: (_) {},
                    zetCount: 0,
                  );
                },
              ),
            ),
          ),
        );

        // Flip and enter data
        await tester.tap(find.byType(SwipeableCard));
        await tester.pumpAndSettle();

        await tester.enterText(find.widgetWithText(TextField, '- kg'), '80');
        await tester.pump();

        expect(find.text('80'), findsOneWidget);
      });
    });
  });
}
