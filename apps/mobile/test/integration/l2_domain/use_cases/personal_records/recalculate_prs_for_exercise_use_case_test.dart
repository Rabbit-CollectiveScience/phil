import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/personal_record.dart';
import 'package:phil/l2_domain/use_cases/personal_records/recalculate_prs_for_exercise_use_case.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/record_workout_set_use_case.dart';
import 'package:phil/l3_data/repositories/personal_record_repository.dart';
import 'package:phil/l3_data/repositories/stub_personal_record_repository.dart';
import 'package:phil/l3_data/repositories/stub_workout_set_repository.dart';
import 'package:phil/l3_data/repositories/stub_exercise_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PersonalRecordRepository prRepo;
  late StubWorkoutSetRepository workoutSetRepo;
  late StubExerciseRepository exerciseRepo;
  late RecalculatePRsForExerciseUseCase useCase;
  late RecordWorkoutSetUseCase recordUseCase;

  setUp(() {
    prRepo = StubPersonalRecordRepository();
    workoutSetRepo = StubWorkoutSetRepository();
    exerciseRepo = StubExerciseRepository();
    useCase = RecalculatePRsForExerciseUseCase(
      prRepo,
      workoutSetRepo,
      exerciseRepo,
    );
    recordUseCase = RecordWorkoutSetUseCase(workoutSetRepo);
  });

  tearDown(() {
    workoutSetRepo.clear();
  });

  group('RecalculatePRsForExerciseUseCase', () {
    test('recalculates maxWeight PR from all historical sets', () async {
      final exercises = await exerciseRepo.getAllExercises();
      final benchPress = exercises.firstWhere(
        (e) => e.name.contains('Bench Press'),
      );

      await recordUseCase.execute(
        exerciseId: benchPress.id,
        values: {'weight': 95.0, 'reps': 10},
        completedAt: DateTime(2026, 1, 1),
      );
      await recordUseCase.execute(
        exerciseId: benchPress.id,
        values: {'weight': 100.0, 'reps': 8},
        completedAt: DateTime(2026, 1, 2),
      );
      await recordUseCase.execute(
        exerciseId: benchPress.id,
        values: {'weight': 97.5, 'reps': 9},
        completedAt: DateTime(2026, 1, 3),
      );

      await useCase.execute(benchPress.id);

      final weightPR = await prRepo.getCurrentPR(benchPress.id, 'maxWeight');
      expect(weightPR, isNotNull);
      expect(weightPR!.value, equals(100.0));
      expect(weightPR.exerciseId, equals(benchPress.id));
    });

    test('recalculates maxReps PR from all historical sets', () async {
      final exercises = await exerciseRepo.getAllExercises();
      final pushups = exercises.firstWhere(
        (e) => e.name.contains('Push') && e.name.contains('Up'),
      );

      await recordUseCase.execute(
        exerciseId: pushups.id,
        values: {'reps': 30},
        completedAt: DateTime(2026, 1, 1),
      );
      await recordUseCase.execute(
        exerciseId: pushups.id,
        values: {'reps': 50},
        completedAt: DateTime(2026, 1, 2),
      );
      await recordUseCase.execute(
        exerciseId: pushups.id,
        values: {'reps': 40},
        completedAt: DateTime(2026, 1, 3),
      );

      await useCase.execute(pushups.id);

      final repsPR = await prRepo.getCurrentPR(pushups.id, 'maxReps');
      expect(repsPR, isNotNull);
      expect(repsPR!.value, equals(50.0));
    });

    test('deletes old PRs before creating new ones', () async {
      final exercises = await exerciseRepo.getAllExercises();
      final squat = exercises.firstWhere((e) => e.name.contains('Squat'));

      // Save old PR
      await prRepo.save(
        PersonalRecord(
          id: 'old_pr',
          exerciseId: squat.id,
          type: 'maxWeight',
          value: 120.0,
          achievedAt: DateTime(2025, 12, 1),
        ),
      );

      // Record new sets
      await recordUseCase.execute(
        exerciseId: squat.id,
        values: {'weight': 150.0, 'reps': 5},
      );

      await useCase.execute(squat.id);

      // Should have new PR, not old one
      final allPRs = await prRepo.getPRsByExercise(squat.id);
      expect(allPRs.every((pr) => pr.id != 'old_pr'), isTrue);
    });

    test('returns empty when no sets exist for exercise', () async {
      await useCase.execute('nonexistent_exercise');

      final prs = await prRepo.getPRsByExercise('nonexistent_exercise');
      expect(prs, isEmpty);
    });

    test('finds correct max values across multiple dates', () async {
      final exercises = await exerciseRepo.getAllExercises();
      final deadlift = exercises.firstWhere((e) => e.name.contains('Deadlift'));

      await recordUseCase.execute(
        exerciseId: deadlift.id,
        values: {'weight': 160.0, 'reps': 5},
        completedAt: DateTime(2025, 12, 15),
      );
      await recordUseCase.execute(
        exerciseId: deadlift.id,
        values: {'weight': 180.0, 'reps': 3},
        completedAt: DateTime(2026, 1, 1),
      );
      await recordUseCase.execute(
        exerciseId: deadlift.id,
        values: {'weight': 170.0, 'reps': 4},
        completedAt: DateTime(2026, 1, 2),
      );

      await useCase.execute(deadlift.id);

      final weightPR = await prRepo.getCurrentPR(deadlift.id, 'maxWeight');
      expect(weightPR, isNotNull);
      expect(weightPR!.value, equals(180.0));
    });

    test('handles multiple PR types simultaneously', () async {
      final exercises = await exerciseRepo.getAllExercises();
      final benchPress = exercises.firstWhere(
        (e) => e.name.contains('Bench Press'),
      );

      await recordUseCase.execute(
        exerciseId: benchPress.id,
        values: {'weight': 100.0, 'reps': 10},
      );
      await recordUseCase.execute(
        exerciseId: benchPress.id,
        values: {'weight': 95.0, 'reps': 12},
      );

      await useCase.execute(benchPress.id);

      final allPRs = await prRepo.getPRsByExercise(benchPress.id);
      expect(allPRs.any((pr) => pr.type == 'maxWeight'), isTrue);
    });

    test('preserves achievedAt date from original set', () async {
      final exercises = await exerciseRepo.getAllExercises();
      final benchPress = exercises.firstWhere(
        (e) => e.name.contains('Bench Press'),
      );
      final achievedDate = DateTime(2026, 1, 1, 10, 30);

      await recordUseCase.execute(
        exerciseId: benchPress.id,
        values: {'weight': 100.0, 'reps': 10},
        completedAt: achievedDate,
      );

      await useCase.execute(benchPress.id);

      final weightPR = await prRepo.getCurrentPR(benchPress.id, 'maxWeight');
      expect(weightPR, isNotNull);
      expect(weightPR!.achievedAt, equals(achievedDate));
    });
  });
}
