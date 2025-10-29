import 'package:hive/hive.dart';
import 'package:novacole/hive/quiz.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/utils/api.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/hive-service.dart';
import 'package:novacole/utils/sync_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizSyncService {
  static Future<bool> syncAllQuizFromApi() async {
    try {
      SharedPreferences prefs = await Http().local();

      UserModel? user = await UserModel.fromLocalStorage();
      if (!_canUserSync(user)) {
        return false;
      }

      DateTime lastSynced = DateTime.parse(
        prefs.getString(await SyncManager.getLastSyncKey(user!, Entity.quiz)) ??
            '1970-01-01T00:00:00Z',
      );

      Box<Quiz> quizBox = await HiveService.quizBox({});

      List? response = await MasterCrudModel(Entity.quiz).search(
        paginate: '0',
        filters: [
          {
            'field': 'updated_at',
            'operator': 'DATEBETWEEN',
            'value': [
              lastSynced
                  .subtract(const Duration(minutes: 10))
                  .toIso8601String(),
              DateTime.now().add(Duration(minutes: 1)).toIso8601String(),
            ],
          },
        ],
      );

      if (response == null) return false;

      final Map<String, Quiz> index = {
        for (var quiz in quizBox.values) quiz.remoteId: quiz,
      };

      for (final remoteQuiz in (response)) {
        Quiz? existing = index[remoteQuiz['id'].toString()];

        if (existing == null) {
          final newQuiz = Quiz()
            ..name = remoteQuiz['name'].toString()
            ..remoteId = remoteQuiz['id'].toString()
            ..options = List<String>.from(remoteQuiz['options'] ?? [])
            ..levelId = remoteQuiz['level_id']
            ..disciplineId = remoteQuiz['discipline_id']
            ..chapterId = remoteQuiz['chapter_id'];

          await quizBox.add(newQuiz);
        } else {
          existing.name = remoteQuiz['name'].toString();
          existing.options = List<String>.from(remoteQuiz['options'] ?? []);
          existing.levelId = remoteQuiz['level_id'];
          existing.disciplineId = remoteQuiz['discipline_id'];
          existing.chapterId = remoteQuiz['chapter_id'];
          await existing.save();
        }
      }

      await removeObsoleteQuiz();

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> removeObsoleteQuiz() async {
    UserModel? user = await UserModel.fromLocalStorage();
    if (!_canUserSync(user)) {
      return;
    }

    Box<Quiz> quizBox = await HiveService.quizBox({});

    final localQuiz = quizBox.values.toList();

    List<String> localIds = localQuiz.map((e) => e.remoteId).toList();

    List? response = await MasterCrudModel.load(
      '/sync/quiz/obsoletes',
      data: {'ids': localIds},
    );

    if (response == null) return;

    final idsToDelete = localQuiz
        .where((a) => response.contains(a.remoteId))
        .map((a) => a.key)
        .toList();

    if (idsToDelete.isNotEmpty) {
      await quizBox.deleteAll(idsToDelete);
    }
  }

  static bool _canUserSync(UserModel? user) {
    if (user == null || user.school == null || user.academic == null) {
      return false;
    }
    return true;
  }
}
