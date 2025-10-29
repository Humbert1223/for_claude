import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:novacole/components/permission_widgets.dart';
import 'package:novacole/components/sub_menu_item.dart';
import 'package:novacole/pages/admin/activities/assessment_page.dart';
import 'package:novacole/pages/admin/activities/exam_page.dart';
import 'package:novacole/pages/admin/activities/registration_page.dart';
import 'package:novacole/pages/leave_page.dart';
import 'package:novacole/pages/marks_page.dart';
import 'package:novacole/pages/presence_page.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/permission_utils.dart';

class ActivitiesSubmenuPage extends StatefulWidget {
  const ActivitiesSubmenuPage({super.key});

  @override
  ActivitiesSubmenuPageState createState() {
    return ActivitiesSubmenuPageState();
  }
}

class ActivitiesSubmenuPageState extends State<ActivitiesSubmenuPage> {
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
          'Activités',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DisableIfNoPermission(
                permission: PermissionName.viewAny(Entity.registration),
                child: SubMenuWidget(
                  icon: Icons.app_registration_sharp,
                  title: 'Inscription',
                  subtitle: 'Inscription des nouveaux et anciens élèves',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const RegistrationPage()),
                    );
                  },
                ),
              ),
              DisableIfNoPermission(
                permission: PermissionName.viewAny(Entity.assessment),
                child: SubMenuWidget(
                  icon: Icons.assessment_outlined,
                  title: 'Évaluations',
                  subtitle: 'Programmer, démarrer et clôturer les intérrogations, devoirs, et compositions',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const AssessmentPage()),
                    );
                  },
                ),
              ),
              DisableIfNoPermission(
                permission: PermissionName.viewAny(Entity.exam),
                child: SubMenuWidget(
                  icon: Icons.assessment_outlined,
                  title: 'Examens blancs',
                  subtitle: 'Examen blanc, évaluation inter-établissements...',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ExamPage()),
                    );
                  },
                ),
              ),
              DisableIfNoPermission(
                permission: PermissionName.viewAny(Entity.mark),
                child: SubMenuWidget(
                  icon: FontAwesomeIcons.a,
                  title: 'Saisie des Notes',
                  subtitle: 'Saisir les notes des évaluations',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const MarksPage()),
                    );
                  },
                ),
              ),
              DisableIfNoPermission(
                permission: PermissionName.viewAny(Entity.irregularity),
                child: SubMenuWidget(
                  icon: FontAwesomeIcons.personCircleCheck,
                  title: 'Présences',
                  subtitle: 'Liste de présence',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const PresencePage()),
                    );
                  },
                ),
              ),
              DisableIfNoPermission(
                permission: PermissionName.viewAny(Entity.leave),
                child: SubMenuWidget(
                  icon: FontAwesomeIcons.personWalkingDashedLineArrowRight,
                  title: 'Demandes de permissions',
                  subtitle: 'Permissions de sortie, départs...',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const LeavePage()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}