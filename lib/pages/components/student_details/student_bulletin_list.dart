import 'package:flutter/material.dart';
import 'package:novacole/components/empty_page.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/utils/tools.dart';

class StudentBulletinList extends StatelessWidget {
  final Map<String, dynamic> student;

  const StudentBulletinList({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: MasterCrudModel('bulletin').search(
          paginate: '0',
          filters: [
            {'field': 'student_id', 'value': student['id']}
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
                  children: assess.map<Widget>((bulletin) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 5.0),
                      child: ListTile(
                        onTap: () {},
                        title: Text("${bulletin['lot_name']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Moyenne: ${number(bulletin['avg'], digit: 2)}"),
                            const SizedBox(width: 10),
                            Text(
                              "Rang: ${bulletin['rang']}",
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
