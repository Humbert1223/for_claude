import 'package:flutter/material.dart';
import 'package:novacole/components/app_bar_back_button.dart';
import 'package:novacole/components/sub_menu_item.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/auth/account/account_deletion_page.dart';
import 'package:novacole/pages/auth/account/account_info_page.dart';
import 'package:novacole/pages/auth/account/update_email.dart';
import 'package:novacole/pages/auth/account/update_password.dart';
import 'package:novacole/pages/auth/account/update_phone.dart';
import 'package:novacole/pages/auth/user_teacher_profile.dart';
import 'package:novacole/pages/auth/user_tutor_profile.dart';

class UserAccountPage extends StatefulWidget {
  final UserModel? user;

  const UserAccountPage({super.key, this.user});

  @override
  State<StatefulWidget> createState() {
    return UserAccountPageState();
  }
}

class UserAccountPageState extends State<UserAccountPage> {
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
        title: const Text("Compte"),
        centerTitle: true,
        leading: AppBarBackButton(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SubMenuWidget(
              title: "Information de compte",
              subtitle: "Afficher et modifier les informations de mon compte",
              icon:  Icons.person,
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return const UserAccountInfo();
                }));
              },
            ),
            SubMenuWidget(
              title: "Profil Enseignant",
              subtitle: "Modifier les informations de mon profil enseignant",
              icon:  Icons.person,
              onTap: (){
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const UserTeacherProfile();
                }));
              },
            ),
            SubMenuWidget(
              title: "Profil Parent",
              subtitle: "Modifier les informations de mon profil parent",
              icon:  Icons.person,
              onTap: (){
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const UserTutorProfile();
                }));
              },
            ),
            SubMenuWidget(
              title: "Adresse email",
              icon: Icons.email_outlined,
              subtitle: 'Modifier et valider mon adresse email',
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return const UpdateEmailPage();
                }));
              },
            ),
            SubMenuWidget(
              title: "Téléphone",
              icon: Icons.phone,
              subtitle: 'Modifier et valider mon numéro de téléphone',
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return const UpdatePhonePage();
                }));
              },
            ),
            SubMenuWidget(
              title: "Modifier le mot de passe",
              icon: Icons.password,
              subtitle: 'Modifier mon mot de passe',
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return const UpdatePasswordPage();
                }));
              },
            ),
            SubMenuWidget(
              title: "Suppression de compte",
              icon: Icons.delete_forever,
              iconColor: Colors.red,
              subtitle: 'Suppression de mon compte',
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return const DeleteAccountPage();
                }));
              },
            ),
          ],
        )
      ),
    );
  }
}
