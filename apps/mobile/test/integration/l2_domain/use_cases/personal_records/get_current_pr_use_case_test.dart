import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/legacy_models/personal_record.dart';
import 'package:phil/l2_domain/use_cases/personal_records/get_current_pr_use_case.dart';
import 'package:phil/l3_data/repositories/personal_record_repository.dart';
import 'package:phil/l3_data/repositories/stub_personal_record_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PersonalRecordRepository prRepo;
  late GetCurrentPRUseCase useCase;

  setUp(() {
    prRepo = StubPersonalRecordRepository();
    useCase = GetCurrentPRUseCase(prRepo);
  });

  group('GetCurrentPRUseCase', () {
    test('returns null when no PR exists for exercise', () async {
      final result = await useCase.execute('nonexistent_exercise', 'maxWeight');

      expect(result, isNull);
    });

    test('returns maxWeight PR when it exists', () async {
      final pr = PersonalRecord(
        id: 'pr_1',
        exerciseId: 'bench_press',
        type: 'maxWeight',
        value: 100.0,
        achievedAt: DateTime(2026, 1, 1),
      );
      await prRepo.save(pr);

      final result = await useCase.execute('bench_press', 'maxWeight');

      expect(result, isNotNull);
      expect(result!.value, equals(100.0));
      expect(result.type, equals('maxWeight'));
    });

    test('returns maxReps PR when it exists', () async {
      final pr = PersonalRecord(
        id: 'pr_2',
        exerciseId: 'push_ups',
        type: 'maxReps',
        value: 50.0,
        achievedAt: DateTime(2026, 1, 1),
      );
      await prRepo.save(pr);

      final result = await useCase.execute('push_ups', 'maxReps');

      expect(result, isNotNull);
      expect(result!.value, equals(50.0));
      expect(result.type, equals('maxReps'));
    });

    test('returns maxVolume PR when it exists', () async {
      final pr = PersonalRecord(
        id: 'pr_3',
        exerciseId: 'squat',
        type: 'maxVolume',
        value: 2700.0,
        achievedAt: DateTime(2026, 1, 1),
      );
      await prRepo.save(pr);

      final result = await useCase.execute('squat', 'maxVolume');

      expect(result, isNotNull);
      expect(result!.value, equals(2700.0));
      expect(result.type, equals('maxVolume'));
    });

    test('returns the highest value when multiple PRs exist', () async {
      await prRepo.save(
        PersonalRecord(
          id: 'pr_1',
          exerciseId: 'bench_press',
          type: 'maxWeight',
          value: 95.0,
          achievedAt: DateTime(2025, 12, 1),
        ),
      );
      await prRepo.save(
        PersonalRecord(
          id: 'pr_2',
          exerciseId: 'bench_press',
          type: 'maxWeight',
          value: 100.0,
          achievedAt: DateTime(2026, 1, 1),
        ),
      );
      await prRepo.save(
        PersonalRecord(
          id: 'pr_3',
          exerciseId: 'bench_press',
          type: 'maxWeight',
          value: 97.5,
          achievedAt: DateTime(2025, 11, 1),
        ),
      );

      final result = await useCase.execute('bench_press', 'maxWeight');

      expect(result, isNotNull);
      expect(result!.value, equals(100.0));
      expect(result.id, equals('pr_2'));
    });

    test('returns most recent PR when values are equal', () async {
      await prRepo.save(
        PersonalRecord(
          id: 'pr_1',
          exerciseId: 'deadlift',
          type: 'maxWeight',
          value: 150.0,
          achievedAt: DateTime(2025, 12, 1),
        ),
      );
      await prRepo.save(
        PersonalRecord(
          id: 'pr_2',
          exerciseId: 'deadlift',
          type: 'maxWeight',
          value: 150.0,
          achievedAt: DateTime(2026, 1, 2),
        ),
      );

      final result = await useCase.execute('deadlift', 'maxWeight');

      expect(result, isNotNull);
      expect(result!.value, equals(150.0));
      expect(result.id, equals('pr_2'));
      expect(result.achievedAt, equals(DateTime(2026, 1, 2)));
    });
  });
}
