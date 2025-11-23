/// Utility class for converting between different units of measurement
///
/// Base units: kg for weight, km for distance
/// All data is stored in base units, converted at UI boundaries
class UnitConverter {
  // Conversion constants
  static const double _lbsToKgFactor = 0.453592;
  static const double _milesToKmFactor = 1.60934;

  // ============================================================================
  // Weight Conversions (Base: kg)
  // ============================================================================

  /// Convert user input to base units (kg)
  /// Stores value with 2 decimal precision
  static double weightToBase(double value, String unit) {
    if (unit == 'kg') return double.parse(value.toStringAsFixed(2));
    if (unit == 'lbs')
      return double.parse((value * _lbsToKgFactor).toStringAsFixed(2));
    return value;
  }

  /// Convert base units (kg) to user's preferred unit for display
  static double weightFromBase(double kg, String targetUnit) {
    if (targetUnit == 'kg') return kg;
    if (targetUnit == 'lbs') return kg / _lbsToKgFactor;
    return kg;
  }

  // ============================================================================
  // Distance Conversions (Base: km)
  // ============================================================================

  /// Convert user input to base units (km)
  /// Stores value with 2 decimal precision
  static double distanceToBase(double value, String unit) {
    if (unit == 'km') return double.parse(value.toStringAsFixed(2));
    if (unit == 'miles')
      return double.parse((value * _milesToKmFactor).toStringAsFixed(2));
    return value;
  }

  /// Convert base units (km) to user's preferred unit for display
  static double distanceFromBase(double km, String targetUnit) {
    if (targetUnit == 'km') return km;
    if (targetUnit == 'miles') return km / _milesToKmFactor;
    return km;
  }

  // ============================================================================
  // Formatting Helpers
  // ============================================================================

  /// Format weight value for display
  /// Rounds to whole number (e.g., 185 lbs instead of 184.97)
  static String formatWeight(double kg, String unit) {
    final value = weightFromBase(kg, unit);
    final rounded = value.round();
    return '$rounded $unit';
  }

  /// Format distance value for display
  /// Rounds to whole number for values >= 1, shows 2 decimals for < 1
  static String formatDistance(double km, String unit) {
    final value = distanceFromBase(km, unit);
    if (value >= 1) {
      final rounded = value.round();
      return '$rounded $unit';
    } else {
      return '${value.toStringAsFixed(2)} $unit';
    }
  }
}
