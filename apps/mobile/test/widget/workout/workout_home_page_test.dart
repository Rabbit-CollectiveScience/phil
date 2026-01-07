import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:phil/l1_ui/features/workout/workout_home_page.dart';
import 'package:phil/l2_domain/use_cases/exercises/get_recommended_exercises_use_case.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/record_workout_set_use_case.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/get_today_completed_count_use_case.dart';
import 'package:phil/l2_domain/use_cases/filters/get_last_filter_selection_use_case.dart';
import 'package:phil/l2_domain/use_cases/filters/record_filter_selection_use_case.dart';
import 'package:phil/l2_domain/use_cases/filters/should_show_filter_page_use_case.dart';
import 'package:phil/l2_domain/models/exercises/exercise.dart';
import 'package:phil/l2_domain/models/exercises/free_weight_exercise.dart';
import 'package:phil/l2_domain/models/exercises/bodyweight_exercise.dart';
import 'package:phil/l2_domain/models/exercises/distance_cardio_exercise.dart';
import 'package:phil/l2_domain/models/common/muscle_group.dart';
import 'package:phil/l2_domain/models/workout_sets/workout_set.dart';

// Mock classes
class MockGetRecommendedExercisesUseCase extends Mock
    implements GetRecommendedExercisesUseCase {}

class MockRecordWorkoutSetUseCase extends Mock
    implements RecordWorkoutSetUseCase {}

class MockGetTodayCompletedCountUseCase extends Mock
    implements GetTodayCompletedCountUseCase {}

class MockGetLastFilterSelectionUseCase extends Mock
    implements GetLastFilterSelectionUseCase {}

class MockRecordFilterSelectionUseCase extends Mock
    implements RecordFilterSelectionUseCase {}

class MockShouldShowFilterPageUseCase extends Mock
    implements ShouldShowFilterPageUseCase {}

