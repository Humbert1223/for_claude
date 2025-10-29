import 'package:flutter/material.dart';

/// Modèle de données pour un élément de menu
class SubMenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const SubMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}

/// Widget de sous-menu moderne et réutilisable - Compatible dark mode
class SubMenuWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? backgroundColor;

  const SubMenuWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Couleurs adaptatives selon le thème
    final effectiveIconColor = iconColor ?? colorScheme.primary;
    final effectiveBackgroundColor = backgroundColor ??
        (isDark ? colorScheme.primaryContainer : colorScheme.surface);

    // Couleurs de texte adaptatives
    final titleColor = isDark
        ? colorScheme.onSurface
        : colorScheme.onSurface;

    final subtitleColor = isDark
        ? colorScheme.onSurface.withValues(alpha:0.7)
        : colorScheme.onSurface.withValues(alpha:0.6);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        elevation: 0,
        shadowColor: colorScheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark
                ? colorScheme.outline.withValues(alpha:0.2)
                : colorScheme.outline.withValues(alpha:0.15),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: effectiveIconColor.withValues(alpha:0.1),
          highlightColor: effectiveIconColor.withValues(alpha:0.05),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isDark ? null : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  effectiveBackgroundColor,
                  effectiveBackgroundColor.withValues(alpha:0.95),
                ],
              ),
              color: isDark ? effectiveBackgroundColor : null,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: effectiveIconColor.withValues(alpha:isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: effectiveIconColor.withValues(alpha:isDark ? 0.3 : 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: 24,
                ),
              ),
              title: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: titleColor,
                  letterSpacing: 0.2,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: subtitleColor,
                    height: 1.3,
                  ),
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: effectiveIconColor.withValues(alpha:isDark ? 0.15 : 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: effectiveIconColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Exemple d'utilisation avec différents thèmes
class SubMenuExample extends StatelessWidget {
  const SubMenuExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sous-Menu'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SubMenuWidget(
            icon: Icons.school_rounded,
            title: 'Gestion des cours',
            subtitle: 'Créer, modifier et gérer vos cours',
            onTap: () {
              // Navigation vers la page de gestion des cours
            },
          ),
          SubMenuWidget(
            icon: Icons.group_rounded,
            title: 'Gestion des élèves',
            subtitle: 'Consulter et gérer les informations des élèves',
            onTap: () {
              // Navigation vers la page de gestion des élèves
            },
          ),
          SubMenuWidget(
            icon: Icons.calendar_month_rounded,
            title: 'Emploi du temps',
            subtitle: 'Visualiser et organiser les horaires',
            onTap: () {
              // Navigation vers l'emploi du temps
            },
          ),
          SubMenuWidget(
            icon: Icons.assignment_rounded,
            title: 'Notes et évaluations',
            subtitle: 'Saisir et consulter les résultats',
            onTap: () {
              // Navigation vers les notes
            },
          ),
          SubMenuWidget(
            icon: Icons.notifications_rounded,
            title: 'Notifications',
            subtitle: 'Gérer vos alertes et communications',
            onTap: () {
              // Navigation vers les notifications
            },
            iconColor: Colors.orange,
          ),
          SubMenuWidget(
            icon: Icons.settings_rounded,
            title: 'Paramètres',
            subtitle: 'Configurer votre application',
            onTap: () {
              // Navigation vers les paramètres
            },
            iconColor: Colors.blueGrey,
          ),
        ],
      ),
    );
  }
}