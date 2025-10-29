import 'package:hive/hive.dart';
import 'package:novacole/hive/classe.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/utils/api.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/hive-service.dart';
import 'package:novacole/utils/sync_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClasseSyncService {
  static Future<bool> syncAllClasseFromApi() async {
    try {
      SharedPreferences prefs = await Http().local();

      UserModel? user = await UserModel.fromLocalStorage();
      if (!_canUserSync(user)) {
        return false;
      }

      DateTime lastSynced = DateTime.parse(
        prefs.getString(await SyncManager.getLastSyncKey(user!, Entity.classe)) ??
            '1970-01-01T00:00:00Z',
      ).subtract(const Duration(minutes: 10));

      Box<Classe> classesBox = await HiveService.classesBox(user);

      List? response = await MasterCrudModel(Entity.classe).search(
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

      for (final remoteClasse in response) {
        Classe? existing = classesBox.values
            .where((c) => c.remoteId == remoteClasse['id'].toString())
            .firstOrNull;

        if (existing == null) {
          final newClasse = Classe()
            ..name = remoteClasse['name'].toString()
            ..remoteId = remoteClasse['id'].toString()
            ..schoolId = remoteClasse['school_id'].toString()
            ..academicId = remoteClasse['academic_id'].toString()
            ..levelOrder = remoteClasse['level_order'] != null
                ? int.tryParse(remoteClasse['level_order'].toString())
                : null;
          await classesBox.add(newClasse);
        } else {
          existing.name = remoteClasse['name'].toString();
          existing.levelOrder = remoteClasse['level_order'] != null
              ? int.tryParse(remoteClasse['level_order'].toString())
              : null;
          await existing.save();
        }
      }
      await removeObsoleteClasse();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> removeObsoleteClasse() async {
    UserModel? user = await UserModel.fromLocalStorage();
    if (!_canUserSync(user)) {
      return;
    }

    Box<Classe> classesBox = await HiveService.classesBox(user!);

    final localClasses = classesBox.values.toList();

    List<String> localIds = localClasses.map((e) => e.remoteId).toList();

    List? response = await MasterCrudModel.load(
      '/sync/classe/obsoletes',
      data: {'ids': localIds},
    );

    if (response == null) return;

    final idsToDelete = localClasses
        .where((a) => response.contains(a.remoteId))
        .map((a) => a.key)
        .toList();

    if (idsToDelete.isNotEmpty) {
      await classesBox.deleteAll(idsToDelete);
    }
  }

  static bool _canUserSync(UserModel? user) {
    if (user == null || user.school == null || user.academic == null)
      return false;
    return ![
      UserAccountType.student,
      UserAccountType.tutor,
    ].contains(user.accountType);
  }
}
