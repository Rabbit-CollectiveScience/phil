import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/use_cases/stats/get_today_stats_overview_use_case.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/get_workout_sets_by_date_use_case.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/record_workout_set_use_case.dart';
import 'package:phil/l3_data/repositories/stub_workout_set_repository.dart';
import 'package:phil/l3_data/repositories/stub_exercise_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GetTodayStatsOverviewUseCase useCase;
  late StubWorkoutSetRepository workoutSetRepo;
  late StubExerciseRepository exerciseRepo;
  late RecordWorkoutSetUseCase recordUseCase;

  setUp(() {
    workoutSetRepo = StubWorkoutSetRepository();
    exerciseRepo = StubExerciseRepository();

    final getWorkoutSetsByDateUseCase = GetWorkoutSetsByDateUseCase(
      workoutSetRepo,
      exerciseRepo,
    );

    recordUseCase = RecordWorkoutSetUseCase(workoutSetRepo);

    useCase = GetTodayStatsOverviewUseCase(
      getWorkoutSetsByDateUseCase,
      exerciseRepo,
    );
  });

  tearDown(() {
    workoutSetRepo.clear();
  });

  group('GetTodayStatsOverviewUseCase', () {
    test('returns zero stats when no workout sets today', () async {
      // Act
      final result = await useCase.execute();

      // Assert
      expect(result['setsCount'], equals(0));
      expect(result['exercisesCount'], equals(0));
      expect(result['totalVolume'], equals(0.0));
      expect(result['exerciseTypes'], isEmpty);
    });

    test(
      'returns correct stats for single exercise with multiple sets',
      () async {
        // Arrange
        final exercises = await exerciseRepo.getAllExercises();
        final benchPress = exercises.firstWhere(
          (e) => e.name.contains('Bench Press'),
        );

        await recordUseCase.execute(
          exerciseId: benchPress.id,
          values: {'weight': 100, 'reps': 10},
        );
        await recordUseCase.execute(
          exerciseId: benchPress.id,
          values: {'weight': 100, 'reps': 8},
        );

        // Act
        final result = await useCase.execute();

        // Assert
        expect(result['setsCount'], equals(2));
        expect(result['exercisesCount'], equals(1));
        expect(result['totalVolume'], equals(1800.0)); // (100*10) + (100*8)
        expect(result['exerciseTypes'], isNotEmpty);
      },
    );

    test('returns correct stats for multiple exercises', () async {
      // Arrange
      final exercises = await exerciseRepo.getAllExercises();
      final benchPress = exercises.firstWhere(
        (e) => e.name.contains('Bench Press'),
      );
      final squat = exercises.firstWhere((e) => e.name.contains('Squat'));

      await recordUseCase.execute(
        exerciseId: benchPress.id,
        values: {'weight': 100, 'reps': 10},
      );
      await recordUseCase.execute(
        exerciseId: squat.id,
        values: {'weight': 150, 'reps': 5},
      );

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result['setsCount'], equals(2));
      expect(result['exercisesCount'], equals(2));
      expect(result['totalVolume'], equals(1750.0)); // (100*10) + (150*5)
      expect(result['exerciseTypes'], isNotEmpty);
    });

    test('handles exercises with only reps (no weight)', () async {
      // Arrange
      final exercises = await exerciseRepo.getAllExercises();
      final pushup = exercises.firstWhere(
        (e) => e.name.contains('Push') && e.name.contains('Up'),
      );

      await recordUseCase.execute(exerciseId: pushup.id, values: {'reps': 20});

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result['setsCount'], equals(1));
      expect(result['exercisesCount'], equals(1));
      expect(result['totalVolume'], equals(20.0)); // Priority 2: reps only
    });

    test('handles sets with null or missing values', () async {
      // Arrange
      final exercises = await exerciseRepo.getAllExercises();
      final firstExercise = exercises.first;

      await recordUseCase.execute(exerciseId: firstExercise.id, values: null);
      await recordUseCase.execute(exerciseId: firstExercise.id, values: {});

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result['setsCount'], equals(2));
      expect(result['exercisesCount'], equals(1));
      expect(result['totalVolume'], equals(0.0));
    });
  });
}
