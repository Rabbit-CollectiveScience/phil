import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:phil/l2_domain/use_cases/stats/get_today_stats_overview_use_case.dart';
import 'package:phil/l2_domain/use_cases/stats/get_today_exercise_details_use_case.dart';
import 'package:phil/l2_domain/use_cases/stats/get_weekly_stats_use_case.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/get_workout_sets_by_date_use_case.dart';
import 'package:phil/l3_data/repositories/workout_set_repository.dart';
import 'package:phil/l3_data/repositories/exercise_repository.dart';
import 'package:phil/l3_data/repositories/personal_record_repository.dart';
import 'package:phil/l2_domain/models/workout_sets/weighted_workout_set.dart';
import 'package:phil/l2_domain/models/workout_sets/bodyweight_workout_set.dart';
import 'package:phil/l2_domain/models/common/weight.dart';
import 'package:phil/l2_domain/models/exercises/free_weight_exercise.dart';
import 'package:phil/l2_domain/models/exercises/bodyweight_exercise.dart';
import 'package:phil/l2_domain/models/common/muscle_group.dart';

void main() {
  late WorkoutSetRepository workoutSetRepository;
  late ExerciseRepository exerciseRepository;
  late PersonalRecordRepository prRepository;
  late GetWorkoutSetsByDateUseCase getWorkoutSetsByDateUseCase;

  setUp(() async {
    await Hive.initFlutter();

    await Hive.openBox<Map>('workout_sets');
    await Hive.openBox<Map>('exercises');
    await Hive.openBox<Map>('personal_records');

    workoutSetRepository = WorkoutSetRepository();
    exerciseRepository = ExerciseRepository();
    prRepository = PersonalRecordRepository();

    getWorkoutSetsByDateUseCase = GetWorkoutSetsByDateUseCase(
      workoutSetRepository,
      exerciseRepository,
    );

    await workoutSetRepository.deleteAll();
    await exerciseRepository.deleteAll();
    await prRepository.deleteAll();
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk('workout_sets');
    await Hive.deleteBoxFromDisk('exercises');
    await Hive.deleteBoxFromDisk('personal_records');
    await Hive.close();
  });

  group('GetTodayStatsOverviewUseCase Integration Tests', () {
    test('returns zero stats when no workouts exist', () async {
      final useCase = GetTodayStatsOverviewUseCase(
        getWorkoutSetsByDateUseCase,
        exerciseRepository,
      );

      final result = await useCase.execute(date: DateTime.now());

      expect(result['setsCount'], 0);
      expect(result['exercisesCount'], 0);
      expect(result['totalVolume'], 0.0);
      expect(result['avgReps'], 0.0);
      expect(result['exerciseTypes'], isEmpty);
    });

    test('counts total sets for a given date', () async {
      final today = DateTime.now();

      final benchExercise = FreeWeightExercise(
        description: 'Test exercise',
        isCustom: false,
        id: 'bench',
        name: 'Bench Press',
        targetMuscles: [MuscleGroup.chest],
      );
      await exerciseRepository.save(benchExercise);

      await workoutSetRepository.save(
        WeightedWorkoutSet(
          id: 'set1',
          exerciseId: 'bench',
          timestamp: today,
          weight: Weight(100.0),
          reps: 10,
        ),
      );

      await workoutSetRepository.save(
        WeightedWorkoutSet(
          id: 'set2',
          exerciseId: 'bench',
          timestamp: today,
          weight: Weight(100.0),
          reps: 10,
        ),
      );

      final useCase = GetTodayStatsOverviewUseCase(
        getWorkoutSetsByDateUseCase,
        exerciseRepository,
      );

      final result = await useCase.execute(date: today);

      expect(result['setsCount'], 2);
    });

    test('counts unique exercises', () async {
      final today = DateTime.now();

      final benchExercise = FreeWeightExercise(
        id: 'bench',
        name: 'Bench Press',
        description: 'Test exercise',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
      );
      final squatExercise = FreeWeightExercise(
        id: 'squat',
        name: 'Squat',
        description: 'Leg exercise',
        isCustom: false,
        targetMuscles: [MuscleGroup.legs],
      );
      await exerciseRepository.save(benchExercise);
      await exerciseRepository.save(squatExercise);

      await workoutSetRepository.save(
        WeightedWorkoutSet(
          id: 'set1',
          exerciseId: 'bench',
          timestamp: today,
          weight: Weight(100.0),
          reps: 10,
        ),
      );

      await workoutSetRepository.save(
        WeightedWorkoutSet(
          id: 'set2',
          exerciseId: 'squat',
          timestamp: today,
          weight: Weight(150.0),
          reps: 8,
        ),
      );

      await workoutSetRepository.save(
        WeightedWorkoutSet(
          id: 'set3',
          exerciseId: 'bench',
          timestamp: today,
          weight: Weight(100.0),
          reps: 10,
        ),
      );

      final useCase = GetTodayStatsOverviewUseCase(
        getWorkoutSetsByDateUseCase,
        exerciseRepository,
      );

      final result = await useCase.execute(date: today);

      expect(result['exercisesCount'], 2); // bench and squat
    });

    test('calculates total volume', () async {
      final today = DateTime.now();

      final benchExercise = FreeWeightExercise(
        description: 'Test exercise',
        isCustom: false,
        id: 'bench',
        name: 'Bench Press',
        targetMuscles: [MuscleGroup.chest],
      );
      await exerciseRepository.save(benchExercise);

      await workoutSetRepository.save(
        WeightedWorkoutSet(
          id: 'set1',
          exerciseId: 'bench',
          timestamp: today,
          weight: Weight(100.0),
          reps: 10,
        ),
      );

      await workoutSetRepository.save(
        WeightedWorkoutSet(
          id: 'set2',
          exerciseId: 'bench',
          timestamp: today,
          weight: Weight(100.0),
          reps: 8,
        ),
      );

      final useCase = GetTodayStatsOverviewUseCase(
        getWorkoutSetsByDateUseCase,
        exerciseRepository,
      );

      final result = await useCase.execute(date: today);

      // Volume = (100 * 10) + (100 * 8) = 1800
      expect(result['totalVolume'], 1800.0);
    });

    test('calculates average reps', () async {
      final today = DateTime.now();

      final benchExercise = FreeWeightExercise(
        id: 'bench',
        name: 'Bench Press',
        description: 'Test exercise',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
      );
      final pullupExercise = BodyweightExercise(
        id: 'pullup',
        name: 'Pull-up',
        description: 'Back exercise',
        isCustom: false,
        targetMuscles: [MuscleGroup.back],
        canAddWeight: true,
      );
      await exerciseRepository.save(benchExercise);
      await exerciseRepository.save(pullupExercise);

      await workoutSetRepository.save(
        WeightedWorkoutSet(
          id: 'set1',
          exerciseId: 'bench',
          timestamp: today,
          weight: Weight(100.0),
          reps: 10,
        ),
      );

      await workoutSetRepository.save(
        BodyweightWorkoutSet(
          id: 'set2',
          exerciseId: 'pullup',
          timestamp: today,
          reps: 8,
        ),
      );

      final useCase = GetTodayStatsOverviewUseCase(
        getWorkoutSetsByDateUseCase,
        exerciseRepository,
      );

      final result = await useCase.execute(date: today);

      // Avg = (10 + 8) / 2 = 9.0
      expect(result['avgReps'], 9.0);
    });
  });

  group('GetTodayExerciseDetailsUseCase Integration Tests', () {
    test('returns empty list when no workouts exist', () async {
      final useCase = GetTodayExerciseDetailsUseCase(
        getWorkoutSetsByDateUseCase,
        prRepository: prRepository,
      );

      final result = await useCase.execute(date: DateTime.now());

      expect(result, isEmpty);
    });

    test('returns exercise details with set count', () async {
      final today = DateTime.now();

      final benchExercise = FreeWeightExercise(
        description: 'Test exercise',
        isCustom: false,
        id: 'bench',
        name: 'Bench Press',
        targetMuscles: [MuscleGroup.chest],
      );
      await exerciseRepository.save(benchExercise);

      await workoutSetRepository.save(
        WeightedWorkoutSet(
          id: 'set1',
          exerciseId: 'bench',
          timestamp: today,
          weight: Weight(100.0),
          reps: 10,
        ),
      );

      await workoutSetRepository.save(
        WeightedWorkoutSet(
          id: 'set2',
          exerciseId: 'bench',
          timestamp: today,
          weight: Weight(105.0),
          reps: 8,
        ),
      );

      final useCase = GetTodayExerciseDetailsUseCase(
        getWorkoutSetsByDateUseCase,
        prRepository: prRepository,
      );

      final result = await useCase.execute(date: today);

      expect(result.length, 1);
      expect(result[0]['exerciseName'], 'Bench Press');
      expect(result[0]['setCount'], 2);
    });
  });

  group('GetWeeklyStatsUseCase Integration Tests', () {
    test('returns zero attendance when no workouts exist', () async {
      final useCase = GetWeeklyStatsUseCase(
        getWorkoutSetsByDateUseCase,
        exerciseRepository,
      );

      final result = await useCase.execute(weekOffset: 0);

      expect(result['attendance']['daysTrained'], 0);
      expect(result['attendance']['avgSetsPerDay'], 0.0);
      expect(result['exerciseTypes'], isEmpty);
    });

    test('calculates attendance for current week', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(Duration(days: 1));

      final benchExercise = FreeWeightExercise(
        description: 'Test exercise',
        isCustom: false,
        id: 'bench',
        name: 'Bench Press',
        targetMuscles: [MuscleGroup.chest],
      );
      await exerciseRepository.save(benchExercise);

      // Add sets for today
      await workoutSetRepository.save(
        WeightedWorkoutSet(
          id: 'set1',
          exerciseId: 'bench',
          timestamp: today,
          weight: Weight(100.0),
          reps: 10,
        ),
      );

      await workoutSetRepository.save(
        WeightedWorkoutSet(
          id: 'set2',
          exerciseId: 'bench',
          timestamp: today,
          weight: Weight(100.0),
          reps: 10,
        ),
      );

      // Add sets for yesterday
      await workoutSetRepository.save(
        WeightedWorkoutSet(
          id: 'set3',
          exerciseId: 'bench',
          timestamp: yesterday,
          weight: Weight(100.0),
          reps: 10,
        ),
      );

      final useCase = GetWeeklyStatsUseCase(
        getWorkoutSetsByDateUseCase,
        exerciseRepository,
      );

      final result = await useCase.execute(weekOffset: 0);

      expect(result['attendance']['daysTrained'], 2);
      expect(result['attendance']['avgSetsPerDay'], 1.5); // 3 sets / 2 days
    });
  });
}
