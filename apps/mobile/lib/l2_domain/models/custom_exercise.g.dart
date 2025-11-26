// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomExerciseAdapter extends TypeAdapter<CustomExercise> {
  @override
  final int typeId = 3;

  @override
  CustomExercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomExercise(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      isCustom: fields[3] as bool,
      createdAt: fields[4] as DateTime?,
      muscleGroup: fields[5] as String?,
      equipment: fields[6] as String?,
      movementPattern: fields[7] as String?,
      activityType: fields[8] as String?,
      intensityLevel: fields[9] as String?,
      targetArea: fields[10] as String?,
      stretchType: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CustomExercise obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.isCustom)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.muscleGroup)
      ..writeByte(6)
      ..write(obj.equipment)
      ..writeByte(7)
      ..write(obj.movementPattern)
      ..writeByte(8)
      ..write(obj.activityType)
      ..writeByte(9)
      ..write(obj.intensityLevel)
      ..writeByte(10)
      ..write(obj.targetArea)
      ..writeByte(11)
      ..write(obj.stretchType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
