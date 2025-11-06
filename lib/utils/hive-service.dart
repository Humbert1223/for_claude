import 'package:hive_flutter/hive_flutter.dart';
import 'package:novacole/hive/quiz.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/quiz/models/quiz_user_model.dart';
import 'package:path_provider/path_provider.dart';

import 'package:novacole/hive/assessment.dart';
import 'package:novacole/hive/classe.dart';
import 'package:novacole/hive/mark.dart';
import 'package:novacole/hive/registration.dart';
import 'package:novacole/hive/subject.dart';

class HiveService {
  static bool _initialized = false;
  static final Map<String, Box> _boxes = {};

  HiveService._();

  static void reinit() {
    _initialized = false;
    _boxes.clear();
  }


  static Future<void> init({String? path }) async {
    if (_initialized) return;

    final dir = await getApplicationDocumentsDirectory();

    Hive.init(path ?? dir.path);

    Hive
      ..registerAdapter(AssessmentAdapter())
      ..registerAdapter(ClasseAdapter())
      ..registerAdapter(MarkAdapter())
      ..registerAdapter(RegistrationAdapter())
      ..registerAdapter(QuizAdapter())
      ..registerAdapter(QuizUserAdapter())
      ..registerAdapter(QuizScoreAdapter())
      ..registerAdapter(SubjectAdapter());

    _initialized = true;
  }

  static Future<Box<T>> _getBox<T>(String name) async {
    if (_boxes.containsKey(name)) {
      return _boxes[name] as Box<T>;
    }
    final box = await Hive.openBox<T>(name);
    _boxes[name] = box;
    return box;
  }

  static Future<Box<Classe>> classesBox(UserModel user) =>
      _getBox<Classe>('${user.id}_${user.accountType}_${user.school}_${user.academic}_classes');

  static Future<Box<Assessment>> assessmentsBox(UserModel user) =>
      _getBox<Assessment>('${user.id}_${user.accountType}_${user.school}_${user.academic}_assessments');

  static Future<Box<Mark>> marksBox(UserModel user) =>
      _getBox<Mark>('${user.id}_${user.accountType}_${user.school}_${user.academic}_marks');

  static Future<Box<Registration>> registrationsBox(UserModel user) =>
      _getBox<Registration>('${user.id}_${user.accountType}_${user.school}_${user.academic}_registrations');

  static Future<Box<Subject>> subjectsBox(UserModel user) =>
      _getBox<Subject>('${user.id}_${user.accountType}_${user.school}_${user.academic}_subjects');

  static Future<Box<Quiz>> quizBox(quizParams) =>
      _getBox<Quiz>('${quizParams.levelId}_${quizParams.disciplineId}_${quizParams.chapterId}');

  static Future<Box<QuizUser>> quizUserBox() => _getBox<QuizUser>('quiz_users');

  static Future<Box<QuizScore>> quizScoreBox() => _getBox<QuizScore>('quiz_scores');

  static Future<Box> quizSettingBox() => _getBox('quiz_settings');
}
