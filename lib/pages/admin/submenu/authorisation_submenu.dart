import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:novacole/components/app_bar_back_button.dart';
import 'package:novacole/components/permission_widgets.dart';
import 'package:novacole/components/sub_menu_item.dart';
import 'package:novacole/pages/admin/auth/role_data_page.dart';
import 'package:novacole/pages/admin/auth/user_data_page.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/permission_utils.dart';

class AuthorisationSubmenuPage extends StatefulWidget {
  const AuthorisationSubmenuPage({super.key});

  @override
  AuthorisationSubmenuPageState createState() {
    return AuthorisationSubmenuPageState();
  }
}

class AuthorisationSubmenuPageState extends State<AuthorisationSubmenuPage> {
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
        leading: AppBarBackButton(),
        title: const Text(
          'Autorisations',
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
              DisableIfNoPermission(
                permission: PermissionName.viewAny(Entity.user),
                child: SubMenuWidget(
                  icon: FontAwesomeIcons.users,
                  title: 'Utilisateurs',
                  subtitle: 'Création, gestion des droits & permissions ...',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const UserDataPage()),
                    );
                  },
                ),
              ),
              DisableIfNoPermission(
                permission: PermissionName.viewAny(Entity.role),
                child: SubMenuWidget(
                  icon: Icons.security_outlined,
                  title: 'Rôles',
                  subtitle: 'Création, permissions, ...',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const RoleDataPage()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}