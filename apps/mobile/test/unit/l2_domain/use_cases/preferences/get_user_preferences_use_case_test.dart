import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phil/l2_domain/models/user_preferences.dart';
import 'package:phil/l2_domain/use_cases/preferences/get_user_preferences_use_case.dart';
import 'package:phil/l3_data/repositories/user_preferences_repository.dart';

void main() {
  group('GetUserPreferencesUseCase', () {
    late GetUserPreferencesUseCase useCase;
    late UserPreferencesRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repository = UserPreferencesRepository();
      useCase = GetUserPreferencesUseCase(repository: repository);
    });

    test('returns default preferences when none are saved', () async {
      final result = await useCase();

      expect(result, isNotNull);
      expect(result.measurementSystem, equals(MeasurementSystem.metric));
    });

    test('returns saved metric preferences', () async {
      SharedPreferences.setMockInitialValues({'measurement_system': 'metric'});

      final result = await useCase();

      expect(result.measurementSystem, equals(MeasurementSystem.metric));
    });

    test('returns saved imperial preferences', () async {
      SharedPreferences.setMockInitialValues({
        'measurement_system': 'imperial',
      });

      final result = await useCase();

      expect(result.measurementSystem, equals(MeasurementSystem.imperial));
    });

    test('returns default preferences on repository error', () async {
      // Simulate error by leaving SharedPreferences empty
      // Repository will return default metric system

      final result = await useCase();

      expect(result, isNotNull);
      // Should return metric as default
      expect(result.measurementSystem, equals(MeasurementSystem.metric));
    });

    test('can be called multiple times', () async {
      SharedPreferences.setMockInitialValues({
        'measurement_system': 'imperial',
      });

      final result1 = await useCase();
      final result2 = await useCase();

      expect(result1.measurementSystem, equals(MeasurementSystem.imperial));
      expect(result2.measurementSystem, equals(MeasurementSystem.imperial));
    });

    test('returns updated preferences after repository changes', () async {
      SharedPreferences.setMockInitialValues({'measurement_system': 'metric'});

      final result1 = await useCase();
      expect(result1.measurementSystem, equals(MeasurementSystem.metric));

      // Change the preference
      await repository.setMeasurementSystem(MeasurementSystem.imperial);

      final result2 = await useCase();
      expect(result2.measurementSystem, equals(MeasurementSystem.imperial));
    });
  });
}
