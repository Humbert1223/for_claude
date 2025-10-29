import 'package:hive/hive.dart';

part 'registration.g.dart';

@HiveType(typeId: 3) // ⚠️ typeId unique (0=Assessment, 1=Classe, 2=Mark, 3=Registration)
class Registration extends HiveObject {

  @HiveField(0)
  late String remoteId;

  @HiveField(1)
  late String gender;

  @HiveField(2)
  late String fullName;

  @HiveField(3)
  late String studentId;

  @HiveField(4)
  late String classeId;

  @HiveField(5)
  late String schoolId;

  @HiveField(6)
  late String academicId;

  @HiveField(7)
  String? matricule;

}
