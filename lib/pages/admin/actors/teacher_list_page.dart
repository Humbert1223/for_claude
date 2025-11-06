import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/admin/actors/actor_info_widget.dart';
import 'package:novacole/pages/admin/actors/teacher_details.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/permission_utils.dart';

class TeacherListPage extends StatefulWidget {
  const TeacherListPage({super.key});

  @override
  TeacherListPageState createState() {
    return TeacherListPageState();
  }
}

class TeacherListPageState extends State<TeacherListPage> {
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
        itemBuilder: (teacher) {
          return TeacherInfoWidget(teacher: teacher);
        },
        dataModel: 'teacher',
        paginate: PaginationValue.paginated,
        title: 'Enseignants',
        canDelete: (data) => false,
        query: {'order_by': 'last_name'},
        data: {
          'filters': [
            {'field': 'school_ids', 'operator': '=', 'value': user?.school},
          ],
        },
        onItemTap: (teacher, updateLine) {
          if(user!.hasPermissionSafe(PermissionName.view(Entity.teacher))){
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return TeacherDetails(teacher: teacher);
                },
              ),
            );
          }
        },
      ),
    );
  }
}
