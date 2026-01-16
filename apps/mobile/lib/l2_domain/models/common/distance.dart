class Distance {
  final double meters;

  const Distance(this.meters);

  // Conversion constants
  static const double metersToKm = 0.001;
  static const double metersToMiles = 0.000621371;
  static const double kmToMeters = 1000.0;
  static const double milesToMeters = 1609.344;

  /// Convert distance to kilometers
  double getInKilometers() => meters * metersToKm;

  /// Convert distance to miles
  double getInMiles() => meters * metersToMiles;

  /// Create Distance from kilometers
  static Distance fromKm(double km) => Distance(km * kmToMeters);

  /// Create Distance from miles
  static Distance fromMiles(double miles) => Distance(miles * milesToMeters);

  // Kept for backward compatibility
  double getInKm() => getInKilometers();
  Distance setInKm(double km) => fromKm(km);
  Distance setInMiles(double miles) => fromMiles(miles);

  // JSON serialization
  Map<String, dynamic> toJson() => {'meters': meters};

  factory Distance.fromJson(Map<String, dynamic> json) =>
      Distance((json['meters'] as num).toDouble());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Distance &&
          runtimeType == other.runtimeType &&
          meters == other.meters;

  @override
  int get hashCode => meters.hashCode;

  @override
  String toString() => '${getInKm().toStringAsFixed(2)} km';
}
