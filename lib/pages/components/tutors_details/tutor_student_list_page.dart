import 'package:flutter/material.dart';
import 'package:novacole/components/empty_page.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/components/model_photo_widget.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/pages/student_details.dart';

class TutorStudentListPage extends StatefulWidget {
  final Map<String, dynamic> tutor;

  const TutorStudentListPage({super.key, required this.tutor});

  @override
  TutorStudentListPageState createState() {
    return TutorStudentListPageState();
  }
}

class TutorStudentListPageState extends State<TutorStudentListPage> {
  List<Map<String, dynamic>> students = [];
  bool isLoading = false;

  @override
  void initState() {
    _loadStudents();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingIndicator();
    } else {
      if (students.isEmpty) {
        return const EmptyPage();
      } else {
        return RefreshIndicator(
          onRefresh: () async {
            _loadStudents();
          },
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 400,
            child: ListView(
              primary: false,
              children:
                  students.map((student) {
                    return Card(
                      child: ListTile(
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
                            ModelPhotoWidget(model: student),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${student['full_name']}",
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
                                  'Niveau : ${student['level']?['name'] ?? '-'}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right_outlined),
                      ),
                    );
                  }).toList(),
            ),
          ),
        );
      }
    }
  }

  _loadStudents() async {
    setState(() {
      isLoading = true;
    });
    var res = await MasterCrudModel('student').search(
      paginate: '0',
      filters: [
        {
          'field': 'tutor_ids',
          'operator': 'all',
          'value': [widget.tutor['id']],
        },
      ],
      query: {'order_by': 'last_name'},
    );
    if (res != null) {
      setState(() {
        students = List<Map<String, dynamic>>.from(res);
      });
    }
    setState(() {
      isLoading = false;
    });
  }
}
