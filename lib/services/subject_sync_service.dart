import 'package:novacole/hive/subject.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/utils/api.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/hive-service.dart';
import 'package:novacole/utils/sync_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubjectSyncService {
  static Future<bool> syncAllSubjectFromApi() async {
    try {
      SharedPreferences prefs = await Http().local();

      UserModel? user = await UserModel.fromLocalStorage();
      if (!_canUserSync(user)) {
        return false;
      }
      DateTime lastSynced = DateTime.parse(
        prefs.getString(await SyncManager.getLastSyncKey(user!, Entity.subject)) ??
            '1970-01-01T00:00:00Z',
      ).subtract(const Duration(minutes: 10));
      final subjectBox = await HiveService.subjectsBox(user);
      List? response = await MasterCrudModel(Entity.subject).search(
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

      for (final remoteSubject in response) {
        Subject? existing = subjectBox.values
            .where((sub) => sub.remoteId == remoteSubject['id'].toString())
            .firstOrNull;

        if (existing == null) {
          final newSubject = Subject()
            ..name = remoteSubject['name'].toString()
            ..classeId = remoteSubject['classe_id'].toString()
            ..schoolId = remoteSubject['school_id'].toString()
            ..remoteId = remoteSubject['id'].toString();
          await subjectBox.add(newSubject);
        } else {
          existing.name = remoteSubject['name'].toString();
          existing.schoolId = remoteSubject['school_id'].toString();
          existing.classeId = remoteSubject['classe_id'].toString();
          await existing.save();
        }
      }

      await removeObsoleteSubject();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> removeObsoleteSubject() async {
    UserModel? user = await UserModel.fromLocalStorage();
    if (user == null) {
      return;
    }
    final subjectBox = await HiveService.subjectsBox(user);

    final localSubjects = subjectBox.values.toList();

    List<String> localIds = localSubjects.map((e) => e.remoteId).toList();

    List? response = await MasterCrudModel.load(
      '/sync/subject/obsoletes',
      data: {'ids': localIds},
    );

    if (response == null) return;

    final idsToDelete = localSubjects
        .where((a) => response.contains(a.remoteId))
        .map((a) => a.key)
        .toList();

    if (idsToDelete.isNotEmpty) {
      await subjectBox.deleteAll(idsToDelete);
    }
  }

  static bool _canUserSync(UserModel? user) {
    if (user == null || user.school == null || user.academic == null) {
      return false;
    }
    return ![
      UserAccountType.student,
      UserAccountType.tutor,
    ].contains(user.accountType);
  }
}
