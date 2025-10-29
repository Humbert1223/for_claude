import 'package:flutter/material.dart';

const String kAppName = "Novacole";
const String kAppDescription =
    "Plateforme de gestion scolaire innovante,"
    " conçue pour transformer la gestion quotidienne"
    " des établissements scolaire, de la maternelle au lycée";
const String kAppPrivacyUrl = "https://novacole.com/privacy";
const String kAppStorageUrl =
    "https://novacole-bucket.fr-par-1.linodeobjects.com/";
const String kAppUrl =
    "https://play.google.com/store/apps/details?id=com.novacole.app";

class LocalStorageKeys {
  static const String lockActive = 'lock_active';
  static const String authUser = 'auth_user';
  static const String authUserList = 'account_list';
  static const String theme = 'app_theme';
  static const String lastNotification = 'last_notification';
}

class TaskType {
  static const String syncAllForMarks = 'syncAllForMarkTask';
  static const String syncMarkTask = 'syncMarkTask';
}

class Entity {
  static const String teacher = 'teacher';
  static const String tutor = 'tutor';
  static const String registration = 'registration';
  static const String exam = 'exam';
  static const String student = 'student';
  static const String classe = 'classe';
  static const String subject = 'subject';
  static const String mark = 'mark';
  static const String assessment = 'assessment';
  static const String school = 'school';
  static const String irregularity = 'irregularity';
  static const String level = 'level';
  static const String period = 'period';
  static const String tuition = 'tuition';
  static const String serie = 'serie';
  static const String expense = 'expense';
  static const String quiz = 'qcm';
  static const String chapter = 'chapter';
  static const String document = 'document';
  static const String leave = 'leave';
  static const String paymentRequest = 'payment_request';
  static const String operation = 'operation';
  static const String payment = 'payment';
  static const String post = 'post';
  static const String event = 'event';
  static const String notification = 'notification';
  static const String academic = 'academic';
  static const String paymentMethod = 'payment_method';
  static const String user = 'user';
  static const String role = 'role';
  static const String permission = 'permission';
  static const String timetable  = 'timetable';
  static const String lotBulletin = 'lot_bulletin';
  static const String bulletin = 'bulletin';

}

class UserAccountType {
  static const String admin = 'admin';
  static const String teacher = 'teacher';
  static const String tutor = 'tutor';
  static const String student = 'student';
  static const String god = 'god';
  static const String staff = 'staff';
}

const colorPalette = <Color>[
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.teal,
  Colors.pink,
  Colors.indigo,
  Colors.cyan,
  Colors.lime,
  Colors.brown,
  Colors.amber,
  Colors.deepOrange,
  Colors.lightBlue,
  Colors.lightGreen,
  Colors.deepPurple,
  Colors.blueGrey,
  Colors.yellow,
  Colors.grey,
  Colors.black,
  Colors.redAccent,
  Colors.blueAccent,
  Colors.greenAccent,
  Colors.purpleAccent,
  Colors.orangeAccent,
  Colors.tealAccent,
  Colors.indigoAccent,
  Colors.pinkAccent,
  Colors.cyanAccent,
  Colors.limeAccent,
];
