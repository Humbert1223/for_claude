import 'package:hive/hive.dart';

part 'quiz.g.dart';

@HiveType(typeId: 5)
class Quiz extends HiveObject {

  @HiveField(0)
  late String name;

  @HiveField(1)
  late List<String> options;

  @HiveField(2)
  late String correctAnswer;

  @HiveField(3)
  late String remoteId;

  @HiveField(4)
  late String levelId;

  @HiveField(5)
  late String disciplineId;

  @HiveField(6)
  late String chapterId;

}
