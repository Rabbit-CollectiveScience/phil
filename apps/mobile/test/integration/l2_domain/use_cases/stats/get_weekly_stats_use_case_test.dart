import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/use_cases/stats/get_weekly_stats_use_case.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/get_workout_sets_by_date_use_case.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/record_workout_set_use_case.dart';
import 'package:phil/l3_data/repositories/stub_workout_set_repository.dart';
import 'package:phil/l3_data/repositories/stub_exercise_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GetWeeklyStatsUseCase useCase;
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

    useCase = GetWeeklyStatsUseCase(getWorkoutSetsByDateUseCase, exerciseRepo);
  });

  tearDown(() {
    workoutSetRepo.clear();
  });

  group('GetWeeklyStatsUseCase - Attendance', () {
    test('returns zero stats when no workouts in the week', () async {
      // Act
      final result = await useCase.execute();

      // Assert
      expect(result['attendance']['daysTrained'], equals(0));
      expect(result['attendance']['avgSetsPerDay'], equals(0.0));
      expect(result['exerciseTypes'], isEmpty);
    });

    test('calculates days trained correctly for single day', () async {
      // Arrange
      final exercises = await exerciseRepo.getAllExercises();
      final benchPress = exercises.firstWhere(
        (e) => e.name.contains('Bench Press'),
      );

      // Record 3 sets today
      await recordUseCase.execute(
        exerciseId: benchPress.id,
        values: {'weight': 100, 'reps': 10},
      );
      await recordUseCase.execute(
        exerciseId: benchPress.id,
        values: {'weight': 100, 'reps': 8},
      );
      await recordUseCase.execute(
        exerciseId: benchPress.id,
        values: {'weight': 100, 'reps': 6},
      );

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result['attendance']['daysTrained'], equals(1));
      expect(result['attendance']['avgSetsPerDay'], equals(3.0));
    });

    test('calculates avg sets per day correctly for multiple days', () async {
      // Arrange
      final exercises = await exerciseRepo.getAllExercises();
      final benchPress = exercises.firstWhere(
        (e) => e.name.contains('Bench Press'),
      );
      final squat = exercises.firstWhere((e) => e.name.contains('Squat'));

      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      // Today: 3 sets
      await recordUseCase.execute(
        exerciseId: benchPress.id,
        values: {'weight': 100, 'reps': 10},
        completedAt: today,
      );
      await recordUseCase.execute(
        exerciseId: benchPress.id,
        values: {'weight': 100, 'reps': 8},
        completedAt: today,
      );
      await recordUseCase.execute(
        exerciseId: squat.id,
        values: {'weight': 150, 'reps': 5},
        completedAt: today,
      );

      // Yesterday: 2 sets
      await recordUseCase.execute(
        exerciseId: benchPress.id,
        values: {'weight': 100, 'reps': 10},
        completedAt: yesterday,
      );
      await recordUseCase.execute(
        exerciseId: squat.id,
        values: {'weight': 150, 'reps': 5},
        completedAt: yesterday,
      );

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result['attendance']['daysTrained'], equals(2));
      expect(
        result['attendance']['avgSetsPerDay'],
        equals(2.5),
      ); // 5 sets / 2 days
    });
  });

  group('GetWeeklyStatsUseCase - Exercise Types', () {
    test('groups strength exercises correctly', () async {
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
      final types = result['exerciseTypes'] as List<Map<String, dynamic>>;
      expect(types.length, greaterThanOrEqualTo(1));

      final strengthType = types.first;
      expect(strengthType['exercises'], equals(1));
      expect(strengthType['sets'], equals(2));
      expect(strengthType['volume'], equals(1800.0)); // (100*10) + (100*8)
      expect(strengthType['duration'], isNull);
    });

    test('calculates duration for cardio exercises', () async {
      // Arrange
      final exercises = await exerciseRepo.getAllExercises();
      final treadmill = exercises.firstWhere(
        (e) => e.name.contains('Treadmill'),
      );

      // 30 minutes = 1800 seconds
      await recordUseCase.execute(
        exerciseId: treadmill.id,
        values: {'durationInSeconds': 1800, 'speed': 10},
      );
      // 20 minutes = 1200 seconds
      await recordUseCase.execute(
        exerciseId: treadmill.id,
        values: {'durationInSeconds': 1200, 'speed': 12},
      );

      // Act
      final result = await useCase.execute();

      // Assert
      final types = result['exerciseTypes'] as List<Map<String, dynamic>>;
      final cardioType = types.firstWhere((t) => t['type'] == 'CARDIO');

      expect(cardioType['exercises'], equals(1));
      expect(cardioType['sets'], equals(2));
      expect(
        cardioType['duration'],
        equals(50.0),
      ); // 3000 seconds / 60 = 50 minutes
      expect(cardioType['volume'], equals(0.0));
    });

    test('handles multiple exercise types', () async {
      // Arrange
      final exercises = await exerciseRepo.getAllExercises();
      final benchPress = exercises.firstWhere(
        (e) => e.name.contains('Bench Press'),
      );
      final squat = exercises.firstWhere((e) => e.name.contains('Squat'));
      final treadmill = exercises.firstWhere(
        (e) => e.name.contains('Treadmill'),
      );

      await recordUseCase.execute(
        exerciseId: benchPress.id,
        values: {'weight': 100, 'reps': 10},
      );
      await recordUseCase.execute(
        exerciseId: squat.id,
        values: {'weight': 150, 'reps': 5},
      );
      await recordUseCase.execute(
        exerciseId: treadmill.id,
        values: {'durationInSeconds': 1800, 'speed': 10},
      );

      // Act
      final result = await useCase.execute();

      // Assert
      final types = result['exerciseTypes'] as List<Map<String, dynamic>>;
      expect(
        types.length,
        greaterThanOrEqualTo(2),
      ); // At least strength and cardio

      final cardioType = types.firstWhere((t) => t['type'] == 'CARDIO');
      expect(cardioType['exercises'], equals(1));
    });

    test('counts unique exercises per type', () async {
      // Arrange
      final exercises = await exerciseRepo.getAllExercises();
      final benchPress = exercises.firstWhere(
        (e) => e.name.contains('Bench Press'),
      );
      final squat = exercises.firstWhere((e) => e.name.contains('Squat'));

      // Record sets from same type (assuming they're same category)
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
      final types = result['exerciseTypes'] as List<Map<String, dynamic>>;

      // Should have exercises counted correctly
      final totalExercises = types.fold<int>(
        0,
        (sum, type) => sum + (type['exercises'] as int),
      );
      expect(totalExercises, greaterThanOrEqualTo(2));
    });
  });

  group('GetWeeklyStatsUseCase - Week Offset', () {
    test('can query previous week data', () async {
      // Arrange
      final exercises = await exerciseRepo.getAllExercises();
      final benchPress = exercises.firstWhere(
        (e) => e.name.contains('Bench Press'),
      );

      final lastWeek = DateTime.now().subtract(const Duration(days: 7));

      await recordUseCase.execute(
        exerciseId: benchPress.id,
        values: {'weight': 100, 'reps': 10},
        completedAt: lastWeek,
      );

      // Act - query last week (weekOffset: -1)
      final result = await useCase.execute(weekOffset: -1);

      // Assert
      expect(result['attendance']['daysTrained'], equals(1));
    });

    test('current week (offset 0) does not include last week data', () async {
      // Arrange
      final exercises = await exerciseRepo.getAllExercises();
      final benchPress = exercises.firstWhere(
        (e) => e.name.contains('Bench Press'),
      );

      final lastWeek = DateTime.now().subtract(const Duration(days: 8));

      await recordUseCase.execute(
        exerciseId: benchPress.id,
        values: {'weight': 100, 'reps': 10},
        completedAt: lastWeek,
      );

      // Act - query this week
      final result = await useCase.execute();

      // Assert
      expect(result['attendance']['daysTrained'], equals(0));
    });
  });
}
