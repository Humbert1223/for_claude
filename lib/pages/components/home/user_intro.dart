import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novacole/controllers/auth_controller.dart';
import 'package:novacole/models/user_model.dart';

class UserIntro extends StatelessWidget {
  final VoidCallback? onTap;

  const UserIntro({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Récupérer le controller une seule fois
    final authController = Get.find<AuthController>();

    return Obx(() {
      final currentUser = authController.currentUser.value;
      final currentSchool = authController.currentSchool;
      final currentAcademic = authController.currentAcademic;

      // Vérification améliorée
      if (!authController.isLoggedIn || currentUser.id == null) {
        return const SizedBox.shrink();
      }

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: colorScheme.primary.withValues(alpha: 0.1),
          highlightColor: colorScheme.primary.withValues(alpha: 0.05),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                  colorScheme.primaryContainer.withValues(alpha: 0.5),
                  colorScheme.primaryContainer.withValues(alpha: 0.3),
                ]
                    : [
                  colorScheme.primary.withValues(alpha: 0.08),
                  colorScheme.primary.withValues(alpha: 0.04),
                ],
              ),
              border: Border.all(
                color: isDark
                    ? colorScheme.outline.withValues(alpha: 0.3)
                    : colorScheme.primary.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Avatar avec badge en ligne
                _buildAvatar(
                  currentUser,
                  colorScheme,
                  isDark,
                ),

                const SizedBox(width: 14),

                // Informations utilisateur
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nom de l'utilisateur
                      Text(
                        currentUser.name ?? 'Utilisateur',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // École (réactif aux changements de currentSchool)
                      if (currentSchool.isNotEmpty &&
                          currentSchool['name'] != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: _buildInfoRow(
                            icon: Icons.school_rounded,
                            text: currentSchool['name'].toString(),
                            iconColor: colorScheme.primary,
                            textColor:
                            colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),

                      // Année académique (réactif aux changements de currentAcademic)
                      if (currentAcademic.isNotEmpty &&
                          currentAcademic['name'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: _buildInfoRow(
                            icon: Icons.calendar_today_rounded,
                            text: currentAcademic['name'].toString(),
                            iconColor:
                            colorScheme.onSurface.withValues(alpha: 0.5),
                            textColor:
                            colorScheme.onSurface.withValues(alpha: 0.5),
                            fontSize: 12,
                            iconSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),

                // Chevron indicateur
                if (onTap != null)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// Widget pour afficher une ligne d'information (école, année)
  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required Color iconColor,
    required Color textColor,
    double fontSize = 13,
    double iconSize = 14,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(
      UserModel user,
      ColorScheme colorScheme,
      bool isDark,
      ) {
    // Utiliser une clé unique pour forcer le rechargement si l'avatar change
    final imageProvider = user.avatar == null || user.avatar!.isEmpty
        ? const AssetImage('assets/images/person.jpeg') as ImageProvider
        : CachedNetworkImageProvider(
      user.avatar!,
      // Clé pour forcer le rechargement si l'URL change
      cacheKey: user.avatar,
    );

    return Hero(
      tag: 'user_avatar_${user.id}', // Tag unique avec l'ID
      child: Stack(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? colorScheme.surface : Colors.white,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image(
                    image: imageProvider,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person_rounded,
                          size: 32,
                          color: colorScheme.primary,
                        ),
                      );
                    },
                    // Placeholder pendant le chargement
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded) return child;
                      return AnimatedOpacity(
                        opacity: frame == null ? 0.3 : 1,
                        duration: const Duration(milliseconds: 300),
                        child: frame == null
                            ? Container(
                          color: colorScheme.primaryContainer,
                          child: Icon(
                            Icons.person_rounded,
                            size: 32,
                            color: colorScheme.primary,
                          ),
                        )
                            : child,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Badge de statut en ligne (réactif au statut de connexion)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              height: 14,
              width: 14,
              decoration: BoxDecoration(
                color: const Color(0xff4caf50), // Vert pour "en ligne"
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? colorScheme.surface : Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Variante compacte pour les petits espaces
class UserIntroCompact extends StatelessWidget {
  final VoidCallback? onTap;

  const UserIntroCompact({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      final currentUser = authController.currentUser.value;

      // Vérification améliorée
      if (!authController.isLoggedIn || currentUser.id == null) {
        return const SizedBox.shrink();
      }

      final imageProvider = currentUser.avatar == null ||
          currentUser.avatar!.isEmpty
          ? const AssetImage('assets/images/person.jpeg') as ImageProvider
          : CachedNetworkImageProvider(
        currentUser.avatar!,
        cacheKey: currentUser.avatar,
      );

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'user_avatar_compact_${currentUser.id}',
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image(
                        image: imageProvider,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: colorScheme.primaryContainer,
                            child: Icon(
                              Icons.person_rounded,
                              size: 24,
                              color: colorScheme.primary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentUser.name ?? 'Utilisateur',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Voir le profil',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

/// Widget avec skeleton loader pendant le chargement
class UserIntroWithLoading extends StatelessWidget {
  final VoidCallback? onTap;

  const UserIntroWithLoading({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      // Afficher un skeleton pendant le chargement
      if (authController.isLoading.value &&
          !authController.isLoggedIn) {
        return _buildSkeleton(colorScheme, isDark);
      }

      // Afficher le widget normal une fois chargé
      return UserIntro(onTap: onTap);
    });
  }

  Widget _buildSkeleton(ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Row(
        children: [
          // Avatar skeleton
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ligne de texte 1
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 8),
                // Ligne de texte 2
                Container(
                  height: 12,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}