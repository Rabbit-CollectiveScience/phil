import 'dart:ui' as ui;

/// Enumeration of measurement systems for weight and distance
enum MeasurementSystem {
  /// Metric system: kilograms, kilometers, meters/second
  metric,

  /// Imperial system: pounds, miles, miles per hour
  imperial;

  String toJson() => name;
  static MeasurementSystem fromJson(String json) {
    return MeasurementSystem.values.firstWhere((e) => e.name == json);
  }
}

/// User preferences for the application
class UserPreferences {
  final MeasurementSystem measurementSystem;

  const UserPreferences({required this.measurementSystem});

  /// Detect the appropriate default measurement system based on device locale
  ///
  /// Only 3 countries use imperial system:
  /// - US (United States)
  /// - LR (Liberia)
  /// - MM (Myanmar)
  ///
  /// All other countries use metric system
  static MeasurementSystem detectDefault() {
    try {
      final locale = ui.PlatformDispatcher.instance.locale;
      final countryCode = locale.countryCode ?? '';

      // Imperial countries (only 3 in the world)
      const imperialCountries = {'US', 'LR', 'MM'};

      return imperialCountries.contains(countryCode)
          ? MeasurementSystem.imperial
          : MeasurementSystem.metric;
    } catch (e) {
      // If locale detection fails, default to metric (most common worldwide)
      return MeasurementSystem.metric;
    }
  }

  /// Create default user preferences with detected system
  factory UserPreferences.defaultPreferences() {
    return UserPreferences(measurementSystem: detectDefault());
  }

  /// JSON serialization
  Map<String, dynamic> toJson() => {
    'measurementSystem': measurementSystem.toJson(),
  };

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      measurementSystem: MeasurementSystem.fromJson(
        json['measurementSystem'] as String,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferences &&
          runtimeType == other.runtimeType &&
          measurementSystem == other.measurementSystem;

  @override
  int get hashCode => measurementSystem.hashCode;

  @override
  String toString() => 'UserPreferences(measurementSystem: $measurementSystem)';

  /// Create a copy with updated fields
  UserPreferences copyWith({MeasurementSystem? measurementSystem}) {
    return UserPreferences(
      measurementSystem: measurementSystem ?? this.measurementSystem,
    );
  }
}
