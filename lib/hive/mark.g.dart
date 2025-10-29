// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mark.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MarkAdapter extends TypeAdapter<Mark> {
  @override
  final int typeId = 2;

  @override
  Mark read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Mark()
      ..assessmentId = fields[0] as String
      ..studentId = fields[1] as String
      ..subjectId = fields[2] as String
      ..schoolId = fields[3] as String
      ..value = fields[4] as double?
      ..updatedAt = fields[5] as DateTime
      ..remoteId = fields[6] as String?
      ..isSynced = fields[7] as bool
      ..isDeleted = fields[8] as bool;
  }

  @override
  void write(BinaryWriter writer, Mark obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.assessmentId)
      ..writeByte(1)
      ..write(obj.studentId)
      ..writeByte(2)
      ..write(obj.subjectId)
      ..writeByte(3)
      ..write(obj.schoolId)
      ..writeByte(4)
      ..write(obj.value)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.remoteId)
      ..writeByte(7)
      ..write(obj.isSynced)
      ..writeByte(8)
      ..write(obj.isDeleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
