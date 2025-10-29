import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
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
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Permissions du rôle'),
            if (_role != null)
              Text(
                _role!['name'] ?? '',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        elevation: 0,
        actions: [
          if (!_isLoading && _allPermissions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
              tooltip: 'Recharger',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorView()
          : _allPermissions.isEmpty
          ? _buildEmptyView()
          : _buildContent(),
      bottomNavigationBar: !_isLoading && _allPermissions.isNotEmpty
          ? _buildBottomBar()
          : null,
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Une erreur est survenue',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Erreur inconnue',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucune permission disponible',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Il n\'y a aucune permission à configurer pour ce rôle',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final filteredPermissions = _getFilteredPermissions();

    return Column(
      children: [
        // Barre de recherche et statistiques
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher une permission ou entité...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() => _searchQuery = '');
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_getTotalSelectedCount()} / ${_getTotalPermissionsCount()} permissions sélectionnées',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    Text(
                      '${filteredPermissions.length} résultat(s)',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        // Liste des permissions
        Expanded(
          child: filteredPermissions.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Aucun résultat trouvé',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Essayez avec d\'autres termes de recherche',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredPermissions.length,
            itemBuilder: (context, index) {
              final entry = filteredPermissions.entries.elementAt(index);
              return _buildPermissionCard(entry.key, entry.value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveRole,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: _isSaving
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : const Icon(Icons.save),
            label: Text(
              _isSaving ? 'Enregistrement...' : 'Enregistrer les permissions',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard(String entity, List<dynamic> permissions) {
    final isChecked = _isAllChecked(entity);
    final isIndeterminate = _isIndeterminate(entity);
    final selectedCount = permissions.where(
          (p) => _checkedPermissions.contains(p['name']),
    ).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isChecked
              ? Theme.of(context).primaryColor
              : isIndeterminate
              ? Theme.of(context).primaryColor.withValues(alpha: 0.5)
              : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // En-tête de la carte
          InkWell(
            onTap: () => _checkAllChange(!isChecked, entity),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: isChecked
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                    : Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    tristate: true,
                    onChanged: (value) => _checkAllChange(value, entity),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entity.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$selectedCount / ${permissions.length} sélectionnée(s)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isChecked
                        ? Icons.check_circle
                        : isIndeterminate
                        ? Icons.indeterminate_check_box
                        : Icons.circle_outlined,
                    color: isChecked || isIndeterminate
                        ? Theme.of(context).primaryColor
                        : Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // Liste des permissions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              children: permissions.map((permission) {
                final permName = permission['name'];
                final isSelected = _checkedPermissions.contains(permName);

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CheckboxListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    controlAffinity: ListTileControlAffinity.leading,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    title: Text(
                      _translatePermission(permName),
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        color: isSelected ? Theme.of(context).primaryColor : null,
                      ),
                    ),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _checkedPermissions.add(permName);
                        } else {
                          _checkedPermissions.remove(permName);
                        }
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}