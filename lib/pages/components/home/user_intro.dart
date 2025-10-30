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

    return FutureBuilder<UserModel?>(
      future: UserModel.fromLocalStorage(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final currentUser = snapshot.data;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: colorScheme.primary.withValues(alpha:0.1),
            highlightColor: colorScheme.primary.withValues(alpha:0.05),
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                    colorScheme.primaryContainer.withValues(alpha:0.5),
                    colorScheme.primaryContainer.withValues(alpha:0.3),
                  ]
                      : [
                    colorScheme.primary.withValues(alpha:0.08),
                    colorScheme.primary.withValues(alpha:0.04),
                  ],
                ),
                border: Border.all(
                  color: isDark
                      ? colorScheme.outline.withValues(alpha:0.3)
                      : colorScheme.primary.withValues(alpha:0.15),
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
                          currentUser?.name ?? '',
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

                        // École
                        Obx((){

                          final authController = Get.find<AuthController>();
                          if (authController.currentSchool.value == null ||
                              authController.currentSchool.value?['name'] == null) {
                            return const SizedBox.shrink();
                          }

                          return Row(
                            children: [
                              Icon(
                                Icons.school_rounded,
                                size: 14,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  authController.currentSchool.value!['name'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurface.withValues(alpha:0.7),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        }),

                        const SizedBox(height: 2),

                        // Année académique
                        Obx((){

                          final authController = Get.find<AuthController>();
                          if (authController.currentAcademic.value == null ||
                              authController.currentAcademic.value?['name'] == null) {
                            return const SizedBox.shrink();
                          }

                          return Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 12,
                                color: colorScheme.onSurface.withValues(alpha:0.5),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  authController.currentAcademic.value!['name'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurface.withValues(alpha:0.5),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        })
                      ],
                    ),
                  ),

                  // Chevron indicateur
                  if (onTap != null)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha:0.1),
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
      },
    );
  }

  Widget _buildAvatar(
      UserModel? user,
      ColorScheme colorScheme,
      bool isDark,
      ) {
    final imageProvider = user?.avatar == null
        ? const AssetImage('assets/images/person.jpeg') as ImageProvider
        : CachedNetworkImageProvider(user!.avatar!);

    return Hero(
      tag: 'user_avatar',
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
                  colorScheme.primary.withValues(alpha:0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha:0.3),
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
                    color: isDark
                        ? colorScheme.surface
                        : Colors.white,
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
                  ),
                ),
              ),
            ),
          ),

          // Badge de statut en ligne (optionnel)
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FutureBuilder<UserModel?>(
      future: UserModel.fromLocalStorage(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final currentUser = snapshot.data;
        final imageProvider = currentUser?.avatar == null
            ? const AssetImage('assets/images/person.jpeg') as ImageProvider
            : CachedNetworkImageProvider(currentUser!.avatar!);

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
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha:0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentUser?.name ?? '',
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}