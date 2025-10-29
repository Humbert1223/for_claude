import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novacole/controllers/auth_controller.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/auth/school_space_switch_page.dart';
import 'package:novacole/pages/components/home/home_page_admin_menu.dart';
import 'package:novacole/pages/components/home/home_page_teacher_menu.dart';
import 'package:novacole/pages/components/home/home_page_tutor_menu.dart';

class HomePageMenu extends StatefulWidget {
  const HomePageMenu({super.key});

  @override
  HomePageMenuState createState() {
    return HomePageMenuState();
  }
}

class HomePageMenuState extends State<HomePageMenu> {
  UserModel? user;
  List? users;
  final authController = Get.find<AuthController>();
  @override
  void initState() {
    UserModel.fromLocalStorage().then((value) {
      setState(() {
        user = value;
      });
    });
    setState(() {
      users = authController.savedAccounts.toList();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (users != null && users!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 64,
              color: Colors.amber,
            ),
            Text(
              "Vous n'avez pas encore un accès dans un établissement !",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            Text(
              "Rapprochez-vous de votre établissement scolaire pour vous faire ajouté.e aux utilisateurs.",
              textAlign: TextAlign.center,
            )
          ],
        ),
      );
    }
    if (user != null &&
        (user!.isAccountType('admin') == true ||
            user!.isAccountType('staff') == true)) {
      return const HomePageAdminMenu();
    } else if (user != null && user!.isAccountType('teacher') == true) {
      return const HomePageTeacherMenu();
    } else if (user != null && user!.accountType == 'tutor') {
      return const HomePageTutorMenu();
    } else {
      return Column(
        children: [
          if ((user?.schools ?? []).isNotEmpty)
            const Text(
              "Sélectionner un accès",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SchoolSpaceSwitch()
        ],
      );
    }
  }
}
