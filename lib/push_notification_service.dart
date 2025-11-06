import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:novacole/core/services/navigator_service.dart';
import 'package:novacole/firebase_options.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/notification_event_handler.dart';
import 'package:novacole/utils/api.dart';
import 'package:novacole/utils/constants.dart';

/// Gestionnaire des notifications en arrière-plan
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    final service = PushNotificationService();
    await service.setupLocalNotificationPlugin();
    await service.showFlutterNotification(message);

    if (message.data.isNotEmpty) {
      final data = {
        'title': message.notification?.title,
        'body': message.notification?.body,
        'data': message.data,
      };
      final pref = await Http().local();
      await pref.setString(LocalStorageKeys.lastNotification, jsonEncode(data));
    }
  } catch (e) {
    if (kDebugMode) {
      print('Erreur dans le gestionnaire background: $e');
    }
  }
}

/// Canal de notification Android
const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'novacole_canal_2',
  'High Importance Notifications',
  importance: Importance.max,
  playSound: true,
  sound: RawResourceAndroidNotificationSound('notification'),
);

class PushNotificationService {
  // Singleton pattern
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  // Variables d'instance
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _nPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialisation du service de notifications
  Future<void> initialise() async {
    try {
      // Demande de permissions
      await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: true,
        sound: true,
      );

      // Configuration du gestionnaire background
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Écoute des notifications en foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Écoute des clics sur notifications (app en background)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Mise à jour du token FCM
      FirebaseMessaging.instance.onTokenRefresh.listen(_handleTokenRefresh);

      // Gestion de l'ouverture depuis une notification (app fermée)
      _handleInitialMessage();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de l\'initialisation du service de notifications: $e');
      }
    }
  }

  /// Gère les notifications reçues en foreground
  _handleForegroundMessage(RemoteMessage message) {
    try {
      // Traitement des événements spécifiques
      if (message.data['data_type'] == 'event') {
        _handleEventNotification(message);
      }

      // Affichage de la notification
      showFlutterNotification(message);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du traitement de la notification foreground: $e');
      }
    }
  }

  /// Traite les notifications de type événement
  _handleEventNotification(RemoteMessage message) {
    try {
      NotificationEventHandler.handle(message);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du traitement de l\'événement: $e');
      }
    }
  }

  /// Gère le clic sur une notification (app en background)
  void _handleNotificationTap(RemoteMessage message) {
    try {
      final data = {
        'title': message.notification?.title,
        'body': message.notification?.body,
        'data': message.data,
      };
      //todo: Ajouter les données dans le local storage
      NavigationService.navigateTo('/notification');
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de l\'ouverture de la notification: $e');
      }
    }
  }

  /// Gère le rafraîchissement du token FCM
  Future<void> _handleTokenRefresh(String token) async {
    try {
      await MasterCrudModel.patch('/auth/user/update-fcm-token', {
        'device_fcm_token': token,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la mise à jour du token FCM: $e');
      }
    }
  }

  /// Gère l'ouverture de l'app depuis une notification (app fermée)
  Future<void> _handleInitialMessage() async {
    try {
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        final data = {
          'title': initialMessage.notification?.title,
          'body': initialMessage.notification?.body,
          'data': initialMessage.data,
        };

        //todo: Ajouter les données dans le local storage
        NavigationService.navigateAndRemoveUntil('/notification');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération de la notification initiale: $e');
      }
    }
  }

  /// Affiche une notification locale
  Future<void> showFlutterNotification(RemoteMessage message) async {
    try {
      await setupLocalNotificationPlugin();

      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null && android != null) {
        await _nPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          _notificationDetails,
          payload: jsonEncode({
            'title': notification.title,
            'body': notification.body,
            'data': message.data,
          }),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de l\'affichage de la notification: $e');
      }
    }
  }

  /// Paramètres de la notification
  NotificationDetails get _notificationDetails {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        sound: const RawResourceAndroidNotificationSound('notification'),
        icon: 'notification_icon',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableLights: true,
        enableVibration: true,
        fullScreenIntent: true,
      ),
    );
  }

  /// Configuration du plugin de notifications locales
  Future<void> setupLocalNotificationPlugin() async {
    if (_isInitialized) {
      return;
    }

    try {
      // Création du canal Android
      await _nPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      // Initialisation du plugin
      const initSetAndroid = AndroidInitializationSettings('launcher_icon');
      const initSettings = InitializationSettings(android: initSetAndroid);

      await _nPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la configuration du plugin de notifications: $e');
      }
    }
  }

  /// Callback lors du clic sur une notification locale
  void _onNotificationResponse(NotificationResponse response) {
    try {
      if (response.payload != null) {
        final data = jsonDecode(response.payload!);

        //todo: Ajouter les données dans le local storage
        NavigationService.navigateTo('/notification');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du traitement de la réponse à la notification: $e');
      }
    }
  }

  /// Récupère le token FCM actuel
  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération du token FCM: $e');
      }
      return null;
    }
  }

  /// Supprime le token FCM
  Future<void> deleteToken() async {
    try {
      await _fcm.deleteToken();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la suppression du token FCM: $e');
      }
    }
  }
}