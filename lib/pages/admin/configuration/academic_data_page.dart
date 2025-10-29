import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/components/permission_widgets.dart';
import 'package:novacole/components/tag_widget.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/permission_utils.dart';
import 'package:novacole/utils/tools.dart';

class AcademicDataPage extends StatefulWidget {
  const AcademicDataPage({super.key});

  @override
  AcademicDataPageState createState() {
    return AcademicDataPageState();
  }
}

class AcademicDataPageState extends State<AcademicDataPage> {
  UserModel? user;

  bool isLoading = false;

  List<Map<String, dynamic>>? items = [];

  @override
  void initState() {
    UserModel.fromLocalStorage().then(
      (value) {
        setState(() {
          user = value;
        });
      },
    );
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
            itemBuilder: (academic) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    academic['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "${NovaTools.dateFormat(academic['start_at'])} ~ "
                    "${NovaTools.dateFormat(academic['end_at'])}",
                    style: const TextStyle(fontSize: 13),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      academic['started_at'] != null
                          ? const TagWidget(
                              title: Text('Démarrée',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white,
                                  )),
                            )
                          : TagWidget(
                              title: const Text('Non démarrée',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white,
                                  )).tr(),
                              color: Colors.amber,
                            ),
                      academic['closed'] == true
                          ? TagWidget(
                              title: const Text('closed',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white,
                                  )).tr(),
                              color: Colors.orange,
                            )
                          : TagWidget(
                              title: const Text('opened',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white,
                                  )).tr(),
                            ),
                    ],
                  ),
                ],
              );
            },
            dataModel: 'academic',
            paginate: PaginationValue.paginated,
            title: 'Années scolaires',
            data: {
              'filters': [
                {'field': 'school_id', 'operator': '=', 'value': user?.school},
              ],
            },
            formInputsMutator: (inputs, datum) {
              inputs = inputs.map((el) {
                if (el['field'] == 'director_id') {
                  el['filters'] = [
                    {
                      'field': 'account_type',
                      'operator': 'in',
                      'value': ['staff', 'admin']
                    }
                  ];
                }
                if (datum != null) {
                  if (el['field'] == 'parent_id') {
                    el['hidden'] = true;
                  }
                }
                return el;
              }).toList();
              return inputs;
            },
            optionsBuilder: (academic, reload, updateLine) {
              return [
                if (academic['started_at'] == null)
                  DisableIfNoPermission(
                    permission: PermissionName.start(Entity.academic),
                    child: ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        _startAcademic(academic, updateLine);
                      },
                      title: const Text("Démarrer"),
                      leading: const Icon(Icons.not_started_outlined),
                    ),
                  ),
                if (academic['closed'] == true &&
                    academic['started_at'] != null)
                  DisableIfNoPermission(
                    permission: PermissionName.open(Entity.academic),
                    child: ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        _academicOpen(academic, updateLine);
                      },
                      title: const Text("Ouvrir"),
                      leading: const Icon(Icons.lock_open_outlined),
                    ),
                  ),
                if ([null, false, ''].contains(academic['closed']) &&
                    academic['started_at'] != null)
                  DisableIfNoPermission(
                    permission: PermissionName.close(Entity.academic),
                    child: ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        _academicClose(academic, updateLine);
                      },
                      title: const Text("Clôturer"),
                      leading: const Icon(Icons.lock),
                    ),
                  )
              ];
            },
          )
        : Container();
  }

  _academicOpen(Map<String, dynamic> academic, updateLine) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ouvrir l'année scolaire"),
          content: const Text('Voulez-vous ouvrir cette année scolaire ?'),
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
                  "/academics/close/${academic['id']}",
                  data: {
                    'status': false,
                  },
                );
                if(res != null){
                  updateLine(res);
                }
                Navigator.pop(context);
              },
              child: const Text(
                'Oui',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  _academicClose(Map<String, dynamic> academic, reload) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Clôturer l'année scolaire"),
          content: const Text('Voulez-vous clôturer cette année scolaire ?'),
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
                  "/academics/close/${academic['id']}",
                  data: {
                    'status': true,
                  },
                );
                if(res != null){
                  reload();
                }
                Navigator.pop(context);
              },
              child: const Text(
                'Oui',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  _startAcademic(Map<String, dynamic> academic, reload) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Démarrer l'année scolaire"),
          content: const Text('Voulez-vous démarrer cette année scolaire ?'),
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
                  "/academics/start/${academic['id']}",
                );
                if(res != null){
                  reload();
                }
                Navigator.pop(context);
              },
              child: const Text('Oui'),
            ),
          ],
        );
      },
    );
  }
}
