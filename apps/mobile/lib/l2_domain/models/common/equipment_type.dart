/// Equipment types used in strength training
/// Each type has predefined available weights for smart rounding
enum EquipmentType {
  dumbbell,
  barbell,
  ezBar,
  kettlebell,
  machine,
  cable,
  bodyweight,
  none,
}

extension EquipmentWeights on EquipmentType {
  /// Available weights in kilograms
  /// Based on standard gym equipment in most commercial gyms
  List<double> get availableWeightsKg {
    switch (this) {
      case EquipmentType.dumbbell:
        return [
          0.5,
          1,
          1.5,
          2,
          2.5,
          5,
          7.5,
          10,
          12.5,
          15,
          17.5,
          20,
          22.5,
          25,
          27.5,
          30,
          32.5,
          35,
          37.5,
          40,
          42.5,
          45,
          47.5,
          50,
          55,
          60,
          65,
          70,
          75,
          80,
        ];

      case EquipmentType.barbell:
      case EquipmentType.ezBar:
        // Starts at 20kg (Olympic bar weight) + plate increments
        return [
          20,
          22.5,
          25,
          27.5,
          30,
          32.5,
          35,
          37.5,
          40,
          42.5,
          45,
          47.5,
          50,
          52.5,
          55,
          57.5,
          60,
          62.5,
          65,
          67.5,
          70,
          72.5,
          75,
          77.5,
          80,
          82.5,
          85,
          87.5,
          90,
          92.5,
          95,
          97.5,
          100,
          105,
          110,
          115,
          120,
          125,
          130,
          135,
          140,
          145,
          150,
          160,
          170,
          180,
          190,
          200,
        ];

      case EquipmentType.kettlebell:
        // Irregular progression (larger gaps at heavier weights)
        return [4, 6, 8, 12, 16, 20, 24, 28, 32, 40, 48];

      case EquipmentType.machine:
        // Most machines use 5kg weight stack increments
        return [
          5,
          10,
          15,
          20,
          25,
          30,
          35,
          40,
          45,
          50,
          55,
          60,
          65,
          70,
          75,
          80,
          85,
          90,
          95,
          100,
          105,
          110,
          115,
          120,
          130,
          140,
          150,
          160,
          170,
          180,
          200,
        ];

      case EquipmentType.cable:
        // Typically finer increment (2.5kg)
        return [
          2.5,
          5,
          7.5,
          10,
          12.5,
          15,
          17.5,
          20,
          22.5,
          25,
          27.5,
          30,
          35,
          40,
          45,
          50,
          55,
          60,
          65,
          70,
          75,
          80,
        ];

      case EquipmentType.bodyweight:
        // Added weight using dumbbells or weight vest
        return [
          2.5,
          5,
          7.5,
          10,
          12.5,
          15,
          17.5,
          20,
          22.5,
          25,
          30,
          35,
          40,
          45,
          50,
        ];

      case EquipmentType.none:
        return []; // Free-form, no constraints
    }
  }

  /// Available weights in pounds
  /// Based on standard gym equipment in imperial system
  List<double> get availableWeightsLbs {
    switch (this) {
      case EquipmentType.dumbbell:
        return [
          1,
          2,
          3,
          5,
          10,
          15,
          20,
          25,
          30,
          35,
          40,
          45,
          50,
          55,
          60,
          65,
          70,
          75,
          80,
          85,
          90,
          95,
          100,
          110,
          120,
          130,
          140,
          150,
        ];

      case EquipmentType.barbell:
      case EquipmentType.ezBar:
        // Starts at 45lbs (Olympic bar weight) + plate increments
        return [
          45,
          50,
          55,
          60,
          65,
          70,
          75,
          80,
          85,
          90,
          95,
          100,
          105,
          110,
          115,
          120,
          125,
          130,
          135,
          140,
          145,
          150,
          155,
          160,
          165,
          170,
          175,
          180,
          185,
          190,
          195,
          200,
          205,
          210,
          215,
          220,
          225,
          230,
          235,
          240,
          245,
          250,
          275,
          300,
          315,
          335,
          365,
          405,
          455,
        ];

      case EquipmentType.kettlebell:
        return [10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 70, 80, 90, 100];

      case EquipmentType.machine:
        // Most machines use 10lb weight stack increments
        return [
          10,
          20,
          30,
          40,
          50,
          60,
          70,
          80,
          90,
          100,
          110,
          120,
          130,
          140,
          150,
          160,
          170,
          180,
          190,
          200,
          220,
          240,
          260,
          280,
          300,
          320,
          340,
          360,
          380,
          400,
        ];

      case EquipmentType.cable:
        // 5lb increment
        return [
          5,
          10,
          15,
          20,
          25,
          30,
          35,
          40,
          45,
          50,
          55,
          60,
          65,
          70,
          75,
          80,
          85,
          90,
          95,
          100,
          110,
          120,
          130,
          140,
          150,
          160,
          170,
          180,
        ];

      case EquipmentType.bodyweight:
        return [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 70, 80, 90, 100];

      case EquipmentType.none:
        return [];
    }
  }

  /// Round a target weight to the nearest available weight for this equipment
  /// Returns the original value if no constraints (none type) or empty list
  double roundToNearest(double targetWeight, bool isMetric) {
    final available = isMetric ? availableWeightsKg : availableWeightsLbs;

    if (available.isEmpty) return targetWeight;

    // Find closest available weight
    return available.reduce(
      (a, b) => (a - targetWeight).abs() < (b - targetWeight).abs() ? a : b,
    );
  }
}
