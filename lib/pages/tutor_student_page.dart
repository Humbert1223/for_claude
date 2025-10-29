import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/components/model_photo_widget.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/student_details.dart';

class TutorStudentPage extends StatefulWidget {
  const TutorStudentPage({super.key});

  @override
  TutorStudentPageState createState() {
    return TutorStudentPageState();
  }
}

class TutorStudentPageState extends State<TutorStudentPage> {
  UserModel? user;
  bool loading = true;
  List<Map<String, dynamic>> students = [];

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
    return DefaultDataGrid(
      itemBuilder: (Map<String, dynamic> student) {
        return ListTile(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return StudentDetails(student: student);
                },
              ),
            );
          },
          title: Row(
            children: [
              ModelPhotoWidget(
                model: student,
                width: 70,
                height: 70,
                editable: false,
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['full_name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Matricule : ${student['matricule']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    "Niveau : ${student['level']?['name'] ?? '-'}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      dataModel: 'student',
      paginate: PaginationValue.none,
      title: 'Liste des enfants',
      canEdit: (data) => false,
      canDelete: (data) => false,
      canAdd: false,
    );
  }
}
