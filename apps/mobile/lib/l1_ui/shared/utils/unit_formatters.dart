import '../../../l2_domain/models/common/weight.dart';
import '../../../l2_domain/models/common/distance.dart';
import '../../../l2_domain/models/user_preferences.dart';

/// Utility class for formatting and parsing weights and distances
/// based on the user's measurement system preference
class UnitFormatters {
  final MeasurementSystem measurementSystem;

  const UnitFormatters(this.measurementSystem);

  // ============================================================================
  // Weight Formatting
  // ============================================================================

  /// Format weight value with appropriate unit suffix
  /// Examples: "50 kg", "110 lb", "22.5 kg"
  String formatWeight(Weight weight, {bool includeUnit = true}) {
    final value = measurementSystem == MeasurementSystem.imperial
        ? weight.getInLbs()
        : weight.kg;

    final formatted = _formatNumber(value);

    if (!includeUnit) return formatted;

    final unit = measurementSystem == MeasurementSystem.imperial ? 'lb' : 'kg';
    return '$formatted $unit';
  }

  /// Format weight with decimal precision
  /// Examples: "50.0 kg", "110.23 lb"
  String formatWeightPrecise(
    Weight weight, {
    int decimals = 1,
    bool includeUnit = true,
  }) {
    final value = measurementSystem == MeasurementSystem.imperial
        ? weight.getInLbs()
        : weight.kg;

    final formatted = value.toStringAsFixed(decimals);

    if (!includeUnit) return formatted;

    final unit = measurementSystem == MeasurementSystem.imperial ? 'lb' : 'kg';
    return '$formatted $unit';
  }

  /// Get weight unit suffix only
  /// Returns: "kg" or "lb"
  String getWeightUnit() {
    return measurementSystem == MeasurementSystem.imperial ? 'lb' : 'kg';
  }

  /// Parse weight value from string input
  /// Input is assumed to be in the user's preferred unit
  /// Returns Weight object stored in kg (metric)
  Weight parseWeight(String input) {
    final value = double.parse(input.trim());

    if (measurementSystem == MeasurementSystem.imperial) {
      return Weight.fromLbs(value);
    } else {
      return Weight(value);
    }
  }

  // ============================================================================
  // Distance Formatting
  // ============================================================================

  /// Format distance value with appropriate unit suffix
  /// Examples: "5 km", "3.1 mi", "10.5 km"
  String formatDistance(Distance distance, {bool includeUnit = true}) {
    final value = measurementSystem == MeasurementSystem.imperial
        ? distance.getInMiles()
        : distance.getInKilometers();

    final formatted = _formatNumber(value);

    if (!includeUnit) return formatted;

    final unit = measurementSystem == MeasurementSystem.imperial ? 'mi' : 'km';
    return '$formatted $unit';
  }

  /// Format distance with decimal precision
  /// Examples: "5.0 km", "3.11 mi"
  String formatDistancePrecise(
    Distance distance, {
    int decimals = 1,
    bool includeUnit = true,
  }) {
    final value = measurementSystem == MeasurementSystem.imperial
        ? distance.getInMiles()
        : distance.getInKilometers();

    final formatted = value.toStringAsFixed(decimals);

    if (!includeUnit) return formatted;

    final unit = measurementSystem == MeasurementSystem.imperial ? 'mi' : 'km';
    return '$formatted $unit';
  }

  /// Get distance unit suffix only
  /// Returns: "km" or "mi"
  String getDistanceUnit() {
    return measurementSystem == MeasurementSystem.imperial ? 'mi' : 'km';
  }

  /// Parse distance value from string input
  /// Input is assumed to be in the user's preferred unit
  /// Returns Distance object stored in meters (metric)
  Distance parseDistance(String input) {
    final value = double.parse(input.trim());

    if (measurementSystem == MeasurementSystem.imperial) {
      return Distance.fromMiles(value);
    } else {
      return Distance.fromKm(value);
    }
  }

  // ============================================================================
  // Volume Formatting (for workout statistics)
  // ============================================================================

  /// Format volume (weight × reps) with unit
  /// Examples: "5200 kg", "11464 lb"
  String formatVolume(double volumeInKg, {bool includeUnit = true}) {
    final value = measurementSystem == MeasurementSystem.imperial
        ? volumeInKg * Weight.kgToLb
        : volumeInKg;

    final formatted = value.toInt().toString();

    if (!includeUnit) return formatted;

    final unit = measurementSystem == MeasurementSystem.imperial ? 'lb' : 'kg';
    return '$formatted $unit';
  }

  /// Get volume unit suffix only (for labels)
  /// Returns: "VOLUME (KG)" or "VOLUME (LB)"
  String getVolumeLabel() {
    final unit = measurementSystem == MeasurementSystem.imperial ? 'LB' : 'KG';
    return 'VOLUME ($unit)';
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Format number intelligently: remove .0 for whole numbers, keep decimals for others
  String _formatNumber(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    } else {
      return value.toStringAsFixed(1);
    }
  }
}
