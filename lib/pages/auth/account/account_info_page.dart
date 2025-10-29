import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:novacole/components/empty_page.dart';
import 'package:novacole/components/json_schema.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/controllers/auth_controller.dart';
import 'package:novacole/models/form.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';

class UserAccountInfo extends StatefulWidget {
  const UserAccountInfo({super.key});

  @override
  State<StatefulWidget> createState() {
    return UserAccountInfoState();
  }
}

class UserAccountInfoState extends State<UserAccountInfo> {
  bool isFetching = true;
  late Map<String, dynamic> form;
  final authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();

    authController.refreshUser().then((fetchUser) {
      CoreForm().get(entity: 'user').then((value) {
        form = value!;
        var passConf = Map<String, dynamic>.from(List.from(form['inputs'])
            .where((el) => el['field'] == 'password')
            .firstOrNull);
        passConf['field'] = 'password_confirmation';
        passConf['name'] = 'Retaper le mot de passe';
        passConf['placeholder'] = 'Retaper le mot de passe';

        var userMap = authController.currentUser.value?.toMap();
        List inputs = List.from(form['inputs']).where((input) {
          return !['password', 'phone', 'email'].contains(input['field']);
        }).toList();
        inputs = inputs.map((e) {
          e['value'] = userMap?[e['field']] ?? '';
          return e;
        }).toList();
        //inputs.add(passConf);
        setState(() {
          form['inputs'] = inputs;
          isFetching = false;
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Compte"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SingleChildScrollView(
        child: isFetching
            ? const SizedBox(
                height: 200,
                child: Center(child: LoadingIndicator()),
              )
            : Column(
                children: [
                  Card(
                    child: ListTile(
                      title:
                          const Text("Sexe : ", style: TextStyle(fontSize: 14)),
                      trailing: Text(
                        authController.currentUser.value?.gender ?? '-',
                        style: const TextStyle(fontSize: 14),
                      ).tr(),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title:
                          const Text("Nom : ", style: TextStyle(fontSize: 14)),
                      trailing: Text(
                        authController.currentUser.value?.name ?? '-',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text("Téléphone : ",
                          style: TextStyle(fontSize: 14)),
                      trailing: Text(
                        authController.currentUser.value?.phone ?? '-',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text(
                        "Email : ",
                        style: TextStyle(fontSize: 14),
                      ),
                      trailing: Text(
                        authController.currentUser.value?.email ?? '-',
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  TextButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return SimpleDialog(
                              children: [formWidget()],
                            );
                          });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: const Text("Modifier"),
                  )
                ],
              ),
      ),
    );
  }

  Widget formWidget() {
    if (form['inputs'] != null && List.from(form['inputs']).isNotEmpty) {
      var hiddenField = [
        'status',
        'account_type',
        'active',
        'photo',
        'password',
        'phone',
        'email'
      ];
      return JsonSchema(
        hiddenFields: hiddenField,
        form: form,
        actionSave: (Map<String, dynamic> form) async {
          Map<String, dynamic> data = {};
          for (var element in List.from(form['inputs'])) {
            data[element['field']] = element['value'];
          }
          var response = await MasterCrudModel.patch(
            '/auth/users/${authController.currentUser.value?.id}',
            data,
          );
          if (response != null) {
            var newUser = Map<String, dynamic>.from(response);
            newUser['token'] = authController.currentUser.value?.token;
            authController.setCurrentUser(UserModel.fromMap(newUser));
            Navigator.pop(context);
          }
        },
      );
    } else {
      return const EmptyPage();
    }
  }
}
