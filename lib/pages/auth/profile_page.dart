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
import 'package:novacole/components/sub_menu_item.dart';

@immutable
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  UserModel? currentUser;
  List<Map<String, dynamic>> schools = [];
  final authController = Get.find<AuthController>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _loadUserData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final value = await UserModel.fromLocalStorage();
    if (mounted) {
      setState(() => currentUser = value);
    }

    if (value?.schools != null) {
      final schoolIds = value!.schools!.map((e) => e['school_id']).toList();
      final schoolsData = await MasterCrudModel('school').search(
        paginate: '0',
        filters: [
          {'field': 'id', 'operator': 'IN', 'value': schoolIds},
        ],
      );

      if (mounted && schoolsData != null) {
        setState(() {
          schools = List<Map<String, dynamic>>.from(schoolsData);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Map<String, dynamic> mappedUser = currentUser?.toMap() ?? {};
    mappedUser['photo_url'] = currentUser?.avatar;
    mappedUser['entity'] = 'user';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
            theme.colorScheme.surface,
            theme.colorScheme.surface,
          ]
              : [
            theme.colorScheme.primary.withValues(alpha: 0.02),
            Colors.grey.shade50,
          ],
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 8),
                _buildProfileHeader(context, mappedUser, theme, isDark),
                const SizedBox(height: 24),
                _buildQuickStats(theme, isDark),
                const SizedBox(height: 24),
                _buildMenuOptions(context),
                const SizedBox(height: 24),
                _buildLogoutButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget d'en-tête du profil modernisé
  Widget _buildProfileHeader(
      BuildContext context,
      Map<String, dynamic> mappedUser,
      ThemeData theme,
      bool isDark,
      ) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Bannière de profil avec gradient
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Stack(
                children: [
                  // Motif décoratif
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -20,
                    bottom: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contenu du profil
            Transform.translate(
              offset: const Offset(0, -50),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Photo de profil avec bordure
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? theme.colorScheme.surface
                              : Colors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ModelPhotoWidget(
                        model: mappedUser,
                        width: 100,
                        height: 100,
                        borderRadius: BorderRadius.circular(20),
                        onSave: (value) {
                          if (value != null) {
                            authController.refreshUser();
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Nom
                    Text(
                      currentUser?.name ?? '',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    // Badge du rôle
                    if (currentUser?.accountType != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_user_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${currentUser?.accountType}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ).tr(),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Informations de contact
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.email_outlined,
                            currentUser?.email ?? '',
                            theme,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.phone_outlined,
                            currentUser?.phone ?? '',
                            theme,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Bouton de changement d'espace
                    _buildSpaceSwitchButton(theme, isDark),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 16,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSpaceSwitchButton(ThemeData theme, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            context: context,
            builder: (context) => const SchoolSpaceSwitch(),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.15),
                theme.colorScheme.primary.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.swap_horiz_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Text(
                'Changer d\'espace scolaire',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(ThemeData theme, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.school_rounded,
            label: 'Écoles',
            value: '${schools.length}',
            color: Colors.blue,
            theme: theme,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.account_circle_rounded,
            label: 'Profils',
            value: '${currentUser?.schools?.length ?? 0}',
            color: Colors.purple,
            theme: theme,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Construction des options du menu avec animations
  Widget _buildMenuOptions(BuildContext context) {
    final menuItems = [
      (
      icon: Icons.account_balance_wallet_outlined,
      title: 'Portefeuille',
      subtitle: 'Abonnement novacole, crédit sms ...',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SchoolUserWallet()),
      ),
      ),
      (
      icon: Icons.account_circle_outlined,
      title: 'Compte',
      subtitle: 'Modifier, Supprimer, Valider',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserAccountPage(user: currentUser),
        ),
      ),
      ),
      (
      icon: Icons.person_outline,
      title: 'Profils',
      subtitle: 'Enseignant, Tuteur/Parent, Élève',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const UserActorProfilesSubmenu(),
        ),
      ),
      ),
      (
      icon: Icons.settings,
      title: 'Préférences',
      subtitle: 'Ecole, Année scolaire, Canaux de notification',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const UserPreferencesPage(),
        ),
      ),
      ),
      (
      icon: Icons.color_lens_outlined,
      title: 'Thème',
      subtitle: 'Changer le thème de l\'application',
      onTap: () => _changeTheme(),
      ),
      (
      icon: FontAwesomeIcons.repeat,
      title: 'Changer de compte',
      subtitle: 'Passer à un autre compte',
      onTap: () => showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        context: context,
        builder: (context) => AccountSwitchPage(),
      ),
      ),
      if (['admin', 'teacher', 'staff'].contains(currentUser?.accountType))
        (
        icon: Icons.cloud_sync_outlined,
        title: 'Synchronisation',
        subtitle: 'Élèves, Évaluations, Notes, Classes, Quiz',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SynchronisationPage()),
        ),
        ),
      (
      icon: FontAwesomeIcons.share,
      title: 'Partager',
      subtitle: 'Partager l\'application avec les amis',
      onTap: () async {
        String text = "$kAppDescription \n \nTélechargez"
            " l'application sur: \n$kAppUrl";
        await SharePlus.instance.share(ShareParams(
          text: text,
          subject: kAppName,
          sharePositionOrigin: Rect.fromLTWH(
            0,
            0,
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height,
          ),
        ));
      },
      ),
      (
      icon: FontAwesomeIcons.circleQuestion,
      title: 'A propos',
      subtitle: 'Confidentialité, Termes & conditions',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AboutAppPage()),
      ),
      ),
    ];

    return Column(
      children: menuItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 400 + (index * 80)),
          tween: Tween<double>(begin: 0, end: 1),
          curve: Curves.easeOutCubic,
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: SubMenuWidget(
            icon: item.icon,
            title: item.title,
            subtitle: item.subtitle,
            onTap: item.onTap,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLogoutButton() {
    return MyOutlinedButton(
      buttonText: 'Se déconnecter',
      icon: Icons.logout_rounded,
      colorType: ButtonColorType.danger,
      onTap: _logout,
    );
  }

  Future<void> _changeTheme() async {
    final local = await Http().local();
    final theme = local.getString(LocalStorageKeys.theme);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ThemeModel notifier, child) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.palette_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text("Choisissez un thème", style: TextStyle(fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildThemeOption(
                    context: context,
                    title: 'Clair',
                    icon: Icons.light_mode_rounded,
                    isSelected: theme == 'bright',
                    onTap: () {
                      notifier.isDark = false;
                      local.setString(LocalStorageKeys.theme, 'bright');
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildThemeOption(
                    context: context,
                    title: 'Sombre',
                    icon: Icons.dark_mode_rounded,
                    isSelected: theme == 'dark',
                    onTap: () {
                      notifier.isDark = true;
                      local.setString(LocalStorageKeys.theme, 'dark');
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildThemeOption(
                    context: context,
                    title: 'Système',
                    icon: Icons.phone_android_rounded,
                    isSelected: theme == null || theme == 'system' || theme.isEmpty,
                    onTap: () {
                      final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
                      notifier.isDark = isDarkMode;
                      local.setString(LocalStorageKeys.theme, 'system');
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Déconnexion',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: const Text(
            'Voulez-vous vraiment vous déconnecter ?',
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await authController.logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Déconnecter',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}