import 'package:flutter/material.dart';
import 'package:novacole/core/constants/design_system.dart';

/// Widget de carte réutilisable avec un style cohérent
///
/// Utilisé pour encapsuler du contenu dans un conteneur stylisé
/// avec support d'interaction optionnelle.
class AppCard extends StatelessWidget {
  /// Contenu de la carte
  final Widget child;

  /// Padding interne (défaut: AppSpacing.md)
  final EdgeInsets? padding;

  /// Callback au tap (rend la carte interactive si non-null)
  final VoidCallback? onTap;

  /// Callback au long press
  final VoidCallback? onLongPress;

  /// Couleur de fond personnalisée
  final Color? backgroundColor;

  /// Élévation (ombre)
  final double? elevation;

  /// Rayon des bordures
  final double? borderRadius;

  /// Couleur de la bordure
  final Color? borderColor;

  /// Largeur de la bordure
  final double? borderWidth;

  /// Marge externe
  final EdgeInsets? margin;

  /// Afficher un indicateur de chargement
  final bool isLoading;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.margin,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final effectiveRadius = borderRadius ?? AppRadius.lg;
    final effectivePadding = padding ?? EdgeInsets.all(AppSpacing.md);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.surface,
        borderRadius: BorderRadius.circular(effectiveRadius),
        border: Border.all(
          color: borderColor ??
              (isDark
                  ? colors.outline.withValues(alpha: 0.2)
                  : colors.outline.withValues(alpha: 0.15)),
          width: borderWidth ?? 1,
        ),
        boxShadow: elevation != null && elevation! > 0
            ? [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.05),
            blurRadius: elevation!,
            offset: Offset(0, elevation! / 2),
          ),
        ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          onLongPress: isLoading ? null : onLongPress,
          borderRadius: BorderRadius.circular(effectiveRadius),
          child: Stack(
            children: [
              Padding(
                padding: effectivePadding,
                child: AnimatedOpacity(
                  opacity: isLoading ? 0.5 : 1.0,
                  duration: AppDuration.fast,
                  child: child,
                ),
              ),
              if (isLoading)
                Positioned.fill(
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Variante de carte avec un en-tête
class AppCardWithHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final EdgeInsets? margin;

  const AppCardWithHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      backgroundColor: backgroundColor,
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.primaryContainer,
                  colors.secondaryContainer,
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                topRight: Radius.circular(AppRadius.lg),
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: colors.onPrimaryContainer,
                    size: AppIconSize.md,
                  ),
                  SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onPrimaryContainer.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          // Contenu
          Padding(
            padding: padding ?? EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ],
      ),
    );
  }
}