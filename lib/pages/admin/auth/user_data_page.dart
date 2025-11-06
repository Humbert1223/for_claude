import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/components/model_photo_widget.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/utils/constants.dart';

class UserDataPage extends StatefulWidget {
  const UserDataPage({super.key});

  @override
  UserDataPageState createState() {
    return UserDataPageState();
  }
}

class UserDataPageState extends State<UserDataPage> {
  UserModel? user;
  List<Map<String, dynamic>> availableRoles = [];
  bool isLoadingRoles = true;

  @override
  void initState() {
    UserModel.fromLocalStorage().then((value) {
      setState(() {
        user = value;
      });
    });
    _loadRoles();
    super.initState();
  }

  Future<void> _loadRoles() async {
    try {
      final result = await MasterCrudModel(Entity.role).search(paginate: '0');
      setState(() {
        availableRoles = List<Map<String, dynamic>>.from(result ?? []);
        isLoadingRoles = false;
      });
    } catch (e) {
      setState(() {
        isLoadingRoles = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: user != null,
      replacement: Container(),
      child: DefaultDataGrid(
        itemBuilder: (usr) {
          String? type = List.from(usr['schools'] ?? [])
              .where((sc) {
                return user?.school != null && sc['school_id'] == user?.school;
              })
              .map((sc) {
                return sc['account_type'].toString().tr();
              })
              .toList()
              .join(', ');
          return ModernUserItemWidget(userData: usr, accountType: type);
        },
        dataModel: 'user',
        paginate: PaginationValue.paginated,
        title: 'Utilisateurs',
        canEdit: (value) => false,
        canDelete: (value) => false,
        optionsBuilder: (userData, loadData, updateLine) {
          return [
            RoleAssignmentButton(
              userData: userData,
              availableRoles: availableRoles,
              isLoadingRoles: isLoadingRoles,
              onRolesUpdated: (user) {
                updateLine(user);
              },
              updateLine: updateLine,
            ),
          ];
        },
        formInputsMutator: (inputs, datum) {
          if (datum != null) {
            inputs = inputs.map((e) {
              if (e['field'] == 'account_type') {
                if (!['admin', 'staff'].contains(datum['account_type'])) {
                  e['hidden'] = true;
                }
              }
              if (['password', 'email'].contains(e['field'])) {
                e['hidden'] = true;
              }
              return e;
            }).toList();
          }
          return inputs;
        },
        data: {
          'filters': [
            {
              'field': 'schools.school_id',
              'operator': '=',
              'value': user?.school,
            },
          ],
        },
      ),
    );
  }
}

class RoleAssignmentButton extends StatelessWidget {
  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> availableRoles;
  final bool isLoadingRoles;
  final Function onRolesUpdated;
  final Function(Map<String, dynamic>) updateLine;

  const RoleAssignmentButton({
    super.key,
    required this.userData,
    required this.availableRoles,
    required this.isLoadingRoles,
    required this.onRolesUpdated,
    required this.updateLine,
  });

  @override
  Widget build(BuildContext context) {
    return OptionItem(
      onTap: () {
        Navigator.pop(context);
        if (isLoadingRoles) {
          return;
        }
        _showRoleDialog(context);
      },
      icon: Icons.shield_outlined,
      iconColor: Colors.purple,
      title: 'Assigner les rôles',
    );
  }

  void _showRoleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RoleAssignmentDialog(
        userData: userData,
        availableRoles: availableRoles,
        onRolesUpdated: (updatedRoleIds) async {
          try {
            final user = await MasterCrudModel.patch('/auth/user/roles', {
              'user_id': userData['id'],
              'roles': updatedRoleIds,
            });
            onRolesUpdated(user);
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erreur lors de la mise à jour: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }
}

class RoleAssignmentDialog extends StatefulWidget {
  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> availableRoles;
  final Function(List<String>) onRolesUpdated;

  const RoleAssignmentDialog({
    super.key,
    required this.userData,
    required this.availableRoles,
    required this.onRolesUpdated,
  });

  @override
  State<RoleAssignmentDialog> createState() => _RoleAssignmentDialogState();
}

class _RoleAssignmentDialogState extends State<RoleAssignmentDialog> {
  late Set<String> selectedRoleIds;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    selectedRoleIds = Set<String>.from(widget.userData['role_ids'] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userName = widget.userData['name'] ?? 'Utilisateur';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gérer les rôles',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.7)
                              : Colors.black.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Liste des rôles
            Expanded(
              child: widget.availableRoles.isEmpty
                  ? Center(
                      child: Text(
                        'Aucun rôle disponible',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.5)
                              : Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.availableRoles.length,
                      itemBuilder: (context, index) {
                        final role = widget.availableRoles[index];
                        final roleId = role['id'] as String;
                        final roleName = role['name'] ?? 'Rôle sans nom';
                        final isSelected = selectedRoleIds.contains(roleId);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedRoleIds.remove(roleId);
                                  } else {
                                    selectedRoleIds.add(roleId);
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.colorScheme.primary.withValues(
                                          alpha: 0.1,
                                        )
                                      : isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade100,
                                  border: Border.all(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected
                                              ? theme.colorScheme.primary
                                              : isDark
                                              ? Colors.grey.shade600
                                              : Colors.grey.shade400,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            roleName,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 24),

            // Boutons d'action
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setState(() {
                            isSaving = true;
                          });

                          await widget.onRolesUpdated(selectedRoleIds.toList());

                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Rôles mis à jour avec succès'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Enregistrer',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ModernUserItemWidget extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String? accountType;

  const ModernUserItemWidget({
    super.key,
    required this.userData,
    this.accountType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isActive = userData['active'] == true;
    final name = userData['name']?.toString() ?? 'Sans nom';
    final email = userData['email']?.toString() ?? 'Aucun email';

    return Row(
      children: [
        // Avatar avec gradient
        _buildAvatar(theme, userData, isActive, name),
        const SizedBox(width: 16),

        // Informations utilisateur
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nom avec badge de statut
              _buildNameWithStatus(theme, isDark, name, isActive),
              const SizedBox(height: 8),

              // Email avec icône
              _buildInfoRow(
                theme,
                isDark,
                Icons.email_rounded,
                email,
                theme.colorScheme.primary,
              ),
              const SizedBox(height: 6),

              // Type avec icône
              if (accountType != null && accountType!.isNotEmpty)
                _buildInfoRow(
                  theme,
                  isDark,
                  Icons.badge_rounded,
                  accountType!,
                  Colors.purple,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(
    ThemeData theme,
    Map<String, dynamic>? user,
    bool isActive,
    String name,
  ) {
    return Visibility(
      visible: user != null && user['photo'] != null,
      replacement: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isActive
                ? [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.7),
                  ]
                : [Colors.grey.shade400, Colors.grey.shade500],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isActive ? theme.colorScheme.primary : Colors.grey)
                  .withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            name
                .split(' ')
                .map((part) => part.substring(0, 1))
                .toList()
                .take(2)
                .join()
                .toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      child: ModelPhotoWidget(
        model: user!,
        editable: false,
        width: 56,
        height: 56,
        photoKey: 'avatar',
      ),
    );
  }

  Widget _buildNameWithStatus(
    ThemeData theme,
    bool isDark,
    String name,
    bool isActive,
  ) {
    return Row(
      children: [
        Flexible(
          child: Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: -0.3,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        _buildStatusBadge(isActive),
      ],
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.orange.shade400, Colors.orange.shade600],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: (isActive ? Colors.green : Colors.orange).withValues(
              alpha: 0.3,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.pending,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Actif' : 'Inactif',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    bool isDark,
    IconData icon,
    String text,
    Color iconColor,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
