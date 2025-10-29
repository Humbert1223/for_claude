import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/components/permission_widgets.dart';
import 'package:novacole/components/tag_widget.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/permission_utils.dart';
import 'package:novacole/utils/tools.dart';

class AssessmentPage extends StatefulWidget {
  const AssessmentPage({super.key});

  @override
  AssessmentPageState createState() {
    return AssessmentPageState();
  }
}

class AssessmentPageState extends State<AssessmentPage> {
  UserModel? user;

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
    return user != null
        ? DefaultDataGrid(
          itemBuilder: (assessment) {
            final classes = List.from(
              assessment['classes'] ?? [],
            ).map((e) => e['name']).toList().join(', ');
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${assessment['name']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 170,
                          child: Text(
                            classes,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Text(
                          "Date: ${NovaTools.dateFormat(assessment['start_at'])}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    status(assessment),
                  ],
                ),
              ],
            );
          },
          dataModel: 'assessment',
          paginate: PaginationValue.paginated,
          title: 'Évaluations',
          query: {'order_by': 'start_at', 'order_direction': 'DESC'},
          data: {
            'relations': ['classes'],
            'filters': [
              {'field': 'academic_id', 'value': user?.academic},
            ],
          },
          optionsBuilder: (assessment, reload, updateLine) {
            return [
              if (assessment['started_at'] == null)
                DisableIfNoPermission(
                  permission: PermissionName.start(Entity.assessment),
                  child: ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      _startAssessment(assessment, updateLine);
                    },
                    title: const Text("Démarrer"),
                    leading: const Icon(Icons.not_started_outlined),
                  ),
                ),
              if (assessment['closed'] == true &&
                  assessment['started_at'] != null)
                DisableIfNoPermission(
                  permission: PermissionName.open(Entity.assessment),
                  child: ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      _assessmentOpen(assessment, updateLine);
                    },
                    title: const Text("Ouvrir"),
                    leading: const Icon(Icons.lock_open_outlined),
                  ),
                ),
              if ([null, false, ''].contains(assessment['closed']) &&
                  assessment['started_at'] != null)
                DisableIfNoPermission(
                  permission: PermissionName.close(Entity.assessment),
                  child: ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      _assessmentClose(assessment, updateLine);
                    },
                    title: const Text("Clôturer"),
                    leading: const Icon(Icons.lock),
                  ),
                ),
            ];
          },
        )
        : Container();
  }

  Widget status(assessment) {
    if (assessment['started_at'] == null) {
      return TagWidget(
        title: Text(
          "Non démarrée",
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Colors.white,
          ),
        ),
        color: Colors.amber,
      );
    }
    return assessment['closed'] == false || assessment['closed'] == null
        ? const TagWidget(
          title: Text(
            'Ouvert',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
          ),
        )
        : const TagWidget(
          title: Text(
            'Fermée',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
          ),
          color: Colors.orange,
        );
  }

  _assessmentClose(Map<String, dynamic> period, updateLine) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Clôturer l'évaluation"),
          content: const Text('Voulez-vous clôturer cette évaluation ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Non'),
            ),
            TextButton(
              onPressed: () async {
                var res = await MasterCrudModel.post(
                  "/assessments/close/${period['id']}",
                  data: {'status': true},
                );
                if (res != null) {
                  updateLine(res);
                }
                if(context.mounted){
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Oui',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  _assessmentOpen(Map<String, dynamic> period, updateLine) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ouvrir l'évaluation"),
          content: const Text('Voulez-vous ouvrir cette évaluation ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Non'),
            ),
            TextButton(
              onPressed: () async {
                var res = await MasterCrudModel.post(
                  "/assessments/close/${period['id']}",
                  data: {'status': false},
                );
                if (res != null) {
                  updateLine(res);
                }
                if(context.mounted){
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Oui',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  _startAssessment(Map<String, dynamic> period, updateLine) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Démarrer l'évaluation"),
          content: const Text('Voulez-vous démarrer cette évaluation ?'),
          actions: [
            TextButton(
              onPressed: () async {
                var res = await MasterCrudModel.post(
                  "/assessments/start/${period['id']}",
                );
                if (res != null) {
                  updateLine(res);
                }
                if(context.mounted){
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Oui',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Non'),
            ),
          ],
        );
      },
    );
  }
}
