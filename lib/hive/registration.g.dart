// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RegistrationAdapter extends TypeAdapter<Registration> {
  @override
  final int typeId = 3;

  @override
  Registration read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Registration()
      ..remoteId = fields[0] as String
      ..gender = fields[1] as String
      ..fullName = fields[2] as String
      ..studentId = fields[3] as String
      ..classeId = fields[4] as String
      ..schoolId = fields[5] as String
      ..academicId = fields[6] as String
      ..matricule = fields[7] as String?;
  }

  @override
  void write(BinaryWriter writer, Registration obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.remoteId)
      ..writeByte(1)
      ..write(obj.gender)
      ..writeByte(2)
      ..write(obj.fullName)
      ..writeByte(3)
      ..write(obj.studentId)
      ..writeByte(4)
      ..write(obj.classeId)
      ..writeByte(5)
      ..write(obj.schoolId)
      ..writeByte(6)
      ..write(obj.academicId)
      ..writeByte(7)
      ..write(obj.matricule);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegistrationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
