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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text("Permissions: ${role['permission_count']}")],
              ),
            ],
          );
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
