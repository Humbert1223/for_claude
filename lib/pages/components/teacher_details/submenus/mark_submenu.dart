import 'package:flutter/material.dart';
import 'package:novacole/components/sub_menu_item.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/components/teacher_details/teacher_exam_list.dart';
import 'package:novacole/pages/marks_page.dart';

class TeacherMarkSubMenuPage extends StatefulWidget {
  const TeacherMarkSubMenuPage({super.key});

  @override
  TeacherMarkSubMenuPageState createState() {
    return TeacherMarkSubMenuPageState();
  }
}

class TeacherMarkSubMenuPageState extends State<TeacherMarkSubMenuPage> {
  UserModel? user;

  @override
  void initState() {
    super.initState();
    UserModel.fromLocalStorage().then((value) {
      setState(() {
        user = value;
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
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Saisie des notes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SubMenuWidget(
                icon: Icons.assessment_outlined,
                title: "Notes d'évaluation",
                subtitle: 'Interrogations, devoirs, compositions, etc.',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MarksPage(),
                    ),
                  );
                },
              ),
              SubMenuWidget(
                icon: Icons.assignment_turned_in_outlined,
                title: "Notes d'examens",
                subtitle: "Examens blancs, examens de fin d'année, etc.",
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TeacherExamList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}