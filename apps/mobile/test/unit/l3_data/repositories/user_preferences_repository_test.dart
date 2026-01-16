import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phil/l2_domain/models/user_preferences.dart';
import 'package:phil/l3_data/repositories/user_preferences_repository.dart';

void main() {
  group('UserPreferencesRepository', () {
    late UserPreferencesRepository repository;

    setUp(() {
      repository = UserPreferencesRepository();
      // Ensure clean state for each test
      SharedPreferences.setMockInitialValues({});
    });

    group('getMeasurementSystem', () {
      test('returns metric as default when not set', () async {
        final result = await repository.getMeasurementSystem();

        expect(result, equals(MeasurementSystem.metric));
      });

      test('returns saved metric value', () async {
        SharedPreferences.setMockInitialValues({
          'measurement_system': 'metric',
        });

        final result = await repository.getMeasurementSystem();

        expect(result, equals(MeasurementSystem.metric));
      });

      test('returns saved imperial value', () async {
        SharedPreferences.setMockInitialValues({
          'measurement_system': 'imperial',
        });

        final result = await repository.getMeasurementSystem();

        expect(result, equals(MeasurementSystem.imperial));
      });

      test('returns metric when invalid value is stored', () async {
        SharedPreferences.setMockInitialValues({
          'measurement_system': 'invalid_value',
        });

        final result = await repository.getMeasurementSystem();

        expect(result, equals(MeasurementSystem.metric));
      });
    });

    group('setMeasurementSystem', () {
      test('saves metric preference', () async {
        await repository.setMeasurementSystem(MeasurementSystem.metric);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('measurement_system'), equals('metric'));
      });

      test('saves imperial preference', () async {
        await repository.setMeasurementSystem(MeasurementSystem.imperial);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('measurement_system'), equals('imperial'));
      });

      test('overwrites existing preference', () async {
        await repository.setMeasurementSystem(MeasurementSystem.metric);
        await repository.setMeasurementSystem(MeasurementSystem.imperial);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('measurement_system'), equals('imperial'));
      });
    });

    group('getUserPreferences', () {
      test('returns preferences with default measurement system', () async {
        final result = await repository.getUserPreferences();

        expect(result.measurementSystem, equals(MeasurementSystem.metric));
      });

      test('returns preferences with saved measurement system', () async {
        SharedPreferences.setMockInitialValues({
          'measurement_system': 'imperial',
        });

        final result = await repository.getUserPreferences();

        expect(result.measurementSystem, equals(MeasurementSystem.imperial));
      });
    });

    group('saveUserPreferences', () {
      test('saves measurement system from preferences object', () async {
        final preferences = UserPreferences(
          measurementSystem: MeasurementSystem.imperial,
        );

        await repository.saveUserPreferences(preferences);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('measurement_system'), equals('imperial'));
      });

      test('updates existing preferences', () async {
        await repository.saveUserPreferences(
          UserPreferences(measurementSystem: MeasurementSystem.metric),
        );

        await repository.saveUserPreferences(
          UserPreferences(measurementSystem: MeasurementSystem.imperial),
        );

        final saved = await repository.getUserPreferences();
        expect(saved.measurementSystem, equals(MeasurementSystem.imperial));
      });
    });

    group('clear', () {
      test('removes all preferences', () async {
        await repository.setMeasurementSystem(MeasurementSystem.imperial);

        await repository.clear();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('measurement_system'), isNull);
      });

      test('after clear, getMeasurementSystem returns default', () async {
        await repository.setMeasurementSystem(MeasurementSystem.imperial);
        await repository.clear();

        final result = await repository.getMeasurementSystem();

        expect(result, equals(MeasurementSystem.metric));
      });
    });

    group('round-trip', () {
      test('can save and load preferences', () async {
        final original = UserPreferences(
          measurementSystem: MeasurementSystem.imperial,
        );

        await repository.saveUserPreferences(original);
        final loaded = await repository.getUserPreferences();

        expect(loaded.measurementSystem, equals(original.measurementSystem));
      });

      test('metric system round-trip', () async {
        await repository.setMeasurementSystem(MeasurementSystem.metric);
        final result = await repository.getMeasurementSystem();

        expect(result, equals(MeasurementSystem.metric));
      });

      test('imperial system round-trip', () async {
        await repository.setMeasurementSystem(MeasurementSystem.imperial);
        final result = await repository.getMeasurementSystem();

        expect(result, equals(MeasurementSystem.imperial));
      });
    });
  });
}
