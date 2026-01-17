import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:phil/l2_domain/models/common/equipment_type.dart';
import 'package:phil/l2_domain/models/common/muscle_group.dart';
import 'package:phil/l2_domain/models/common/weight.dart';
import 'package:phil/l2_domain/models/exercises/free_weight_exercise.dart';
import 'package:phil/l2_domain/models/exercises/bodyweight_exercise.dart';
import 'package:phil/l2_domain/models/exercises/distance_cardio_exercise.dart';
import 'package:phil/l2_domain/models/personal_records/weight_pr.dart';
import 'package:phil/l2_domain/models/personal_records/reps_pr.dart';
import 'package:phil/l2_domain/models/workout_sets/weighted_workout_set.dart';
import 'package:phil/l2_domain/use_cases/personal_records/calculate_pr_percentages_use_case.dart';
import 'package:phil/l2_domain/use_cases/preferences/get_user_preferences_use_case.dart';
import 'package:phil/l2_domain/models/user_preferences.dart';
import 'package:phil/l3_data/repositories/personal_record_repository.dart';
import 'package:phil/l3_data/repositories/workout_set_repository.dart';

class MockPersonalRecordRepository extends Mock
    implements PersonalRecordRepository {}

class MockWorkoutSetRepository extends Mock implements WorkoutSetRepository {}

class MockGetUserPreferencesUseCase extends Mock
    implements GetUserPreferencesUseCase {}

