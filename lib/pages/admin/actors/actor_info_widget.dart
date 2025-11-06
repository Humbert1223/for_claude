import 'package:flutter/material.dart';
import 'package:novacole/components/model_photo_widget.dart';
import 'package:novacole/controllers/auth_provider.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/permission_utils.dart';


class StudentInfoWidget extends StatelessWidget {
  final Map<String, dynamic> student;
  const StudentInfoWidget({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Photo avec bordure moderne
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.2),
                theme.colorScheme.primary.withValues(alpha: 0.05),
              ],
            ),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(3),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: ModelPhotoWidget(
              model: student,
              width: 60,
              height: 60,
              editIconSize: 9,
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Informations
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nom
              Text(
                "${student['full_name']}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // Matricule avec icône
              _buildInfoRow(
                icon: Icons.badge_outlined,
                text: student['matricule'],
                theme: theme,
              ),
              const SizedBox(height: 8),
              // Âge et Niveau avec tags
              Row(
                children: [
                  // Tag Âge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withValues(alpha: 0.15),
                          Colors.blue.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cake_outlined,
                          size: 13,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${student['age']} ans',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Tag Niveau
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.withValues(alpha: 0.15),
                            Colors.purple.withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.purple.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 13,
                            color: Colors.purple.shade700,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              student['level']?['name'] ?? '-',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.purple.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class TeacherInfoWidget extends StatelessWidget {
  final Map<String, dynamic> teacher;

  const TeacherInfoWidget({super.key, required this.teacher});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Photo avec badge "Enseignant"
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.orange.withValues(alpha: 0.2),
                    Colors.orange.withValues(alpha: 0.05),
                  ],
                ),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(3),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: ModelPhotoWidget(
                  model: teacher,
                  width: 60,
                  height: 60,
                  editIconSize: 9.0,
                  editable: authProvider.currentUser.hasPermissionSafe(
                    PermissionName.update(Entity.teacher),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        // Informations
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nom
              Text(
                "${teacher['full_name']}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // Matricule avec icône
              _buildInfoRow(
                icon: Icons.badge_outlined,
                text: teacher['matricule'] ?? '-',
                theme: theme,
              ),
              const SizedBox(height: 4),
              // Téléphone avec icône et design moderne
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withValues(alpha: 0.12),
                      Colors.green.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 13,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        teacher['phone'] ?? '-',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class TutorInfoWidget extends StatelessWidget {
  final Map<String, dynamic> tutor;
  const TutorInfoWidget({super.key, required this.tutor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Photo avec badge "Tuteur"
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.teal.withValues(alpha: 0.2),
                    Colors.teal.withValues(alpha: 0.05),
                  ],
                ),
                border: Border.all(
                  color: Colors.teal.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(3),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: ModelPhotoWidget(
                  model: tutor,
                  width: 60,
                  height: 60,
                  editIconSize: 9.0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        // Informations
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nom
              Text(
                "${tutor['full_name']}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // Téléphone avec design moderne
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withValues(alpha: 0.12),
                      Colors.green.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 13,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        tutor['phone'] ?? '-',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              // Adresse avec icône
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      tutor['address'] ?? '-',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}