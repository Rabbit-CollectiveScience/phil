import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/user_preferences.dart';

void main() {
  group('MeasurementSystem', () {
    test('has metric value', () {
      expect(MeasurementSystem.metric, isNotNull);
    });

    test('has imperial value', () {
      expect(MeasurementSystem.imperial, isNotNull);
    });

    test('serializes to JSON correctly', () {
      expect(MeasurementSystem.metric.toJson(), 'metric');
      expect(MeasurementSystem.imperial.toJson(), 'imperial');
    });

    test('deserializes from JSON correctly', () {
      expect(MeasurementSystem.fromJson('metric'), MeasurementSystem.metric);
      expect(
        MeasurementSystem.fromJson('imperial'),
        MeasurementSystem.imperial,
      );
    });
  });

  group('UserPreferences', () {
    test('creates instance with measurement system', () {
      final prefs = UserPreferences(
        measurementSystem: MeasurementSystem.metric,
      );

      expect(prefs.measurementSystem, MeasurementSystem.metric);
    });

    test('serializes to JSON correctly', () {
      final prefs = UserPreferences(
        measurementSystem: MeasurementSystem.imperial,
      );

      final json = prefs.toJson();
      expect(json['measurementSystem'], 'imperial');
    });

    test('deserializes from JSON correctly', () {
      final json = {'measurementSystem': 'metric'};
      final prefs = UserPreferences.fromJson(json);

      expect(prefs.measurementSystem, MeasurementSystem.metric);
    });

    test('round-trip JSON serialization preserves data', () {
      final original = UserPreferences(
        measurementSystem: MeasurementSystem.imperial,
      );

      final json = original.toJson();
      final restored = UserPreferences.fromJson(json);

      expect(restored, original);
    });

    test('equality works correctly', () {
      final prefs1 = UserPreferences(
        measurementSystem: MeasurementSystem.metric,
      );
      final prefs2 = UserPreferences(
        measurementSystem: MeasurementSystem.metric,
      );
      final prefs3 = UserPreferences(
        measurementSystem: MeasurementSystem.imperial,
      );

      expect(prefs1, prefs2);
      expect(prefs1, isNot(prefs3));
    });

    test('hashCode works correctly', () {
      final prefs1 = UserPreferences(
        measurementSystem: MeasurementSystem.metric,
      );
      final prefs2 = UserPreferences(
        measurementSystem: MeasurementSystem.metric,
      );

      expect(prefs1.hashCode, prefs2.hashCode);
    });

    test('toString provides readable output', () {
      final prefs = UserPreferences(
        measurementSystem: MeasurementSystem.metric,
      );

      expect(
        prefs.toString(),
        'UserPreferences(measurementSystem: MeasurementSystem.metric)',
      );
    });

    test('copyWith creates new instance with updated field', () {
      final original = UserPreferences(
        measurementSystem: MeasurementSystem.metric,
      );

      final updated = original.copyWith(
        measurementSystem: MeasurementSystem.imperial,
      );

      expect(updated.measurementSystem, MeasurementSystem.imperial);
      expect(original.measurementSystem, MeasurementSystem.metric);
    });

    test('copyWith with no arguments returns equal instance', () {
      final original = UserPreferences(
        measurementSystem: MeasurementSystem.imperial,
      );

      final copy = original.copyWith();

      expect(copy, original);
    });
  });

  group('UserPreferences.detectDefault', () {
    test('returns a valid MeasurementSystem', () {
      final detected = UserPreferences.detectDefault();

      expect(
        detected,
        anyOf(MeasurementSystem.metric, MeasurementSystem.imperial),
      );
    });

    test('defaultPreferences factory uses detectDefault', () {
      final prefs = UserPreferences.defaultPreferences();

      expect(prefs.measurementSystem, isNotNull);
      expect(
        prefs.measurementSystem,
        anyOf(MeasurementSystem.metric, MeasurementSystem.imperial),
      );
    });

    // Note: Cannot reliably test country-specific detection in unit tests
    // as it depends on device locale. Integration/manual testing required.
  });
}
