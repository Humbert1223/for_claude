import 'package:flutter/material.dart';
import 'package:novacole/controllers/auth_provider.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/auth/school_space_switch_page.dart';
import 'package:novacole/pages/components/home/home_page_admin_menu.dart';
import 'package:novacole/pages/components/home/home_page_teacher_menu.dart';
import 'package:novacole/pages/components/home/home_page_tutor_menu.dart';

class HomePageMenu extends StatefulWidget {
  const HomePageMenu({super.key});

  @override
  HomePageMenuState createState() => HomePageMenuState();
}

class HomePageMenuState extends State<HomePageMenu> {
  UserModel? user;
  List? users;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final value = await UserModel.fromLocalStorage();
    if (mounted) {
      setState(() {
        user = value;
        users = authProvider.savedAccounts.toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // État vide - pas d'accès
    if (users != null && users!.isEmpty) {
      return _buildEmptyState(theme, isDark);
    }

    // Afficher le menu selon le type d'utilisateur
    if (user != null &&
        (user!.isAccountType('admin') || user!.isAccountType('staff'))) {
      return const HomePageAdminMenu();
    } else if (user != null && user!.isAccountType('teacher')) {
      return const HomePageTeacherMenu();
    } else if (user != null && user!.accountType == 'tutor') {
      return const HomePageTutorMenu();
    } else {
      return _buildSpaceSelection(theme);
    }
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.amber.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.shade100,
                    Colors.amber.shade50,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 64,
                color: Colors.amber.shade700,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Aucun accès disponible",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Vous n'avez pas encore d'accès dans un établissement.",
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Rapprochez-vous de votre établissement scolaire pour être ajouté aux utilisateurs.",
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpaceSelection(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if ((user?.schools ?? []).isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  "Sélectionner un espace",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
        const Expanded(child: SchoolSpaceSwitch()),
      ],
    );
  }
}