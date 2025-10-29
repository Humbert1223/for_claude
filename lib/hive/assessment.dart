import 'package:hive/hive.dart';

part 'assessment.g.dart';

@HiveType(typeId: 0)
class Assessment extends HiveObject {

  @HiveField(0)
  late String name;

  @HiveField(1)
  late String remoteId;

  @HiveField(2)
  late String schoolId;

  @HiveField(3)
  late List<String> classeIds;

  @HiveField(4)
  bool? closed;
}
