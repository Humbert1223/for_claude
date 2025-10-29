import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/controllers/auth_controller.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/auth/account_switch_page.dart';
import 'package:novacole/pages/auth/login_page.dart';
import 'package:novacole/pages/home_page.dart';
import 'package:novacole/services/mark_sync_service.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/sync_manager.dart';
import 'package:splash_view/source/presentation/presentation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  UserModel? user;
  List<UserModel> users = [];
  final authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    if (authController.isAuthenticated()) {
      authController.refreshUser();
      authController.getCurrentFcmToken().then((token) async {
        if(token == null){
          await authController.updateFcmToken();
        }
      });
    }
    UserModel.fromLocalStorage().then((value){
      setState(() {
        user = value;
      });
    });
    users = authController.savedAccounts.toList();

    // Listen to connectivity changes to trigger sync when online again
    Connectivity().onConnectivityChanged.listen((result) async {
      if (!result.contains(ConnectivityResult.none)) {
        await MarkSyncService.syncAllNotesToApi();
      }
    });

    Future.delayed(Duration(seconds: 2), () async {
      await SyncManager.triggerSyncAllForMarks();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = (user != null && user?.token != null && user?.token != '')
        ? const HomeScreen()
        : (users.isNotEmpty
            ? const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Sélectionner un compte",
                        style: TextStyle(fontSize: 25),
                      ),
                      SizedBox(height: 20),
                      AccountSwitchPage(),
                    ],
                  ),
                ),
              )
            : const LoginPage());
    return SplashView(
      logo: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage("assets/images/logo_3.png"),
            ),
            borderRadius: BorderRadius.circular(20)
          ),
        ),
      ),
      done: Done(
        widget,
        animationDuration: const Duration(microseconds: 100),
      ),
      loadingIndicator: const LoadingIndicator(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Text(
          kAppName,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      showStatusBar: true,
      duration: const Duration(seconds: 1),
    );
  }
}
