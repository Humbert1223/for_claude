import 'package:hive/hive.dart';

part 'quiz_user_model.g.dart';

@HiveType(typeId: 6)
class QuizUser extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? avatarUrl;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  Map<String, dynamic>? preferences;

  @HiveField(5)
  List<QuizScore>? scores;

  QuizUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.createdAt,
    this.preferences,
    this.scores,
  });

  // Méthodes utiles
  String get levelId => preferences?['levelId'] ?? '';
  String? get serieId => preferences?['serieId'];
  String get disciplineId => preferences?['disciplineId'] ?? '';
  bool get isTimerEnabled => preferences?['isTimerEnabled'] ?? false;
  bool get isSoundEnabled => preferences?['isSoundEnabled'] ?? false;

  void updatePreferences({
    String? levelId,
    String? serieId,
    String? disciplineId,
    bool? isTimerEnabled,
    bool? isSoundEnabled,
  }) {
    preferences ??= {};
    if (levelId != null) preferences!['levelId'] = levelId;
    if (serieId != null) preferences!['serieId'] = serieId;
    if (disciplineId != null) preferences!['disciplineId'] = disciplineId;
    if (isTimerEnabled != null) preferences!['isTimerEnabled'] = isTimerEnabled;
    if (isSoundEnabled != null) preferences!['isSoundEnabled'] = isSoundEnabled;
    save();
  }

  void addScore(QuizScore score) {
    scores ??= [];
    scores!.add(score);
    save();
  }
}

@HiveType(typeId: 7)
class QuizScore extends HiveObject {
  @HiveField(0)
  String levelId;

  @HiveField(1)
  String? serieId;

  @HiveField(2)
  String disciplineId;

  @HiveField(3)
  int score;

  @HiveField(4)
  int totalQuestions;

  @HiveField(5)
  bool usedTimer;

  @HiveField(6)
  DateTime playedAt;

  QuizScore({
    required this.levelId,
    this.serieId,
    required this.disciplineId,
    required this.score,
    required this.totalQuestions,
    required this.usedTimer,
    required this.playedAt,
  });

  double get percentage => (score / totalQuestions) * 100;
}