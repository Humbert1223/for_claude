import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/app_bar_back_button.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';

class RolePermissionsPage extends StatefulWidget {
  final String roleId;

  const RolePermissionsPage({super.key, required this.roleId});

  @override
  State<RolePermissionsPage> createState() => _RolePermissionsPageState();
}

class _RolePermissionsPageState extends State<RolePermissionsPage> {
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  Map<String, dynamic>? _role;
  Map<String, List<dynamic>> _allPermissions = {};
  Set<String> _checkedPermissions = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.wait([
        _getRole(),
        _getPermissions(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de chargement: $e';
      });
      _showError(_errorMessage!);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getRole() async {
    try {
      final response = await MasterCrudModel.find('/auth/roles/${widget.roleId}');

      if (response != null) {
        setState(() {
          _role = Map<String, dynamic>.from(response);
          _checkedPermissions = Set<String>.from(response['permissions'] ?? []);
        });
      } else {
        throw Exception('Rôle non trouvé');
      }
    } catch (e) {
      debugPrint('Erreur _getRole: $e');
      rethrow;
    }
  }

  Future<void> _getPermissions() async {
    try {
      final response = await MasterCrudModel.find("/auth/permissions");

      if (response != null) {
        setState(() {
          _allPermissions = response.map(
                (key, value) => MapEntry(key, List<dynamic>.from(value)),
          );
        });
      } else {
        throw Exception('Format de réponse invalide');
      }
    } catch (e) {
      debugPrint('Erreur _getPermissions: $e');
      rethrow;
    }
  }

  Future<void> _saveRole() async {
    setState(() => _isSaving = true);

    try {
      final filteredPermissions = _checkedPermissions
          .where((perm) => perm.split(' ').length == 2)
          .toList();

      final response = await MasterCrudModel.patch(
        '/auth/roles/${widget.roleId}',
        {'name': _role?['name'], 'permissions': filteredPermissions},
      );

      if (response != null) {
        setState(() {
          _role = response;
          _checkedPermissions = Set<String>.from(response['permissions'] ?? []);
        });
        _showSuccess('Permissions enregistrées avec succès');
      } else {
        throw Exception('Échec de l\'enregistrement');
      }
    } catch (e) {
      _showError('Erreur d\'enregistrement: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _checkAllChange(bool? value, String entity) {
    setState(() {
      if (value == false) {
        _checkedPermissions.removeWhere(
              (perm) => perm.split(' ').length > 1 && perm.split(' ')[1] == entity,
        );
      } else {
        final entityPermissions = _allPermissions[entity] ?? [];
        for (var perm in entityPermissions) {
          _checkedPermissions.add(perm['name']);
        }
      }
    });
  }

  bool _isAllChecked(String entity) {
    final entityPermissions = _allPermissions[entity];
    if (entityPermissions == null || entityPermissions.isEmpty) return false;

    return entityPermissions.every(
          (perm) => _checkedPermissions.contains(perm['name']),
    );
  }

  bool _isIndeterminate(String entity) {
    final entityPermissions = _allPermissions[entity];
    if (entityPermissions == null || entityPermissions.isEmpty) return false;

    final isAll = _isAllChecked(entity);
    final hasSome = entityPermissions.any(
          (perm) => _checkedPermissions.contains(perm['name']),
    );

    return !isAll && hasSome;
  }

  String _translatePermission(String permName) {
    final parts = permName.split(' ');
    if (parts.isEmpty) return permName;
    return parts[0].toString().tr();
  }

  Map<String, List<dynamic>> _getFilteredPermissions() {
    if (_searchQuery.isEmpty) return _allPermissions;

    final filtered = <String, List<dynamic>>{};
    _allPermissions.forEach((entity, permissions) {
      if (entity.toLowerCase().contains(_searchQuery.toLowerCase())) {
        filtered[entity] = permissions;
      } else {
        final matchingPerms = permissions.where((perm) {
          final permName = perm['name'].toString().toLowerCase();
          return permName.contains(_searchQuery.toLowerCase());
        }).toList();

        if (matchingPerms.isNotEmpty) {
          filtered[entity] = matchingPerms;
        }
      }
    });

    return filtered;
  }

  int _getTotalSelectedCount() {
    return _checkedPermissions.where((perm) => perm.split(' ').length == 2).length;
  }

  int _getTotalPermissionsCount() {
    return _allPermissions.values.fold(0, (sum, list) => sum + list.length);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: _buildAppBar(theme, isDark),
      body: _isLoading
          ? _buildLoadingView(theme)
          : _errorMessage != null
          ? _buildErrorView(theme, isDark)
          : _allPermissions.isEmpty
          ? _buildEmptyView(theme, isDark)
          : _buildContent(theme, isDark),
      floatingActionButton: !_isLoading && _allPermissions.isNotEmpty
          ? _buildFab(theme)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, bool isDark) {
    return AppBar(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.85),
            ],
          ),
        ),
      ),
      leading: const AppBarBackButton(),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Permissions du rôle',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (_role != null)
                  Text(
                    _role!['name'] ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (!_isLoading && _allPermissions.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
            tooltip: 'Recharger',
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.15),
            ),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLoadingView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.2),
                  theme.colorScheme.primary.withValues(alpha: 0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: LoadingIndicator(
              color: theme.colorScheme.primary,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chargement des permissions...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.shade400,
                    Colors.red.shade600,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 64,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Une erreur est survenue',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Erreur inconnue',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'Réessayer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                    theme.colorScheme.primary.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 80,
                color: theme.colorScheme.primary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Aucune permission disponible',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Il n\'y a aucune permission à configurer pour ce rôle',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, bool isDark) {
    final filteredPermissions = _getFilteredPermissions();

    return Column(
      children: [
        _buildSearchHeader(theme, isDark, filteredPermissions),
        Expanded(
          child: filteredPermissions.isEmpty
              ? _buildNoResults(theme, isDark)
              : _buildPermissionsList(theme, isDark, filteredPermissions),
        ),
      ],
    );
  }

  Widget _buildSearchHeader(
      ThemeData theme,
      bool isDark,
      Map<String, List<dynamic>> filteredPermissions,
      ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barre de recherche
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: TextField(
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Rechercher une permission ou entité...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: theme.colorScheme.primary,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    setState(() => _searchQuery = '');
                  },
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          const SizedBox(height: 16),
          // Statistiques
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  theme,
                  isDark,
                  Icons.check_circle_rounded,
                  '${_getTotalSelectedCount()}',
                  'Sélectionnées',
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  theme,
                  isDark,
                  Icons.key_rounded,
                  '${_getTotalPermissionsCount()}',
                  'Total',
                  Colors.blue,
                ),
              ),
              if (_searchQuery.isNotEmpty) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    theme,
                    isDark,
                    Icons.search_rounded,
                    '${filteredPermissions.length}',
                    'Résultats',
                    Colors.orange,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      ThemeData theme,
      bool isDark,
      IconData icon,
      String value,
      String label,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade300,
                  Colors.grey.shade400,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucun résultat trouvé',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez avec d\'autres termes de recherche',
            style: TextStyle(
              fontSize: 15,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsList(
      ThemeData theme,
      bool isDark,
      Map<String, List<dynamic>> filteredPermissions,
      ) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredPermissions.length,
      itemBuilder: (context, index) {
        final entry = filteredPermissions.entries.elementAt(index);
        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 350 + (index * 50)),
          tween: Tween<double>(begin: 0, end: 1),
          curve: Curves.easeOutCubic,
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: _buildPermissionCard(theme, isDark, entry.key, entry.value),
        );
      },
    );
  }

  Widget _buildPermissionCard(
      ThemeData theme,
      bool isDark,
      String entity,
      List<dynamic> permissions,
      ) {
    final isChecked = _isAllChecked(entity);
    final isIndeterminate = _isIndeterminate(entity);
    final selectedCount = permissions.where(
          (p) => _checkedPermissions.contains(p['name']),
    ).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            const Color(0xFF1E1E1E),
            const Color(0xFF1A1A1A),
          ]
              : [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isChecked
              ? theme.colorScheme.primary
              : isIndeterminate
              ? theme.colorScheme.primary.withValues(alpha: 0.5)
              : isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.shade300,
          width: isChecked || isIndeterminate ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isChecked
                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _checkAllChange(!isChecked, entity),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: isChecked || isIndeterminate
                      ? LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.15),
                      theme.colorScheme.primary.withValues(alpha: 0.08),
                    ],
                  )
                      : null,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isChecked || isIndeterminate
                              ? [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withValues(alpha: 0.8),
                          ]
                              : [
                            Colors.grey.shade400,
                            Colors.grey.shade500,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: (isChecked || isIndeterminate
                                ? theme.colorScheme.primary
                                : Colors.grey)
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isChecked
                            ? Icons.check_circle_rounded
                            : isIndeterminate
                            ? Icons.remove_circle_rounded
                            : Icons.circle_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entity.tr().toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 0.5,
                              color: isChecked || isIndeterminate
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: (isChecked
                                      ? Colors.green
                                      : isIndeterminate
                                      ? Colors.orange
                                      : Colors.grey)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$selectedCount / ${permissions.length}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isChecked
                                        ? Colors.green.shade700
                                        : isIndeterminate
                                        ? Colors.orange.shade700
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.expand_more_rounded,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Divider(
            height: 1,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          // Liste des permissions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: permissions.map((permission) {
                final permName = permission['name'];
                final isSelected = _checkedPermissions.contains(permName);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.3)
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _checkedPermissions.remove(permName);
                          } else {
                            _checkedPermissions.add(permName);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.primary
                                        .withValues(alpha: 0.8),
                                  ],
                                )
                                    : null,
                                color: isSelected
                                    ? null
                                    : isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 14,
                              )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _translatePermission(permName),
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isSaving
              ? [
            Colors.grey.shade400,
            Colors.grey.shade500,
          ]
              : [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: (_isSaving
                ? Colors.grey
                : theme.colorScheme.primary)
                .withValues(alpha: 0.5),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _isSaving ? null : _saveRole,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSaving)
                  const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  const Icon(
                    Icons.save_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                const SizedBox(width: 12),
                Text(
                  _isSaving
                      ? 'Enregistrement...'
                      : 'Enregistrer les permissions',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}