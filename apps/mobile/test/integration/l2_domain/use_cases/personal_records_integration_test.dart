import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:phil/l2_domain/use_cases/personal_records/get_all_prs_use_case.dart';
import 'package:phil/l2_domain/use_cases/personal_records/recalculate_prs_for_exercise_use_case.dart';
import 'package:phil/l3_data/repositories/personal_record_repository.dart';
import 'package:phil/l3_data/repositories/workout_set_repository.dart';
import 'package:phil/l3_data/repositories/exercise_repository.dart';
import 'package:phil/l2_domain/models/personal_records/weight_pr.dart';
import 'package:phil/l2_domain/models/personal_records/reps_pr.dart';
import 'package:phil/l2_domain/models/personal_records/volume_pr.dart';
import 'package:phil/l2_domain/models/personal_records/duration_pr.dart';
import 'package:phil/l2_domain/models/personal_records/distance_pr.dart';
import 'package:phil/l2_domain/models/personal_records/pace_pr.dart';
import 'package:phil/l2_domain/models/workout_sets/weighted_workout_set.dart';
import 'package:phil/l2_domain/models/workout_sets/bodyweight_workout_set.dart';
import 'package:phil/l2_domain/models/workout_sets/distance_cardio_workout_set.dart';
import 'package:phil/l2_domain/models/common/weight.dart';
import 'package:phil/l2_domain/models/common/distance.dart';
import 'package:phil/l2_domain/models/exercises/free_weight_exercise.dart';
import 'package:phil/l2_domain/models/exercises/bodyweight_exercise.dart';
import 'package:phil/l2_domain/models/exercises/distance_cardio_exercise.dart';
import 'package:phil/l2_domain/models/common/muscle_group.dart';

