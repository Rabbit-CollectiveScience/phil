import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phil/l2_domain/models/user_preferences.dart';
import 'package:phil/l2_domain/use_cases/preferences/update_user_preferences_use_case.dart';
import 'package:phil/l3_data/repositories/user_preferences_repository.dart';

void main() {
  group('UpdateUserPreferencesUseCase', () {
    late UpdateUserPreferencesUseCase useCase;
    late UserPreferencesRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repository = UserPreferencesRepository();
      useCase = UpdateUserPreferencesUseCase(repository: repository);
    });

    test('returns true when update is successful', () async {
      final preferences = UserPreferences(
        measurementSystem: MeasurementSystem.imperial,
      );

      final result = await useCase(preferences);

      expect(result, isTrue);
    });

    test('saves metric preferences correctly', () async {
      final preferences = UserPreferences(
        measurementSystem: MeasurementSystem.metric,
      );

      final result = await useCase(preferences);

      expect(result, isTrue);

      // Verify it was actually saved
      final saved = await repository.getUserPreferences();
      expect(saved.measurementSystem, equals(MeasurementSystem.metric));
    });

    test('saves imperial preferences correctly', () async {
      final preferences = UserPreferences(
        measurementSystem: MeasurementSystem.imperial,
      );

      final result = await useCase(preferences);

      expect(result, isTrue);

      // Verify it was actually saved
      final saved = await repository.getUserPreferences();
      expect(saved.measurementSystem, equals(MeasurementSystem.imperial));
    });

    test('can update existing preferences', () async {
      // Save initial preferences
      final initial = UserPreferences(
        measurementSystem: MeasurementSystem.metric,
      );
      await useCase(initial);

      // Update to different preferences
      final updated = UserPreferences(
        measurementSystem: MeasurementSystem.imperial,
      );
      final result = await useCase(updated);

      expect(result, isTrue);

      // Verify the update was saved
      final saved = await repository.getUserPreferences();
      expect(saved.measurementSystem, equals(MeasurementSystem.imperial));
    });

    test('can be called multiple times', () async {
      final preferences1 = UserPreferences(
        measurementSystem: MeasurementSystem.metric,
      );
      final result1 = await useCase(preferences1);
      expect(result1, isTrue);

      final preferences2 = UserPreferences(
        measurementSystem: MeasurementSystem.imperial,
      );
      final result2 = await useCase(preferences2);
      expect(result2, isTrue);

      final preferences3 = UserPreferences(
        measurementSystem: MeasurementSystem.metric,
      );
      final result3 = await useCase(preferences3);
      expect(result3, isTrue);

      // Verify final state
      final saved = await repository.getUserPreferences();
      expect(saved.measurementSystem, equals(MeasurementSystem.metric));
    });

    test('persists changes across use case instances', () async {
      // Create first use case and save preferences
      final useCase1 = UpdateUserPreferencesUseCase(repository: repository);
      final preferences = UserPreferences(
        measurementSystem: MeasurementSystem.imperial,
      );
      await useCase1(preferences);

      // Create second use case and verify it can read the saved preferences
      final useCase2 = UpdateUserPreferencesUseCase(repository: repository);
      final saved = await repository.getUserPreferences();

      expect(saved.measurementSystem, equals(MeasurementSystem.imperial));
    });

    test('updates are immediately reflected in repository', () async {
      final preferences = UserPreferences(
        measurementSystem: MeasurementSystem.imperial,
      );

      await useCase(preferences);

      // Immediately check repository without delay
      final saved = await repository.getUserPreferences();
      expect(saved.measurementSystem, equals(MeasurementSystem.imperial));
    });
  });
}
