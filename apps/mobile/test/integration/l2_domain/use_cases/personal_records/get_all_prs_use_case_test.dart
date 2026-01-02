import 'package:flutter_test/flutter_test.dart';
import '../../../../../lib/l2_domain/models/personal_record.dart';
import '../../../../../lib/l2_domain/models/exercise.dart';
import '../../../../../lib/l2_domain/models/exercise_field.dart';
import '../../../../../lib/l2_domain/models/field_type_enum.dart';
import '../../../../../lib/l2_domain/use_cases/personal_records/get_all_prs_use_case.dart';
import '../../../../../lib/l3_data/repositories/stub_personal_record_repository.dart';
import '../../../../../lib/l3_data/repositories/exercise_repository.dart';

// Simple in-memory exercise repository for testing
class TestExerciseRepository implements ExerciseRepository {
  final List<Exercise> _exercises = [];

  void addExercise(Exercise exercise) {
    _exercises.add(exercise);
  }

  @override
  Future<List<Exercise>> getAllExercises() async => List.from(_exercises);

  @override
  Future<Exercise> getExerciseById(String id) async {
    return _exercises.firstWhere((e) => e.id == id);
  }

  @override
  Future<List<Exercise>> searchExercises(String query) async {
    return _exercises
        .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<Exercise> updateExercise(Exercise exercise) async {
    final index = _exercises.indexWhere((e) => e.id == exercise.id);
    if (index >= 0) {
      _exercises[index] = exercise;
    }
    return exercise;
  }
}

Exercise createTestExercise(String id, String name, List<String> categories) {
  return Exercise(
    id: id,
    name: name,
    description: 'Test $name',
    categories: categories,
    fields: [
      ExerciseField(
        name: 'weight',
        label: 'Weight',
        unit: 'kg',
        type: FieldTypeEnum.number,
      ),
      ExerciseField(
        name: 'reps',
        label: 'Reps',
        unit: 'reps',
        type: FieldTypeEnum.number,
      ),
    ],
  );
}

void main() {
  late StubPersonalRecordRepository prRepo;
  late TestExerciseRepository exerciseRepo;
  late GetAllPRsUseCase useCase;

  setUp(() {
    prRepo = StubPersonalRecordRepository();
    exerciseRepo = TestExerciseRepository();
    useCase = GetAllPRsUseCase(prRepo, exerciseRepo);
  });

  group('GetAllPRsUseCase', () {
    test('should return empty list when no PRs exist', () async {
      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, isEmpty);
    });

    test('should return all PRs with exercise details', () async {
      // Arrange - Create test exercises
      final squat = createTestExercise('squat_001', 'Barbell Squat', [
        'strength',
        'legs',
      ]);
      final benchPress = createTestExercise('bench_001', 'Bench Press', [
        'strength',
        'chest',
      ]);

      exerciseRepo.addExercise(squat);
      exerciseRepo.addExercise(benchPress);

      // Create PRs
      final pr1 = PersonalRecord(
        id: 'pr_001',
        exerciseId: squat.id,
        type: 'maxWeight',
        value: 150.0,
        achievedAt: DateTime(2026, 1, 1),
      );

      final pr2 = PersonalRecord(
        id: 'pr_002',
        exerciseId: squat.id,
        type: 'maxReps',
        value: 20.0,
        achievedAt: DateTime(2026, 1, 2),
      );

      final pr3 = PersonalRecord(
        id: 'pr_003',
        exerciseId: benchPress.id,
        type: 'maxWeight',
        value: 120.0,
        achievedAt: DateTime(2025, 12, 28),
      );

      await prRepo.save(pr1);
      await prRepo.save(pr2);
      await prRepo.save(pr3);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result.length, equals(3));

      // Check that all PRs are returned
      expect(result.any((pr) => pr.prRecord.id == 'pr_001'), isTrue);
      expect(result.any((pr) => pr.prRecord.id == 'pr_002'), isTrue);
      expect(result.any((pr) => pr.prRecord.id == 'pr_003'), isTrue);

      // Check that exercise details are included
      final squatWeightPR = result.firstWhere(
        (pr) => pr.prRecord.id == 'pr_001',
      );
      expect(squatWeightPR.exerciseName, equals('Barbell Squat'));
      expect(squatWeightPR.exerciseCategories, contains('legs'));
      expect(squatWeightPR.exerciseCategories, contains('strength'));

      final benchPR = result.firstWhere((pr) => pr.prRecord.id == 'pr_003');
      expect(benchPR.exerciseName, equals('Bench Press'));
      expect(benchPR.exerciseCategories, contains('chest'));
    });

    test('should handle PRs for deleted exercises gracefully', () async {
      // Arrange - Create test exercise
      final squat = createTestExercise('squat_001', 'Barbell Squat', [
        'strength',
        'legs',
      ]);
      exerciseRepo.addExercise(squat);

      final pr1 = PersonalRecord(
        id: 'pr_001',
        exerciseId: squat.id,
        type: 'maxWeight',
        value: 150.0,
        achievedAt: DateTime(2026, 1, 1),
      );

      // Create PR for non-existent exercise
      final pr2 = PersonalRecord(
        id: 'pr_002',
        exerciseId: 'deleted_exercise',
        type: 'maxWeight',
        value: 100.0,
        achievedAt: DateTime(2025, 12, 1),
      );

      await prRepo.save(pr1);
      await prRepo.save(pr2);

      // Act
      final result = await useCase.execute();

      // Assert - Should only return PR with valid exercise
      expect(result.length, equals(1));
      expect(result[0].prRecord.id, equals('pr_001'));
      expect(result[0].exerciseName, equals('Barbell Squat'));
    });

    test('should sort PRs by date descending (newest first)', () async {
      // Arrange - Create test exercise
      final squat = createTestExercise('squat_001', 'Barbell Squat', [
        'strength',
        'legs',
      ]);
      exerciseRepo.addExercise(squat);

      final oldPR = PersonalRecord(
        id: 'pr_old',
        exerciseId: squat.id,
        type: 'maxWeight',
        value: 100.0,
        achievedAt: DateTime(2025, 12, 1),
      );

      final recentPR = PersonalRecord(
        id: 'pr_recent',
        exerciseId: squat.id,
        type: 'maxReps',
        value: 15.0,
        achievedAt: DateTime(2026, 1, 2),
      );

      final newestPR = PersonalRecord(
        id: 'pr_newest',
        exerciseId: squat.id,
        type: 'maxVolume',
        value: 1500.0,
        achievedAt: DateTime(2026, 1, 3),
      );

      // Save in random order
      await prRepo.save(recentPR);
      await prRepo.save(oldPR);
      await prRepo.save(newestPR);

      // Act
      final result = await useCase.execute();

      // Assert - Should be sorted newest first
      expect(result.length, equals(3));
      expect(result[0].prRecord.id, equals('pr_newest'));
      expect(result[1].prRecord.id, equals('pr_recent'));
      expect(result[2].prRecord.id, equals('pr_old'));
    });
  });
}
