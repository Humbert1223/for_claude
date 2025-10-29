import 'package:flutter/material.dart';
import 'package:novacole/components/data_models/default_data_form.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/admin/actors/teacher_details.dart';
import 'package:novacole/utils/constants.dart';

class UserTeacherProfile extends StatefulWidget {
  const UserTeacherProfile({super.key});

  @override
  UserTeacherProfileState createState() {
    return UserTeacherProfileState();
  }
}

class UserTeacherProfileState extends State<UserTeacherProfile> {
  UserModel? user;
  bool showForm = false;
  Map<String, dynamic>? teacher;

  bool loading = true;

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
          appBar: AppBar(),
          body: const LoadingIndicator(),
        ),
      );
    } else {
      if (showForm || teacher == null) {
        return DefaultDataForm(
          dataModel: Entity.teacher,
          title: 'Modifier mon profil Enseignant',
          defaultData: {
            'user_id': user?.id,
            'email': user?.email,
            'phone': user?.phone
          },
          data: teacher,
          onSaved: (value) {
            setState(() {
              showForm = false;
            });
          },
        );
      } else {
        return Scaffold(
          body: TeacherDetails(teacher: teacher!),
          floatingActionButton: FloatingActionButton(
            onPressed: (){
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

  _getData() async{
    setState(() {
      loading = true;
    });
    await MasterCrudModel.post('/auth/user/profile/${Entity.teacher}').then((teacher) {
      if (teacher != null && teacher['id'] != null) {
        setState(() {
          teacher = teacher;
        });
      }
    });
    setState(() {
      loading = false;
    });
  }
}
