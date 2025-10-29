// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuizAdapter extends TypeAdapter<Quiz> {
  @override
  final int typeId = 5;

  @override
  Quiz read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Quiz()
      ..name = fields[0] as String
      ..options = (fields[1] as List).cast<String>()
      ..correctAnswer = fields[2] as String
      ..remoteId = fields[3] as String
      ..levelId = fields[4] as String
      ..disciplineId = fields[5] as String
      ..chapterId = fields[6] as String;
  }

  @override
  void write(BinaryWriter writer, Quiz obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.options)
      ..writeByte(2)
      ..write(obj.correctAnswer)
      ..writeByte(3)
      ..write(obj.remoteId)
      ..writeByte(4)
      ..write(obj.levelId)
      ..writeByte(5)
      ..write(obj.disciplineId)
      ..writeByte(6)
      ..write(obj.chapterId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
