import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:novacole/controllers/auth_controller.dart';
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
        final authController = Get.find<AuthController>();
        authController.refreshUser();
        if (kDebugMode) {
          print("Event: User refreshed !");
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
            final authController = Get.find<AuthController>();
            Box<Mark> markBox = await HiveService.marksBox(authController.currentUser.value!);
             Obx((){
               return MarkSyncService.upsertMark(markBox, metaData['mark']);
             });
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
