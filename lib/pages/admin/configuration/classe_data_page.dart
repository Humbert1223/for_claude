import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/models/user_model.dart';

class ClassesDataPage extends StatefulWidget {
  const ClassesDataPage({super.key});

  @override
  ClassesDataPageState createState() {
    return ClassesDataPageState();
  }
}

class ClassesDataPageState extends State<ClassesDataPage> {
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
            itemBuilder: (classe) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classe['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Niveau: ${classe['level']?['name']}"),
                            Text("Série: ${(classe['serie']?['name'])}")
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Capacité: ${classe['capacity'] ?? '-' }"),
                            Text("Effectif: ${(classe['effectif'])}")
                          ],
                        ),
                        Text("Titulaire: ${(classe['titulaire']?['full_name'])}")
                      ],
                    ),
                  ],
                );
            },
            dataModel: 'classe',
            paginate: PaginationValue.paginated,
            title: 'Classes scolaires',
            data: {
              'filters': [
                {'field': 'school_id', 'operator': '=', 'value': user?.school},
                {
                  'field': 'academic_id',
                  'operator': '=',
                  'value': user?.academic
                },
              ],
            },
          )
        : Container();
  }
}
