import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/empty_page.dart';
import 'package:novacole/components/json_schema.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/components/tag_widget.dart';
import 'package:novacole/models/form.dart';
import 'package:novacole/models/master_crud_model.dart';

class StudentLeaveList extends StatefulWidget {
  final Map<String, dynamic> repartition;

  const StudentLeaveList({super.key, required this.repartition});

  @override
  State<StatefulWidget> createState() {
    return StudentLeaveListState();
  }
}

class StudentLeaveListState extends State<StudentLeaveList> {
  Map<String, dynamic> leaveForm = {};

  @override
  void initState() {
    CoreForm().get(entity: 'irregularity').then((data) {
      if (data != null) {
        List<Map<String, dynamic>> fields = List<Map<String, dynamic>>.from(
          data['inputs'],
        );
        fields =
            fields.map((field) {
              if (field['field'] == 'classe_id') {
                field['value'] = widget.repartition['classe_id'];
                field['hidden'] = true;
              }
              if (field['field'] == 'type') {
                field['value'] = 'leave';
                field['hidden'] = true;
              }
              if (field['field'] == 'subject_id') {
                List<Map<String, dynamic>> subjectFilters =
                    List<Map<String, dynamic>>.from(field['filters'] ?? []);
                subjectFilters.add({
                  'field': 'classe_id',
                  'value': widget.repartition['classe_id'],
                });
                field['filters'] = subjectFilters;
              }
              return field;
            }).toList();

        setState(() {
          leaveForm = Map<String, dynamic>.from(data);
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: MasterCrudModel('irregularity').search(
          paginate: '0',
          filters: [
            {'field': 'type', 'value': 'leave'},
            {'field': 'student_id', 'value': widget.repartition['student_id']},
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
                  children:
                      assess.map<Widget>((absence) {
                        Color color = Colors.orange;

                        if (absence['status'] == 'canceled') {
                          color = Colors.red;
                        }
                        if (absence['status'] == 'approved') {
                          color = Colors.green;
                        }
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
                            subtitle: SizedBox(
                              width: 500,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Raison: ${(absence['reason']).toString().tr()}",
                                  ),
                                  const SizedBox(width: 10),
                                  TagWidget(
                                    title: Text(
                                      tr(absence['status'] ?? 'waiting'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    color: color,
                                  ),
                                ],
                              ),
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
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          dynamic data = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return SimpleDialog(
                children: [JsonSchema(form: leaveForm, actionSave: (form) {})],
              );
            },
          );
          if (data != null) {
            data['irregularity_type'] = 'leave';
            await MasterCrudModel(
              'irregularity',
            ).create(data);
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add),
      ),
    );
  }
}
