import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/admin/auth/role_permissions_page.dart';

class RoleDataPage extends StatefulWidget {
  const RoleDataPage({super.key});

  @override
  RoleDataPageState createState() {
    return RoleDataPageState();
  }
}

class RoleDataPageState extends State<RoleDataPage> {
  UserModel? user;

  @override
  void initState() {
    UserModel.fromLocalStorage().then((value) {
      setState(() {
        user = value;
      });
    });
    super.initState();
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
        itemBuilder: (role) {
          return ModernRoleItemWidget(roleData: role);
        },
        dataModel: 'role',
        paginate: PaginationValue.none,
        title: 'Rôles',
        data: {
          'filters': [
            {'field': 'school_id', 'operator': '=', 'value': user?.school},
          ],
        },
        onItemTap: (item, updateLine){
          Navigator.of(context).push(MaterialPageRoute(builder: (context){
            return RolePermissionsPage(roleId: item['id']);
          }));
        },
      ),
    );
  }
}
class ModernRoleItemWidget extends StatelessWidget {
  final Map<String, dynamic> roleData;

  const ModernRoleItemWidget({
    super.key,
    required this.roleData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final name = roleData['name']?.toString() ?? 'Sans nom';
    final permissionCount = roleData['permission_count'] ?? 0;

    return Row(
      children: [
        // Icône avec gradient
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.shield_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),

        // Informations du rôle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nom du rôle
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: -0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Nombre de permissions avec badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.key_rounded,
                      size: 14,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$permissionCount',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      permissionCount <= 1 ? 'permission' : 'permissions',
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
              ),
            ],
          ),
        ),
      ],
    );
  }
}