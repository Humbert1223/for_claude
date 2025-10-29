import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novacole/controllers/auth_controller.dart';


class PermissionName{
  static String viewAny(String entity){
    return 'viewany $entity';
  }
  static String create(String entity){
    return 'create $entity';
  }
  static String update(String entity){
    return 'update $entity';
  }
  static String view(String entity){
    return 'view $entity';
  }
  static String delete(String entity){
    return 'delete $entity';
  }
  static String forceDelete(String entity){
    return 'forcedelete $entity';
  }
  static String restore(String entity){
    return 'restore $entity';
  }
  static String start(String entity){
    return 'start $entity';
  }
  static String close(String entity){
    return 'close $entity';
  }

  static String open(String entity) {
    return 'open $entity';
  }

  static String accept(String entity) {
    return 'accept $entity';
  }

  static String reject(String entity) {
    return 'reject $entity';
  }

  static String approve(String entity) {
    return 'approve $entity';
  }
}

/// Classe utilitaire pour les permissions
class PermissionUtils {
  static AuthController get _authController => Get.find<AuthController>();

  /// Vérifier si l'utilisateur peut effectuer une action
  static bool canPerformAction(String action) {
    return _authController.hasPermission(action);
  }

  /// Exécuter une action si la permission est accordée
  static void executeIfAllowed(String permission, VoidCallback action) {
    if (_authController.hasPermission(permission)) {
      action();
    } else {
      _showNoPermissionDialog();
    }
  }

  /// Exécuter une action avec callback de fallback
  static void executeWithFallback(
      String permission,
      VoidCallback onAllowed,
      VoidCallback onDenied,
      ) {
    if (_authController.hasPermission(permission)) {
      onAllowed();
    } else {
      onDenied();
    }
  }

  /// Afficher un dialogue de permission refusée
  static void _showNoPermissionDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Permission requise'),
          ],
        ),
        content: Text(
          'Vous n\'avez pas la permission d\'effectuer cette action.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  /// Obtenir une liste de permissions formatée
  static String getFormattedPermissions() {
    final perms = _authController.permissions;
    if (perms.isEmpty) {
      return 'Aucune permission';
    }
    return perms.map((p) => '• $p').join('\n');
  }

  /// Vérifier si l'utilisateur est admin
  static bool isAdmin() {
    return _authController.currentUser.value?.accountType == 'admin';
  }

  /// Filtrer une liste d'actions selon les permissions
  static List<T> filterByPermission<T>(
      List<T> items,
      String Function(T) getPermission,
      ) {
    return items.where((item) {
      final permission = getPermission(item);
      return _authController.hasPermission(permission);
    }).toList();
  }
}

/// Décorateur de fonction avec vérification de permission
class PermissionRequired {
  final String permission;
  final Function onDenied;

  const PermissionRequired(this.permission, {required this.onDenied});

  void execute(Function action) {
    if (Get.find<AuthController>().hasPermission(permission)) {
      action();
    } else {
      onDenied();
    }
  }
}

/// Builder pour créer des menus avec permissions
class PermissionMenuBuilder {
  final List<MenuItemConfig> items = [];

  void addItem(MenuItemConfig config) {
    items.add(config);
  }

  List<Widget> build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return items.where((item) {
      if (item.permission == null) return true;
      return authController.hasPermission(item.permission!);
    }).map((item) {
      return ListTile(
        leading: item.icon != null ? Icon(item.icon) : null,
        title: Text(item.title),
        subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
        trailing: item.trailing,
        onTap: item.onTap,
      );
    }).toList();
  }
}

class MenuItemConfig {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final String? permission;
  final VoidCallback? onTap;

  MenuItemConfig({
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.permission,
    this.onTap,
  });
}

/// Classe pour gérer les actions en masse avec permissions
class BulkActionManager {
  final AuthController _authController = Get.find<AuthController>();

  final List<BulkAction> _actions = [];

  void addAction(BulkAction action) {
    _actions.add(action);
  }

  List<BulkAction> getAvailableActions() {
    return _actions.where((action) {
      return _authController.hasPermission(action.requiredPermission);
    }).toList();
  }

  void executeAction(String actionId, List<dynamic> selectedItems) {
    final action = _actions.firstWhereOrNull((a) => a.id == actionId);
    if (action != null && _authController.hasPermission(action.requiredPermission)) {
      action.execute(selectedItems);
    }
  }
}

class BulkAction {
  final String id;
  final String label;
  final IconData icon;
  final String requiredPermission;
  final Function(List<dynamic>) execute;

  BulkAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.requiredPermission,
    required this.execute,
  });
}

/// Widget pour afficher un badge de permission
class PermissionBadge extends StatelessWidget {
  final String permission;
  final Widget child;

