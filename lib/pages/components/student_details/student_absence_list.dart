import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:novacole/components/empty_page.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';

class StudentAbsenceList extends StatelessWidget {
  final Map<String, dynamic> repartition;

  const StudentAbsenceList({super.key, required this.repartition});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: MasterCrudModel('irregularity').search(
          paginate: '0',
          data: {
            'relations': ['subject']
          },
          filters: [
            {'field': 'type', 'value': 'absence'},
            {'field': 'student_id', 'value': repartition['student_id']},
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
                  children: assess.map<Widget>((absence) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 5.0),
                      child: ListTile(
                        onTap: () {},
                        title: Text(
                          DateFormat('dd MMM yyyy').format(
                            DateTime.parse(absence['irregularity_date']),
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Raison: ${absence['reason'] ?? '-'}"),
                            Text("Matière: ${absence['subject']?['discipline']?['name'] ?? '-'}")
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
