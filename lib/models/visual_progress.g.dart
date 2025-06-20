// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visual_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VisualProgressAdapter extends TypeAdapter<VisualProgress> {
  @override
  final int typeId = 4;

  @override
  VisualProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VisualProgress(
      date: fields[0] as DateTime,
      mediaPath: fields[1] as String,
      isVideo: fields[2] as bool,
      notes: fields[3] as String?,
      weight: fields[4] as double?,
      measurements: (fields[5] as Map?)?.cast<String, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, VisualProgress obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.mediaPath)
      ..writeByte(2)
      ..write(obj.isVideo)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.weight)
      ..writeByte(5)
      ..write(obj.measurements);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisualProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
