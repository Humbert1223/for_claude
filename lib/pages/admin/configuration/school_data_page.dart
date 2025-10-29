import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/models/user_model.dart';

class SchoolDataPage extends StatefulWidget {
  const SchoolDataPage({super.key});

  @override
  SchoolDataPageState createState() {
    return SchoolDataPageState();
  }
}

class SchoolDataPageState extends State<SchoolDataPage> {
  UserModel? user;

  @override
  void initState() {
    UserModel.fromLocalStorage().then(
      (value) {
        setState(() {
          user = value;
        });
      },
    );
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
            itemBuilder: (school) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    school['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "N°: ${school['registration_number']}",
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        "Tél: ${school['phone']}",
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        "Adresse: ${school['address']}",
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              );
            },
            dataModel: 'school',
            paginate: PaginationValue.paginated,
            title: 'Mes écoles',
            data: {
              'filters': [
                {'field': 'created_by', 'operator': '=', 'value': user?.id}
              ],
            },
          )
        : Container();
  }
}