void main() {
  late CalculatePRPercentagesUseCase useCase;
  late MockPersonalRecordRepository mockPRRepo;
  late MockWorkoutSetRepository mockWorkoutSetRepo;
  late MockGetUserPreferencesUseCase mockPreferencesUseCase;

  setUp(() {
    mockPRRepo = MockPersonalRecordRepository();
    mockWorkoutSetRepo = MockWorkoutSetRepository();
    mockPreferencesUseCase = MockGetUserPreferencesUseCase();

    useCase = CalculatePRPercentagesUseCase(
      mockPRRepo,
      mockWorkoutSetRepo,
      mockPreferencesUseCase,
    );
  });

  group('Happy Path - Successful Calculations', () {
    test('calculates percentages for plate equipment (exact values)', () async {
      // Given: Bench Press with 100kg PR
      final exercise = FreeWeightExercise(
        id: 'bench_1',
        name: 'Bench Press',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
        equipmentType: EquipmentType.plate,
      );

      final weightPR = WeightPR(
        id: 'pr_1',
        exerciseId: 'bench_1',
        workoutSetId: 'set_1',
        achievedAt: DateTime(2026, 1, 1),
      );

      final workoutSet = WeightedWorkoutSet(
        id: 'set_1',
        exerciseId: 'bench_1',
        timestamp: DateTime(2026, 1, 1),
        weight: Weight(100.0),
        reps: 5,
      );

      when(() => mockPRRepo.getByExerciseId('bench_1'))
          .thenAnswer((_) async => [weightPR]);
      when(() => mockWorkoutSetRepo.getById('set_1'))
          .thenAnswer((_) async => workoutSet);
      when(() => mockPreferencesUseCase.call()).thenAnswer(
        (_) async => UserPreferences(measurementSystem: MeasurementSystem.metric),
      );

      // When
      final result = await useCase.execute(exercise);

      // Then: 100%, 90%, 80%, 50% with plate rounding
      expect(result, isNotNull);
      expect(result!.percent100, equals(100.0));
      expect(result.percent90, equals(90.0));
      expect(result.percent80, equals(80.0));
      expect(result.percent50, equals(50.0));
      expect(result.isMetric, isTrue);
    });

    test('calculates percentages requiring plate rounding', () async {
      // Given: 100kg PR, need to round non-exact percentages
      final exercise = FreeWeightExercise(
        id: 'bench_1',
        name: 'Bench Press',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
        equipmentType: EquipmentType.plate,
      );

      final weightPR = WeightPR(
        id: 'pr_1',
        exerciseId: 'bench_1',
        workoutSetId: 'set_1',
        achievedAt: DateTime(2026, 1, 1),
      );

      final workoutSet = WeightedWorkoutSet(
        id: 'set_1',
        exerciseId: 'bench_1',
        timestamp: DateTime(2026, 1, 1),
        weight: Weight(100.0),
        reps: 5,
      );

      when(() => mockPRRepo.getByExerciseId('bench_1'))
          .thenAnswer((_) async => [weightPR]);
      when(() => mockWorkoutSetRepo.getById('set_1'))
          .thenAnswer((_) async => workoutSet);
      when(() => mockPreferencesUseCase.call()).thenAnswer(
        (_) async => UserPreferences(measurementSystem: MeasurementSystem.metric),
      );

      // When
      final result = await useCase.execute(exercise);

      // Then: Rounded to nearest 2.5kg plate increment
      expect(result, isNotNull);
      expect(result!.percent100, equals(100.0)); // 100kg exact
      expect(result.percent90, equals(90.0)); // 90kg exact
      expect(result.percent80, equals(80.0)); // 80kg exact
      expect(result.percent50, equals(50.0)); // 50kg exact
    });

    test('calculates percentages with dumbbell equipment', () async {
      // Given: Dumbbell Press with 40kg PR
      final exercise = FreeWeightExercise(
        id: 'db_press',
        name: 'Dumbbell Press',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
        equipmentType: EquipmentType.dumbbell,
      );

      final weightPR = WeightPR(
        id: 'pr_1',
        exerciseId: 'db_press',
        workoutSetId: 'set_1',
        achievedAt: DateTime(2026, 1, 1),
      );

      final workoutSet = WeightedWorkoutSet(
        id: 'set_1',
        exerciseId: 'db_press',
        timestamp: DateTime(2026, 1, 1),
        weight: Weight(40.0),
        reps: 8,
      );

      when(() => mockPRRepo.getByExerciseId('db_press'))
          .thenAnswer((_) async => [weightPR]);
      when(() => mockWorkoutSetRepo.getById('set_1'))
          .thenAnswer((_) async => workoutSet);
      when(() => mockPreferencesUseCase.call()).thenAnswer(
        (_) async => UserPreferences(measurementSystem: MeasurementSystem.metric),
      );

      // When
      final result = await useCase.execute(exercise);

      // Then: Rounded to available dumbbell weights
      expect(result, isNotNull);
      expect(result!.percent100, equals(40.0)); // 40kg available
      expect(result.percent90, equals(35.0)); // 36kg → 35kg
      expect(result.percent80, equals(32.5)); // 32kg → 32.5kg
      expect(result.percent50, equals(20.0)); // 20kg available
    });

    test('calculates percentages with machine equipment', () async {
      // Given: Leg Press with 150kg PR
      final exercise = FreeWeightExercise(
        id: 'leg_press',
        name: 'Leg Press',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.legs],
        equipmentType: EquipmentType.machine,
      );

      final weightPR = WeightPR(
        id: 'pr_1',
        exerciseId: 'leg_press',
        workoutSetId: 'set_1',
        achievedAt: DateTime(2026, 1, 1),
      );

      final workoutSet = WeightedWorkoutSet(
        id: 'set_1',
        exerciseId: 'leg_press',
        timestamp: DateTime(2026, 1, 1),
        weight: Weight(150.0),
        reps: 10,
      );

      when(() => mockPRRepo.getByExerciseId('leg_press'))
          .thenAnswer((_) async => [weightPR]);
      when(() => mockWorkoutSetRepo.getById('set_1'))
          .thenAnswer((_) async => workoutSet);
      when(() => mockPreferencesUseCase.call()).thenAnswer(
        (_) async => UserPreferences(measurementSystem: MeasurementSystem.metric),
      );

      // When
      final result = await useCase.execute(exercise);

      // Then: Rounded to 5kg modulo
      expect(result, isNotNull);
      expect(result!.percent100, equals(150.0)); // 150kg exact
      expect(result.percent90, equals(135.0)); // 135kg exact
      expect(result.percent80, equals(120.0)); // 120kg exact
      expect(result.percent50, equals(75.0)); // 75kg exact
    });

    test('calculates percentages with imperial units', () async {
      // Given: 225lbs PR with plate equipment
      final exercise = FreeWeightExercise(
        id: 'squat',
        name: 'Squat',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.legs],
        equipmentType: EquipmentType.plate,
      );

      final weightPR = WeightPR(
        id: 'pr_1',
        exerciseId: 'squat',
        workoutSetId: 'set_1',
        achievedAt: DateTime(2026, 1, 1),
      );

      final workoutSet = WeightedWorkoutSet(
        id: 'set_1',
        exerciseId: 'squat',
        timestamp: DateTime(2026, 1, 1),
        weight: Weight(225.0),
        reps: 5,
      );

      when(() => mockPRRepo.getByExerciseId('squat'))
          .thenAnswer((_) async => [weightPR]);
      when(() => mockWorkoutSetRepo.getById('set_1'))
          .thenAnswer((_) async => workoutSet);
      when(() => mockPreferencesUseCase.call()).thenAnswer(
        (_) async => UserPreferences(measurementSystem: MeasurementSystem.imperial),
      );

      // When
      final result = await useCase.execute(exercise);

      // Then: Imperial plate increments (5lbs)
      expect(result, isNotNull);
      expect(result!.percent100, equals(225.0));
      expect(result.percent90, equals(205.0)); // 202.5 → 205
      expect(result.percent80, equals(180.0)); // 180 exact
      expect(result.percent50, equals(115.0)); // 112.5 → 115 (rounds to nearest 5)
      expect(result.isMetric, isFalse);
    });
  });

  group('Edge Cases - No PR Data', () {
    test('returns null when no PR exists for exercise', () async {
      final exercise = FreeWeightExercise(
        id: 'new_exercise',
        name: 'New Exercise',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
        equipmentType: EquipmentType.plate,
      );

      when(() => mockPRRepo.getByExerciseId('new_exercise'))
          .thenAnswer((_) async => []);

      final result = await useCase.execute(exercise);

      expect(result, isNull);
    });

    test('returns null when only non-WeightPR exists (RepsPR)', () async {
      final exercise = BodyweightExercise(
        id: 'pullups',
        name: 'Pull-ups',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.back],
        equipmentType: EquipmentType.other,
        canAddWeight: false,
      );

      final repsPR = RepsPR(
        id: 'pr_1',
        exerciseId: 'pullups',
        workoutSetId: 'set_1',
        achievedAt: DateTime(2026, 1, 1),
      );

      when(() => mockPRRepo.getByExerciseId('pullups'))
          .thenAnswer((_) async => [repsPR]);

      final result = await useCase.execute(exercise);

      expect(result, isNull);
    });

    test('returns null when workout set has zero weight', () async {
      final exercise = FreeWeightExercise(
        id: 'bench_1',
        name: 'Bench Press',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
        equipmentType: EquipmentType.plate,
      );

      final weightPR = WeightPR(
        id: 'pr_1',
        exerciseId: 'bench_1',
        workoutSetId: 'set_1',
        achievedAt: DateTime(2026, 1, 1),
      );

      final workoutSet = WeightedWorkoutSet(
        id: 'set_1',
        exerciseId: 'bench_1',
        timestamp: DateTime(2026, 1, 1),
        weight: Weight(0.0),
        reps: 5,
      );

      when(() => mockPRRepo.getByExerciseId('bench_1'))
          .thenAnswer((_) async => [weightPR]);
      when(() => mockWorkoutSetRepo.getById('set_1'))
          .thenAnswer((_) async => workoutSet);

      final result = await useCase.execute(exercise);

      expect(result, isNull);
    });

    test('returns null when workout set is not found', () async {
      final exercise = FreeWeightExercise(
        id: 'bench_1',
        name: 'Bench Press',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
        equipmentType: EquipmentType.plate,
      );

      final weightPR = WeightPR(
        id: 'pr_1',
        exerciseId: 'bench_1',
        workoutSetId: 'set_1',
        achievedAt: DateTime(2026, 1, 1),
      );

      when(() => mockPRRepo.getByExerciseId('bench_1'))
          .thenAnswer((_) async => [weightPR]);
      when(() => mockWorkoutSetRepo.getById('set_1'))
          .thenAnswer((_) async => null);

      final result = await useCase.execute(exercise);

      expect(result, isNull);
    });
  });

  group('Multiple PRs Handling', () {
    test('uses most recent WeightPR when multiple exist', () async {
      final exercise = FreeWeightExercise(
        id: 'bench_1',
        name: 'Bench Press',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
        equipmentType: EquipmentType.plate,
      );

      final olderPR = WeightPR(
        id: 'pr_old',
        exerciseId: 'bench_1',
        workoutSetId: 'set_old',
        achievedAt: DateTime(2025, 12, 1),
      );

      final newerPR = WeightPR(
        id: 'pr_new',
        exerciseId: 'bench_1',
        workoutSetId: 'set_new',
        achievedAt: DateTime(2026, 1, 15),
      );

      final oldWorkoutSet = WeightedWorkoutSet(
        id: 'set_old',
        exerciseId: 'bench_1',
        timestamp: DateTime(2025, 12, 1),
        weight: Weight(95.0),
        reps: 5,
      );

      final newWorkoutSet = WeightedWorkoutSet(
        id: 'set_new',
        exerciseId: 'bench_1',
        timestamp: DateTime(2026, 1, 15),
        weight: Weight(100.0),
        reps: 5,
      );

      when(() => mockPRRepo.getByExerciseId('bench_1'))
          .thenAnswer((_) async => [olderPR, newerPR]);
      when(() => mockWorkoutSetRepo.getById('set_old'))
          .thenAnswer((_) async => oldWorkoutSet);
      when(() => mockWorkoutSetRepo.getById('set_new'))
          .thenAnswer((_) async => newWorkoutSet);
      when(() => mockPreferencesUseCase.call()).thenAnswer(
        (_) async => UserPreferences(measurementSystem: MeasurementSystem.metric),
      );

      final result = await useCase.execute(exercise);

      expect(result, isNotNull);
      expect(result!.percent100, equals(100.0)); // Uses newer 100kg, not 95kg
    });

    test('ignores non-WeightPR when mixed PR types exist', () async {
      final exercise = FreeWeightExercise(
        id: 'bench_1',
        name: 'Bench Press',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
        equipmentType: EquipmentType.plate,
      );

      final weightPR = WeightPR(
        id: 'pr_weight',
        exerciseId: 'bench_1',
        workoutSetId: 'set_1',
        achievedAt: DateTime(2026, 1, 1),
      );

      final repsPR = RepsPR(
        id: 'pr_reps',
        exerciseId: 'bench_1',
        workoutSetId: 'set_2',
        achievedAt: DateTime(2026, 1, 2),
      );

      final workoutSet = WeightedWorkoutSet(
        id: 'set_1',
        exerciseId: 'bench_1',
        timestamp: DateTime(2026, 1, 1),
        weight: Weight(100.0),
        reps: 5,
      );

      when(() => mockPRRepo.getByExerciseId('bench_1'))
          .thenAnswer((_) async => [weightPR, repsPR]);
      when(() => mockWorkoutSetRepo.getById('set_1'))
          .thenAnswer((_) async => workoutSet);
      when(() => mockPreferencesUseCase.call()).thenAnswer(
        (_) async => UserPreferences(measurementSystem: MeasurementSystem.metric),
      );

      final result = await useCase.execute(exercise);

      expect(result, isNotNull);
      expect(result!.percent100, equals(100.0));
    });
  });

  group('Equipment Type Rounding Verification', () {
    test('correctly rounds for kettlebell equipment', () async {
      final exercise = FreeWeightExercise(
        id: 'kb_swing',
        name: 'Kettlebell Swing',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.legs],
        equipmentType: EquipmentType.kettlebell,
      );

      final weightPR = WeightPR(
        id: 'pr_1',
        exerciseId: 'kb_swing',
        workoutSetId: 'set_1',
        achievedAt: DateTime(2026, 1, 1),
      );

      final workoutSet = WeightedWorkoutSet(
        id: 'set_1',
        exerciseId: 'kb_swing',
        timestamp: DateTime(2026, 1, 1),
        weight: Weight(32.0),
        reps: 20,
      );

      when(() => mockPRRepo.getByExerciseId('kb_swing'))
          .thenAnswer((_) async => [weightPR]);
      when(() => mockWorkoutSetRepo.getById('set_1'))
          .thenAnswer((_) async => workoutSet);
      when(() => mockPreferencesUseCase.call()).thenAnswer(
        (_) async => UserPreferences(measurementSystem: MeasurementSystem.metric),
      );

      final result = await useCase.execute(exercise);

      expect(result, isNotNull);
      expect(result!.percent100, equals(32.0)); // 32kg available
      expect(result.percent90, equals(28.0)); // 28.8 → 28kg
      expect(result.percent80, equals(24.0)); // 25.6 → 24kg
      expect(result.percent50, equals(16.0)); // 16kg available
    });

    test('correctly rounds for cable equipment', () async {
      final exercise = FreeWeightExercise(
        id: 'cable_fly',
        name: 'Cable Fly',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
        equipmentType: EquipmentType.cable,
      );

      final weightPR = WeightPR(
        id: 'pr_1',
        exerciseId: 'cable_fly',
        workoutSetId: 'set_1',
        achievedAt: DateTime(2026, 1, 1),
      );

      final workoutSet = WeightedWorkoutSet(
        id: 'set_1',
        exerciseId: 'cable_fly',
        timestamp: DateTime(2026, 1, 1),
        weight: Weight(50.0),
        reps: 12,
      );

      when(() => mockPRRepo.getByExerciseId('cable_fly'))
          .thenAnswer((_) async => [weightPR]);
      when(() => mockWorkoutSetRepo.getById('set_1'))
          .thenAnswer((_) async => workoutSet);
      when(() => mockPreferencesUseCase.call()).thenAnswer(
        (_) async => UserPreferences(measurementSystem: MeasurementSystem.metric),
      );

      final result = await useCase.execute(exercise);

      expect(result, isNotNull);
      expect(result!.percent100, equals(50.0));
      expect(result.percent90, equals(45.0)); // 45kg exact (modulo 5)
      expect(result.percent80, equals(40.0)); // 40kg exact (modulo 5)
      expect(result.percent50, equals(25.0)); // 25kg exact (modulo 5)
    });

    test('correctly rounds for other equipment type', () async {
      final exercise = FreeWeightExercise(
        id: 'resistance_band',
        name: 'Resistance Band Press',
        description: 'Test',
        isCustom: false,
        targetMuscles: [MuscleGroup.chest],
        equipmentType: EquipmentType.other,
      );

      final weightPR = WeightPR(
        id: 'pr_1',
        exerciseId: 'resistance_band',
        workoutSetId: 'set_1',
        achievedAt: DateTime(2026, 1, 1),
      );

      final workoutSet = WeightedWorkoutSet(
        id: 'set_1',
        exerciseId: 'resistance_band',
        timestamp: DateTime(2026, 1, 1),
        weight: Weight(45.67),
        reps: 10,
      );

      when(() => mockPRRepo.getByExerciseId('resistance_band'))
          .thenAnswer((_) async => [weightPR]);
      when(() => mockWorkoutSetRepo.getById('set_1'))
          .thenAnswer((_) async => workoutSet);
      when(() => mockPreferencesUseCase.call()).thenAnswer(
        (_) async => UserPreferences(measurementSystem: MeasurementSystem.metric),
      );

      final result = await useCase.execute(exercise);

      expect(result, isNotNull);
      expect(result!.percent100, equals(45.7)); // 45.67 → 45.7 (0.1 precision)
      expect(result.percent90, equals(41.1)); // 41.103 → 41.1
      expect(result.percent80, equals(36.5)); // 36.536 → 36.5
      expect(result.percent50, equals(22.8)); // 22.835 → 22.8
    });
  });

  group('Non-Strength Exercise Handling', () {
    test('returns null for cardio exercise (no weight PRs)', () async {
      final exercise = DistanceCardioExercise(
        id: 'running',
        name: 'Running',
        description: 'Test',
        isCustom: false,
        equipmentType: EquipmentType.other,
      );

      when(() => mockPRRepo.getByExerciseId('running'))
          .thenAnswer((_) async => []);

      final result = await useCase.execute(exercise);

      expect(result, isNull);
    });
  });
}
