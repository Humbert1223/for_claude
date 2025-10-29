import 'package:flutter/material.dart';
import 'package:novacole/components/empty_page.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/pages/classe_details.dart';

class TeacherClassePage extends StatefulWidget {
  final Map<String, dynamic> teacher;

  const TeacherClassePage({super.key, required this.teacher});

  @override
  TeacherClassePageState createState() {
    return TeacherClassePageState();
  }
}

class TeacherClassePageState extends State<TeacherClassePage> {
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
    return FutureBuilder(
        future: MasterCrudModel('classe').search(
          paginate: '0',
          filters: [
            {
              'field': 'subjects.teacher_id',
              'operator': '=',
              'value': widget.teacher['id']
            }
          ]
        ),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          } else {
            if (snap.hasData && List.from(snap.data).isNotEmpty) {
              List<Map<String, dynamic>> assess =
              List<Map<String, dynamic>>.from(snap.data);
              return SingleChildScrollView(
                child: Column(
                  children: assess.map<Widget>((classe) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return ClasseDetails(classe: classe);
                              },
                            ),
                          );
                        },
                        title: Text(
                          classe['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Effectif: ${classe['effectif'] ?? '-'} "),
                            Text("Titulaire: ${classe['teacher']?['full_name'] ?? '-'}"),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            } else {
              return const EmptyPage();
            }
          }
        });
  }
}
