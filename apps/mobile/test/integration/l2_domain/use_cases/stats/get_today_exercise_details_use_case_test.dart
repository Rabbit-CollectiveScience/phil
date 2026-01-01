import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/use_cases/stats/get_today_exercise_details_use_case.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/get_workout_sets_by_date_use_case.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/record_workout_set_use_case.dart';
import 'package:phil/l3_data/repositories/stub_workout_set_repository.dart';
import 'package:phil/l3_data/repositories/stub_exercise_repository.dart';
import 'package:phil/l3_data/repositories/stub_personal_record_repository.dart';
import 'package:phil/l2_domain/models/personal_record.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GetTodayExerciseDetailsUseCase useCase;
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

    useCase = GetTodayExerciseDetailsUseCase(getWorkoutSetsByDateUseCase);
  });

  tearDown(() {
    workoutSetRepo.clear();
  });

  group('GetTodayExerciseDetailsUseCase', () {
    test('returns empty list when no workout sets today', () async {
      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, isEmpty);
    });

    test(
      'returns correct details for single exercise with multiple sets',
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
          values: {'weight': 110, 'reps': 8},
        );
        await recordUseCase.execute(
          exerciseId: benchPress.id,
          values: {'weight': 100, 'reps': 9},
        );

        // Act
        final result = await useCase.execute();

        // Assert
        expect(result.length, equals(1));
        expect(result[0]['name'], contains('Bench Press'));
        expect(result[0]['sets'], equals(3));
        expect(
          result[0]['volumeToday'],
          equals(2780.0),
        ); // (100*10)+(110*8)+(100*9)
        expect(result[0]['maxWeightToday'], equals(110.0));
      },
    );

    test('groups multiple exercises correctly', () async {
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
        exerciseId: benchPress.id,
        values: {'weight': 100, 'reps': 8},
      );
      await recordUseCase.execute(
        exerciseId: squat.id,
        values: {'weight': 150, 'reps': 5},
      );

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result.length, equals(2));

      final benchPressDetails = result.firstWhere(
        (e) => e['name'].toString().contains('Bench Press'),
      );
      expect(benchPressDetails['sets'], equals(2));
      expect(
        benchPressDetails['volumeToday'],
        equals(1800.0),
      ); // (100*10)+(100*8)
      expect(benchPressDetails['maxWeightToday'], equals(100.0));

      final squatDetails = result.firstWhere(
        (e) => e['name'].toString().contains('Squat'),
      );
      expect(squatDetails['sets'], equals(1));
      expect(squatDetails['volumeToday'], equals(750.0)); // 150*5
      expect(squatDetails['maxWeightToday'], equals(150.0));
    });

    test('calculates volume for reps-only exercise', () async {
      // Arrange
      final exercises = await exerciseRepo.getAllExercises();
      final pushup = exercises.firstWhere(
        (e) => e.name.contains('Push') && e.name.contains('Up'),
      );

      await recordUseCase.execute(exerciseId: pushup.id, values: {'reps': 20});
      await recordUseCase.execute(exerciseId: pushup.id, values: {'reps': 15});

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result.length, equals(1));
      expect(result[0]['volumeToday'], equals(35.0)); // 20+15
      expect(result[0]['maxWeightToday'], isNull); // No weight field
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
      expect(result.length, equals(1));
      expect(result[0]['sets'], equals(2));
      expect(result[0]['volumeToday'], equals(0.0));
    });

    group('Personal Record Integration', () {
      late StubPersonalRecordRepository prRepo;
      late GetTodayExerciseDetailsUseCase useCaseWithPR;

      setUp(() async {
        prRepo = StubPersonalRecordRepository();

        final getWorkoutSetsByDateUseCase = GetWorkoutSetsByDateUseCase(
          workoutSetRepo,
          exerciseRepo,
        );

        useCaseWithPR = GetTodayExerciseDetailsUseCase(
          getWorkoutSetsByDateUseCase,
          prRepository: prRepo,
        );
      });

      test('should include prMaxWeight in exercise details', () async {
        // Arrange
        final exercises = await exerciseRepo.getAllExercises();
        final benchPress = exercises.firstWhere(
          (e) => e.name.contains('Bench Press'),
        );

        // Record a set today
        await recordUseCase.execute(
          exerciseId: benchPress.id,
          values: {'weight': 100, 'reps': 10},
        );

        // Simulate existing PR
        final pr = PersonalRecord(
          id: 'pr_1',
          exerciseId: benchPress.id,
          type: 'maxWeight',
          value: 120,
          achievedAt: DateTime.now().subtract(const Duration(days: 7)),
        );
        await prRepo.save(pr);

        // Act
        final result = await useCaseWithPR.execute();

        // Assert - This will fail until GetCurrentPRUseCase is integrated
        expect(result.length, equals(1));
        expect(result[0]['prMaxWeight'], equals(120.0));
        expect(result[0]['isPRToday'], isFalse);
      });

      test('should mark isPRToday=true when PR achieved today', () async {
        // Arrange
        final exercises = await exerciseRepo.getAllExercises();
        final squat = exercises.firstWhere((e) => e.name.contains('Squat'));

        // Record a set today
        await recordUseCase.execute(
          exerciseId: squat.id,
          values: {'weight': 150, 'reps': 5},
        );

        // Simulate PR achieved today
        final pr = PersonalRecord(
          id: 'pr_today',
          exerciseId: squat.id,
          type: 'maxWeight',
          value: 150,
          achievedAt: DateTime.now(),
        );
        await prRepo.save(pr);

        // Act
        final result = await useCaseWithPR.execute();

        // Assert
        expect(result.length, equals(1));
        expect(result[0]['prMaxWeight'], equals(150.0));
        expect(result[0]['isPRToday'], isTrue);
      });

      test(
        'should mark isPRToday=false when PR is from previous date',
        () async {
          // Arrange
          final exercises = await exerciseRepo.getAllExercises();
          final deadlift = exercises.firstWhere(
            (e) => e.name.contains('Deadlift'),
          );

          // Record a set today
          await recordUseCase.execute(
            exerciseId: deadlift.id,
            values: {'weight': 180, 'reps': 3},
          );

          // Simulate old PR
          final oldDate = DateTime(2024, 1, 1);
          final pr = PersonalRecord(
            id: 'pr_old',
            exerciseId: deadlift.id,
            type: 'maxWeight',
            value: 200,
            achievedAt: oldDate,
          );
          await prRepo.save(pr);

          // Act
          final result = await useCaseWithPR.execute();

          // Assert
          expect(result.length, equals(1));
          expect(result[0]['prMaxWeight'], equals(200.0));
          expect(result[0]['isPRToday'], isFalse);
        },
      );

      test(
        'should return null prMaxWeight when no PR exists for exercise',
        () async {
          // Arrange
          final exercises = await exerciseRepo.getAllExercises();
          final pullUp = exercises.firstWhere((e) => e.name.contains('Pull'));

          // Record a set today (no existing PR)
          await recordUseCase.execute(
            exerciseId: pullUp.id,
            values: {'reps': 10},
          );

          // Act
          final result = await useCaseWithPR.execute();

          // Assert
          expect(result.length, equals(1));
          expect(result[0].containsKey('prMaxWeight'), isTrue);
          expect(result[0]['prMaxWeight'], isNull);
          expect(result[0]['isPRToday'], isFalse);
        },
      );
    });
  });
}
