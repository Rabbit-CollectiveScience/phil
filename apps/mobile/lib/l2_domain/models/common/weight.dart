class Weight {
  final double kg;

  const Weight(this.kg);

  // Conversion constants
  static const double kgToLb = 2.20462;
  static const double lbToKg = 0.453592;

  /// Convert weight to pounds
  double getInLbs() => kg * kgToLb;

  /// Create Weight from pounds value
  static Weight fromLbs(double lbs) => Weight(lbs * lbToKg);

  // JSON serialization
  Map<String, dynamic> toJson() => {'kg': kg};

  factory Weight.fromJson(Map<String, dynamic> json) =>
      Weight((json['kg'] as num).toDouble());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Weight && runtimeType == other.runtimeType && kg == other.kg;

  @override
  int get hashCode => kg.hashCode;

  @override
  String toString() => '${kg.toStringAsFixed(2)} kg';
}
