import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/common/distance.dart';

void main() {
  group('Distance', () {
    group('constructor', () {
      test('creates Distance with meters value', () {
        final distance = Distance(1000.0);
        expect(distance.meters, 1000.0);
      });

      test('creates Distance with zero meters', () {
        final distance = Distance(0.0);
        expect(distance.meters, 0.0);
      });

      test('creates Distance with negative meters value', () {
        final distance = Distance(-500.0);
        expect(distance.meters, -500.0);
      });

      test('creates Distance with very large meters value', () {
        final distance = Distance(1000000.0);
        expect(distance.meters, 1000000.0);
      });

      test('creates Distance with decimal meters value', () {
        final distance = Distance(123.45);
        expect(distance.meters, 123.45);
      });
    });

    group('getInKm', () {
      test('converts meters to km correctly', () {
        final distance = Distance(1000.0);
        expect(distance.getInKm(), 1.0);
      });

      test('converts zero meters to zero km', () {
        final distance = Distance(0.0);
        expect(distance.getInKm(), 0.0);
      });

      test('converts 500 meters to 0.5 km', () {
        final distance = Distance(500.0);
        expect(distance.getInKm(), 0.5);
      });

      test('converts 1 meter to km correctly', () {
        final distance = Distance(1.0);
        expect(distance.getInKm(), 0.001);
      });

      test('converts negative meters to negative km', () {
        final distance = Distance(-1000.0);
        expect(distance.getInKm(), -1.0);
      });

      test('converts decimal meters to km correctly', () {
        final distance = Distance(1234.56);
        expect(distance.getInKm(), closeTo(1.23456, 0.00001));
      });

      test('converts very small distance to km', () {
        final distance = Distance(1.0);
        expect(distance.getInKm(), 0.001);
      });
    });

    group('setInKm', () {
      test('creates Distance from km value', () {
        final distance = Distance(0).setInKm(1.0);
        expect(distance.meters, 1000.0);
      });

      test('creates Distance from zero km', () {
        final distance = Distance(0).setInKm(0.0);
        expect(distance.meters, 0.0);
      });

      test('creates Distance from 0.5 km', () {
        final distance = Distance(0).setInKm(0.5);
        expect(distance.meters, 500.0);
      });

      test('creates Distance from negative km', () {
        final distance = Distance(0).setInKm(-1.0);
        expect(distance.meters, -1000.0);
      });

      test('creates Distance from decimal km', () {
        final distance = Distance(0).setInKm(1.234);
        expect(distance.meters, closeTo(1234.0, 0.01));
      });

      test('creates Distance from very small km value', () {
        final distance = Distance(0).setInKm(0.001);
        expect(distance.meters, 1.0);
      });
    });

    group('getInMiles', () {
      test('converts meters to miles correctly', () {
        final distance = Distance(1609.34);
        expect(distance.getInMiles(), closeTo(1.0, 0.0001));
      });

      test('converts zero meters to zero miles', () {
        final distance = Distance(0.0);
        expect(distance.getInMiles(), 0.0);
      });

      test('converts 1000 meters to miles correctly', () {
        final distance = Distance(1000.0);
        expect(distance.getInMiles(), closeTo(0.621371, 0.000001));
      });

      test('converts negative meters to negative miles', () {
        final distance = Distance(-1609.34);
        expect(distance.getInMiles(), closeTo(-1.0, 0.0001));
      });

      test('converts decimal meters to miles correctly', () {
        final distance = Distance(5000.0);
        expect(distance.getInMiles(), closeTo(3.10686, 0.00001));
      });
    });

    group('setInMiles', () {
      test('creates Distance from miles value', () {
        final distance = Distance(0).setInMiles(1.0);
        expect(distance.meters, closeTo(1609.34, 0.01));
      });

      test('creates Distance from zero miles', () {
        final distance = Distance(0).setInMiles(0.0);
        expect(distance.meters, 0.0);
      });

      test('creates Distance from 0.5 miles', () {
        final distance = Distance(0).setInMiles(0.5);
        expect(distance.meters, closeTo(804.67, 0.01));
      });

      test('creates Distance from negative miles', () {
        final distance = Distance(0).setInMiles(-1.0);
        expect(distance.meters, closeTo(-1609.34, 0.01));
      });

      test('creates Distance from decimal miles', () {
        final distance = Distance(0).setInMiles(3.1);
        expect(distance.meters, closeTo(4988.954, 0.02));
      });
    });

    group('toJson', () {
      test('returns map with meters value', () {
        final distance = Distance(1000.0);
        expect(distance.toJson(), {'meters': 1000.0});
      });

      test('returns map with zero for zero distance', () {
        final distance = Distance(0.0);
        expect(distance.toJson(), {'meters': 0.0});
      });

      test('returns map with decimal value', () {
        final distance = Distance(123.45);
        expect(distance.toJson(), {'meters': 123.45});
      });

      test('returns map with negative value', () {
        final distance = Distance(-500.0);
        expect(distance.toJson(), {'meters': -500.0});
      });
    });

    group('fromJson', () {
      test('creates Distance from map with double', () {
        final distance = Distance.fromJson({'meters': 1000.0});
        expect(distance.meters, 1000.0);
      });

      test('creates Distance from map with int', () {
        final distance = Distance.fromJson({'meters': 1000});
        expect(distance.meters, 1000.0);
      });

      test('creates Distance from map with zero', () {
        final distance = Distance.fromJson({'meters': 0});
        expect(distance.meters, 0.0);
      });

      test('creates Distance from map with negative value', () {
        final distance = Distance.fromJson({'meters': -500.0});
        expect(distance.meters, -500.0);
      });

      test('creates Distance from map with decimal value', () {
        final distance = Distance.fromJson({'meters': 123.45});
        expect(distance.meters, 123.45);
      });
    });

    group('equality', () {
      test('two Distances with same meters are equal', () {
        final distance1 = Distance(1000.0);
        final distance2 = Distance(1000.0);
        expect(distance1, distance2);
      });

      test('two Distances with different meters are not equal', () {
        final distance1 = Distance(1000.0);
        final distance2 = Distance(2000.0);
        expect(distance1, isNot(distance2));
      });

      test('Distance equals itself', () {
        final distance = Distance(1000.0);
        expect(distance, distance);
      });

      test('Distance does not equal null', () {
        final distance = Distance(1000.0);
        expect(distance, isNot(equals(null)));
      });

      test('Distance does not equal different type', () {
        final distance = Distance(1000.0);
        expect(distance == 1000.0, isFalse);
      });
    });

    group('hashCode', () {
      test('same meters values have same hashCode', () {
        final distance1 = Distance(1000.0);
        final distance2 = Distance(1000.0);
        expect(distance1.hashCode, distance2.hashCode);
      });

      test('different meters values have different hashCode', () {
        final distance1 = Distance(1000.0);
        final distance2 = Distance(2000.0);
        expect(distance1.hashCode, isNot(distance2.hashCode));
      });
    });

    group('immutability', () {
      test(
        'creating new Distance with different value does not affect original',
        () {
          final distance = Distance(1000.0);
          final newDistance = Distance(2000.0);
          expect(newDistance.meters, 2000.0);
          expect(distance.meters, 1000.0);
        },
      );

      test('Distance is immutable', () {
        final distance = Distance(1000.0);
        final sameDistance = Distance(1000.0);
        expect(distance, sameDistance);
      });
    });

    group('edge cases', () {
      test('handles very small decimal values', () {
        final distance = Distance(0.001);
        expect(distance.meters, 0.001);
        expect(distance.getInKm(), 0.000001);
      });

      test('handles conversion round-trip meters -> km -> meters', () {
        final original = Distance(1234.56);
        final km = original.getInKm();
        final converted = original.setInKm(km);
        expect(converted.meters, closeTo(original.meters, 0.01));
      });

      test('handles conversion round-trip meters -> miles -> meters', () {
        final original = Distance(5000.0);
        final miles = original.getInMiles();
        final converted = original.setInMiles(miles);
        expect(converted.meters, closeTo(original.meters, 0.1));
      });

      test('handles conversion km -> miles', () {
        final distance = Distance(0).setInKm(1.0);
        expect(distance.getInMiles(), closeTo(0.621371, 0.000001));
      });

      test('handles conversion miles -> km', () {
        final distance = Distance(0).setInMiles(1.0);
        expect(distance.getInKm(), closeTo(1.60934, 0.00001));
      });
    });
  });
}
