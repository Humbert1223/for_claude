import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:novacole/components/empty_page.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/pages/components/student_details/student_assessment_mark_page.dart';

class StudentAssessmentList extends StatelessWidget {
  final Map<String, dynamic> repartition;

  const StudentAssessmentList({super.key, required this.repartition});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: MasterCrudModel('assessment').search(
          paginate: '0',
          filters: [
            {'field': 'closed', 'value': true},
            {'field': 'classe_ids', 'value': repartition['classe_id']}
          ],
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
                    return Card(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return StudentAssessmentMarkPage(
                                  assessment: ass,
                                  student: repartition['student'],
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
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(Icons.calendar_month_outlined),
                            const SizedBox(width: 5),
                            Text(
                              DateFormat('dd MMM yyyy').format(DateTime.parse(ass['start_at'])),
                            ),
                            const Text(' ~ '),
                            Text(
                              DateFormat('dd MMM yyyy').format(DateTime.parse(ass['end_at'])),
                            ),
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
