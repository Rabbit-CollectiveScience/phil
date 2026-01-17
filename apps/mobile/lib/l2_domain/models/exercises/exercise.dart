import '../common/equipment_type.dart';

abstract class Exercise {
  final String id;
  final String name;
  final String description;
  final bool isCustom;
  final EquipmentType equipmentType;

  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.isCustom,
    required this.equipmentType,
  });

  /// Round a weight to the nearest available weight for this exercise's equipment
  /// Delegates to the equipment type's rounding logic
  double roundToNearest(double targetWeight, bool isMetric) {
    return equipmentType.roundToNearest(targetWeight, isMetric);
  }

  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Exercise &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          isCustom == other.isCustom &&
          equipmentType == other.equipmentType;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      isCustom.hashCode ^
      equipmentType.hashCode;
}
