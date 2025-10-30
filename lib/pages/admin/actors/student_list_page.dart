import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/components/model_photo_widget.dart';
import 'package:novacole/controllers/auth_controller.dart';
import 'package:novacole/models/user_model.dart';
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

class StudentInfoWidget extends StatelessWidget {
  final Map<String, dynamic> student;
  const StudentInfoWidget({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ModelPhotoWidget(
          model: student,
          width: 60,
          height: 60,
          editIconSize: 9,
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${student['full_name']}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              'Matricule : ${student['matricule']}',
              style: const TextStyle(fontSize: 12),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Âge : ${student['age']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Niveau : ${student['level']?['name'] ?? '-'}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
