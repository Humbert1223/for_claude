import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/app_bar_back_button.dart';
import 'package:novacole/controllers/auth_provider.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';

class UserSchoolSpacePage extends StatefulWidget {
  const UserSchoolSpacePage({super.key});

  @override
  UserSchoolSpacePageState createState() => UserSchoolSpacePageState();
}

class UserSchoolSpacePageState extends State<UserSchoolSpacePage>
    with SingleTickerProviderStateMixin {
  UserModel? user;
  List<Map<String, dynamic>> schools = [];
  bool isLoading = true;
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

    _loadData();
    _animationController.forward();
  }

  Future<void> _loadData() async {
    try {
      final loadedUser = await UserModel.fromLocalStorage();

      if (mounted) {
        setState(() {
          user = loadedUser;
        });
      }

      if (loadedUser?.schools != null) {
        final schoolIds = loadedUser!.schools!
            .map((e) => e['school_id'])
            .toList();
        final schoolsData = await MasterCrudModel('school').search(
          paginate: '0',
          filters: [
            {'field': 'id', 'operator': 'IN', 'value': schoolIds},
          ],
        );

        if (mounted && schoolsData != null) {
          setState(() {
            schools = List<Map<String, dynamic>>.from(schoolsData);
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? theme.colorScheme.surface : Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        leading: const AppBarBackButton(),
        title: const Text(
          'Espace & Établissement',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: schools.asMap().entries.map((entry) {
                    final index = entry.key;
                    final school = entry.value;
                    return TweenAnimationBuilder(
                      duration: Duration(milliseconds: 400 + (index * 100)),
                      tween: Tween<double>(begin: 0, end: 1),
                      curve: Curves.easeOutCubic,
                      builder: (context, double value, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildSchoolCard(school, theme, isDark),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }

  Widget _buildSchoolCard(
    Map<String, dynamic> school,
    ThemeData theme,
    bool isDark,
  ) {
    final schoolName = school['name'] ?? 'École sans nom';
    final schoolId = school['id'];
    final isCurrentSchool = schoolId == user?.school;

    // Récupérer les profils de l'utilisateur pour cette école
    final userProfiles = (user?.schools ?? [])
        .where((profile) => profile['school_id'] == schoolId)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrentSchool
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          width: isCurrentSchool ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrentSchool
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: isCurrentSchool ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de l'école
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: isCurrentSchool
                  ? LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                        theme.colorScheme.primary.withValues(alpha: 0.05),
                      ],
                    )
                  : null,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isCurrentSchool
                          ? [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withValues(alpha: 0.7),
                            ]
                          : [Colors.grey.shade500, Colors.grey.shade600],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (isCurrentSchool
                                    ? theme.colorScheme.primary
                                    : Colors.grey)
                                .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schoolName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${userProfiles.length} profil${userProfiles.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrentSchool)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Actif',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Liste des profils
          if (userProfiles.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...userProfiles.map((profile) {
                    return _buildProfileItem(profile, schoolId, theme, isDark);
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileItem(
    Map<String, dynamic> profile,
    String schoolId,
    ThemeData theme,
    bool isDark,
  ) {
    final accountType = profile['account_type'] ?? 'unknown';
    final isCurrentProfile =
        profile['account_type'] == user?.accountType &&
        profile['school_id'] == user?.school;

    // Déterminer l'icône et la couleur selon le type de compte
    IconData profileIcon;
    Color profileColor;

    switch (accountType.toLowerCase()) {
      case 'teacher':
        profileIcon = Icons.school_rounded;
        profileColor = Colors.blue;
        break;
      case 'student':
        profileIcon = Icons.person_rounded;
        profileColor = Colors.green;
        break;
      case 'parent':
        profileIcon = Icons.family_restroom_rounded;
        profileColor = Colors.orange;
        break;
      case 'admin':
        profileIcon = Icons.admin_panel_settings_rounded;
        profileColor = Colors.purple;
        break;
      case 'staff':
        profileIcon = Icons.badge_rounded;
        profileColor = Colors.teal;
        break;
      default:
        profileIcon = Icons.account_circle_rounded;
        profileColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCurrentProfile
            ? theme.colorScheme.primary.withValues(alpha: 0.08)
            : isDark
            ? Colors.grey.shade800.withValues(alpha: 0.3)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentProfile
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icône du profil
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: profileColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(profileIcon, size: 20, color: profileColor),
            ),
            const SizedBox(width: 12),

            // Nom du profil
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accountType,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ).tr(),
                  if (isCurrentProfile) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Profil actuel',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Bouton de suppression
            if (!isCurrentProfile)
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    Icons.logout_outlined,
                    color: Colors.red.shade400,
                    size: 20,
                  ),
                ),
                onPressed: () => _confirmDeleteProfile(profile, schoolId),
                tooltip: 'Supprimer ce profil',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              )
            else
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteProfile(
    Map<String, dynamic> profile,
    String schoolId,
  ) async {
    final theme = Theme.of(context);
    final accountType = profile['account_type'].toString().tr();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.warning_rounded,
                color: Colors.red.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Supprimer le profil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voulez-vous vraiment supprimer ce profil ?',
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Type: $accountType',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ).tr(),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Annuler',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Supprimer',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteProfile(profile, schoolId);
    }
  }

  Future<void> _deleteProfile(
    Map<String, dynamic> profile,
    String schoolId,
  ) async {
    final theme = Theme.of(context);

    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              const Text(
                'Suppression en cours...',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Appeler l'API pour supprimer le profil
      await MasterCrudModel.post(
        '/auth/school/user/detach/${user?.id}',
        data: {
          '_method': 'DELETE',
          'entry': profile['id'],
        },
      );
      await authProvider.refreshUser();
      // Recharger les données
      await _loadData();

      if (mounted) {
        Navigator.of(context).pop(); // Fermer le dialog de chargement

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Profil supprimé avec succès',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Fermer le dialog de chargement

        // Afficher un message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Erreur: ${e.toString()}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }
}