  const PermissionBadge({
    super.key,
    required this.permission,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Obx(() {
      final hasPermission = authController.hasPermission(permission);

      return Badge(
        label: Icon(
          hasPermission ? Icons.check : Icons.lock,
          size: 12,
          color: Colors.white,
        ),
        backgroundColor: hasPermission ? Colors.green : Colors.red,
        child: child,
      );
    });
  }
}

/// Helper pour logger les tentatives d'accès
class PermissionLogger {
  static void logAccess(String resource, bool granted) {
    final authController = Get.find<AuthController>();
    final userId = authController.userId;
    final timestamp = DateTime.now().toIso8601String();

    print('[PERMISSION] $timestamp - User: $userId - Resource: $resource - Granted: $granted');

    // Vous pouvez étendre ceci pour envoyer les logs à un serveur
  }

  static void logAttempt(String action, String permission) {
    final authController = Get.find<AuthController>();
    final hasPermission = authController.hasPermission(permission);

    logAccess('$action (requires: $permission)', hasPermission);

    if (!hasPermission) {
      _notifyUnauthorizedAttempt(action, permission);
    }
  }

  static void _notifyUnauthorizedAttempt(String action, String permission) {
    // Envoyer une notification à l'admin ou logger dans un système externe
    print('[SECURITY] Unauthorized attempt: $action - Permission: $permission');
  }
}

/// Gestionnaire de cache pour les permissions
class PermissionCache {
  static final Map<String, bool> _cache = {};
  static final Map<String, DateTime> _cacheExpiry = {};
  static const Duration _cacheDuration = Duration(minutes: 5);

  static bool? getCachedPermission(String permission) {
    final expiry = _cacheExpiry[permission];
    if (expiry != null && DateTime.now().isBefore(expiry)) {
      return _cache[permission];
    }
    // Cache expiré
    _cache.remove(permission);
    _cacheExpiry.remove(permission);
    return null;
  }

  static void cachePermission(String permission, bool hasPermission) {
    _cache[permission] = hasPermission;
    _cacheExpiry[permission] = DateTime.now().add(_cacheDuration);
  }

  static void clearCache() {
    _cache.clear();
    _cacheExpiry.clear();
  }

  static void clearExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = _cacheExpiry.entries
        .where((entry) => now.isAfter(entry.value))
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _cache.remove(key);
      _cacheExpiry.remove(key);
    }
  }
}

/// Énumération des niveaux de permission
enum PermissionLevel {
  none,
  view,
  edit,
  create,
  delete,
  manage,
  admin;

  bool canPerform(PermissionLevel requiredLevel) {
    return index >= requiredLevel.index;
  }
}

/// Gestionnaire de hiérarchie de permissions
class PermissionHierarchy {
  static final Map<String, List<String>> _hierarchy = {
    'manage_users': ['view_users', 'create_users', 'edit_users', 'delete_users'],
    'super_admin': ['manage_users', 'manage_schools', 'manage_settings'],
  };

  /// Obtenir toutes les permissions implicites
  static List<String> getImpliedPermissions(List<String> userPermissions) {
    final allPermissions = <String>{};

    for (final permission in userPermissions) {
      allPermissions.add(permission);

      // Ajouter les permissions implicites
      final implied = _hierarchy[permission];
      if (implied != null) {
        allPermissions.addAll(implied);
        // Récursif pour les sous-permissions
        allPermissions.addAll(getImpliedPermissions(implied));
      }
    }

    return allPermissions.toList();
  }

  /// Définir une hiérarchie personnalisée
  static void setHierarchy(String parentPermission, List<String> childPermissions) {
    _hierarchy[parentPermission] = childPermissions;
  }
}

