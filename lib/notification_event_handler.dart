import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:novacole/controllers/auth_provider.dart';
import 'package:novacole/hive/mark.dart';
import 'package:novacole/services/assessment_sync_service.dart';
import 'package:novacole/services/classe_sync_service.dart';
import 'package:novacole/services/mark_sync_service.dart';
import 'package:novacole/services/registration_sync_service.dart';
import 'package:novacole/utils/hive-service.dart';

class NotificationEventHandler {
  static handle(RemoteMessage message) async {
    final event = message.data['data_value'];
    switch (event) {
      case NotificationEventType.roleChanged:
        await authProvider.refreshUser();
        if (kDebugMode) {
          print("Event: Role updated !");
        }
        break;
      case NotificationEventType.assessmentChanged:
        await AssessmentSyncService.syncAllAssessmentFromApi();
        if (kDebugMode) {
          print("Event: Assessment synced !");
        }
        break;
      case NotificationEventType.registrationChanged:
        await RegistrationSyncService.syncAllRegistrationsFromApi();
        if (kDebugMode) {
          print("Event: Registration synced !");
        }
        break;
      case NotificationEventType.classeChanged:
        await ClasseSyncService.syncAllClasseFromApi();
        if (kDebugMode) {
          print("Event: Classe synced !");
        }
        break;
      case NotificationEventType.markChanged:
        String? metaJsonString = message.data['meta'];
        if(metaJsonString != null){
          final metaData = jsonDecode(metaJsonString);
          if(metaData != null && metaData['mark'] != null){
            if(['update', 'create', 'restore'].contains(metaData['action'])){
            Box<Mark> markBox = await HiveService.marksBox(authProvider.currentUser);
            return MarkSyncService.upsertMark(markBox, metaData['mark']);
            }else{
              await MarkSyncService.syncAllNotesToApi();
            }
          }else{
            await MarkSyncService.syncAllNotesToApi();
          }
        }else{
          await MarkSyncService.syncAllNotesToApi();
        }
        if (kDebugMode) {
          print("Event: Mark synced !");
        }
        break;
      default:
        break;
    }
  }
}

class NotificationEventType {
  static const String roleChanged = 'role_changed';
  static const String assessmentChanged = 'assessment_changed';
  static const String classeChanged = 'classe_changed';
  static const String registrationChanged = 'registration_changed';
  static const String markChanged = 'mark_changed';
}
