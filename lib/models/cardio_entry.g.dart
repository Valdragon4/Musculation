// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cardio_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CardioEntryAdapter extends TypeAdapter<CardioEntry> {
  @override
  final int typeId = 5;

  @override
  CardioEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CardioEntry(
      date: fields[0] as DateTime,
      distance: fields[1] as double,
      duration: fields[2] as int,
      pace: fields[3] as double?,
      isInterval: fields[4] as bool,
      intervals: (fields[5] as List?)?.cast<IntervalSegment>(),
      notes: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CardioEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.distance)
      ..writeByte(2)
      ..write(obj.duration)
      ..writeByte(3)
      ..write(obj.pace)
      ..writeByte(4)
      ..write(obj.isInterval)
      ..writeByte(5)
      ..write(obj.intervals)
      ..writeByte(6)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardioEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IntervalSegmentAdapter extends TypeAdapter<IntervalSegment> {
  @override
  final int typeId = 6;

  @override
  IntervalSegment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IntervalSegment(
      duration: fields[0] as int,
      isRunning: fields[1] as bool,
      pace: fields[2] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, IntervalSegment obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.duration)
      ..writeByte(1)
      ..write(obj.isRunning)
      ..writeByte(2)
      ..write(obj.pace);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntervalSegmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
