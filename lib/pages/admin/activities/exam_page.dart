import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/components/permission_widgets.dart';
import 'package:novacole/components/tag_widget.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/exam_details.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/permission_utils.dart';
import 'package:novacole/utils/tools.dart';

class ExamPage extends StatefulWidget {
  const ExamPage({super.key});

  @override
  ExamPageState createState() {
    return ExamPageState();
  }
}

class ExamPageState extends State<ExamPage> {
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
    return Visibility(
      replacement: Container(),
      visible: user != null,
      child: DefaultDataGrid(
        itemBuilder: (assessment) {
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
                          assessment['level']['name'],
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
        dataModel: 'exam',
        paginate: PaginationValue.paginated,
        title: 'Examens',
        query: {'order_by': 'start_at', 'order_direction': 'DESC'},
        data: {
          'filters': [
            {'field': 'academic_id', 'value': user?.academic},
          ],
          'relations': ['serie', 'level', 'period'],
        },
        optionsBuilder: (exam, reload, updateLine) {
          return [
            if (exam['started_at'] == null)
              DisableIfNoPermission(
                permission: PermissionName.start(Entity.exam),
                child: ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    _startAssessment(exam, updateLine);
                  },
                  title: const Text("Démarrer"),
                  leading: const Icon(Icons.not_started_outlined),
                ),
              ),
            if (exam['closed'] == true && exam['started_at'] != null)
              DisableIfNoPermission(
                permission: PermissionName.open(Entity.exam),
                child: ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    _examOpen(exam, updateLine);
                  },
                  title: const Text("Ouvrir"),
                  leading: const Icon(Icons.lock_open_outlined),
                ),
              ),
            if ([null, false, ''].contains(exam['closed']) &&
                exam['started_at'] != null)
              DisableIfNoPermission(
                permission: PermissionName.close(Entity.exam),
                child: ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    _examClose(exam, updateLine);
                  },
                  title: const Text("Clôturer"),
                  leading: const Icon(Icons.lock),
                ),
              ),
          ];
        },
        onItemTap: (data, updateLine) {
          if(user!.hasPermissionSafe(PermissionName.view(Entity.exam))){
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return ExamDetails(exam: data);
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget status(assessment) {
    if (assessment['started_at'] == null) {
      return TagWidget(
        title: Text(
          "Non démarré",
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

  _examClose(Map<String, dynamic> period, updateLine) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Clôturer l'examen"),
          content: const Text('Voulez-vous clôturer cet examen ?'),
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
                  "/exam/close/${period['id']}",
                  data: {'status': true},
                );
                if (res != null) {
                  updateLine(res);
                }
                Navigator.pop(context);
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

  _examOpen(Map<String, dynamic> period, updateLine) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ouvrir l'examen"),
          content: const Text('Voulez-vous ouvrir cet examen ?'),
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
                  "/exam/close/${period['id']}",
                  data: {'status': false},
                );
                if (res != null) {
                  updateLine(res);
                }
                Navigator.pop(context);
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
          title: const Text("Démarrer l'examen"),
          content: const Text('Voulez-vous démarrer cet examen ?'),
          actions: [
            TextButton(
              onPressed: () async {
                var res = await MasterCrudModel.post(
                  "/exam/start/${period['id']}",
                );
                if (res != null) {
                  updateLine(res);
                }
                Navigator.pop(context);
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
