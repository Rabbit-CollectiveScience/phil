import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/use_cases/filters/record_filter_selection_use_case.dart';
import 'package:phil/l2_domain/use_cases/filters/get_last_filter_selection_use_case.dart';
import 'package:phil/l2_domain/use_cases/filters/should_show_filter_page_use_case.dart';
import 'package:phil/l3_data/repositories/preferences_repository.dart';

// Mock implementation of PreferencesRepository for testing
class MockPreferencesRepository implements PreferencesRepository {
  String? _lastFilterId;
  DateTime? _lastFilterTimestamp;

  @override
  Future<String?> getLastFilterId() async {
    return _lastFilterId;
  }

  @override
  Future<DateTime?> getLastFilterTimestamp() async {
    return _lastFilterTimestamp;
  }

  @override
  Future<void> saveFilterSelection(String filterId, DateTime timestamp) async {
    _lastFilterId = filterId;
    _lastFilterTimestamp = timestamp;
  }

  void clear() {
    _lastFilterId = null;
    _lastFilterTimestamp = null;
  }
}

void main() {
  late PreferencesRepository preferencesRepository;

  setUp(() async {
    // Use mock repository since PreferencesRepository requires SharedPreferences
    preferencesRepository = MockPreferencesRepository();
  });

  tearDown(() async {
    (preferencesRepository as MockPreferencesRepository).clear();
  });

  group('RecordFilterSelectionUseCase Integration Tests', () {
    test('saves filter selection with timestamp', () async {
      final useCase = RecordFilterSelectionUseCase(preferencesRepository);

      await useCase.execute('chest');

      final filterId = await preferencesRepository.getLastFilterId();
      final timestamp = await preferencesRepository.getLastFilterTimestamp();

      expect(filterId, 'chest');
      expect(timestamp, isNotNull);
    });

    test('saves filter selection with custom timestamp', () async {
      final useCase = RecordFilterSelectionUseCase(preferencesRepository);
      final customTime = DateTime(2025, 1, 1, 12, 0);

      await useCase.execute('legs', timestamp: customTime);

      final timestamp = await preferencesRepository.getLastFilterTimestamp();
      expect(timestamp, customTime);
    });

    test('overwrites previous filter selection', () async {
      final useCase = RecordFilterSelectionUseCase(preferencesRepository);

      await useCase.execute('chest');
      await useCase.execute('back');

      final filterId = await preferencesRepository.getLastFilterId();
      expect(filterId, 'back');
    });

    test('saves different filter IDs', () async {
      final useCase = RecordFilterSelectionUseCase(preferencesRepository);

      final filterIds = [
        'chest',
        'legs',
        'back',
        'shoulders',
        'all',
        'strength',
        'cardio',
      ];

      for (final id in filterIds) {
        await useCase.execute(id);
        final saved = await preferencesRepository.getLastFilterId();
        expect(saved, id);
      }
    });
  });

  group('GetLastFilterSelectionUseCase Integration Tests', () {
    test('returns null when no filter has been saved', () async {
      final useCase = GetLastFilterSelectionUseCase(preferencesRepository);

      final result = await useCase.execute();

      expect(result, isNull);
    });

    test('returns default value when no filter has been saved', () async {
      final useCase = GetLastFilterSelectionUseCase(preferencesRepository);

      final result = await useCase.executeWithDefault();

      expect(result, 'all');
    });

    test('retrieves saved filter selection', () async {
      await preferencesRepository.saveFilterSelection('chest', DateTime.now());

      final useCase = GetLastFilterSelectionUseCase(preferencesRepository);

      final result = await useCase.execute();

      expect(result, 'chest');
    });

    test(
      'retrieves most recent filter when multiple have been saved',
      () async {
        await preferencesRepository.saveFilterSelection(
          'chest',
          DateTime.now(),
        );
        await Future.delayed(const Duration(milliseconds: 10));
        await preferencesRepository.saveFilterSelection('back', DateTime.now());

        final useCase = GetLastFilterSelectionUseCase(preferencesRepository);

        final result = await useCase.execute();

        expect(result, 'back'); // Most recent
      },
    );
  });

  group('ShouldShowFilterPageUseCase Integration Tests', () {
    test('returns true when no filter has been selected', () async {
      final useCase = ShouldShowFilterPageUseCase(preferencesRepository);

      final result = await useCase.execute();

      expect(result, true);
    });

    test('returns false when filter was selected recently', () async {
      await preferencesRepository.saveFilterSelection('chest', DateTime.now());

      final useCase = ShouldShowFilterPageUseCase(preferencesRepository);

      final result = await useCase.execute();

      expect(result, false);
    });

    test('returns true when filter is older than 2 hours', () async {
      final twoHoursOneMinuteAgo = DateTime.now().subtract(
        const Duration(hours: 2, minutes: 1),
      );
      await preferencesRepository.saveFilterSelection(
        'chest',
        twoHoursOneMinuteAgo,
      );

      final useCase = ShouldShowFilterPageUseCase(preferencesRepository);

      final result = await useCase.execute();

      expect(result, true);
    });

    test('returns false when filter is at most 2 hours old', () async {
      // Test just under 2 hours - should return false
      final almostTwoHours = DateTime.now().subtract(
        const Duration(hours: 2, seconds: -1),
      );
      await preferencesRepository.saveFilterSelection(
        'chest',
        almostTwoHours,
      );

      final useCase = ShouldShowFilterPageUseCase(preferencesRepository);

      final result = await useCase.execute();

      // Less than 2 hours should return false (threshold is >)
      expect(result, false);
    });

    test('uses 2-hour threshold', () async {
      // 1 hour 59 minutes ago - should not show
      final almostTwoHoursAgo = DateTime.now().subtract(
        const Duration(hours: 1, minutes: 59),
      );
      await preferencesRepository.saveFilterSelection(
        'chest',
        almostTwoHoursAgo,
      );

      final useCase = ShouldShowFilterPageUseCase(preferencesRepository);

      expect(await useCase.execute(), false);
    });

    test('returns false for selection made seconds ago', () async {
      final thirtySecondsAgo = DateTime.now().subtract(
        const Duration(seconds: 30),
      );
      await preferencesRepository.saveFilterSelection(
        'chest',
        thirtySecondsAgo,
      );

      final useCase = ShouldShowFilterPageUseCase(preferencesRepository);

      final result = await useCase.execute();

      expect(result, false);
    });
  });

  group('Filter Use Cases Integration Tests', () {
    test('complete workflow: record, retrieve, and check age', () async {
      final recordUseCase = RecordFilterSelectionUseCase(preferencesRepository);
      final getUseCase = GetLastFilterSelectionUseCase(preferencesRepository);
      final shouldShowUseCase = ShouldShowFilterPageUseCase(
        preferencesRepository,
      );

      // Initially should show filter page
      expect(await shouldShowUseCase.execute(), true);

      // Record a filter selection
      await recordUseCase.execute('chest');

      // Should not show filter page anymore
      expect(await shouldShowUseCase.execute(), false);

      // Retrieve the selection
      final selection = await getUseCase.execute();
      expect(selection, 'chest');
    });

    test('filter expiration workflow', () async {
      final recordUseCase = RecordFilterSelectionUseCase(preferencesRepository);
      final shouldShowUseCase = ShouldShowFilterPageUseCase(
        preferencesRepository,
      );

      // Record a filter
      await recordUseCase.execute('chest');

      // Recent filter - should not show
      expect(await shouldShowUseCase.execute(), false);

      // Simulate old filter by setting timestamp to 3 hours ago
      await preferencesRepository.saveFilterSelection(
        'chest',
        DateTime.now().subtract(const Duration(hours: 3)),
      );

      // Old filter - should show
      expect(await shouldShowUseCase.execute(), true);
    });

    test('updating filter resets age check', () async {
      final recordUseCase = RecordFilterSelectionUseCase(preferencesRepository);
      final shouldShowUseCase = ShouldShowFilterPageUseCase(
        preferencesRepository,
      );

      // Create old filter (3 hours ago)
      await preferencesRepository.saveFilterSelection(
        'chest',
        DateTime.now().subtract(const Duration(hours: 3)),
      );

      // Should show due to age
      expect(await shouldShowUseCase.execute(), true);

      // Update filter
      await recordUseCase.execute('back');

      // Should not show anymore
      expect(await shouldShowUseCase.execute(), false);
    });

    test('changing filters updates all related data', () async {
      final recordUseCase = RecordFilterSelectionUseCase(preferencesRepository);
      final getUseCase = GetLastFilterSelectionUseCase(preferencesRepository);

      // Set initial filter
      await recordUseCase.execute('chest');
      final first = await getUseCase.execute();
      final firstTimestamp = await preferencesRepository
          .getLastFilterTimestamp();
      expect(first, 'chest');

      await Future.delayed(const Duration(milliseconds: 10));

      // Change filter
      await recordUseCase.execute('legs');
      final second = await getUseCase.execute();
      final secondTimestamp = await preferencesRepository
          .getLastFilterTimestamp();

      expect(second, 'legs');
      expect(secondTimestamp!.isAfter(firstTimestamp!), true);
    });
  });
}