void main() {
  late PersonalRecordRepository prRepository;
  late WorkoutSetRepository workoutSetRepository;
  late ExerciseRepository exerciseRepository;

  setUp(() async {
    await Hive.initFlutter();
    
    // Open boxes with the exact names the repositories expect
    final prBox = await Hive.openBox<Map>('personal_records');
    final workoutSetBox = await Hive.openBox<Map>('workout_sets');
    final exerciseBox = await Hive.openBox<Map>('exercises');
    
    // Repositories don't take Box parameters - they access boxes by name
    prRepository = PersonalRecordRepository();
    workoutSetRepository = WorkoutSetRepository();
    exerciseRepository = ExerciseRepository();
    
    await prBox.clear();
    await workoutSetBox.clear();
    await exerciseBox.clear();
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk('personal_records');
    await Hive.deleteBoxFromDisk('workout_sets');
    await Hive.deleteBoxFromDisk('exercises');
    await Hive.close();
  });

  group('GetAllPRsUseCase Integration Tests', () {
    test('returns empty list when no PRs exist', () async {
      final useCase = GetAllPRsUseCase(prRepository, exerciseRepository);

      final result = await useCase.execute();

      expect(result, isEmpty);
    });

    test('retrieves all PRs with exercise details', () async {
      final exercise = FreeWeightExercise(
        id: 'exercise1',
        name: 'Bench Press',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
      );
      await exerciseRepository.save(exercise);

      await prRepository.save(WeightPR(
        id: 'pr1',
        exerciseId: 'exercise1',
        workoutSetId: 'set1',
        achievedAt: DateTime.now(),
      ));

      await prRepository.save(RepsPR(
        id: 'pr2',
        exerciseId: 'exercise1',
        workoutSetId: 'set2',
        achievedAt: DateTime.now(),
      ));

      final useCase = GetAllPRsUseCase(prRepository, exerciseRepository);

      final result = await useCase.execute();

      expect(result.length, 2);
      expect(result[0].exerciseName, 'Bench Press');
    });

    test('sorts PRs by date descending', () async {
      final exercise = FreeWeightExercise(
        id: 'exercise1',
        name: 'Bench Press',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
      );
      await exerciseRepository.save(exercise);

      final now = DateTime.now();

      await prRepository.save(WeightPR(
        id: 'pr1',
        exerciseId: 'exercise1',
        workoutSetId: 'set1',
        achievedAt: now.subtract(const Duration(days: 30)),
      ));

      await prRepository.save(WeightPR(
        id: 'pr2',
        exerciseId: 'exercise1',
        workoutSetId: 'set2',
        achievedAt: now,
      ));

      final useCase = GetAllPRsUseCase(prRepository, exerciseRepository);

      final result = await useCase.execute();

      expect(result.first.prRecord.id, 'pr2'); // Most recent first
    });

    test('includes all PR types', () async {
      final benchExercise = FreeWeightExercise(
        id: 'bench',
        name: 'Bench Press',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
      );
      
      final runningExercise = DistanceCardioExercise(
        id: 'running',
        name: 'Running',
        description: 'Test',
        isCustom: false,
      );

      await exerciseRepository.save(benchExercise);
      await exerciseRepository.save(runningExercise);

      final now = DateTime.now();

      await prRepository.save(WeightPR(
        id: 'pr1',
        exerciseId: 'bench',
        workoutSetId: 'set1',
        achievedAt: now,
      ));

      await prRepository.save(RepsPR(
        id: 'pr2',
        exerciseId: 'bench',
        workoutSetId: 'set2',
        achievedAt: now,
      ));

      await prRepository.save(VolumePR(
        id: 'pr3',
        exerciseId: 'bench',
        workoutSetId: 'set3',
        achievedAt: now,
      ));

      await prRepository.save(DistancePR(
        id: 'pr4',
        exerciseId: 'running',
        workoutSetId: 'set4',
        achievedAt: now,
      ));

      await prRepository.save(DurationPR(
        id: 'pr5',
        exerciseId: 'running',
        workoutSetId: 'set5',
        achievedAt: now,
      ));

      await prRepository.save(PacePR(
        id: 'pr6',
        exerciseId: 'running',
        workoutSetId: 'set6',
        achievedAt: now,
      ));

      final useCase = GetAllPRsUseCase(prRepository, exerciseRepository);

      final result = await useCase.execute();

      expect(result.length, 6);
      expect(result.any((pr) => pr.prRecord is WeightPR), true);
      expect(result.any((pr) => pr.prRecord is RepsPR), true);
      expect(result.any((pr) => pr.prRecord is VolumePR), true);
      expect(result.any((pr) => pr.prRecord is DistancePR), true);
      expect(result.any((pr) => pr.prRecord is DurationPR), true);
      expect(result.any((pr) => pr.prRecord is PacePR), true);
    });

    test('skips PRs for deleted exercises', () async {
      await prRepository.save(WeightPR(
        id: 'pr1',
        exerciseId: 'nonexistent',
        workoutSetId: 'set1',
        achievedAt: DateTime.now(),
      ));

      final useCase = GetAllPRsUseCase(prRepository, exerciseRepository);

      final result = await useCase.execute();

      expect(result, isEmpty);
    });
  });

  group('RecalculatePRsForExerciseUseCase Integration Tests', () {
    test('creates PRs when none exist', () async {
      final exercise = FreeWeightExercise(
        id: 'bench',
        name: 'Bench Press',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
      );

      await exerciseRepository.save(exercise);

      await workoutSetRepository.save(WeightedWorkoutSet(
        id: 'set1',
        exerciseId: 'bench',
        timestamp: DateTime.now(),
        weight: Weight(100.0),
        reps: 10,
      ));

      final useCase = RecalculatePRsForExerciseUseCase(
        prRepository,
        workoutSetRepository,
        exerciseRepository,
      );

      await useCase.execute('bench');

      final prs = await prRepository.getByExerciseId('bench');
      expect(prs.isNotEmpty, true);
    });

    test('updates PRs when better values exist', () async {
      final exercise = FreeWeightExercise(
        id: 'bench',
        name: 'Bench Press',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
      );

      await exerciseRepository.save(exercise);

      // Old workout set
      await workoutSetRepository.save(WeightedWorkoutSet(
        id: 'set1',
        exerciseId: 'bench',
        timestamp: DateTime.now().subtract(const Duration(days: 30)),
        weight: Weight(80.0),
        reps: 10,
      ));

      // New workout set with heavier weight
      await workoutSetRepository.save(WeightedWorkoutSet(
        id: 'set2',
        exerciseId: 'bench',
        timestamp: DateTime.now(),
        weight: Weight(100.0),
        reps: 10,
      ));

      final useCase = RecalculatePRsForExerciseUseCase(
        prRepository,
        workoutSetRepository,
        exerciseRepository,
      );

      await useCase.execute('bench');

      final prs = await prRepository.getByExerciseId('bench');
      expect(prs.isNotEmpty, true);
      
      // Check that we have weight PRs
      final weightPRs = prs.whereType<WeightPR>();
      expect(weightPRs.isNotEmpty, true);
    });

    test('handles bodyweight exercises with additional weight', () async {
      final exercise = BodyweightExercise(
        id: 'pullup',
        name: 'Pull-up',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.back],
        canAddWeight: true,
      );

      await exerciseRepository.save(exercise);

      await workoutSetRepository.save(BodyweightWorkoutSet(
        id: 'set1',
        exerciseId: 'pullup',
        timestamp: DateTime.now(),
        reps: 10,
        additionalWeight: Weight(20.0),
      ));

      final useCase = RecalculatePRsForExerciseUseCase(
        prRepository,
        workoutSetRepository,
        exerciseRepository,
      );

      await useCase.execute('pullup');

      final prs = await prRepository.getByExerciseId('pullup');
      expect(prs.isNotEmpty, true);
    });

    test('calculates cardio exercise PRs', () async {
      final exercise = DistanceCardioExercise(
        id: 'running',
        name: 'Running',
        description: 'Test',
        isCustom: false,
      );

      await exerciseRepository.save(exercise);

      await workoutSetRepository.save(DistanceCardioWorkoutSet(
        id: 'set1',
        exerciseId: 'running',
        timestamp: DateTime.now(),
        duration: const Duration(minutes: 30),
        distance: Distance(5000.0),
      ));

      await workoutSetRepository.save(DistanceCardioWorkoutSet(
        id: 'set2',
        exerciseId: 'running',
        timestamp: DateTime.now(),
        duration: const Duration(minutes: 60),
        distance: Distance(10000.0),
      ));

      final useCase = RecalculatePRsForExerciseUseCase(
        prRepository,
        workoutSetRepository,
        exerciseRepository,
      );

      await useCase.execute('running');

      final prs = await prRepository.getByExerciseId('running');
      expect(prs.isNotEmpty, true);
      
      // Should have distance and duration PRs
      expect(prs.any((pr) => pr is DistancePR), true);
      expect(prs.any((pr) => pr is DurationPR), true);
    });

    test('does not create PRs when no workout sets exist', () async {
      final exercise = FreeWeightExercise(
        id: 'bench',
        name: 'Bench Press',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
      );

      await exerciseRepository.save(exercise);

      final useCase = RecalculatePRsForExerciseUseCase(
        prRepository,
        workoutSetRepository,
        exerciseRepository,
      );

      await useCase.execute('bench');

      final prs = await prRepository.getByExerciseId('bench');
      expect(prs, isEmpty);
    });
  });
}
