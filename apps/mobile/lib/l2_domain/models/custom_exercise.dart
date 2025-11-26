import 'package:hive/hive.dart';

part 'custom_exercise.g.dart';

@HiveType(typeId: 3)
class CustomExercise {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final bool isCustom;

  @HiveField(4)
  final DateTime createdAt;

  // Strength-specific fields
  @HiveField(5)
  final String? muscleGroup;

  @HiveField(6)
  final String? equipment;

  @HiveField(7)
  final String? movementPattern;

  // Cardio-specific fields
  @HiveField(8)
  final String? activityType;

  @HiveField(9)
  final String? intensityLevel;

  // Flexibility-specific fields
  @HiveField(10)
  final String? targetArea;

  @HiveField(11)
  final String? stretchType;

  CustomExercise({
    required this.id,
    required this.name,
    required this.category,
    this.isCustom = true,
    DateTime? createdAt,
    this.muscleGroup,
    this.equipment,
    this.movementPattern,
    this.activityType,
    this.intensityLevel,
    this.targetArea,
    this.stretchType,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert to JSON-like map for storage/serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'isCustom': isCustom,
      'createdAt': createdAt.toIso8601String(),
      if (muscleGroup != null) 'muscleGroup': muscleGroup,
      if (equipment != null) 'equipment': equipment,
      if (movementPattern != null) 'movementPattern': movementPattern,
      if (activityType != null) 'activityType': activityType,
      if (intensityLevel != null) 'intensityLevel': intensityLevel,
      if (targetArea != null) 'targetArea': targetArea,
      if (stretchType != null) 'stretchType': stretchType,
    };
  }

  /// Create from JSON-like map
  factory CustomExercise.fromMap(Map<String, dynamic> map) {
    return CustomExercise(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      isCustom: map['isCustom'] as bool? ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      muscleGroup: map['muscleGroup'] as String?,
      equipment: map['equipment'] as String?,
      movementPattern: map['movementPattern'] as String?,
      activityType: map['activityType'] as String?,
      intensityLevel: map['intensityLevel'] as String?,
      targetArea: map['targetArea'] as String?,
      stretchType: map['stretchType'] as String?,
    );
  }

  @override
  String toString() {
    return 'CustomExercise(id: $id, name: $name, category: $category, muscleGroup: $muscleGroup)';
  }
}
