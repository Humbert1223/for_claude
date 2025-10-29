import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/models/user_model.dart';

class ClasseSubjectList extends StatefulWidget {
  final Map<String, dynamic> classe;

  const ClasseSubjectList({super.key, required this.classe});

  @override
  ClasseSubjectListState createState() {
    return ClasseSubjectListState();
  }
}

class ClasseSubjectListState extends State<ClasseSubjectList> {
  UserModel? currentUser;
  @override
  void initState() {
    super.initState();
    UserModel.fromLocalStorage().then((user){
      setState(() {
        currentUser = user;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultDataGrid(
      itemBuilder: (subject) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${subject['name']}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              "Titulaire: ${subject['charge_full_name']}",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Coefficient: ${subject['coefficient']}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Discipline: ${subject['discipline']['name']}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
      dataModel: 'subject',
      paginate: PaginationValue.paginated,
      formDefaultData: {'classe_id': widget.classe['id']},
      title: 'Matières de ${widget.classe['name']}',
      query: {'order_by': 'name', 'order_direction': 'ASC'},
      formInputsMutator: (inputs, data) {
        inputs = inputs.map<Map<String, dynamic>>((input) {
          if (input['field'] == 'teacher_id') {
            input['filters'] = [
              {
                'field': 'school_ids',
                'operator': '=',
                'value': currentUser?.school
              }
            ];
          }
          if(input['field'] == 'classe_id'){
            input['disabled'] = true;
          }
          return input;
        }).toList();
        return inputs;
      },
      data: {
        'filters': [
          {'field': 'classe_id', 'value': widget.classe['id']}
        ],
        'relations': ['discipline']
      }
    );
  }
}
