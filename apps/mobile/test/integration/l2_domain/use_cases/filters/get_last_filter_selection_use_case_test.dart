import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:phil/l2_domain/use_cases/filters/get_last_filter_selection_use_case.dart';
import 'package:phil/l3_data/repositories/preferences_repository.dart';

import 'get_last_filter_selection_use_case_test.mocks.dart';

@GenerateMocks([PreferencesRepository])
void main() {
  group('GetLastFilterSelectionUseCase', () {
    late GetLastFilterSelectionUseCase useCase;
    late MockPreferencesRepository mockRepository;

    setUp(() {
      mockRepository = MockPreferencesRepository();
      useCase = GetLastFilterSelectionUseCase(mockRepository);
    });

    test('returns last filter ID from repository', () async {
      when(mockRepository.getLastFilterId()).thenAnswer((_) async => 'chest');

      final result = await useCase.execute();

      expect(result, 'chest');
      verify(mockRepository.getLastFilterId()).called(1);
    });

    test('returns null when no filter has been selected', () async {
      when(mockRepository.getLastFilterId()).thenAnswer((_) async => null);

      final result = await useCase.execute();

      expect(result, isNull);
    });

    test('returns default "all" when repository returns null', () async {
      when(mockRepository.getLastFilterId()).thenAnswer((_) async => null);

      final result = await useCase.executeWithDefault();

      expect(result, 'all');
    });
  });
}