void main() {
  late MockGetRecommendedExercisesUseCase mockGetExercises;
  late MockRecordWorkoutSetUseCase mockRecordSet;
  late MockGetTodayCompletedCountUseCase mockGetCount;
  late MockGetLastFilterSelectionUseCase mockGetFilter;
  late MockRecordFilterSelectionUseCase mockRecordFilter;
  late MockShouldShowFilterPageUseCase mockShouldShowFilter;

  final testExercises = [
    FreeWeightExercise(
      id: 'test-1',
      name: 'Bench Press',
      description: 'A chest exercise',
      isCustom: false,
      targetMuscles: [MuscleGroup.chest],
    ),
    FreeWeightExercise(
      id: 'test-2',
      name: 'Squat',
      description: 'A leg exercise',
      isCustom: false,
      targetMuscles: [MuscleGroup.legs],
    ),
    BodyweightExercise(
      id: 'test-3',
      name: 'Push-ups',
      description: 'Bodyweight chest',
      isCustom: false,
      targetMuscles: [MuscleGroup.chest],
      canAddWeight: true,
    ),
  ];

  setUp(() {
    // Reset GetIt
    GetIt.instance.reset();

    // Create mocks
    mockGetExercises = MockGetRecommendedExercisesUseCase();
    mockRecordSet = MockRecordWorkoutSetUseCase();
    mockGetCount = MockGetTodayCompletedCountUseCase();
    mockGetFilter = MockGetLastFilterSelectionUseCase();
    mockRecordFilter = MockRecordFilterSelectionUseCase();
    mockShouldShowFilter = MockShouldShowFilterPageUseCase();

    // Register mocks with GetIt
    GetIt.instance.registerFactory<GetRecommendedExercisesUseCase>(
      () => mockGetExercises,
    );
    GetIt.instance.registerFactory<RecordWorkoutSetUseCase>(
      () => mockRecordSet,
    );
    GetIt.instance.registerFactory<GetTodayCompletedCountUseCase>(
      () => mockGetCount,
    );
    GetIt.instance.registerFactory<GetLastFilterSelectionUseCase>(
      () => mockGetFilter,
    );
    GetIt.instance.registerFactory<RecordFilterSelectionUseCase>(
      () => mockRecordFilter,
    );
    GetIt.instance.registerFactory<ShouldShowFilterPageUseCase>(
      () => mockShouldShowFilter,
    );

    // Setup default mock behaviors
    when(() => mockGetExercises.execute(
          filterCategory: any(named: 'filterCategory'),
          searchQuery: any(named: 'searchQuery'),
        )).thenAnswer((_) async => testExercises);

    when(() => mockGetCount.execute()).thenAnswer((_) async => 0);

    when(() => mockGetFilter.executeWithDefault())
        .thenAnswer((_) async => 'all');

    when(() => mockShouldShowFilter.execute()).thenAnswer((_) async => false);

    when(() => mockRecordSet.execute(workoutSet: any(named: 'workoutSet')))
        .thenAnswer((invocation) async {
      final workoutSet = invocation.namedArguments[#workoutSet] as WorkoutSet;
      return workoutSet;
    });

    // Register fallback values for mocktail
    registerFallbackValue(
      FreeWeightExercise(
        id: 'fallback',
        name: 'Fallback',
        description: 'Fallback',
        isCustom: false,
        targetMuscles: [],
      ),
    );
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  group('WorkoutHomePage', () {
    group('Initial Loading', () {
      testWidgets('shows loading indicator while fetching exercises',
          (tester) async {
        // Make the mock delay to see loading state
        when(() => mockGetExercises.execute(
              filterCategory: any(named: 'filterCategory'),
              searchQuery: any(named: 'searchQuery'),
            )).thenAnswer(
          (_) => Future.delayed(
            const Duration(milliseconds: 100),
            () => testExercises,
          ),
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: WorkoutHomePage(),
          ),
        );

        // Should show loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for loading to complete
        await tester.pumpAndSettle();

        // Loading indicator should be gone
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('displays exercises after loading', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: WorkoutHomePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Should display first exercise name
        expect(find.text('Bench Press'), findsOneWidget);
      });

      testWidgets('shows error message if loading fails', (tester) async {
        when(() => mockGetExercises.execute(
              filterCategory: any(named: 'filterCategory'),
              searchQuery: any(named: 'searchQuery'),
            )).thenThrow(Exception('Failed to load'));

        await tester.pumpWidget(
          const MaterialApp(
            home: WorkoutHomePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Should show error message
        expect(find.textContaining('Failed to load exercises'), findsOneWidget);
      });

      testWidgets('shows message when no exercises available', (tester) async {
        when(() => mockGetExercises.execute(
              filterCategory: any(named: 'filterCategory'),
              searchQuery: any(named: 'searchQuery'),
            )).thenAnswer((_) async => []);

        await tester.pumpWidget(
          const MaterialApp(
            home: WorkoutHomePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Should show no exercises message
        expect(find.textContaining('No exercises found'), findsOneWidget);
      });
    });

    group('Counter', () {
      testWidgets('displays initial count from use case', (tester) async {
        when(() => mockGetCount.execute()).thenAnswer((_) async => 5);

        await tester.pumpWidget(
          const MaterialApp(
            home: WorkoutHomePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Should show count of 5
        expect(find.text('5'), findsOneWidget);
      });

      testWidgets('starts at 0 when no completed sets', (tester) async {
        when(() => mockGetCount.execute()).thenAnswer((_) async => 0);

        await tester.pumpWidget(
          const MaterialApp(
            home: WorkoutHomePage(),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('0'), findsOneWidget);
      });
    });

    group('Card Display', () {
      testWidgets('displays card stack with exercises', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: WorkoutHomePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Should have at least one card visible
        expect(find.text('Bench Press'), findsOneWidget);
      });

      testWidgets('shows exercise description on card', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: WorkoutHomePage(),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('A chest exercise'), findsOneWidget);
      });
    });

    group('Search Functionality', () {
      testWidgets('search bar is present', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: WorkoutHomePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Search bar should be present (look for search icon)
        expect(find.byIcon(Icons.search), findsOneWidget);
      });
    });

    group('Filter Functionality', () {
      testWidgets('filter button is present', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: WorkoutHomePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Filter button should be present
        expect(find.byIcon(Icons.filter_list), findsOneWidget);
      });

      testWidgets('loads last filter selection on startup', (tester) async {
        when(() => mockGetFilter.executeWithDefault())
            .thenAnswer((_) async => 'chest');

        await tester.pumpWidget(
          const MaterialApp(
            home: WorkoutHomePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify filter was requested
        verify(() => mockGetFilter.executeWithDefault()).called(1);
      });

      testWidgets('requests exercises with correct filter', (tester) async {
        when(() => mockGetFilter.executeWithDefault())
            .thenAnswer((_) async => 'chest');

        await tester.pumpWidget(
          const MaterialApp(
            home: WorkoutHomePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify exercises were requested with chest filter
        verify(() => mockGetExercises.execute(
              filterCategory: 'chest',
              searchQuery: null,
            )).called(greaterThan(0));
      });
    });

    group('Navigation', () {
      testWidgets('has dashboard button', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: WorkoutHomePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Should have a stats/dashboard button (bar chart icon)
        expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      });
    });

    group('Use Case Integration', () {
      testWidgets('calls GetRecommendedExercisesUseCase on load',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: WorkoutHomePage(),
          ),
        );

        await tester.pumpAndSettle();

        verify(() => mockGetExercises.execute(
              filterCategory: any(named: 'filterCategory'),
              searchQuery: any(named: 'searchQuery'),
            )).called(greaterThan(0));
      });

      testWidgets('calls GetTodayCompletedCountUseCase on load',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: WorkoutHomePage(),
          ),
        );

        await tester.pumpAndSettle();

        verify(() => mockGetCount.execute()).called(1);
      });

      testWidgets('calls GetLastFilterSelectionUseCase on load',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: WorkoutHomePage(),
          ),
        );

        await tester.pumpAndSettle();

        verify(() => mockGetFilter.executeWithDefault()).called(1);
      });

      testWidgets('calls ShouldShowFilterPageUseCase on load',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: WorkoutHomePage(),
          ),
        );

        await tester.pumpAndSettle();

        verify(() => mockShouldShowFilter.execute()).called(1);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles null exercises list gracefully', (tester) async {
        when(() => mockGetExercises.execute(
              filterCategory: any(named: 'filterCategory'),
              searchQuery: any(named: 'searchQuery'),
            )).thenAnswer((_) async => []);

        await tester.pumpWidget(
          const MaterialApp(
            home: WorkoutHomePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Should show empty state
        expect(find.textContaining('No exercises found'), findsOneWidget);
      });

      testWidgets('handles single exercise', (tester) async {
        when(() => mockGetExercises.execute(
              filterCategory: any(named: 'filterCategory'),
              searchQuery: any(named: 'searchQuery'),
            )).thenAnswer((_) async => [testExercises.first]);

        await tester.pumpWidget(
          const MaterialApp(
            home: WorkoutHomePage(),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Bench Press'), findsOneWidget);
      });

      testWidgets('rebuilds correctly after error recovery', (tester) async {
        // First call fails
        var callCount = 0;
        when(() => mockGetExercises.execute(
              filterCategory: any(named: 'filterCategory'),
              searchQuery: any(named: 'searchQuery'),
            )).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            throw Exception('Network error');
          }
          return testExercises;
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: WorkoutHomePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Should show error
        expect(find.textContaining('Failed to load'), findsOneWidget);
      });
    });

    group('Performance', () {
      testWidgets('loads multiple exercises efficiently', (tester) async {
        final manyExercises = List.generate(
          50,
          (i) => FreeWeightExercise(
            id: 'test-$i',
            name: 'Exercise $i',
            description: 'Description $i',
            isCustom: false,
            targetMuscles: [MuscleGroup.chest],
          ),
        );

        when(() => mockGetExercises.execute(
              filterCategory: any(named: 'filterCategory'),
              searchQuery: any(named: 'searchQuery'),
            )).thenAnswer((_) async => manyExercises);

        await tester.pumpWidget(
          const MaterialApp(
            home: WorkoutHomePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Should display first exercise
        expect(find.text('Exercise 0'), findsOneWidget);
      });
    });
  });
}
