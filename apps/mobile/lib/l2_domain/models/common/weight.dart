class Weight {
  final double kg;

  const Weight(this.kg);

  // Conversion constants
  static const double kgToLbsFactor = 2.20462;

  double getInLbs() => kg * kgToLbsFactor;

  Weight setInLbs(double lbs) => Weight(lbs / kgToLbsFactor);

  // JSON serialization
  Map<String, dynamic> toJson() => {'kg': kg};

  factory Weight.fromJson(Map<String, dynamic> json) => Weight((json['kg'] as num).toDouble());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Weight && runtimeType == other.runtimeType && kg == other.kg;

  @override
  int get hashCode => kg.hashCode;

  @override
  String toString() => '${kg.toStringAsFixed(2)} kg';
}
