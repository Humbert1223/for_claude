import 'package:flutter/material.dart';
import 'package:novacole/components/empty_page.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/pages/admin/actors/actor_info_widget.dart';
import 'package:novacole/pages/admin/actors/student_list_page.dart';
import 'package:novacole/pages/student_details.dart';

class StudentSearchResultList extends StatefulWidget {
  final String? term;

  const StudentSearchResultList({super.key, this.term});

  @override
  StudentSearchResultListState createState() {
    return StudentSearchResultListState();
  }
}

class StudentSearchResultListState extends State<StudentSearchResultList> {
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
    return Column(
      children: [
        const SizedBox(height: 10),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          leading: const Icon(Icons.people_outline),
          title: const Text(
            "Élèves",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          trailing: TextButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return const StudentListPage();
              }));
            },
            child: const Text(
              "Voir tous",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Divider(
          height: 2,
          color: Theme.of(context).primaryColor,
        ),
        if (widget.term != null)
          FutureBuilder(
            future: MasterCrudModel('student').search(
              paginate: '0',
              query: {'term': widget.term, 'limit': 4},
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingIndicator(
                  type: LoadingIndicatorType.waveDot,
                );
              } else {
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.isNotEmpty) {
                  return Column(
                    children: List<Map<String, dynamic>>.from(snapshot.data)
                        .map((item) {
                      return InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: StudentInfoWidget(
                            student: item,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return StudentDetails(student: item);
                          }));
                        },
                      );
                    }).toList(),
                  );
                } else {
                  return const EmptyPage(
                    icon: Icon(Icons.people),
                  );
                }
              }
            },
          )
        else
          const EmptyPage(
            icon: Icon(Icons.people),
          )
      ],
    );
  }
}
