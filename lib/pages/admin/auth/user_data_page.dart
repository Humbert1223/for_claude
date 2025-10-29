import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_grid.dart';
import 'package:novacole/components/tag_widget.dart';
import 'package:novacole/models/user_model.dart';

class UserDataPage extends StatefulWidget {
  const UserDataPage({super.key});

  @override
  UserDataPageState createState() {
    return UserDataPageState();
  }
}

class UserDataPageState extends State<UserDataPage> {
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
      replacement: Container(),
      child: DefaultDataGrid(
        itemBuilder: (usr) {
          String? type = List.from(usr['schools'] ?? [])
              .where((sc) {
                return user?.school != null && sc['school_id'] == user?.school;
              })
              .map((sc) {
                return sc['account_type'].toString().tr();
              })
              .toList()
              .join(', ');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                usr['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Email: ${usr['email']}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 168,
                        child: Text(
                          "Type: $type",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      if (usr['active'] == true)
                        TagWidget(
                          title: const Text(
                            'active',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                            ),
                          ).tr(),
                        )
                      else
                        TagWidget(
                          title: const Text(
                            'inactive',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                            ),
                          ).tr(),
                          color: Colors.orange,
                        ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
        dataModel: 'user',
        paginate: PaginationValue.paginated,
        title: 'Utilisateurs',
        canEdit: (value) => false,
        canDelete: (value) => false,
        formInputsMutator: (inputs, datum) {
          if (datum != null) {
            inputs = inputs.map((e) {
              if (e['field'] == 'account_type') {
                if (!['admin', 'staff'].contains(datum['account_type'])) {
                  e['hidden'] = true;
                }
              }
              if (['password', 'email'].contains(e['field'])) {
                e['hidden'] = true;
              }
              return e;
            }).toList();
          }
          return inputs;
        },
        data: {
          'filters': [
            {
              'field': 'schools.school_id',
              'operator': '=',
              'value': user?.school,
            },
          ],
        },
      ),
    );
  }
}
