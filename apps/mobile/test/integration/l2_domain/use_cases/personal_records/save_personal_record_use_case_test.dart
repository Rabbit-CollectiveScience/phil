import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/legacy_models/personal_record.dart';
import 'package:phil/l2_domain/use_cases/personal_records/save_personal_record_use_case.dart';
import 'package:phil/l3_data/repositories/personal_record_repository.dart';
import 'package:phil/l3_data/repositories/stub_personal_record_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PersonalRecordRepository prRepo;
  late SavePersonalRecordUseCase useCase;

  setUp(() {
    prRepo = StubPersonalRecordRepository();
    useCase = SavePersonalRecordUseCase(prRepo);
  });

  group('SavePersonalRecordUseCase', () {
    test('saves PR successfully and returns saved record', () async {
      final pr = PersonalRecord(
        id: 'pr_1',
        exerciseId: 'bench_press',
        type: 'maxWeight',
        value: 100.0,
        achievedAt: DateTime(2026, 1, 2),
      );

      final result = await useCase.execute(pr);

      expect(result, isNotNull);
      expect(result.id, equals('pr_1'));
      expect(result.exerciseId, equals('bench_press'));
      expect(result.value, equals(100.0));
    });

    test('generates unique ID for new PR', () async {
      final pr1 = await useCase.execute(
        PersonalRecord(
          id: 'pr_1',
          exerciseId: 'bench_press',
          type: 'maxWeight',
          value: 100.0,
          achievedAt: DateTime(2026, 1, 2),
        ),
      );

      final pr2 = await useCase.execute(
        PersonalRecord(
          id: 'pr_2',
          exerciseId: 'squat',
          type: 'maxWeight',
          value: 150.0,
          achievedAt: DateTime(2026, 1, 2),
        ),
      );

      expect(pr1.id, isNot(equals(pr2.id)));
    });

    test('preserves all PR fields correctly', () async {
      final date = DateTime(2026, 1, 2, 14, 30);
      final pr = PersonalRecord(
        id: 'pr_test',
        exerciseId: 'deadlift',
        type: 'maxWeight',
        value: 180.5,
        achievedAt: date,
      );

      final result = await useCase.execute(pr);

      expect(result.id, equals('pr_test'));
      expect(result.exerciseId, equals('deadlift'));
      expect(result.type, equals('maxWeight'));
      expect(result.value, equals(180.5));
      expect(result.achievedAt, equals(date));
    });

    test('saves maxWeight PR correctly', () async {
      final pr = PersonalRecord(
        id: 'pr_1',
        exerciseId: 'bench_press',
        type: 'maxWeight',
        value: 100.0,
        achievedAt: DateTime(2026, 1, 2),
      );

      final result = await useCase.execute(pr);

      expect(result.type, equals('maxWeight'));
    });

    test('saves maxReps PR correctly', () async {
      final pr = PersonalRecord(
        id: 'pr_2',
        exerciseId: 'push_ups',
        type: 'maxReps',
        value: 50.0,
        achievedAt: DateTime(2026, 1, 2),
      );

      final result = await useCase.execute(pr);

      expect(result.type, equals('maxReps'));
    });

    test('saves maxVolume PR correctly', () async {
      final pr = PersonalRecord(
        id: 'pr_3',
        exerciseId: 'squat',
        type: 'maxVolume',
        value: 2700.0,
        achievedAt: DateTime(2026, 1, 2),
      );

      final result = await useCase.execute(pr);

      expect(result.type, equals('maxVolume'));
    });
  });
}
