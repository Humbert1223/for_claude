import 'package:hive/hive.dart';

part 'mark.g.dart';

@HiveType(typeId: 2) // ⚠️ typeId unique (0=Assessment, 1=Classe, 2=Mark, etc.)
class Mark extends HiveObject {

  @HiveField(0)
  late String assessmentId;

  @HiveField(1)
  late String studentId;

  @HiveField(2)
  late String subjectId;

  @HiveField(3)
  late String schoolId;

  @HiveField(4)
  double? value;

  @HiveField(5)
  DateTime updatedAt = DateTime.now();

  @HiveField(6)
  String? remoteId;

  @HiveField(7)
  late bool isSynced;

  @HiveField(8)
  bool isDeleted = false;
}
