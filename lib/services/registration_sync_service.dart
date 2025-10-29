import 'package:novacole/hive/registration.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/utils/api.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/hive-service.dart';
import 'package:novacole/utils/sync_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationSyncService {
  static Future<bool> syncAllRegistrationsFromApi() async {
    try {
      SharedPreferences prefs = await Http().local();

      UserModel? user = await UserModel.fromLocalStorage();
      if (!_canUserSync(user)) {
        return false;
      }
      DateTime lastSynced = DateTime.parse(
        prefs.getString(await SyncManager.getLastSyncKey(user!, Entity.registration)) ??
            '1970-01-01T00:00:00Z',
      ).subtract(const Duration(minutes: 10));
      final registrationBox = await HiveService.registrationsBox(user);
      int page = 1;

      List<String> remoteIds = [];

      do {
        Map<String, dynamic>? response = await MasterCrudModel('registration')
            .search(
              paginate: '1',
              page: page,
              perPage: 50,
              filters: [
                {'field': 'is_abandon', 'operator': '!=', 'value': true},
                {'field': 'classe_id', 'operator': 'exists', 'value': true},
                {'field': 'classe_id', 'operator': '!=', 'value': null},
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

        List data = response?['data'] ?? [];
        if (data.isEmpty) {
          page = -1; // Stop if no more data
        } else {
          page++;
        }

        final Map<String, Registration> index = {
          for (var reg in registrationBox.values) reg.remoteId: reg,
        };
        for (final remoteRegistration in data) {
          remoteIds.add(remoteRegistration['id'].toString());
          Registration? existing = index[remoteRegistration['id'].toString()];

          if (existing == null) {
            final newRegistration = Registration()
              ..studentId = remoteRegistration['student_id'].toString()
              ..gender = remoteRegistration['student']['gender'].toString()
              ..fullName = remoteRegistration['full_name'].toString()
              ..academicId = remoteRegistration['academic_id'].toString()
              ..schoolId = remoteRegistration['school_id'].toString()
              ..classeId = remoteRegistration['classe_id'].toString()
              ..matricule = remoteRegistration['student']['matricule']
                  ?.toString()
              ..remoteId = remoteRegistration['id'].toString();
            await registrationBox.add(newRegistration);
          } else {
            existing.fullName = remoteRegistration['full_name'].toString();
            existing.classeId = remoteRegistration['classe_id'].toString();
            existing.schoolId = remoteRegistration['school_id'].toString();
            existing.gender = remoteRegistration['gender'].toString();
            await existing.save();
          }
        }
      } while (page > 0);
      await removeObsoleteRegistrations();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> removeObsoleteRegistrations() async {
    UserModel? user = await UserModel.fromLocalStorage();
    if (user == null) {
      return;
    }
    final registrationBox = await HiveService.registrationsBox(user);

    final localRegistration = registrationBox.values.toList();

    List<String> localIds = localRegistration.map((e) => e.remoteId).toList();

    List? response = await MasterCrudModel.load(
      '/sync/registration/obsoletes',
      data: {'ids': localIds},
    );

    if (response == null) return;

    final idsToDelete = localRegistration
        .where((a) => response.contains(a.remoteId))
        .map((a) => a.key)
        .toList();

    if (idsToDelete.isNotEmpty) {
      await registrationBox.deleteAll(idsToDelete);
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
