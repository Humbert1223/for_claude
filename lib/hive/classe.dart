import 'package:hive/hive.dart';

part 'classe.g.dart';

@HiveType(typeId: 1)
class Classe extends HiveObject {

  @HiveField(0)
  late String name;

  @HiveField(1)
  late String remoteId;

  @HiveField(2)
  late String schoolId;

  @HiveField(3)
  late String academicId;

  @HiveField(4)
  int? levelOrder;

}
