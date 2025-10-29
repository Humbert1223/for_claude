import 'package:flutter/material.dart';
import 'package:novacole/components/permission_widgets.dart';
import 'package:novacole/pages/admin/dashboard/components/panel_card.dart';
import 'package:novacole/pages/admin/dashboard/components/weekly_cash_trend.dart';
import 'package:novacole/pages/components/home/home_today_event.dart';
import 'package:novacole/pages/components/home/home_unsynced_mark_widget.dart';
import 'package:novacole/pages/components/home/teacher_assessment_mark_progress.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/permission_utils.dart';

class AdminWelcomePage extends StatefulWidget {
  const AdminWelcomePage({super.key});

  @override
  AdminWelcomePageState createState() {
    return AdminWelcomePageState();
  }
}

class AdminWelcomePageState extends State<AdminWelcomePage> {
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
    return Column(
      children: [
        AnalyticPanelBar(),
        PermissionGuard(
          showFallback: false,
          permission: PermissionName.create(Entity.mark),
          child: HomeUnsyncedMarkWidget(),
        ),
        TeacherAssessmentMarkProgress(),
        PermissionGuard(
          showFallback: false,
          permission: PermissionName.viewAny(Entity.payment),
          child: WeeklyCashTrend(),
        ),
        SizedBox(height: 20),
        HomeTodayEvent(),
        SizedBox(height: 40),
      ],
    );
  }
}
