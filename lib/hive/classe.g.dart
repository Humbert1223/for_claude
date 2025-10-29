// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classe.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClasseAdapter extends TypeAdapter<Classe> {
  @override
  final int typeId = 1;

  @override
  Classe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Classe()
      ..name = fields[0] as String
      ..remoteId = fields[1] as String
      ..schoolId = fields[2] as String
      ..academicId = fields[3] as String
      ..levelOrder = fields[4] as int?;
  }

  @override
  void write(BinaryWriter writer, Classe obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.remoteId)
      ..writeByte(2)
      ..write(obj.schoolId)
      ..writeByte(3)
      ..write(obj.academicId)
      ..writeByte(4)
      ..write(obj.levelOrder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClasseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
