import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phil/l3_data/repositories/local_preferences_repository.dart';

void main() {
  group('LocalPreferencesRepository', () {
    late LocalPreferencesRepository repository;

    setUp(() async {
      // Reset SharedPreferences for each test
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = LocalPreferencesRepository(prefs);
    });

    group('getLastFilterId', () {
      test('returns null when no filter has been saved', () async {
        final result = await repository.getLastFilterId();
        expect(result, isNull);
      });

      test('returns saved filter ID', () async {
        await repository.saveFilterSelection('chest', DateTime.now());
        final result = await repository.getLastFilterId();
        expect(result, 'chest');
      });
    });

    group('getLastFilterTimestamp', () {
      test('returns null when no timestamp has been saved', () async {
        final result = await repository.getLastFilterTimestamp();
        expect(result, isNull);
      });

      test('returns saved timestamp', () async {
        final now = DateTime.now();
        await repository.saveFilterSelection('legs', now);
        final result = await repository.getLastFilterTimestamp();

        expect(result, isNotNull);
        expect(result!.year, now.year);
        expect(result.month, now.month);
        expect(result.day, now.day);
        expect(result.hour, now.hour);
        expect(result.minute, now.minute);
      });
    });

    group('saveFilterSelection', () {
      test('saves filter ID and timestamp', () async {
        final timestamp = DateTime(2025, 12, 30, 14, 30);
        await repository.saveFilterSelection('back', timestamp);

        final savedId = await repository.getLastFilterId();
        final savedTimestamp = await repository.getLastFilterTimestamp();

        expect(savedId, 'back');
        expect(savedTimestamp, timestamp);
      });

      test('overwrites previous filter selection', () async {
        await repository.saveFilterSelection('cardio', DateTime(2025, 12, 29));
        await repository.saveFilterSelection('arms', DateTime(2025, 12, 30));

        final savedId = await repository.getLastFilterId();
        expect(savedId, 'arms');
      });
    });
  });
}
