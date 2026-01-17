import 'package:flutter_test/flutter_test.dart';
import 'package:phil/l2_domain/models/common/equipment_type.dart';

void main() {
  group('EquipmentType.roundToNearest tests', () {
    group('plate equipment (Olympic plates, 2.5kg increments)', () {
      test('rounds 72.3kg to 72.5kg', () {
        expect(EquipmentType.plate.roundToNearest(72.3, true), equals(72.5));
      });

      test('rounds 100.1kg to 100kg', () {
        expect(EquipmentType.plate.roundToNearest(100.1, true), equals(100.0));
      });

      test('rounds 67.6kg to 67.5kg', () {
        expect(EquipmentType.plate.roundToNearest(67.6, true), equals(67.5));
      });

      test('rounds 45.0kg to 45kg (exact match)', () {
        expect(EquipmentType.plate.roundToNearest(45.0, true), equals(45.0));
      });

      test('rounds 2.3kg to 5kg', () {
        expect(EquipmentType.plate.roundToNearest(2.3, true), equals(5.0));
      });
    });

    group('dumbbell equipment (array-based, common gym weights)', () {
      test('rounds 23.7kg to 22.5kg', () {
        expect(EquipmentType.dumbbell.roundToNearest(23.7, true), equals(22.5));
      });

      test('rounds 13.2kg to 12.5kg', () {
        expect(EquipmentType.dumbbell.roundToNearest(13.2, true), equals(12.5));
      });

      test('rounds 0.7kg to 0.5kg (minimum)', () {
        expect(EquipmentType.dumbbell.roundToNearest(0.7, true), equals(0.5));
      });

      test('rounds 85kg to 80kg (maximum)', () {
        expect(EquipmentType.dumbbell.roundToNearest(85.0, true), equals(80.0));
      });

      test('exact match at 20kg', () {
        expect(EquipmentType.dumbbell.roundToNearest(20.0, true), equals(20.0));
      });
    });

    group('kettlebell equipment (array-based: 2, 4, 6, 8, 10, 12, 14, 16, 20, 24, 28, 32, 40, 48)', () {
      test('rounds 11.5kg to 12kg', () {
        expect(EquipmentType.kettlebell.roundToNearest(11.5, true), equals(12.0));
      });

      test('rounds 17.3kg to 16kg', () {
        expect(EquipmentType.kettlebell.roundToNearest(17.3, true), equals(16.0));
      });

      test('rounds 3kg to 4kg', () {
        expect(EquipmentType.kettlebell.roundToNearest(3.0, true), equals(4.0));
      });

      test('rounds 50kg to 48kg (maximum)', () {
        expect(EquipmentType.kettlebell.roundToNearest(50.0, true), equals(48.0));
      });

      test('exact match at 32kg', () {
        expect(EquipmentType.kettlebell.roundToNearest(32.0, true), equals(32.0));
      });
    });

    group('machine equipment (modulo-based, 5kg increments)', () {
      test('rounds 67kg to 65kg', () {
        expect(EquipmentType.machine.roundToNearest(67.0, true), equals(65.0));
      });

      test('rounds 23kg to 25kg', () {
        expect(EquipmentType.machine.roundToNearest(23.0, true), equals(25.0));
      });

      test('rounds 12kg to 10kg', () {
        expect(EquipmentType.machine.roundToNearest(12.0, true), equals(10.0));
      });

      test('exact match at 50kg', () {
        expect(EquipmentType.machine.roundToNearest(50.0, true), equals(50.0));
      });

      test('rounds 2.5kg to 5kg', () {
        expect(EquipmentType.machine.roundToNearest(2.5, true), equals(5.0));
      });
    });

    group('cable equipment (modulo-based, 5kg increments)', () {
      test('rounds 67kg to 65kg', () {
        expect(EquipmentType.cable.roundToNearest(67.0, true), equals(65.0));
      });

      test('rounds 33kg to 35kg', () {
        expect(EquipmentType.cable.roundToNearest(33.0, true), equals(35.0));
      });

      test('rounds 8kg to 10kg', () {
        expect(EquipmentType.cable.roundToNearest(8.0, true), equals(10.0));
      });

      test('exact match at 25kg', () {
        expect(EquipmentType.cable.roundToNearest(25.0, true), equals(25.0));
      });

      test('rounds 1kg to 0kg', () {
        expect(EquipmentType.cable.roundToNearest(1.0, true), equals(0.0));
      });
    });

    group('other equipment (decimal precision, 0.1kg rounding)', () {
      test('rounds 45.67kg to 45.7kg', () {
        expect(EquipmentType.other.roundToNearest(45.67, true), equals(45.7));
      });

      test('rounds 12.34kg to 12.3kg', () {
        expect(EquipmentType.other.roundToNearest(12.34, true), equals(12.3));
      });

      test('rounds 99.99kg to 100kg', () {
        expect(EquipmentType.other.roundToNearest(99.99, true), equals(100.0));
      });

      test('exact match at 20.5kg', () {
        expect(EquipmentType.other.roundToNearest(20.5, true), equals(20.5));
      });

      test('rounds 0.06kg to 0.1kg', () {
        expect(EquipmentType.other.roundToNearest(0.06, true), equals(0.1));
      });
    });

    group('edge cases', () {
      test('zero weight rounds appropriately for all types', () {
        expect(EquipmentType.plate.roundToNearest(0.0, true), equals(5.0)); // Minimum plate weight
        expect(EquipmentType.dumbbell.roundToNearest(0.0, true), equals(0.5)); // Minimum dumbbell
        expect(EquipmentType.kettlebell.roundToNearest(0.0, true), equals(2.0)); // Minimum kettlebell
        expect(EquipmentType.machine.roundToNearest(0.0, true), equals(0.0));
        expect(EquipmentType.cable.roundToNearest(0.0, true), equals(0.0));
        expect(EquipmentType.other.roundToNearest(0.0, true), equals(0.0));
      });

      test('negative weights behave reasonably', () {
        // Negative doesn't make sense but should not crash
        expect(EquipmentType.other.roundToNearest(-5.5, true), equals(-5.5));
      });
    });
  });

  group('EquipmentType enum tests', () {
    test('enum has expected values', () {
      expect(EquipmentType.values.length, equals(6));
      expect(EquipmentType.values.contains(EquipmentType.dumbbell), isTrue);
      expect(EquipmentType.values.contains(EquipmentType.plate), isTrue);
      expect(EquipmentType.values.contains(EquipmentType.kettlebell), isTrue);
      expect(EquipmentType.values.contains(EquipmentType.machine), isTrue);
      expect(EquipmentType.values.contains(EquipmentType.cable), isTrue);
      expect(EquipmentType.values.contains(EquipmentType.other), isTrue);
    });

    test('enum values have correct names', () {
      expect(EquipmentType.dumbbell.name, equals('dumbbell'));
      expect(EquipmentType.plate.name, equals('plate'));
      expect(EquipmentType.kettlebell.name, equals('kettlebell'));
      expect(EquipmentType.machine.name, equals('machine'));
      expect(EquipmentType.cable.name, equals('cable'));
      expect(EquipmentType.other.name, equals('other'));
    });
  });
}
