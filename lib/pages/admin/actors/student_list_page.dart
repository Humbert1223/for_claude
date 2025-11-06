import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/admin/actors/actor_info_widget.dart';
import 'package:novacole/pages/student_details.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/permission_utils.dart';

class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key});

  @override
  StudentListPageState createState() {
    return StudentListPageState();
  }
}

class StudentListPageState extends State<StudentListPage> {
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
        itemBuilder: (student) {
          return StudentInfoWidget(student: student);
        },
        dataModel: 'student',
        paginate: PaginationValue.paginated,
        title: 'Élèves',
        canDelete: (data) => false,
        query: {'order_by': 'last_name'},
        data: {
          'filters': [
            {
              'field': 'current_school_id',
              'operator': '=',
              'value': user?.school,
            },
          ],
          'relations': ['level'],
        },
        onItemTap: (student, updateLine) {
          if (user!.hasPermissionSafe(PermissionName.view(Entity.student))) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return StudentDetails(student: student);
                },
              ),
            );
          }
        },
      ),
    );
  }
}
