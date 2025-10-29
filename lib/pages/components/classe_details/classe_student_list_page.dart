import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/components/model_photo_widget.dart';
import 'package:novacole/pages/student_details.dart';

class ClasseStudentListPage extends StatefulWidget {
  final Map<String, dynamic> classe;
  const ClasseStudentListPage({super.key, required this.classe});

  @override
  ClasseStudentListPageState createState() {
    return ClasseStudentListPageState();
  }
}

class ClasseStudentListPageState extends State<ClasseStudentListPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultDataGrid(
      itemBuilder: (repartition) {
        Map<String, dynamic> student = repartition['student'];
        return Row(
          children: [
            ModelPhotoWidget(
              model: student,
              width: 60,
              height: 60,
              editIconSize: 9,
            ),
            const SizedBox(width: 10),
            SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 185,
                    child: Text(
                      "${student['full_name']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    'Matricule : ${student['matricule']}',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 185,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Âge : ${student['age']}',
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Niveau : ${widget.classe['level']?['name'] ?? '-'}',
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      dataModel: 'registration',
      paginate: PaginationValue.paginated,
      title: 'Liste des élèves de ${widget.classe['name']}',
      query: {'order_by': 'last_name'},
      canEdit: (item) => false,
      canAdd: false,
      data: {
        'filters': [
          {
            'field': 'classe_id',
            'operator': '=',
            'value': widget.classe['id']
          },
        ],
        'relations': ['student']
      },
      onItemTap: (repartition, updateLine) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          Map<String, dynamic> student = Map<String, dynamic>.from(repartition['student']);
          student['level'] = widget.classe['level'];
          return StudentDetails(student: student);
        }));
      },
    );
  }
}
