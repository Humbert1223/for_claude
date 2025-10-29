import 'package:hive/hive.dart';
import 'package:novacole/hive/assessment.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/utils/api.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/hive-service.dart';
import 'package:novacole/utils/sync_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AssessmentSyncService {
  static Future<bool> syncAllAssessmentFromApi() async {
    try {
      SharedPreferences prefs = await Http().local();

      UserModel? user = await UserModel.fromLocalStorage();
      if (!_canUserSync(user)) {
        return false;
      }

      DateTime lastSynced = DateTime.parse(
        prefs.getString(await SyncManager.getLastSyncKey(user!, Entity.assessment)) ??
            '1970-01-01T00:00:00Z',
      ).subtract(const Duration(minutes: 10));

      List? response = await MasterCrudModel(Entity.assessment).search(
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

      for (final remoteAss in (response)) {
        await upsertAssessment(remoteAss, user);
      }

      await removeObsoleteAssessment();

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> removeObsoleteAssessment() async {
    UserModel? user = await UserModel.fromLocalStorage();
    if (!_canUserSync(user)) {
      return;
    }

    Box<Assessment> assessmentsBox = await HiveService.assessmentsBox(user!);

    final localAssessments = assessmentsBox.values.toList();

    List<String> localIds = localAssessments.map((e) => e.remoteId).toList();

    List? response = await MasterCrudModel.load(
      '/sync/assessment/obsoletes',
      data: {'ids': localIds},
    );

    if (response == null) return;

    final idsToDelete = localAssessments
        .where((a) => response.contains(a.remoteId))
        .map((a) => a.key)
        .toList();

    if (idsToDelete.isNotEmpty) {
      await assessmentsBox.deleteAll(idsToDelete);
    }
  }

  static Future<bool> upsertAssessment(remoteAss, user) async {
    try{
      Box<Assessment> assessmentsBox = await HiveService.assessmentsBox(user);

      Assessment? existing = assessmentsBox.values
          .where((c) => c.remoteId == remoteAss['id'].toString())
          .firstOrNull;

      if (existing == null) {
        final newAssessment = Assessment()
          ..name = remoteAss['name'].toString()
          ..remoteId = remoteAss['id'].toString()
          ..schoolId = remoteAss['school_id'].toString()
          ..closed = remoteAss['closed']
          ..classeIds = List<String>.from(remoteAss['classe_ids'] ?? []);
        return await assessmentsBox.add(newAssessment) >= 1;
      } else {
        existing.name = remoteAss['name'].toString();
        existing.schoolId = remoteAss['school_id'].toString();
        existing.closed = remoteAss['closed'];
        existing.classeIds = List<String>.from(remoteAss['classe_ids'] ?? []);
        await existing.save();
        return true;
      }
    }catch(e){
      return false;
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
