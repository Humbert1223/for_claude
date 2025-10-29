import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:novacole/components/model_photo_widget.dart';
import 'package:novacole/components/my_button.dart';
import 'package:novacole/controllers/auth_controller.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/auth/about_app.dart';
import 'package:novacole/pages/auth/account_switch_page.dart';
import 'package:novacole/pages/auth/profile_submenu.dart';
import 'package:novacole/pages/auth/school_space_switch_page.dart';
import 'package:novacole/pages/auth/sync_page.dart';
import 'package:novacole/pages/auth/user_account_page.dart';
import 'package:novacole/pages/auth/user_preferences_page.dart';
import 'package:novacole/pages/auth/wallet/school_wallet.dart';
import 'package:novacole/theme/theme_model.dart';
import 'package:novacole/utils/api.dart';
import 'package:novacole/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:novacole/components/sub_menu_item.dart';

@immutable
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ProfilePageState();
  }
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? currentUser;
  List<Map<String, dynamic>> schools = [];
  final authController = Get.find<AuthController>();

  @override
  void initState() {
    UserModel.fromLocalStorage().then((value) {
      setState(() {
        currentUser = value;
      });
      MasterCrudModel('school')
          .search(
        paginate: '0',
        filters: [
          {
            'field': 'id',
            'operator': 'IN',
            'value':
            value?.schools?.map((e) => e['school_id']).toList() ?? [],
          },
        ],
      )
          .then((value) {
        setState(() {
          schools = List<Map<String, dynamic>>.from(value ?? []);
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> mappedUser = currentUser?.toMap() ?? {};
    mappedUser['photo_url'] = currentUser?.avatar;
    mappedUser['entity'] = 'user';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(context, mappedUser),
            const SizedBox(height: 20),
            _buildMenuOptions(context),
            const SizedBox(height: 20),
            _buildLogoutButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Widget d'en-tête du profil
  Widget _buildProfileHeader(BuildContext context, Map<String, dynamic> mappedUser) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            theme.colorScheme.primary.withValues(alpha: 0.15),
            theme.colorScheme.primary.withValues(alpha: 0.05),
          ]
              : [
            theme.colorScheme.primary.withValues(alpha: 0.08),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                // Photo de profil avec effet de cercle et bordure
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.2),
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(3),
                  child: ModelPhotoWidget(
                    model: mappedUser,
                    width: 90,
                    height: 90,
                    borderRadius: BorderRadius.circular(17),
                    onSave: (value) {
                      if (value != null) {
                        authController.refreshUser();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Informations utilisateur
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${currentUser?.name}",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleLarge?.color,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              currentUser?.email ?? '',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            currentUser?.phone ?? '',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (currentUser?.accountType != null &&
                          "${currentUser?.accountType}".isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6.0,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified_user,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "${currentUser?.accountType}",
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ).tr(),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Bouton de changement d'espace scolaire
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20.0),
                    ),
                  ),
                  context: context,
                  builder: (context) {
                    return const SchoolSpaceSwitch();
                  },
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Changer d\'espace scolaire',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_drop_down_circle_outlined,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construction des options du menu avec SubMenuWidget
  Widget _buildMenuOptions(BuildContext context) {
    return Column(
      children: [
        SubMenuWidget(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Portefeuille',
          subtitle: 'Abonnement novacole, crédit sms ...',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SchoolUserWallet(),
              ),
            );
          },
        ),
        SubMenuWidget(
          icon: Icons.account_circle_outlined,
          title: 'Compte',
          subtitle: 'Modifier, Supprimer, Valider',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UserAccountPage(user: currentUser),
              ),
            );
          },
        ),
        SubMenuWidget(
          icon: Icons.person_outline,
          title: 'Profils',
          subtitle: 'Enseignant, Tuteur/Parent, Élève',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const UserActorProfilesSubmenu();
                },
              ),
            );
          },
        ),
        SubMenuWidget(
          icon: Icons.settings,
          title: 'Préférences',
          subtitle: 'Ecole, Année scolaire, Canaux de notification',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const UserPreferencesPage(),
              ),
            );
          },
        ),
        SubMenuWidget(
          icon: Icons.color_lens_outlined,
          title: 'Thème',
          subtitle: 'Changer le thème de l\'application (Noir, Clair)',
          onTap: () {
            _changeTheme();
          },
        ),
        SubMenuWidget(
          icon: FontAwesomeIcons.repeat,
          title: 'Changer de compte',
          subtitle: 'Passer à un autre compte',
          onTap: () {
            showModalBottomSheet(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(0.0),
                ),
              ),
              context: context,
              builder: (context) {
                return AccountSwitchPage();
              },
            );
          },
        ),
        if ([
          'admin',
          'teacher',
          'staff',
        ].contains(currentUser?.accountType))
          SubMenuWidget(
            icon: Icons.cloud_sync_outlined,
            title: 'Synchronisation',
            subtitle: 'Élèves, Évaluations, Notes, Classes, Quiz',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return SynchronisationPage();
                  },
                ),
              );
            },
          ),
        SubMenuWidget(
          icon: FontAwesomeIcons.share,
          title: 'Partager',
          subtitle: 'Partager l\'application avec les amis',
          onTap: () async {
            String text = "$kAppDescription \n \nTélechargez"
                " l'application sur: \n$kAppUrl";
            ShareParams params = ShareParams(
              text: text,
              subject: kAppName,
              sharePositionOrigin: Rect.fromLTWH(
                0,
                0,
                MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height,
              ),
            );
            await SharePlus.instance.share(params);
          },
        ),
        SubMenuWidget(
          icon: FontAwesomeIcons.circleQuestion,
          title: 'A propos',
          subtitle: 'Confidentialité, Termes & conditions d\'utilisation',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AboutAppPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Widget du bouton de déconnexion
  Widget _buildLogoutButton() {
    return MyOutlinedButton(
      buttonText: 'Se déconnecter',
      colorType: ButtonColorType.danger,
      onTap: () {
        _logout();
      },
    );
  }

  Future<void> _changeTheme() async {
    SharedPreferences local = await Http().local();
    String? theme = local.getString(LocalStorageKeys.theme);
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (BuildContext context, ThemeModel notifier, Widget? child) {
            return SimpleDialog(
              title: const Text(
                "Choisissez un thème",
                style: TextStyle(fontSize: 16),
              ),
              children: [
                ListTile(
                  tileColor: Colors.transparent,
                  onTap: () {
                    notifier.isDark = false;
                    local.setString(LocalStorageKeys.theme, 'bright');
                    Navigator.pop(context);
                  },
                  title: const Text("Clair"),
                  trailing: (theme == 'bright')
                      ? Icon(
                    Icons.check_circle,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  )
                      : Icon(
                    Icons.circle_outlined,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                ListTile(
                  tileColor: Colors.transparent,
                  onTap: () {
                    notifier.isDark = true;
                    local.setString(LocalStorageKeys.theme, 'dark');
                    Navigator.pop(context);
                  },
                  title: const Text("Sombre"),
                  trailing: (theme == 'dark')
                      ? Icon(
                    Icons.check_circle,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  )
                      : Icon(
                    Icons.circle_outlined,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                ListTile(
                  tileColor: Colors.transparent,
                  onTap: () {
                    final isDarkMode =
                        MediaQuery.of(context).platformBrightness ==
                            Brightness.dark;
                    notifier.isDark = isDarkMode;
                    local.setString(LocalStorageKeys.theme, 'system');

                    Navigator.pop(context);
                  },
                  title: const Text("Système"),
                  trailing:
                  (theme == null || theme == 'system' || theme.isEmpty)
                      ? Icon(
                    Icons.check_circle,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  )
                      : Icon(
                    Icons.circle_outlined,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: Icon(
            FontAwesomeIcons.arrowRightFromBracket,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
          title: const Text(
            'Voulez-vous vous déconnecter ?',
            style: TextStyle(fontSize: 20),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await authController.logout().then(
                      (value) {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/', (route) => false);
                  },
                );
              },
              child: const Text(
                'Oui',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Non',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}