/// Widget pour afficher les permissions de l'utilisateur (debug)
class PermissionDebugWidget extends StatelessWidget {
  const PermissionDebugWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Obx(() {
      final permissions = authController.permissions;

      return Card(
        child: ExpansionTile(
          leading: Icon(Icons.security, color: Colors.blue),
          title: Text('Permissions (${permissions.length})'),
          children: [
            if (permissions.isEmpty)
              Padding(
                padding: EdgeInsets.all(16),
                child: Text('Aucune permission'),
              )
            else
              ...permissions.map((permission) {
                return ListTile(
                  dense: true,
                  leading: Icon(Icons.check_circle, color: Colors.green, size: 16),
                  title: Text(
                    permission,
                    style: TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
          ],
        ),
      );
    });
  }
}

/// Widget pour un sélecteur de permissions
class PermissionSelector extends StatefulWidget {
  final List<String> availablePermissions;
  final List<String> selectedPermissions;
  final Function(List<String>) onChanged;
  final String? requiredPermissionToEdit;

  const PermissionSelector({
    super.key,
    required this.availablePermissions,
    required this.selectedPermissions,
    required this.onChanged,
    this.requiredPermissionToEdit,
  });

  @override
  State<PermissionSelector> createState() => _PermissionSelectorState();
}

class _PermissionSelectorState extends State<PermissionSelector> {
  late List<String> _selected;
  bool _canEdit = true;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedPermissions);

    if (widget.requiredPermissionToEdit != null) {
      final authController = Get.find<AuthController>();
      _canEdit = authController.hasPermission(widget.requiredPermissionToEdit!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.security),
                SizedBox(width: 8),
                Text(
                  'Permissions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!_canEdit)
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Chip(
                      label: Text('Lecture seule'),
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
              ],
            ),
          ),
          Divider(),
          ...widget.availablePermissions.map((permission) {
            final isSelected = _selected.contains(permission);

            return CheckboxListTile(
              value: isSelected,
              enabled: _canEdit,
              title: Text(permission),
              subtitle: Text(_getPermissionDescription(permission)),
              onChanged: _canEdit ? (value) {
                setState(() {
                  if (value == true) {
                    _selected.add(permission);
                  } else {
                    _selected.remove(permission);
                  }
                  widget.onChanged(_selected);
                });
              } : null,
            );
          }).toList(),
        ],
      ),
    );
  }

  String _getPermissionDescription(String permission) {
    // Mapper les permissions à des descriptions lisibles
    final descriptions = {
      'view_users': 'Voir la liste des utilisateurs',
      'create_users': 'Créer de nouveaux utilisateurs',
      'edit_users': 'Modifier les utilisateurs existants',
      'delete_users': 'Supprimer des utilisateurs',
      'manage_users': 'Gérer tous les aspects des utilisateurs',
      'view_students': 'Voir la liste des étudiants',
      'create_students': 'Ajouter de nouveaux étudiants',
      'edit_students': 'Modifier les informations des étudiants',
      'delete_students': 'Supprimer des étudiants',
      'view_teachers': 'Voir la liste des enseignants',
      'create_teachers': 'Ajouter de nouveaux enseignants',
      'edit_teachers': 'Modifier les informations des enseignants',
      'delete_teachers': 'Supprimer des enseignants',
      'view_settings': 'Voir les paramètres',
      'edit_settings': 'Modifier les paramètres',
      'access_admin': 'Accéder au panneau d\'administration',
      'manage_permissions': 'Gérer les permissions des utilisateurs',
      'manage_roles': 'Gérer les rôles',
    };

    return descriptions[permission] ?? 'Permission: $permission';
  }
}

/// Helper pour créer des groupes de permissions
class PermissionGroup {
  final String name;
  final String description;
  final List<String> permissions;
  final IconData icon;

  PermissionGroup({
    required this.name,
    required this.description,
    required this.permissions,
    this.icon = Icons.security,
  });

  static List<PermissionGroup> getDefaultGroups() {
    return [
      PermissionGroup(
        name: 'Utilisateurs',
        description: 'Gestion des utilisateurs',
        icon: Icons.people,
        permissions: [
          'view_users',
          'create_users',
          'edit_users',
          'delete_users',
          'manage_users',
        ],
      ),
      PermissionGroup(
        name: 'Étudiants',
        description: 'Gestion des étudiants',
        icon: Icons.school,
        permissions: [
          'view_students',
          'create_students',
          'edit_students',
          'delete_students',
        ],
      ),
      PermissionGroup(
        name: 'Enseignants',
        description: 'Gestion des enseignants',
        icon: Icons.person_outline,
        permissions: [
          'view_teachers',
          'create_teachers',
          'edit_teachers',
          'delete_teachers',
        ],
      ),
      PermissionGroup(
        name: 'Administration',
        description: 'Fonctionnalités d\'administration',
        icon: Icons.admin_panel_settings,
        permissions: [
          'access_admin',
          'manage_permissions',
          'manage_roles',
          'view_settings',
          'edit_settings',
        ],
      ),
    ];
  }
}

/// Widget pour afficher les groupes de permissions
class PermissionGroupWidget extends StatelessWidget {
  final PermissionGroup group;
  final List<String> userPermissions;

  const PermissionGroupWidget({
    super.key,
    required this.group,
    required this.userPermissions,
  });

  @override
  Widget build(BuildContext context) {
    final grantedCount = group.permissions
        .where((p) => userPermissions.contains(p))
        .length;
    final totalCount = group.permissions.length;
    final progress = totalCount > 0 ? grantedCount / totalCount : 0.0;

    return Card(
      margin: EdgeInsets.all(8),
      child: ExpansionTile(
        leading: Icon(group.icon),
        title: Text(group.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(group.description),
            SizedBox(height: 4),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: progress == 1.0 ? Colors.green : Colors.orange,
            ),
            SizedBox(height: 4),
            Text(
              '$grantedCount sur $totalCount permissions',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        children: group.permissions.map((permission) {
          final hasPermission = userPermissions.contains(permission);

          return ListTile(
            dense: true,
            leading: Icon(
              hasPermission ? Icons.check_circle : Icons.cancel,
              color: hasPermission ? Colors.green : Colors.red,
              size: 20,
            ),
            title: Text(permission),
          );
        }).toList(),
      ),
    );
  }
}

/// Extension pour faciliter les vérifications multiples
extension PermissionListExtension on List<String> {
  bool containsAny(List<String> permissions) {
    return permissions.any((p) => contains(p));
  }

  bool containsAll(List<String> permissions) {
    return permissions.every((p) => contains(p));
  }

  List<String> filterByPermissions(List<String> requiredPermissions) {
    return where((item) => requiredPermissions.contains(item)).toList();
  }
}