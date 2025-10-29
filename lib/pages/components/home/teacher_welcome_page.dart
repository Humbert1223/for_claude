import 'package:flutter/material.dart';
import 'package:novacole/pages/admin/dashboard/components/panel_card.dart';
import 'package:novacole/pages/components/home/home_classe_lecture.dart';
import 'package:novacole/pages/components/home/home_today_event.dart';
import 'package:novacole/pages/components/home/home_unsynced_mark_widget.dart';
import 'package:novacole/pages/components/home/teacher_assessment_mark_progress.dart';

class TeacherWelcomePage extends StatefulWidget {
  const TeacherWelcomePage({super.key});

  @override
  TeacherWelcomePageState createState() {
    return TeacherWelcomePageState();
  }
}

class TeacherWelcomePageState extends State<TeacherWelcomePage> {
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
    return const Column(
      children: [
        SizedBox(height: 20),
        TeacherWelcomePanelBar(),
        HomeUnsyncedMarkWidget(),
        TeacherAssessmentMarkProgress(),
        HomeClasseLecture(),
        HomeTodayEvent(),
        SizedBox(height: 40),
      ],
    );
  }
}