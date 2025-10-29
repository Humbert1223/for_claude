import 'package:novacole/models/user_model.dart';
import 'package:novacole/services/assessment_sync_service.dart';
import 'package:novacole/services/classe_sync_service.dart';
import 'package:novacole/services/mark_sync_service.dart';
import 'package:novacole/services/registration_sync_service.dart';
import 'package:novacole/services/subject_sync_service.dart';
import 'package:novacole/utils/api.dart';
import 'package:novacole/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma("vm:entry-point")
void callbackSyncDispatcher() {
  /*Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    await HiveService.init(path: inputData?['path']);
    switch (task) {
      case TaskType.syncMarkTask:
        await MarkSyncService.syncAllNotesToApi();
        break;
      case TaskType.syncAllForMarks:
        SyncManager.triggerSyncAllForMarks();
        break;
      default:
        debugPrint("Unknown task");
    }
    return Future.value(false);
  });*/
}

class SyncManager {
  static Future<int?> lastSyncElapsedTime(String model) async {
    SharedPreferences prefs = await Http().local();
    UserModel? user = await UserModel.fromLocalStorage();
    if (user == null) return null;
    String? lastSyncString = prefs.getString(
      await SyncManager.getLastSyncKey(user, model),
    );

    DateTime lastSync = DateTime.parse(
      lastSyncString ?? '1970-01-01T00:00:00Z',
    );
    return DateTime.now().difference(lastSync).inMinutes;
  }

  static Future<void> setLastSyncNow(String model, {bool reinit = false}) async {
    SharedPreferences prefs = await Http().local();
    UserModel? user = await UserModel.fromLocalStorage();
    if (user == null) return;
    await prefs.setString(
      await SyncManager.getLastSyncKey(user, model),
      reinit
          ? '1970-01-01T00:00:00Z'
          : DateTime.now().toUtc().toIso8601String(),
    );
  }

  static Future<String> getLastSyncKey(UserModel user, String model) async {
    return '${user.id}_${user.accountType}_${user.school}_${model}_last_synced_at';
  }

  static Future<void> triggerSyncAllForMarks() async {
    if(await ClasseSyncService.syncAllClasseFromApi()){
      setLastSyncNow(Entity.classe);
    }
    if(await SubjectSyncService.syncAllSubjectFromApi()){
      setLastSyncNow(Entity.subject);
    }
    if(await AssessmentSyncService.syncAllAssessmentFromApi()){
      setLastSyncNow(Entity.assessment);
    }
    if(await MarkSyncService.syncAllNotesToApi()){
      setLastSyncNow(Entity.mark);
    }
    if(await RegistrationSyncService.syncAllRegistrationsFromApi()){
      setLastSyncNow(Entity.registration);
    }
  }
}
