import 'package:flutter/material.dart';
import 'package:novacole/components/app_bar_back_button.dart';
import 'package:novacole/components/data_models/default_data_form.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/admin/actors/tutor_details.dart';
import 'package:novacole/utils/constants.dart';

class UserTutorProfile extends StatefulWidget {
  const UserTutorProfile({super.key});

  @override
  UserTutorProfileState createState() {
    return UserTutorProfileState();
  }
}

class UserTutorProfileState extends State<UserTutorProfile> {
  UserModel? user;
  bool showForm = false;
  bool loading = true;
  Map<String, dynamic>? tutor;

  @override
  void initState() {
    UserModel.fromLocalStorage().then((usr) {
      setState(() {
        user = usr;
      });
      _getData();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return body();
  }

  Widget body() {
    if (loading) {
      return Center(
        child: Scaffold(
          appBar: AppBar(
            leading: AppBarBackButton(),
          ),
          body: const LoadingIndicator(),
        ),
      );
    } else {
      if (showForm || tutor == null) {
        return DefaultDataForm(
          dataModel: Entity.tutor,
          title: 'Modifier mon profil Tuteur/Parent',
          defaultData: {
            'user_id': user?.id,
            'email': user?.email,
            'phone': user?.phone
          },
          data: tutor,
          onSaved: (value) {},
        );
      } else {
        return Scaffold(
          body: TutorDetails(tutor: tutor!),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              setState(() {
                showForm = true;
              });
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.edit),
          ),
        );
      }
    }
  }

  _getData() async {
    setState(() {
      loading = true;
    });
    await MasterCrudModel.post('/auth/user/profile/${Entity.tutor}')
        .then((t) {
      if (t != null && t['id'] != null) {
        setState(() {
          tutor = t;
        });
      }
    });
    setState(() {
      loading = false;
    });
  }
}
