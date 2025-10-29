import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:novacole/components/empty_page.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/pages/components/teacher_details/teacher_assessment_mark_page.dart';

class TeacherAssessmentList extends StatelessWidget {
  final Map<String, dynamic> teacher;

  const TeacherAssessmentList({super.key, required this.teacher});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: MasterCrudModel('assessment').search(
          paginate: '0',
          data: {'relations': ['classes']},
          filters: [
            {
              'field': 'classes.subjects.teacher_id',
              'operator': '=',
              'value': teacher['id']
            },
            {
              'field': 'closed',
              'operator': '!=',
              'value': true
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
                  children: assess.map<Widget>((ass) {
                    String classes = List.from((ass['classes'] ?? [])).map((el){
                      return el['name'];
                    }).join(', ');
                    DateTime? startAt = DateTime.tryParse(ass['start_at'].toString());
                    DateTime? endAt = DateTime.tryParse(ass['end_at'].toString());
                    return Card(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return TeacherAssessmentMarkPage(
                                  assessment: ass,
                                  teacher: teacher,
                                );
                              },
                            ),
                          );
                        },
                        title: Text(
                          ass['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(Icons.date_range_outlined),
                                const SizedBox(width: 5),
                                Text(
                                  startAt == null ? '-' : DateFormat('dd MMM yyyy').format(startAt),
                                ),
                                const Text(' ~ '),
                                Text(
                                  endAt == null ? '-' : DateFormat('dd MMM yyyy').format(endAt),
                                ),
                              ],
                            ),
                            Text("Classes: $classes")
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
