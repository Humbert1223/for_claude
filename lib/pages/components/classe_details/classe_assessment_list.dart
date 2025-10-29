import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/components/tag_widget.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/utils/tools.dart';

class ClasseAssessmentList extends StatefulWidget {
  final Map<String, dynamic> classe;

  const ClasseAssessmentList({super.key, required this.classe});

  @override
  ClasseAssessmentListState createState() {
    return ClasseAssessmentListState();
  }
}

class ClasseAssessmentListState extends State<ClasseAssessmentList> {
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
            itemBuilder: (assessment) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${assessment['name']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Date: ${NovaTools.dateFormat(assessment['start_at'])}",
                          ),
                        ],
                      ),
                      assessment['closed'] == false ||
                              assessment['closed'] == null
                          ? const TagWidget(
                              title: Text(
                                'Ouvert',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : const TagWidget(
                              title: Text(
                                'Fermée',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                ),
                              ),
                              color: Colors.orange,
                            ),
                    ],
                  ),
                ],
              );
            },
            dataModel: 'assessment',
            paginate: PaginationValue.paginated,
            formDefaultData: {'classe_id': widget.classe['id']},
            title: 'Évaluations de ${widget.classe['name']}',
            query: {'order_by': 'start_at', 'order_direction': 'DESC'},
            data: {
              'filters': [
                {'field': 'classe_ids', 'value': widget.classe['id']}
              ]
            },
            formInputsMutator: (inputs, data) {
              inputs = inputs.map<Map<String, dynamic>>((input) {
                if (input['field'] == 'period_id') {
                  input['filters'] = [
                    {
                      'field': 'degree',
                      'operator': '=',
                      'value': widget.classe['level']?['degree']
                    }
                  ];
                }
                return input;
              }).toList();
              return inputs;
            },
          )
        : Container();
  }
}
