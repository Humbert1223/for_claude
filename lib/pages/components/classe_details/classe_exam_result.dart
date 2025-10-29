import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/components/permission_widgets.dart';
import 'package:novacole/components/tag_widget.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/permission_utils.dart';

class ClasseExamResult extends StatefulWidget {
  final Map<String, dynamic> classe;

  const ClasseExamResult({super.key, required this.classe});
  @override
  State<StatefulWidget> createState() {
    return ClasseExamResultState();
  }
}

class ClasseExamResultState extends State<ClasseExamResult> {
  Key key = UniqueKey();
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
    return Scaffold(
      body: DefaultDataGrid(
        key: Key(key.toString()),
        canAdd: false,
        canDelete: (data) => false,
        canEdit: (data) => false,
        itemBuilder: (repartition) {
          Map<String, dynamic> student = Map<String, dynamic>.from(
            repartition['student'],
          );
          String state = 'Non défini';
          Color stateColor = Colors.grey;
          if (repartition['is_success_exam'] == true) {
            state = 'Admis(e)';
            stateColor = Colors.green;
          } else if (repartition['is_success_exam'] == false) {
            state = 'Ajourné(e)';
            stateColor = Colors.red;
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 185,
                    child: Text(
                      "${repartition['name']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    'Matricule : ${student['matricule']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Âge : ${student['age']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        TagWidget(
                          title: Text(
                            state,
                            style: TextStyle(color: Colors.white),
                          ),
                          color: stateColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        dataModel: 'registration',
        paginate: PaginationValue.none,
        data: {
          'filters': [
            {'field': 'classe_id', 'value': widget.classe['id'], 'operator': '='},
          ],
        },
        title: "Résultats de l'examen de ${widget.classe['level']?['exam_name']}",
        optionsBuilder: (data, reload, updateLine) {
          bool? groupValue = data['is_success_exam'];
          return [
            DisableIfNoPermission(
              permission: PermissionName.update(Entity.registration),
              child: ListTile(
                title: Text("Admis(e)"),
                onTap: () {
                  _markExamSuccess(true, data['id'], context, updateLine);
                },
                trailing: checkBox(groupValue == true, context),
              ),
            ),
            DisableIfNoPermission(
              permission: PermissionName.update(Entity.registration),
              child: ListTile(
                title: Text("Ajourné(e)"),
                onTap: () {
                  _markExamSuccess(false, data['id'], context, updateLine);
                },
                trailing: checkBox(groupValue == false, context),
              ),
            ),
            DisableIfNoPermission(
              permission: PermissionName.update(Entity.registration),
              child: ListTile(
                title: Text("Non défini"),
                onTap: () {
                  _markExamSuccess(null, data['id'], context, updateLine);
                },
                trailing: checkBox(groupValue == null, context),
              ),
            ),
          ];
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var result = await showModalBottomSheet(
            context: context,
            builder: (context) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 10,
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    primary: false,
                    children: [
                      Card(
                        child: DisableIfNoPermission(
                          permission: PermissionName.update(Entity.registration),
                          child: ListTile(
                            title: const Text(
                              "Marquer tous Admis(e)",
                              style: TextStyle(color: Colors.green),
                            ),
                            onTap: () {
                              Navigator.of(context).pop(true);
                            },
                            trailing: Icon(
                              Icons.chevron_right_outlined,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                      Card(
                        child: DisableIfNoPermission(
                          permission: PermissionName.update(Entity.registration),
                          child: ListTile(
                            title: const Text(
                              "Marquer tous Ajourné(e)",
                              style: TextStyle(color: Colors.red),
                            ),
                            onTap: () {
                              Navigator.of(context).pop(false);
                            },
                            trailing: Icon(
                              Icons.chevron_right_outlined,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          title: const Text("Marquer tous Non défini"),
                          onTap: () {
                            Navigator.of(context).pop('');
                          },
                          trailing: Icon(Icons.chevron_right_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
          if (result != null) {
            if (result == '') {
              result = null;
            }
            showLoading(context);
            await _bulkMarkExamSuccess(result, () {
              setState(() {
                key = UniqueKey();
              });
            });
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.checklist, color: Colors.white, size: 32),
      ),
    );
  }

  Future<void> _markExamSuccess(bool? isSuccess, String id, context, callback) async {
    Navigator.of(context).pop();
    showLoading(context);
    Map<String, dynamic>? result = await MasterCrudModel(
      Entity.registration,
    ).update(id, {'is_success_exam': isSuccess, 'entity': Entity.registration});
    Navigator.of(context).pop();
    if (result != null) {
      callback(result);
    }
  }

  Future<void> _bulkMarkExamSuccess(bool? isSuccess, callback) async {
    Map<String, dynamic>? result = await MasterCrudModel.patch(
      "/repartition/hulk-exam-status/${widget.classe['id']}",
      {'is_success_exam': isSuccess, 'selection': []},
    );
    if (result != null) {
      callback();
    }
  }

  Widget checkBox(bool active, context) {
    return active
        ? Icon(
      Icons.check_circle,
      size: 32,
      color: Theme.of(context).colorScheme.primary,
    )
        : Icon(
      Icons.circle_outlined,
      size: 32,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  void showLoading(context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: LoadingIndicator(type: LoadingIndicatorType.inkDrop),
        );
      },
    );
  }

}
