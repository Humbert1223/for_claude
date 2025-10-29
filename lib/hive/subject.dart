import 'package:hive/hive.dart';

part 'subject.g.dart';

@HiveType(typeId: 4) // ⚠️ typeId unique (0=Assessment, 1=Classe, 2=Mark, 3=Registration, 4=Subject)
class Subject extends HiveObject {

  @HiveField(0)
  late String remoteId;

  @HiveField(1)
  late String classeId;

  @HiveField(2)
  late String schoolId;

  @HiveField(3)
  late String name;
}
