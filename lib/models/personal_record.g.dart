// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersonalRecordAdapter extends TypeAdapter<PersonalRecord> {
  @override
  final int typeId = 3;

  @override
  PersonalRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PersonalRecord(
      exerciseId: fields[0] as String,
      sets: (fields[1] as List).cast<WorkoutSet>(),
      date: fields[2] as DateTime,
      notes: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PersonalRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.exerciseId)
      ..writeByte(1)
      ..write(obj.sets)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
