import 'package:flutter/material.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/components/home/home_search_widget.dart';
import 'package:novacole/pages/components/search/classe_search_list.dart';
import 'package:novacole/pages/components/search/student_search_list.dart';
import 'package:novacole/pages/components/search/teacher_search_list.dart';
import 'package:novacole/pages/components/search/tutor_search_list.dart';

class GlobalSearchPage extends StatefulWidget {
  final String? term;

  const GlobalSearchPage({super.key, this.term});

  @override
  GlobalSearchPageState createState() {
    return GlobalSearchPageState();
  }
}

class GlobalSearchPageState extends State<GlobalSearchPage> {
  String? term;
  UserModel? user;

  @override
  void initState() {
    UserModel.fromLocalStorage().then((value) {
      setState(() {
        user = value;
      });
    });
    setState(() {
      term = widget.term;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recherche"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              HomeSearchWidget(
                value: term,
                onSearch: (query) {
                  setState(() {
                    term = query;
                  });
                },
              ),
              const SizedBox(height: 20),
              StudentSearchResultList(term: term),
              if(user != null && ['admin', 'staff'].contains(user!.accountType))
              TeacherSearchResultList(term: term),
              if(user != null && ['admin', 'staff', 'teacher'].contains(user!.accountType))
              TutorSearchResultList(term: term),
              if(user != null && ['admin', 'staff', 'teacher'].contains(user!.accountType))
              ClasseSearchResultList(term: term),
            ],
          ),
        ),
      ),
    );
  }
}
