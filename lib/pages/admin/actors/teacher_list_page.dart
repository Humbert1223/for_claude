import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/components/model_photo_widget.dart';
import 'package:novacole/controllers/auth_controller.dart';
import 'package:novacole/models/user_model.dart';
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

class TeacherInfoWidget extends StatelessWidget {
  final Map<String, dynamic> teacher;

  const TeacherInfoWidget({super.key, required this.teacher});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return Row(
      children: [
        ModelPhotoWidget(
          model: teacher,
          width: 60,
          height: 60,
          editIconSize: 9.0,
          editable: authController.currentUser.value!.hasPermissionSafe(
            PermissionName.update(Entity.teacher),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: MediaQuery.of(context).size.width - 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${teacher['full_name']}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'Matricule : ${teacher['matricule'] ?? '-'}',
                style: const TextStyle(
                  fontSize: 12,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'Tél : ${teacher['phone'] ?? '-'}',
                style: const TextStyle(
                  fontSize: 12,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
