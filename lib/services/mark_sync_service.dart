import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:novacole/hive/mark.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/utils/api.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/hive-service.dart';
import 'package:novacole/utils/sync_manager.dart';

class MarkSyncService {
  /// --- PUBLIC SYNC METHOD ---
  static Future<bool> syncAllNotesToApi() async {
    try {
      final prefs = await Http().local();
      final user = await UserModel.fromLocalStorage();

      final lastSynced = DateTime.parse(
        prefs.getString(await SyncManager.getLastSyncKey(user!, Entity.mark)) ??
            '1970-01-01T00:00:00Z',
      ).subtract(const Duration(minutes: 10));

      if (!_canUserSync(user)) {
        return false;
      }

      final markBox = await HiveService.marksBox(user);

      await _syncLocalNotesToServer(markBox);

      final remoteNotes = await _fetchRemoteNotes(user, lastSynced);

      await _mergeRemoteNotes(markBox, remoteNotes, lastSynced);

      await removeObsoleteMarks();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// --- PRIVATE HELPERS ---

  static bool _canUserSync(UserModel? user) {
    if (user == null ||
        user.school == null ||
        user.academic == null ||
        user.accountType == null) {
      return false;
    }
    return ![
      UserAccountType.student,
      UserAccountType.tutor,
    ].contains(user.accountType);
  }

  static Future<void> _syncLocalNotesToServer(Box<Mark> marksBox) async {
    final unsyncedNotes = marksBox.values
        .where((note) => !note.isSynced)
        .toList();

    for (final note in unsyncedNotes) {
      try {
        final response = await MasterCrudModel.post(
          '/process-mark',
          data: {
            'assessment_id': note.assessmentId,
            'student_id': note.studentId,
            'subject_id': note.subjectId,
            'value': note.value,
          },
        );

        if (response != null && response['value'] != null) {
          note
            ..isSynced = true
            ..remoteId = response['id']?.toString()
            ..updatedAt = DateTime.parse(response['updated_at']);
          await note.save();
        }
      } catch (e) {
       if(kDebugMode){
         debugPrint('❌ Sync échouée pour note ${note.key} : $e');
       }
      }
    }
  }

  static Future<List?> _fetchRemoteNotes(UserModel user, DateTime lastSynced) async {
    final isRestricted = ![
      UserAccountType.admin,
      UserAccountType.staff,
    ].contains(user.accountType);

    final filters = <Map<String, dynamic>>[
      {'field': 'assessment.closed', 'value': false},
      {'field': 'subject.academic_id', 'value': user.academic},
      {
        'field': 'updated_at',
        'operator': 'DATEBETWEEN',
        'value': [
          lastSynced.subtract(const Duration(minutes: 10)).toIso8601String(),
          DateTime.now().add(Duration(minutes: 1)).toIso8601String(),
        ],
      },
    ];

    if (isRestricted) {
      filters.addAll([
        {'field': 'created_by', 'value': user.id, 'group': 'or_owner'},
        {'field': 'subject.teacher_id', 'value': user.id, 'group': 'or_owner'},
        {
          'field': 'subject.classe.titulaire.user_id',
          'value': user.id,
          'group': 'or_owner',
        },
      ]);
    }

    return await MasterCrudModel(
      'mark',
    ).search(paginate: '0', filters: filters);
  }

  static Future<void> _mergeRemoteNotes(
    Box<Mark> markBox,
    List? remoteNotes,
    DateTime lastSynced,
  ) async {
    if (remoteNotes == null) return;

    for (final remote in remoteNotes) {
      upsertMark(markBox, remote);
    }
  }

  static upsertMark(Box<Mark> markBox, remote) async {
    final studentId = remote['student_id'];
    final assessmentId = remote['assessment_id'];
    final subjectId = remote['subject_id'];
    final remoteUpdatedAt = DateTime.parse(remote['updated_at']);

    final existing = markBox.values
        .where(
          (mark) =>
      mark.studentId == studentId &&
          mark.assessmentId == assessmentId &&
          mark.subjectId == subjectId,
    ).firstOrNull;

    if (existing != null) {
      if (existing.updatedAt.isBefore(remoteUpdatedAt)) {
        existing
          ..value = (remote['value'] as num).toDouble()
          ..schoolId = remote['school_id'].toString()
          ..updatedAt = remoteUpdatedAt
          ..isSynced = true
          ..remoteId = remote['id'].toString();
        await existing.save();
      }
    } else {
      final newNote = Mark()
        ..schoolId = remote['school_id'].toString()
        ..studentId = studentId
        ..assessmentId = assessmentId
        ..subjectId = subjectId
        ..value = (remote['value'] as num).toDouble()
        ..updatedAt = remoteUpdatedAt
        ..isSynced = true
        ..remoteId = remote['id'].toString();
      await markBox.add(newNote);
    }
  }
  static Future<void> removeObsoleteMarks() async {
    UserModel? user = await UserModel.fromLocalStorage();
    if (user == null) {
      return;
    }
    final markBox = await HiveService.marksBox(user);

    final localMarks = markBox.values
        .where((mark) => mark.schoolId == user.school && mark.remoteId != null)
        .toList();

    List<String?> localIds = localMarks.map((e) => e.remoteId).toList();

    List? response = await MasterCrudModel.load(
      '/sync/mark/obsoletes',
      data: {'ids': localIds},
    );

    if (response == null) return;

    final idsToDelete = localMarks
        .where((m) => response.contains(m.remoteId))
        .map((m) => m.key)
        .toList();

    if (idsToDelete.isNotEmpty) {
      await markBox.deleteAll(idsToDelete);
    }
  }
}
