// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_tracking.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyTrackingAdapter extends TypeAdapter<DailyTracking> {
  @override
  final int typeId = 7;

  @override
  DailyTracking read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyTracking(
      date: fields[0] as DateTime,
      steps: fields[1] as int,
      waterIntake: fields[2] as double,
      calories: fields[3] as double?,
      notes: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyTracking obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.steps)
      ..writeByte(2)
      ..write(obj.waterIntake)
      ..writeByte(3)
      ..write(obj.calories)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyTrackingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
