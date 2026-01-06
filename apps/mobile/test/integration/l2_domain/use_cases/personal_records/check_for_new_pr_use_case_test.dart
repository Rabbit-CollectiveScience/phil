import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/legacy_models/exercise.dart';
import 'package:phil/l2_domain/legacy_models/exercise_field.dart';
import 'package:phil/l2_domain/legacy_models/field_type_enum.dart';
import 'package:phil/l2_domain/legacy_models/personal_record.dart';
import 'package:phil/l2_domain/use_cases/personal_records/check_for_new_pr_use_case.dart';
import 'package:phil/l3_data/repositories/personal_record_repository.dart';
import 'package:phil/l3_data/repositories/stub_personal_record_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PersonalRecordRepository prRepo;
  late CheckForNewPRUseCase useCase;

  setUp(() {
    prRepo = StubPersonalRecordRepository();
    useCase = CheckForNewPRUseCase(prRepo);
  });

  group('CheckForNewPRUseCase', () {
    test('returns isNewPR=true when no existing PR', () async {
      final exercise = Exercise(
        id: 'bench_press',
        name: 'Bench Press',
        description: 'Barbell bench press',
        categories: ['strength', 'chest'],
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

      final results = await useCase.execute(
        exerciseId: 'bench_press',
        exercise: exercise,
        values: {'weight': 100.0, 'reps': 10},
      );

      expect(results.length, greaterThan(0));
      expect(results.first.isNewPR, isTrue);
      expect(results.first.prType, equals('maxWeight'));
      expect(results.first.newValue, equals(100.0));
      expect(results.first.oldValue, isNull);
    });

    test('returns isNewPR=true when new weight exceeds current PR', () async {
      final exercise = Exercise(
        id: 'bench_press',
        name: 'Bench Press',
        description: 'Barbell bench press',
        categories: ['strength', 'chest'],
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

      await prRepo.save(
        PersonalRecord(
          id: 'pr_1',
          exerciseId: 'bench_press',
          type: 'maxWeight',
          value: 95.0,
          achievedAt: DateTime(2026, 1, 1),
        ),
      );

      final results = await useCase.execute(
        exerciseId: 'bench_press',
        exercise: exercise,
        values: {'weight': 100.0, 'reps': 10},
      );

      final weightPR = results.firstWhere((r) => r.prType == 'maxWeight');
      expect(weightPR.isNewPR, isTrue);
      expect(weightPR.newValue, equals(100.0));
      expect(weightPR.oldValue, equals(95.0));
    });

    test('returns isNewPR=false when new weight equals current PR', () async {
      final exercise = Exercise(
        id: 'bench_press',
        name: 'Bench Press',
        description: 'Barbell bench press',
        categories: ['strength', 'chest'],
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

      await prRepo.save(
        PersonalRecord(
          id: 'pr_1',
          exerciseId: 'bench_press',
          type: 'maxWeight',
          value: 100.0,
          achievedAt: DateTime(2026, 1, 1),
        ),
      );

      final results = await useCase.execute(
        exerciseId: 'bench_press',
        exercise: exercise,
        values: {'weight': 100.0, 'reps': 10},
      );

      final weightPRs = results.where(
        (r) => r.prType == 'maxWeight' && r.isNewPR,
      );
      expect(weightPRs, isEmpty);
    });

    test(
      'returns isNewPR=false when new weight is less than current PR',
      () async {
        final exercise = Exercise(
          id: 'bench_press',
          name: 'Bench Press',
          description: 'Barbell bench press',
          categories: ['strength', 'chest'],
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

        await prRepo.save(
          PersonalRecord(
            id: 'pr_1',
            exerciseId: 'bench_press',
            type: 'maxWeight',
            value: 100.0,
            achievedAt: DateTime(2026, 1, 1),
          ),
        );

        final results = await useCase.execute(
          exerciseId: 'bench_press',
          exercise: exercise,
          values: {'weight': 95.0, 'reps': 10},
        );

        final weightPRs = results.where(
          (r) => r.prType == 'maxWeight' && r.isNewPR,
        );
        expect(weightPRs, isEmpty);
      },
    );

    test('detects new maxReps PR for bodyweight exercises', () async {
      final exercise = Exercise(
        id: 'push_ups',
        name: 'Push-ups',
        description: 'Standard push-ups',
        categories: ['strength', 'chest'],
        fields: [
          ExerciseField(
            name: 'reps',
            label: 'Reps',
            unit: 'reps',
            type: FieldTypeEnum.number,
          ),
        ],
      );

      final results = await useCase.execute(
        exerciseId: 'push_ups',
        exercise: exercise,
        values: {'reps': 50},
      );

      expect(results.length, greaterThan(0));
      expect(results.first.isNewPR, isTrue);
      expect(results.first.prType, equals('maxReps'));
      expect(results.first.newValue, equals(50.0));
    });

    test('detects multiple PRs in one set (weight + volume)', () async {
      final exercise = Exercise(
        id: 'squat',
        name: 'Squat',
        description: 'Barbell squat',
        categories: ['strength', 'legs'],
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

      final results = await useCase.execute(
        exerciseId: 'squat',
        exercise: exercise,
        values: {'weight': 150.0, 'reps': 10},
      );

      expect(results.where((r) => r.isNewPR).length, greaterThanOrEqualTo(1));

      final weightPR = results.where(
        (r) => r.prType == 'maxWeight' && r.isNewPR,
      );
      expect(weightPR, isNotEmpty);
    });

    test('returns empty list when values are null/empty', () async {
      final exercise = Exercise(
        id: 'bench_press',
        name: 'Bench Press',
        description: 'Barbell bench press',
        categories: ['strength', 'chest'],
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

      final results = await useCase.execute(
        exerciseId: 'bench_press',
        exercise: exercise,
        values: null,
      );
      expect(results, isEmpty);

      final results2 = await useCase.execute(
        exerciseId: 'bench_press',
        exercise: exercise,
        values: {},
      );
      expect(results2, isEmpty);
    });
  });
}
