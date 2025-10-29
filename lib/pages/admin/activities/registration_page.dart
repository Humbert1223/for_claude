import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/student_details.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/permission_utils.dart';
import 'package:novacole/utils/tools.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  RegistrationPageState createState() {
    return RegistrationPageState();
  }
}

class RegistrationPageState extends State<RegistrationPage> {
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
    return user != null
        ? DefaultDataGrid(
            itemBuilder: (registration) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${registration['student']['full_name']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Date: ${NovaTools.dateFormat(registration['registration_date'])}",
                      ),
                      Text("Niveau: ${registration['level']['name']}")
                    ],
                  )
                ],
              );
            },
            dataModel: 'registration',
            paginate: PaginationValue.paginated,
            title: 'Inscription des élèves',
            query: {
              'order_by': 'registration_date',
              'order_direction': 'DESC'
            },
            data: {
              'relations': ['student', 'level'],
              'filters': [
                {'field': 'academic_id', 'value': user?.academic}
              ]
            },
            onItemTap: (registration, updateLine) {
              if(user!.hasPermissionSafe(PermissionName.view(Entity.registration))){
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return StudentDetails(student: registration['student']);
                }));
              }
            },
          )
        : Container();
  }
}