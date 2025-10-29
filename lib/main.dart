import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:novacole/controllers/auth_controller.dart';
import 'package:novacole/firebase_options.dart';
import 'package:novacole/pages/quiz/services/quiz_user_service.dart';
import 'package:novacole/push_notification_service.dart';
import 'package:novacole/routes/router.dart';
import 'package:novacole/theme/ecole_theme.dart';
import 'package:novacole/theme/theme_model.dart';
import 'package:novacole/utils/api.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/hive-service.dart';
import 'package:novacole/utils/review_helper.dart';
import 'package:novacole/utils/update_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await HiveService.init();
  await QuizUserService.init();
  await Firebase.initializeApp(
    name: 'novacole-firebase',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  PushNotificationService().initialise();

  await InAppUpdateService.checkForUpdate();

  Get.put(AuthController());

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('fr')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      useOnlyLangCode: true,
      startLocale: Locale(Intl.shortLocale(Intl.getCurrentLocale())),
      child: const EcoleApp(),
    ),
  );
}

class EcoleApp extends StatefulWidget {
  const EcoleApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return EcoleAppState();
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class EcoleAppState extends State<EcoleApp> {
  @override
  void initState() {
    super.initState();
    FlameAudio.bgm.initialize();

    Future.delayed(Duration(seconds: 1), () {
      ReviewHelper().shouldAskForReview().then((value) {
        if (value) {
          ReviewHelper.requestReview();
          ReviewHelper().saveReviewDate();
        }
      });
    });
    Http().local().then((prefs) {
      String? lastNotificationString = prefs.getString(
        LocalStorageKeys.lastNotification,
      );
      if (lastNotificationString != null) {
        Map<String, dynamic> lastNotification = jsonDecode(
          lastNotificationString,
        );
        Get.toNamed('/notification', arguments: lastNotification);
      }
    });
  }

  @override
  void dispose() {
    FlameAudio.bgm.dispose();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent),
    );
    return ChangeNotifierProvider(
      create: (_) => ThemeModel(),
      child: Consumer<ThemeModel>(
        builder: (context, ThemeModel notifier, child) {
          return MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: true,
            title: kAppName,
            theme: notifier.isDark ? darkTheme(context) : lightTheme(context),
            routes: routes,
            initialRoute: '/',
          );
        },
      ),
    );
  }
}
