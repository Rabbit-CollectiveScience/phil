import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/use_cases/stats/get_today_exercise_details_use_case.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/get_workout_sets_by_date_use_case.dart';
import 'package:phil/l2_domain/use_cases/workout_sets/record_workout_set_use_case.dart';
import 'package:phil/l3_data/repositories/stub_workout_set_repository.dart';
import 'package:phil/l3_data/repositories/stub_exercise_repository.dart';

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
    
    useCase = GetTodayExerciseDetailsUseCase(
      getWorkoutSetsByDateUseCase,
    );
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

    test('returns correct details for single exercise with multiple sets', () async {
      // Arrange
      final exercises = await exerciseRepo.getAllExercises();
      final benchPress = exercises.firstWhere((e) => e.name.contains('Bench Press'));

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
      expect(result[0]['volumeToday'], equals(2780.0)); // (100*10)+(110*8)+(100*9)
      expect(result[0]['maxWeightToday'], equals(110.0));
    });

    test('groups multiple exercises correctly', () async {
      // Arrange
      final exercises = await exerciseRepo.getAllExercises();
      final benchPress = exercises.firstWhere((e) => e.name.contains('Bench Press'));
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
      
      final benchPressDetails = result.firstWhere((e) => e['name'].toString().contains('Bench Press'));
      expect(benchPressDetails['sets'], equals(2));
      expect(benchPressDetails['volumeToday'], equals(1800.0)); // (100*10)+(100*8)
      expect(benchPressDetails['maxWeightToday'], equals(100.0));
      
      final squatDetails = result.firstWhere((e) => e['name'].toString().contains('Squat'));
      expect(squatDetails['sets'], equals(1));
      expect(squatDetails['volumeToday'], equals(750.0)); // 150*5
      expect(squatDetails['maxWeightToday'], equals(150.0));
    });

    test('calculates volume for reps-only exercise', () async {
      // Arrange
      final exercises = await exerciseRepo.getAllExercises();
      final pushup = exercises.firstWhere((e) => e.name.contains('Push') && e.name.contains('Up'));

      await recordUseCase.execute(
        exerciseId: pushup.id,
        values: {'reps': 20},
      );
      await recordUseCase.execute(
        exerciseId: pushup.id,
        values: {'reps': 15},
      );

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

      await recordUseCase.execute(
        exerciseId: firstExercise.id,
        values: null,
      );
      await recordUseCase.execute(
        exerciseId: firstExercise.id,
        values: {},
      );

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result.length, equals(1));
      expect(result[0]['sets'], equals(2));
      expect(result[0]['volumeToday'], equals(0.0));
    });
  });
}
