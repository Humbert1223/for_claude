// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuizUserAdapter extends TypeAdapter<QuizUser> {
  @override
  final int typeId = 6;

  @override
  QuizUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizUser(
      id: fields[0] as String,
      name: fields[1] as String,
      avatarUrl: fields[2] as String?,
      createdAt: fields[3] as DateTime,
      preferences: (fields[4] as Map?)?.cast<String, dynamic>(),
      scores: (fields[5] as List?)?.cast<QuizScore>(),
    );
  }

  @override
  void write(BinaryWriter writer, QuizUser obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.avatarUrl)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.preferences)
      ..writeByte(5)
      ..write(obj.scores);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuizScoreAdapter extends TypeAdapter<QuizScore> {
  @override
  final int typeId = 7;

  @override
  QuizScore read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizScore(
      levelId: fields[0] as String,
      serieId: fields[1] as String?,
      disciplineId: fields[2] as String,
      score: fields[3] as int,
      totalQuestions: fields[4] as int,
      usedTimer: fields[5] as bool,
      playedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, QuizScore obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.levelId)
      ..writeByte(1)
      ..write(obj.serieId)
      ..writeByte(2)
      ..write(obj.disciplineId)
      ..writeByte(3)
      ..write(obj.score)
      ..writeByte(4)
      ..write(obj.totalQuestions)
      ..writeByte(5)
      ..write(obj.usedTimer)
      ..writeByte(6)
      ..write(obj.playedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizScoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
