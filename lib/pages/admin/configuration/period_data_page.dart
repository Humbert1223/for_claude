import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/components/permission_widgets.dart';
import 'package:novacole/components/tag_widget.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/permission_utils.dart';

class PeriodDataPage extends StatefulWidget {
  const PeriodDataPage({super.key});

  @override
  PeriodDataPageState createState() {
    return PeriodDataPageState();
  }
}

class PeriodDataPageState extends State<PeriodDataPage> {
  UserModel? user;

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
            itemBuilder: (period) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    period['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Degrée: ${(period['degree']).toString().tr()}",
                          ),
                          if (period['started_at'] == null)
                            const TagWidget(
                              title: Text(
                                'Non démarrée',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                ),
                              ),
                              color: Colors.orange,
                            ),
                          if (period['closed'] == true &&
                              period['started_at'] != null)
                            TagWidget(
                              title: const Text(
                                'closed',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                ),
                              ).tr(),
                              color: Colors.orange,
                            ),
                          if (period['closed'] == false &&
                              period['started_at'] != null)
                            TagWidget(
                              title: const Text(
                                'opened',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                ),
                              ).tr(),
                            )
                        ],
                      ),
                    ],
                  ),
                ],
              );
            },
            dataModel: 'period',
            paginate: PaginationValue.paginated,
            title: 'Périodes scolaires',
            data: {
              'filters': [
                {'field': 'school_id', 'operator': '=', 'value': user?.school},
                {
                  'field': 'academic_id',
                  'operator': '=',
                  'value': user?.academic
                },
              ],
            },
            optionsBuilder: (period, reload, updateLine) {
              return [
                if (period['started_at'] == null)
                  DisableIfNoPermission(
                    permission: PermissionName.start(Entity.period),
                    child: ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        _startPeriod(period, updateLine);
                      },
                      title: const Text("Démarrer"),
                      leading: const Icon(Icons.not_started_outlined),
                    ),
                  ),
                if (period['closed'] == true && period['started_at'] != null)
                  DisableIfNoPermission(
                    permission: PermissionName.open(Entity.period),
                    child: ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        _periodOpen(period, updateLine);
                      },
                      title: const Text("Ouvrir"),
                      leading: const Icon(Icons.lock_open_outlined),
                    ),
                  ),
                if ([null, false, ''].contains(period['closed']) &&
                    period['started_at'] != null)
                  DisableIfNoPermission(
                    permission: PermissionName.close(Entity.period),
                    child: ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        _periodClose(period, updateLine);
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

  _periodClose(Map<String, dynamic> period, updateLine) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clôturer la période'),
          content: const Text('Voulez-vous clôturer cette période scolaire ?'),
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
                  "/periods/close/${period['id']}",
                  data: {
                    'status': true,
                  },
                );
                if (res != null) {
                  updateLine(res);
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

  _periodOpen(Map<String, dynamic> period, updateLine) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ouvrir la période'),
          content: const Text('Voulez-vous ouvrir cette période scolaire ?'),
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
                  "/periods/close/${period['id']}",
                  data: {
                    'status': false,
                  },
                );
                if (res != null) {
                  updateLine(res);
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

  _startPeriod(Map<String, dynamic> period, updateLine) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.question_mark_outlined),
          title: const Text('Démarrer la période'),
          content: const Text('Voulez-vous démarrer cette période scolaire ?'),
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
                  "/periods/start/${period['id']}",
                );
                if (res != null) {
                  updateLine(res);
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
