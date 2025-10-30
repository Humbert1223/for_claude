import 'package:flutter/material.dart';
import '../constants/design_system.dart';

/// En-tête de section réutilisable
///
/// Affiche un titre avec optionnellement une icône, un sous-titre,
/// et un bouton d'action.
class SectionHeader extends StatelessWidget {
  /// Titre de la section
  final String title;

  /// Sous-titre optionnel
  final String? subtitle;

  /// Icône optionnelle à gauche du titre
  final IconData? icon;

  /// Callback pour le bouton d'action
  final VoidCallback? onActionTap;

  /// Texte du bouton d'action
  final String? actionLabel;

  /// Icône du bouton d'action
  final IconData? actionIcon;

  /// Padding personnalisé
  final EdgeInsets? padding;

  /// Style de titre personnalisé
  final TextStyle? titleStyle;

  /// Afficher un diviseur en dessous
  final bool showDivider;

  const SectionHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onActionTap,
    this.actionLabel,
    this.actionIcon,
    this.padding,
    this.titleStyle,
    this.showDivider = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: padding ??
              EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    icon,
                    color: colors.primary,
                    size: AppIconSize.md,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: titleStyle ??
                          theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onActionTap != null)
                TextButton.icon(
                  onPressed: onActionTap,
                  icon: Icon(
                    actionIcon ?? Icons.arrow_forward_ios,
                    size: 14,
                  ),
                  label: Text(actionLabel ?? 'Voir plus'),
                  style: TextButton.styleFrom(
                    foregroundColor: colors.primary,
                  ),
                ),
            ],
          ),
        ),
        if (showDivider) ...[
          SizedBox(height: AppSpacing.sm),
          Divider(
            height: 1,
            color: colors.outline.withValues(alpha: 0.2),
          ),
        ],
      ],
    );
  }
}

/// En-tête de section avec accent vertical
class SectionHeaderWithAccent extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onActionTap;
  final String? actionLabel;
  final Color? accentColor;

  const SectionHeaderWithAccent({
    Key? key,
    required this.title,
    this.subtitle,
    this.onActionTap,
    this.actionLabel,
    this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: accentColor ?? colors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
          if (onActionTap != null)
            TextButton(
              onPressed: onActionTap,
              child: Text(actionLabel ?? 'Voir plus'),
            ),
        ],
      ),
    );
  }
}