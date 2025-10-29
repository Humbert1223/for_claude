import 'package:flutter/material.dart';
import 'package:novacole/pages/admin/dashboard/components/panel_card.dart';
import 'package:novacole/pages/components/home/home_today_event.dart';

class TutorWelcomePage extends StatefulWidget {
  const TutorWelcomePage({super.key});

  @override
  TutorWelcomePageState createState() {
    return TutorWelcomePageState();
  }
}

class TutorWelcomePageState extends State<TutorWelcomePage> {
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
        TutorWelcomePanelBar(),
        SizedBox(height: 20),
        HomeTodayEvent(),
        SizedBox(height: 40),
      ],
    );
  }
}