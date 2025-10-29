import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:novacole/components/data_models/default_data_form.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/components/empty_page.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/components/model_photo_widget.dart';
import 'package:novacole/components/tag_widget.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  LeavePageState createState() {
    return LeavePageState();
  }
}

class LeavePageState extends State<LeavePage> {
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
      visible: user != null,
      replacement: LoadingIndicator(),
      child: Scaffold(
        body: DefaultDataGrid(
          itemBuilder: (leave) {
            return leaveWidget(leave);
          },
          dataModel: 'leave',
          paginate: PaginationValue.paginated,
          title: "Demandes de permission",
          formInputsMutator: (inputs, data) {
            inputs =
                inputs.map((input) {
                  if (input['field'] == 'student_id') {
                    input['hidden'] = false;
                  }
                  if (data != null) {
                    if ([
                      'classe_id',
                      'student_id',
                      'subject_id',
                    ].contains(input['field'])) {
                      input['disabled'] = true;
                    }
                  }
                  return input;
                }).toList();
            return inputs;
          },
          data: {
            'relations': ['student', 'teacher'],
            'filters': [
              {'field': 'school_id', 'value': user?.school},
            ],
            'order_by': 'created_at',
            'order_direction': 'DESC',
          },
          onItemTap: (leave, updateLine) {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        leave['student']['full_name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text("Matricule: ${leave['student']['matricule']}"),
                      Text("Raison : ${tr(leave['reason'] ?? '-')}"),
                      const Text(
                        "Détails:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("${leave['name'] ?? '-'}"),
                    ],
                  ),
                );
              },
            );
          },
          canAdd: false,
          canDelete: (leave) => leave['status'] == 'waiting',
          optionsBuilder: (leave, reload, updateLine) {
            return [
              if (user != null &&
                  (user!.isAccountType('staff') ||
                      user!.isAccountType('admin')) &&
                  (leave['status'] == 'waiting' || leave['status'] == null))
                approveWidget(leave, updateLine),
              if (user != null &&
                  (user!.isAccountType('staff') ||
                      user!.isAccountType('admin')) &&
                  (leave['status'] == 'waiting' || leave['status'] == null))
                rejectWidget(leave, reload),
            ];
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return Container(
                  padding: EdgeInsets.only(top: 40),
                  child: classeList(),
                );
              },
            );
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget leaveWidget(leave) {
    Color color = Colors.orange;

    if (leave['status'] == 'canceled') color = Colors.red;
    if (leave['status'] == 'approved') color = Colors.green;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ModelPhotoWidget(model: leave['student'], editable: false, photoKey: 'photo_url',),
        const SizedBox(width: 10),
        SizedBox(
          width: MediaQuery.of(context).size.width - 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                leave['student']['full_name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                'Matricule : ${leave['student']['matricule']}',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                'Par : ${leave['teacher_name'] ?? '-'}',
                style: const TextStyle(fontSize: 12),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 175,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Raison : ${tr(leave['reason'].toString())}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    TagWidget(
                      title:
                          Text(
                            "${leave['status'] ?? 'waiting'}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ).tr(),
                      color: color,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  goToCreate(String classe) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return DefaultDataForm(
            dataModel: 'leave',
            title: "Demande de permission",
            defaultData: {'classe_id': classe},
            inputsMutator: (inputs, data) {
              inputs =
                  inputs.map((input) {
                    if (input['field'] == 'classe_id') {
                      input['disabled'] = true;
                      input['value'] = classe;
                    }
                    if (input['field'] == 'start_at') {
                      input['value'] = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
                    }
                    if (input['field'] == 'student_id') {
                      input['hidden'] = false;
                      input['filters'] = [
                        {'field': 'repartitions.classe_id', 'value': classe},
                      ];
                    }
                    return input;
                  }).toList();
              return inputs;
            },
          );
        },
      ),
    );
  }

  Widget classeList() {
    return FutureBuilder(
      future: MasterCrudModel('classe').search(paginate: '0'),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        } else {
          if (snap.hasData && List.from(snap.data).isNotEmpty) {
            return ListView(
              children:
                  List<Map<String, dynamic>>.from(snap.data)
                      .map(
                        (e) => Card(
                          child: ListTile(
                            title: Text(
                              e['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Niveau : ${e['level']['name']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              weight: 0.3,
                              size: 12,
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              goToCreate(e['id']);
                            },
                          ),
                        ),
                      )
                      .toList(),
            );
          } else {
            return const Center(child: EmptyPage(sub: Text('Aucune classe')));
          }
        }
      },
    );
  }

  approveWidget(Map<String, dynamic> leave, Function updateLine) {
    return ListTile(
      onTap: () async {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return const SimpleDialog(
              children: [
                LoadingIndicator(),
                Center(child: Text('En cours ...')),
              ],
            );
          },
        );
        try {
          Map<String, dynamic>? response =
          await MasterCrudModel.post(
            '/leaves/approuve/${leave['id']}',
          );
          if (response != null) {
            updateLine(response);
            Fluttertoast.showToast(
              msg: 'Permission approuvée !',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        } catch (e) {
          Fluttertoast.showToast(
            msg: "Une erreur s'est produite: ${e.toString()} !",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
      title: const Text("Approuver"),
      leading: const Icon(Icons.check_box_outlined),
      iconColor: Theme.of(context).colorScheme.primary,
      textColor: Theme.of(context).colorScheme.primary,
      trailing: Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.primary,),
    );
  }

  rejectWidget(Map<String, dynamic> leave, Function reload) {
    return ListTile(
      onTap: () async {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return const SimpleDialog(
              children: [
                LoadingIndicator(),
                Center(child: Text('En cours ...')),
              ],
            );
          },
        );
        try {
          Map<String, dynamic>? response =
          await MasterCrudModel.post(
            '/leaves/reject/${leave['id']}',
          );
          if (response != null) {
            reload();
            Fluttertoast.showToast(
              msg: 'Permission rejetée !',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        } catch (e) {
          Fluttertoast.showToast(
            msg: "Une erreur s'est produite: ${e.toString()} !",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
      title: const Text("Rejeter"),
      leading: const Icon(Icons.cancel_outlined),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.red,),
      iconColor: Colors.red,
      textColor: Colors.red,
    );
  }
}
