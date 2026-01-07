import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:phil/l1_ui/features/workout/completed_list_page.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/get_today_completed_list_use_case.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/remove_workout_set_use_case.dart';
import 'package:phil/l2_domain/models/exercises/free_weight_exercise.dart';
import 'package:phil/l2_domain/models/exercises/bodyweight_exercise.dart';
import 'package:phil/l2_domain/models/exercises/distance_cardio_exercise.dart';
import 'package:phil/l2_domain/models/workout_sets/weighted_workout_set.dart';
import 'package:phil/l2_domain/models/workout_sets/bodyweight_workout_set.dart';
import 'package:phil/l2_domain/models/workout_sets/distance_cardio_workout_set.dart';
import 'package:phil/l2_domain/models/common/weight.dart';
import 'package:phil/l2_domain/models/common/distance.dart';
import 'package:phil/l2_domain/models/common/muscle_group.dart';

// Mock classes
class MockGetTodayCompletedListUseCase extends Mock
    implements GetTodayCompletedListUseCase {}

class MockRemoveWorkoutSetUseCase extends Mock
    implements RemoveWorkoutSetUseCase {}

void main() {
  late MockGetTodayCompletedListUseCase mockGetCompleted;
  late MockRemoveWorkoutSetUseCase mockRemoveSet;

  final testExercise = FreeWeightExercise(
    id: 'ex-1',
    name: 'Bench Press',
    description: 'Chest exercise',
    isCustom: false,
    targetMuscles: [MuscleGroup.chest],
  );

  final testBodyweightExercise = BodyweightExercise(
    id: 'ex-2',
    name: 'Push-ups',
    description: 'Bodyweight exercise',
    isCustom: false,
    targetMuscles: [MuscleGroup.chest],
    canAddWeight: true,
  );

  final testCardioExercise = DistanceCardioExercise(
    id: 'ex-3',
    name: 'Running',
    description: 'Cardio exercise',
    isCustom: false,
  );

  final testWorkoutSets = [
    WorkoutSetWithDetails(
      workoutSet: WeightedWorkoutSet(
        id: 'set-1',
        exerciseId: 'ex-1',
        timestamp: DateTime.now(),
        weight: Weight(80),
        reps: 10,
      ),
      exerciseName: testExercise.name,
      exercise: testExercise,
    ),
    WorkoutSetWithDetails(
      workoutSet: WeightedWorkoutSet(
        id: 'set-2',
        exerciseId: 'ex-1',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        weight: Weight(75),
        reps: 12,
      ),
      exerciseName: testExercise.name,
      exercise: testExercise,
    ),
  ];

  setUp(() {
    GetIt.instance.reset();

    mockGetCompleted = MockGetTodayCompletedListUseCase();
    mockRemoveSet = MockRemoveWorkoutSetUseCase();

    GetIt.instance.registerFactory<GetTodayCompletedListUseCase>(
      () => mockGetCompleted,
    );
    GetIt.instance.registerFactory<RemoveWorkoutSetUseCase>(
      () => mockRemoveSet,
    );

    // Default mock behaviors
    when(() => mockGetCompleted.execute())
        .thenAnswer((_) async => testWorkoutSets);

    when(() => mockRemoveSet.execute(any()))
        .thenAnswer((_) async {});
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  group('CompletedListPage', () {
    group('Display', () {
      testWidgets('shows completed workout sets', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: CompletedListPage(),
          ),
        );

        await tester.pumpAndSettle();

        // Should show exercise name
        expect(find.text('Bench Press'), findsWidgets);
        // Should show formatted weight × reps
        expect(find.textContaining('80.0 kg × 10'), findsOneWidget);
      });

      testWidgets('displays multiple sets for same exercise', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: CompletedListPage(),
          ),
        );

        await tester.pumpAndSettle();

        // Should show both sets
        expect(find.textContaining('80.0 kg × 10'), findsOneWidget);
        expect(find.textContaining('75.0 kg × 12'), findsOneWidget);
      });

      testWidgets('formats WeightedWorkoutSet correctly', (tester) async {
        when(() => mockGetCompleted.execute()).thenAnswer(
          (_) async => [
            WorkoutSetWithDetails(
              workoutSet: WeightedWorkoutSet(
                id: 'set-1',
                exerciseId: 'ex-1',
                timestamp: DateTime.now(),
                weight: Weight(100),
                reps: 5,
              ),
              exerciseName: testExercise.name,
              exercise: testExercise,
            ),
          ],
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: CompletedListPage(),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.textContaining('100.0 kg × 5'), findsOneWidget);
      });

      testWidgets('formats BodyweightWorkoutSet correctly', (tester) async {
        when(() => mockGetCompleted.execute()).thenAnswer(
          (_) async => [
            WorkoutSetWithDetails(
              workoutSet: BodyweightWorkoutSet(
                id: 'set-1',
                exerciseId: 'ex-2',
                timestamp: DateTime.now(),
                reps: 20,
                additionalWeight: null,
              ),
              exerciseName: testBodyweightExercise.name,
              exercise: testBodyweightExercise,
            ),
          ],
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: CompletedListPage(),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.textContaining('20 reps'), findsOneWidget);
      });

      testWidgets('formats BodyweightWorkoutSet with additional weight',
          (tester) async {
        when(() => mockGetCompleted.execute()).thenAnswer(
          (_) async => [
            WorkoutSetWithDetails(
              workoutSet: BodyweightWorkoutSet(
                id: 'set-1',
                exerciseId: 'ex-2',
                timestamp: DateTime.now(),
                reps: 15,
                additionalWeight: Weight(10),
              ),
              exerciseName: testBodyweightExercise.name,
              exercise: testBodyweightExercise,
            ),
          ],
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: CompletedListPage(),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.textContaining('15 reps (+10.0 kg)'), findsOneWidget);
      });

      testWidgets('formats DistanceCardioWorkoutSet correctly',
          (tester) async {
        when(() => mockGetCompleted.execute()).thenAnswer(
          (_) async => [
            WorkoutSetWithDetails(
              workoutSet: DistanceCardioWorkoutSet(
                id: 'set-1',
                exerciseId: 'ex-3',
                timestamp: DateTime.now(),
                distance: Distance(5000), // 5 km
                duration: const Duration(minutes: 30),
              ),
              exerciseName: testCardioExercise.name,
              exercise: testCardioExercise,
            ),
          ],
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: CompletedListPage(),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.textContaining('5.0 km'), findsOneWidget);
        expect(find.textContaining('30 min'), findsOneWidget);
      });

      testWidgets('shows date header', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: CompletedListPage(),
          ),
        );

        await tester.pumpAndSettle();

        // Should show "Today" as date header
        expect(find.textContaining('Today'), findsOneWidget);
      });

      testWidgets('groups sets by date', (tester) async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));

        when(() => mockGetCompleted.execute()).thenAnswer(
          (_) async => [
            WorkoutSetWithDetails(
              workoutSet: WeightedWorkoutSet(
                id: 'set-1',
                exerciseId: 'ex-1',
                timestamp: DateTime.now(),
                weight: Weight(80),
                reps: 10,
              ),
              exerciseName: testExercise.name,
              exercise: testExercise,
            ),
            WorkoutSetWithDetails(
              workoutSet: WeightedWorkoutSet(
                id: 'set-2',
                exerciseId: 'ex-1',
                timestamp: yesterday,
                weight: Weight(75),
                reps: 12,
              ),
              exerciseName: testExercise.name,
              exercise: testExercise,
            ),
          ],
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: CompletedListPage(),
          ),
        );

        await tester.pumpAndSettle();

        // Should show both date headers
        expect(find.textContaining('Today'), findsOneWidget);
        expect(find.textContaining('Yesterday'), findsOneWidget);
      });
    });

    group('Empty State', () {
      testWidgets('shows empty state when no workouts', (tester) async {
        when(() => mockGetCompleted.execute()).thenAnswer((_) async => []);

        await tester.pumpWidget(
          const MaterialApp(
            home: CompletedListPage(),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.textContaining('No completed workouts'), findsOneWidget);
      });

      testWidgets('shows appropriate icon for empty state', (tester) async {
        when(() => mockGetCompleted.execute()).thenAnswer((_) async => []);

        await tester.pumpWidget(
          const MaterialApp(
            home: CompletedListPage(),
          ),
        );

        await tester.pumpAndSettle();

        // Should show some icon (like emoji or fitness icon)
        expect(find.byType(Icon), findsOneWidget);
      });
    });

    group('Loading State', () {
      testWidgets('shows loading indicator while fetching', (tester) async {
        when(() => mockGetCompleted.execute()).thenAnswer(
          (_) => Future.delayed(
            const Duration(milliseconds: 100),
            () => testWorkoutSets,
          ),
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: CompletedListPage(),
          ),
        );

        // Should show loading
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle();

        // Loading should be gone
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });

    group('Error Handling', () {
      testWidgets('shows error message on load failure', (tester) async {
        when(() => mockGetCompleted.execute())
            .thenThrow(Exception('Failed to load'));

        await tester.pumpWidget(
          const MaterialApp(
            home: CompletedListPage(),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.textContaining('Failed'), findsOneWidget);
      });
    });

    group('Use Case Integration', () {
      testWidgets('calls GetTodayCompletedListUseCase on load',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: CompletedListPage(),
          ),
        );

        await tester.pumpAndSettle();

        verify(() => mockGetCompleted.execute()).called(1);
      });
    });

    group('Navigation', () {
      testWidgets('has back button', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: CompletedListPage(),
          ),
        );

        await tester.pumpAndSettle();

        // Should have back button
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });

      testWidgets('back button pops navigation', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CompletedListPage(),
                        ),
                      );
                    },
                    child: const Text('Go'),
                  );
                },
              ),
            ),
          ),
        );

        // Navigate to completed list
        await tester.tap(find.text('Go'));
        await tester.pumpAndSettle();

        expect(find.byType(CompletedListPage), findsOneWidget);

        // Tap back
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        expect(find.byType(CompletedListPage), findsNothing);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles single workout set', (tester) async {
        when(() => mockGetCompleted.execute()).thenAnswer(
          (_) async => [testWorkoutSets.first],
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: CompletedListPage(),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.textContaining('80.0 kg × 10'), findsOneWidget);
      });

      testWidgets('handles many workout sets', (tester) async {
        final manySets = List.generate(
          50,
          (i) => WorkoutSetWithDetails(
            workoutSet: WeightedWorkoutSet(
              id: 'set-$i',
              exerciseId: 'ex-1',
              timestamp: DateTime.now().subtract(Duration(minutes: i)),
              weight: Weight(80.0 + i),
              reps: 10,
            ),
            exerciseName: testExercise.name,
            exercise: testExercise,
          ),
        );

        when(() => mockGetCompleted.execute()).thenAnswer((_) async => manySets);

        await tester.pumpWidget(
          const MaterialApp(
            home: CompletedListPage(),
          ),
        );

        await tester.pumpAndSettle();

        // Should render without error
        expect(find.text('Bench Press'), findsWidgets);
      });
    });
  });
}
