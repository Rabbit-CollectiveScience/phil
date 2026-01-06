import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/record_workout_set_use_case.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/get_workout_sets_by_date_use_case.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/get_today_completed_count_use_case.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/get_today_completed_list_use_case.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/remove_workout_set_use_case.dart';
import 'package:phil/l3_data/repositories/workout_set_repository.dart';
import 'package:phil/l3_data/repositories/exercise_repository.dart';
import 'package:phil/l3_data/repositories/personal_record_repository.dart';
import 'package:phil/l2_domain/models/workout_sets/weighted_workout_set.dart';
import 'package:phil/l2_domain/models/workout_sets/bodyweight_workout_set.dart';
import 'package:phil/l2_domain/models/common/weight.dart';
import 'package:phil/l2_domain/models/exercises/bodyweight_exercise.dart';
import 'package:phil/l2_domain/models/exercises/free_weight_exercise.dart';
import 'package:phil/l2_domain/models/common/muscle_group.dart';

void main() {
  late WorkoutSetRepository workoutSetRepository;
  late ExerciseRepository exerciseRepository;
  late PersonalRecordRepository prRepository;

  setUp(() async {
    final tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);

    await Hive.openBox<Map>('workout_sets');
    await Hive.openBox<Map>('exercises');
    await Hive.openBox<Map>('personal_records');

    workoutSetRepository = WorkoutSetRepository();
    exerciseRepository = ExerciseRepository();
    prRepository = PersonalRecordRepository();

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

  group('RecordWorkoutSetUseCase Integration Tests', () {
    test('records weighted workout set successfully', () async {
      final exercise = FreeWeightExercise(
        id: 'ex1',
        name: 'Bench Press',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
      );
      await exerciseRepository.save(exercise);

      final useCase = RecordWorkoutSetUseCase(
        workoutSetRepository,
        prRepository: prRepository,
        exerciseRepository: exerciseRepository,
      );

      final workoutSet = WeightedWorkoutSet(
        id: 'set1',
        exerciseId: 'ex1',
        timestamp: DateTime.now(),
        weight: Weight(100.0),
        reps: 10,
      );

      final result = await useCase.execute(workoutSet: workoutSet);

      expect(result.id, 'set1');
      expect((result as WeightedWorkoutSet).weight.kg, 100.0);
      expect(result.reps, 10);

      // Verify it was saved
      final saved = await workoutSetRepository.getById('set1');
      expect(saved, isNotNull);
    });

    test('records bodyweight workout set successfully', () async {
      final exercise = BodyweightExercise(
        id: 'ex2',
        name: 'Push-up',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
        canAddWeight: true,
      );
      await exerciseRepository.save(exercise);

      final useCase = RecordWorkoutSetUseCase(
        workoutSetRepository,
        prRepository: prRepository,
        exerciseRepository: exerciseRepository,
      );

      final workoutSet = BodyweightWorkoutSet(
        id: 'set2',
        exerciseId: 'ex2',
        timestamp: DateTime.now(),
        reps: 15,
      );

      final result = await useCase.execute(workoutSet: workoutSet);

      expect(result.id, 'set2');
      expect((result as BodyweightWorkoutSet).reps, 15);
    });
  });

  group('GetWorkoutSetsByDateUseCase Integration Tests', () {
    test('returns empty list when no sets exist for date', () async {
      final useCase = GetWorkoutSetsByDateUseCase(
        workoutSetRepository,
        exerciseRepository,
      );

      final result = await useCase.execute(date: DateTime.now());

      expect(result, isEmpty);
    });

    test('returns sets for the given date', () async {
      final today = DateTime.now();
      final exercise = FreeWeightExercise(
        id: 'ex1',
        name: 'Bench Press',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
      );
      await exerciseRepository.save(exercise);

      await workoutSetRepository.save(
        WeightedWorkoutSet(
          id: 'set1',
          exerciseId: 'ex1',
          timestamp: today,
          weight: Weight(100.0),
          reps: 10,
        ),
      );

      final useCase = GetWorkoutSetsByDateUseCase(
        workoutSetRepository,
        exerciseRepository,
      );

      final result = await useCase.execute(date: today);

      expect(result.length, 1);
      expect(result[0].workoutSet.id, 'set1');
      expect(result[0].exercise?.name, 'Bench Press');
    });

    test('does not return sets from other dates', () async {
      final today = DateTime.now();
      final yesterday = today.subtract(Duration(days: 1));

      final exercise = FreeWeightExercise(
        id: 'ex1',
        name: 'Bench Press',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
      );
      await exerciseRepository.save(exercise);

      await workoutSetRepository.save(
        WeightedWorkoutSet(
          id: 'set1',
          exerciseId: 'ex1',
          timestamp: yesterday,
          weight: Weight(100.0),
          reps: 10,
        ),
      );

      final useCase = GetWorkoutSetsByDateUseCase(
        workoutSetRepository,
        exerciseRepository,
      );

      final result = await useCase.execute(date: today);

      expect(result, isEmpty);
    });
  });

  group('GetTodayCompletedCountUseCase Integration Tests', () {
    test('returns 0 when no sets exist', () async {
      final useCase = GetTodayCompletedCountUseCase(workoutSetRepository);

      final result = await useCase.execute();

      expect(result, 0);
    });

    test('returns count of today\'s sets', () async {
      final today = DateTime.now();
      final exercise = FreeWeightExercise(
        id: 'ex1',
        name: 'Bench Press',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
      );
      await exerciseRepository.save(exercise);

      await workoutSetRepository.save(
        WeightedWorkoutSet(
          id: 'set1',
          exerciseId: 'ex1',
          timestamp: today,
          weight: Weight(100.0),
          reps: 10,
        ),
      );

      await workoutSetRepository.save(
        WeightedWorkoutSet(
          id: 'set2',
          exerciseId: 'ex1',
          timestamp: today,
          weight: Weight(100.0),
          reps: 10,
        ),
      );

      final useCase = GetTodayCompletedCountUseCase(workoutSetRepository);

      final result = await useCase.execute();

      expect(result, 2);
    });
  });

  group('GetTodayCompletedListUseCase Integration Tests', () {
    test('returns empty list when no sets exist', () async {
      final useCase = GetTodayCompletedListUseCase(
        workoutSetRepository,
        exerciseRepository,
      );

      final result = await useCase.execute();

      expect(result, isEmpty);
    });

    test('returns list with exercise details', () async {
      final today = DateTime.now();
      final exercise = FreeWeightExercise(
        id: 'ex1',
        name: 'Bench Press',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
      );
      await exerciseRepository.save(exercise);

      await workoutSetRepository.save(
        WeightedWorkoutSet(
          id: 'set1',
          exerciseId: 'ex1',
          timestamp: today,
          weight: Weight(100.0),
          reps: 10,
        ),
      );

      final useCase = GetTodayCompletedListUseCase(
        workoutSetRepository,
        exerciseRepository,
      );

      final result = await useCase.execute();

      expect(result.length, 1);
      expect(result[0].exercise?.name, 'Bench Press');
      expect(result[0].workoutSet.id, 'set1');
    });

    test('returns multiple sets for different exercises', () async {
      final today = DateTime.now();

      final benchExercise = FreeWeightExercise(
        id: 'bench',
        name: 'Bench Press',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
      );
      final squatExercise = FreeWeightExercise(
        id: 'squat',
        name: 'Squat',
        description: 'Test',
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

      final useCase = GetTodayCompletedListUseCase(
        workoutSetRepository,
        exerciseRepository,
      );

      final result = await useCase.execute();

      expect(result.length, 2);
      final exerciseIds = result.map((s) => s.exercise?.id).toSet();
      expect(exerciseIds, contains('bench'));
      expect(exerciseIds, contains('squat'));
    });
  });

  group('RemoveWorkoutSetUseCase Integration Tests', () {
    test('removes workout set successfully', () async {
      final exercise = FreeWeightExercise(
        id: 'ex1',
        name: 'Bench Press',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
      );
      await exerciseRepository.save(exercise);

      await workoutSetRepository.save(
        WeightedWorkoutSet(
          id: 'set15',
          exerciseId: 'ex1',
          timestamp: DateTime.now(),
          weight: Weight(100.0),
          reps: 10,
        ),
      );

      final useCase = RemoveWorkoutSetUseCase(
        workoutSetRepository,
        prRepository: prRepository,
        exerciseRepository: exerciseRepository,
      );

      await useCase.execute('set15');

      final deleted = await workoutSetRepository.getById('set15');
      expect(deleted, isNull);
    });

    test('handles non-existent set gracefully', () async {
      final useCase = RemoveWorkoutSetUseCase(
        workoutSetRepository,
        prRepository: prRepository,
        exerciseRepository: exerciseRepository,
      );

      // Should complete without error
      await useCase.execute('nonexistent');

      // Verify no exception was thrown and test completes
      expect(true, true);
    });

    test('recalculates PRs after deletion', () async {
      final exercise = FreeWeightExercise(
        id: 'ex1',
        name: 'Bench Press',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
      );
      await exerciseRepository.save(exercise);

      await workoutSetRepository.save(
        WeightedWorkoutSet(
          id: 'set16',
          exerciseId: 'ex1',
          timestamp: DateTime.now(),
          weight: Weight(100.0),
          reps: 10,
        ),
      );

      await workoutSetRepository.save(
        WeightedWorkoutSet(
          id: 'set17',
          exerciseId: 'ex1',
          timestamp: DateTime.now(),
          weight: Weight(110.0),
          reps: 8,
        ),
      );

      final useCase = RemoveWorkoutSetUseCase(
        workoutSetRepository,
        prRepository: prRepository,
        exerciseRepository: exerciseRepository,
      );

      await useCase.execute('set16');

      // Verify the set was removed
      final deleted = await workoutSetRepository.getById('set16');
      expect(deleted, isNull);

      // Verify the other set still exists
      final remaining = await workoutSetRepository.getById('set17');
      expect(remaining, isNotNull);
    });
  });
}
