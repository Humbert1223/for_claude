import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:novacole/pages/auth/user_teacher_profile.dart';
import 'package:novacole/pages/auth/user_tutor_profile.dart';

class UserActorProfilesSubmenu extends StatefulWidget {
  const UserActorProfilesSubmenu({super.key});

  @override
  UserActorProfilesSubmenuState createState() {
    return UserActorProfilesSubmenuState();
  }
}

class UserActorProfilesSubmenuState extends State<UserActorProfilesSubmenu> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false,
            );
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Mes profils',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return const UserTeacherProfile();
                    }));
                  },
                  leading: const Icon(FontAwesomeIcons.chalkboardUser),
                  title: const Text(
                    "Enseignant",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    'Informations liées aux enseignants',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    size: 16,
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return const UserTutorProfile();
                    }));
                  },
                  leading: const Icon(FontAwesomeIcons.handsHoldingChild),
                  title: const Text(
                    'Parents / Tuteurs',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    'Informations liées aux parents et aux tuteurs',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    size: 16,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
