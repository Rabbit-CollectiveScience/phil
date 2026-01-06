class Distance {
  final double meters;

  const Distance(this.meters);

  // Conversion constants
  static const double metersToKmFactor = 0.001;
  static const double metersToMilesFactor = 0.000621371;

  double getInKm() => meters * metersToKmFactor;

  double getInMiles() => meters * metersToMilesFactor;

  Distance setInKm(double km) => Distance(km / metersToKmFactor);

  Distance setInMiles(double miles) => Distance(miles / metersToMilesFactor);

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
