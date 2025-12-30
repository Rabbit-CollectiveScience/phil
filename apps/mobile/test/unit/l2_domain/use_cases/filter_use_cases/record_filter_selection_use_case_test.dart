import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:phil/l2_domain/use_cases/filter_use_cases/record_filter_selection_use_case.dart';
import 'package:phil/l3_data/repositories/preferences_repository.dart';

import 'record_filter_selection_use_case_test.mocks.dart';

@GenerateMocks([PreferencesRepository])
void main() {
  group('RecordFilterSelectionUseCase', () {
    late RecordFilterSelectionUseCase useCase;
    late MockPreferencesRepository mockRepository;

    setUp(() {
      mockRepository = MockPreferencesRepository();
      useCase = RecordFilterSelectionUseCase(mockRepository);
    });

    test('saves filter selection with current timestamp', () async {
      when(
        mockRepository.saveFilterSelection(any, any),
      ).thenAnswer((_) async => {});

      await useCase.execute('legs');

      final captured = verify(
        mockRepository.saveFilterSelection(captureAny, captureAny),
      ).captured;

      expect(captured[0], 'legs');
      expect(captured[1], isA<DateTime>());
    });

    test('saves filter selection with provided timestamp', () async {
      final timestamp = DateTime(2025, 12, 30, 15, 45);
      when(
        mockRepository.saveFilterSelection(any, any),
      ).thenAnswer((_) async => {});

      await useCase.execute('back', timestamp: timestamp);

      verify(mockRepository.saveFilterSelection('back', timestamp)).called(1);
    });

    test('saves "all" filter correctly', () async {
      when(
        mockRepository.saveFilterSelection(any, any),
      ).thenAnswer((_) async => {});

      await useCase.execute('all');

      final captured = verify(
        mockRepository.saveFilterSelection(captureAny, captureAny),
      ).captured;

      expect(captured[0], 'all');
    });
  });
}
