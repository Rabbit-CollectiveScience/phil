import '../common/equipment_type.dart';

/// Helper for parsing equipment type from JSON with fallback to 'other'
EquipmentType parseEquipmentType(dynamic value) {
  if (value == null) return EquipmentType.other;

  final str = value.toString().toLowerCase().trim();
  switch (str) {
    case 'dumbbell':
      return EquipmentType.dumbbell;
    case 'plate':
    case 'barbell': // Legacy support
    case 'ezbar': // Legacy support
    case 'ez_bar': // Legacy support
    case 'ezBar': // Legacy support
      return EquipmentType.plate;
    case 'kettlebell':
      return EquipmentType.kettlebell;
    case 'machine':
      return EquipmentType.machine;
    case 'cable':
      return EquipmentType.cable;
    case 'other':
    default:
      return EquipmentType.other;
  }
}
