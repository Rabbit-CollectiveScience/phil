import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/common/equipment_type.dart';
import 'package:phil/l2_domain/models/exercises/equipment_type_parser.dart';

void main() {
  group('parseEquipmentType tests', () {
    group('valid enum values parse correctly', () {
      test('parses "dumbbell" to EquipmentType.dumbbell', () {
        expect(parseEquipmentType('dumbbell'), equals(EquipmentType.dumbbell));
      });

      test('parses "plate" to EquipmentType.plate', () {
        expect(parseEquipmentType('plate'), equals(EquipmentType.plate));
      });

      test('parses "kettlebell" to EquipmentType.kettlebell', () {
        expect(
          parseEquipmentType('kettlebell'),
          equals(EquipmentType.kettlebell),
        );
      });

      test('parses "machine" to EquipmentType.machine', () {
        expect(parseEquipmentType('machine'), equals(EquipmentType.machine));
      });

      test('parses "cable" to EquipmentType.cable', () {
        expect(parseEquipmentType('cable'), equals(EquipmentType.cable));
      });

      test('parses "other" to EquipmentType.other', () {
        expect(parseEquipmentType('other'), equals(EquipmentType.other));
      });
    });

    group('legacy barbell values parse to plate', () {
      test('parses "barbell" to EquipmentType.plate (legacy)', () {
        expect(parseEquipmentType('barbell'), equals(EquipmentType.plate));
      });

      test('parses "ezBar" to EquipmentType.plate (legacy)', () {
        expect(parseEquipmentType('ezBar'), equals(EquipmentType.plate));
      });

      test(
        'parses "ez_bar" to EquipmentType.plate (legacy with underscore)',
        () {
          expect(parseEquipmentType('ez_bar'), equals(EquipmentType.plate));
        },
      );

      test('parses "ezbar" to EquipmentType.plate (legacy lowercase)', () {
        expect(parseEquipmentType('ezbar'), equals(EquipmentType.plate));
      });
    });

    group('case sensitivity', () {
      test('parses "Dumbbell" (capital D) to EquipmentType.dumbbell', () {
        expect(parseEquipmentType('Dumbbell'), equals(EquipmentType.dumbbell));
      });

      test('parses "PLATE" (all caps) to EquipmentType.plate', () {
        expect(parseEquipmentType('PLATE'), equals(EquipmentType.plate));
      });

      test('parses "Machine" (capital M) to EquipmentType.machine', () {
        expect(parseEquipmentType('Machine'), equals(EquipmentType.machine));
      });

      test('parses "BARBELL" (all caps legacy) to EquipmentType.plate', () {
        expect(parseEquipmentType('BARBELL'), equals(EquipmentType.plate));
      });
    });

    group('invalid values default to other', () {
      test('parses null to EquipmentType.other', () {
        expect(parseEquipmentType(null), equals(EquipmentType.other));
      });

      test('parses empty string to EquipmentType.other', () {
        expect(parseEquipmentType(''), equals(EquipmentType.other));
      });

      test('parses invalid value "invalid_type" to EquipmentType.other', () {
        expect(parseEquipmentType('invalid_type'), equals(EquipmentType.other));
      });

      test('parses invalid value "bands" to EquipmentType.other', () {
        expect(parseEquipmentType('bands'), equals(EquipmentType.other));
      });

      test('parses whitespace to EquipmentType.other', () {
        expect(parseEquipmentType('   '), equals(EquipmentType.other));
      });
    });

    group('edge cases', () {
      test('parses value with leading/trailing spaces', () {
        expect(parseEquipmentType(' plate '), equals(EquipmentType.plate));
      });

      test('parses value with mixed whitespace', () {
        expect(
          parseEquipmentType('  dumbbell  '),
          equals(EquipmentType.dumbbell),
        );
      });
    });
  });
}
