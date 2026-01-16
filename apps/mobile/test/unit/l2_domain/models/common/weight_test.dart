import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/common/weight.dart';

void main() {
  group('Weight', () {
    group('constructor', () {
      test('creates Weight with kg value', () {
        final weight = Weight(10.0);
        expect(weight.kg, 10.0);
      });

      test('creates Weight with zero kg', () {
        final weight = Weight(0.0);
        expect(weight.kg, 0.0);
      });

      test('creates Weight with negative kg value', () {
        final weight = Weight(-5.0);
        expect(weight.kg, -5.0);
      });

      test('creates Weight with very large kg value', () {
        final weight = Weight(1000000.0);
        expect(weight.kg, 1000000.0);
      });

      test('creates Weight with decimal kg value', () {
        final weight = Weight(2.5);
        expect(weight.kg, 2.5);
      });
    });

    group('getInLbs', () {
      test('converts kg to lbs correctly', () {
        final weight = Weight(10.0);
        expect(weight.getInLbs(), closeTo(22.0462, 0.0001));
      });

      test('converts zero kg to zero lbs', () {
        final weight = Weight(0.0);
        expect(weight.getInLbs(), 0.0);
      });

      test('converts 1 kg to lbs correctly', () {
        final weight = Weight(1.0);
        expect(weight.getInLbs(), closeTo(2.20462, 0.00001));
      });

      test('converts negative kg to negative lbs', () {
        final weight = Weight(-10.0);
        expect(weight.getInLbs(), closeTo(-22.0462, 0.0001));
      });

      test('converts decimal kg to lbs correctly', () {
        final weight = Weight(2.5);
        expect(weight.getInLbs(), closeTo(5.51155, 0.00001));
      });
    });

    group('fromLbs', () {
      test('creates Weight from lbs value', () {
        final weight = Weight.fromLbs(22.0462);
        expect(weight.kg, closeTo(10.0, 0.001));
      });

      test('creates Weight from zero lbs', () {
        final weight = Weight.fromLbs(0.0);
        expect(weight.kg, 0.0);
      });

      test('creates Weight from 1 lb', () {
        final weight = Weight.fromLbs(1.0);
        expect(weight.kg, closeTo(0.453592, 0.000001));
      });

      test('creates Weight from negative lbs', () {
        final weight = Weight.fromLbs(-22.0462);
        expect(weight.kg, closeTo(-10.0, 0.001));
      });

      test('creates Weight from decimal lbs', () {
        final weight = Weight.fromLbs(5.5);
        expect(weight.kg, closeTo(2.49476, 0.00001));
      });
    });

    group('toJson', () {
      test('returns map with kg value', () {
        final weight = Weight(10.0);
        expect(weight.toJson(), {'kg': 10.0});
      });

      test('returns map with zero for zero weight', () {
        final weight = Weight(0.0);
        expect(weight.toJson(), {'kg': 0.0});
      });

      test('returns map with decimal value', () {
        final weight = Weight(2.5);
        expect(weight.toJson(), {'kg': 2.5});
      });

      test('returns map with negative value', () {
        final weight = Weight(-5.0);
        expect(weight.toJson(), {'kg': -5.0});
      });
    });

    group('fromJson', () {
      test('creates Weight from map with double', () {
        final weight = Weight.fromJson({'kg': 10.0});
        expect(weight.kg, 10.0);
      });

      test('creates Weight from map with int', () {
        final weight = Weight.fromJson({'kg': 10});
        expect(weight.kg, 10.0);
      });

      test('creates Weight from map with zero', () {
        final weight = Weight.fromJson({'kg': 0});
        expect(weight.kg, 0.0);
      });

      test('creates Weight from map with negative value', () {
        final weight = Weight.fromJson({'kg': -5.0});
        expect(weight.kg, -5.0);
      });

      test('creates Weight from map with decimal value', () {
        final weight = Weight.fromJson({'kg': 2.5});
        expect(weight.kg, 2.5);
      });
    });

    group('equality', () {
      test('two Weights with same kg are equal', () {
        final weight1 = Weight(10.0);
        final weight2 = Weight(10.0);
        expect(weight1, weight2);
      });

      test('two Weights with different kg are not equal', () {
        final weight1 = Weight(10.0);
        final weight2 = Weight(20.0);
        expect(weight1, isNot(weight2));
      });

      test('Weight equals itself', () {
        final weight = Weight(10.0);
        expect(weight, weight);
      });

      test('Weight does not equal null', () {
        final weight = Weight(10.0);
        expect(weight, isNot(equals(null)));
      });

      test('Weight does not equal different type', () {
        final weight = Weight(10.0);
        expect(weight == 10.0, isFalse);
      });
    });

    group('hashCode', () {
      test('same kg values have same hashCode', () {
        final weight1 = Weight(10.0);
        final weight2 = Weight(10.0);
        expect(weight1.hashCode, weight2.hashCode);
      });

      test('different kg values have different hashCode', () {
        final weight1 = Weight(10.0);
        final weight2 = Weight(20.0);
        expect(weight1.hashCode, isNot(weight2.hashCode));
      });
    });

    group('immutability', () {
      test(
        'creating new Weight with different value does not affect original',
        () {
          final weight = Weight(10.0);
          final newWeight = Weight(20.0);
          expect(newWeight.kg, 20.0);
          expect(weight.kg, 10.0);
        },
      );

      test('Weight is immutable', () {
        final weight = Weight(10.0);
        final sameWeight = Weight(10.0);
        expect(weight, sameWeight);
      });
    });

    group('edge cases', () {
      test('handles very small decimal values', () {
        final weight = Weight(0.001);
        expect(weight.kg, 0.001);
        expect(weight.getInLbs(), closeTo(0.00220462, 0.0000001));
      });

      test('handles conversion round-trip kg -> lbs -> kg', () {
        final original = Weight(10.0);
        final lbs = original.getInLbs();
        final converted = Weight.fromLbs(lbs);
        expect(converted.kg, closeTo(original.kg, 0.0001));
      });

      test('handles conversion round-trip lbs -> kg -> lbs', () {
        final original = Weight.fromLbs(22.0);
        final lbs = original.getInLbs();
        expect(lbs, closeTo(22.0, 0.001));
      });
    });
  });
}
