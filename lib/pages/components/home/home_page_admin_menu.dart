import 'package:flutter/material.dart';
import 'package:novacole/components/permission_widgets.dart';
import 'package:novacole/pages/admin/actors/student_list_page.dart';
import 'package:novacole/pages/admin/actors/teacher_list_page.dart';
import 'package:novacole/pages/admin/actors/tutor_list_page.dart';
import 'package:novacole/pages/admin/reports/admin_report_page.dart';
import 'package:novacole/pages/admin/submenu/activities_submenu.dart';
import 'package:novacole/pages/admin/submenu/authorisation_submenu.dart';
import 'package:novacole/pages/admin/submenu/config_submenu.dart';
import 'package:novacole/pages/admin/submenu/dashboard_submenu.dart';
import 'package:novacole/pages/admin/submenu/finances_submenu.dart';
import 'package:novacole/pages/admin/submenu/informations_submenu.dart';
import 'package:novacole/pages/classe_page.dart';
import 'package:novacole/pages/components/home/home_menu_widget.dart';
import 'package:novacole/pages/library_list_page.dart';
import 'package:novacole/pages/quiz/quiz_home_page.dart';
import 'package:novacole/pages/suggestion_page.dart';
import 'package:novacole/utils/constants.dart';
import 'package:novacole/utils/permission_utils.dart';

class HomePageAdminMenu extends StatelessWidget {
  const HomePageAdminMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      primary: false,
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(vertical: 40.0),
      children: [
        HomeMenuWidget(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return const DashboardSubmenuPage();
                },
              ),
            );
          },
          image: Image.asset(
            "assets/images/menus/dashboard.png",
            height: 70,
          ),
          title: "Dashboard",
        ),
        DisableIfNoPermission(
          permission: PermissionName.viewAny(Entity.classe),
          child: HomeMenuWidget(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ClasseListPage()),
              );
            },
            image: Image.asset(
              "assets/images/menus/classroom.png",
              height: 70,
            ),
            title: "Classes",
          ),
        ),
        PermissionGuard(
          anyOf: [
            PermissionName.viewAny(Entity.registration),
            PermissionName.viewAny(Entity.assessment),
            PermissionName.viewAny(Entity.exam),
            PermissionName.viewAny(Entity.mark),
            PermissionName.viewAny(Entity.irregularity),
            PermissionName.viewAny(Entity.leave),
          ],
          showFallback: true,
          child: HomeMenuWidget(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const ActivitiesSubmenuPage();
                  },
                ),
              );
            },
            title: "Activités",
            image: Image.asset(
              "assets/images/menus/activities.png",
              height: 70,
            ),
          ),
        ),
        DisableIfNoPermission(
          permission: PermissionName.viewAny(Entity.student),
          child: HomeMenuWidget(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const StudentListPage();
                  },
                ),
              );
            },
            image: Image.asset(
              "assets/images/menus/students.png",
              height: 70,
            ),
            title: "Élèves",
          ),
        ),
        DisableIfNoPermission(
          permission: PermissionName.viewAny(Entity.tutor),
          child: HomeMenuWidget(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TutorListPage(),
                ),
              );
            },
            image: Image.asset(
              "assets/images/menus/parents.png",
              height: 70,
            ),
            title: "Parents",
          ),
        ),
        DisableIfNoPermission(
          permission: PermissionName.viewAny(Entity.teacher),
          child: HomeMenuWidget(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const TeacherListPage();
                  },
                ),
              );
            },
            image: Image.asset(
              "assets/images/menus/teacher.png",
              height: 70,
            ),
            title: "Enseignants",
          ),
        ),
        PermissionGuard(
          showFallback: true,
          anyOf: [
            PermissionName.viewAny(Entity.paymentRequest),
            PermissionName.viewAny(Entity.operation),
            PermissionName.viewAny(Entity.payment),
          ],
          child: HomeMenuWidget(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const FinancesSubmenuPage();
                  },
                ),
              );
            },
            image: Image.asset(
              "assets/images/menus/finance.png",
              height: 70,
            ),
            title: "Finances",
          ),
        ),
        PermissionGuard(
          showFallback: true,
          anyOf: [
            PermissionName.viewAny(Entity.post),
            PermissionName.viewAny(Entity.event),
          ],
          child: HomeMenuWidget(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const InformationSubmenuPage();
                  },
                ),
              );
            },
            image: Image.asset(
              "assets/images/menus/notification.png",
              height: 70,
            ),
            title: "Information",
          ),
        ),
        PermissionGuard(
          showFallback: true,
          anyOf: [
            PermissionName.viewAny(Entity.academic),
            PermissionName.viewAny(Entity.classe),
            PermissionName.viewAny(Entity.paymentMethod),
            PermissionName.viewAny(Entity.expense),
            PermissionName.viewAny(Entity.period),
            PermissionName.viewAny(Entity.tuition),
          ],
          child: HomeMenuWidget(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const ConfigSubmenuPage();
                  },
                ),
              );
            },
            image: Image.asset(
              "assets/images/menus/setting.png",
              height: 70,
            ),
            title: "Config.",
          ),
        ),
        PermissionGuard(
          showFallback: true,
          anyOf: [
            PermissionName.viewAny(Entity.user),
            PermissionName.viewAny(Entity.role),
            PermissionName.viewAny(Entity.permission)
          ],
          child: HomeMenuWidget(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const AuthorisationSubmenuPage();
                  },
                ),
              );
            },
            image: Image.asset(
              "assets/images/menus/auth.png",
              height: 70,
            ),
            title: "Sécurité",
          ),
        ),
        HomeMenuWidget(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminReportPage(),
              ),
            );
          },
          image: Image.asset(
            "assets/images/menus/reports.png",
            height: 70,
          ),
          title: "Rapports & États",
        ),
        HomeMenuWidget(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SuggestionPage(),
              ),
            );
          },
          image: Image.asset(
            "assets/images/menus/suggestion.png",
            height: 70,
          ),
          title: "Boite à Suggestion",
        ),
        HomeMenuWidget(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LibraryListPage(),
              ),
            );
          },
          image: Image.asset(
            "assets/images/menus/library.png",
            height: 70,
          ),
          title: "BIBLIOTHÈQUE",
        ),
        HomeMenuWidget(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const QuizEntryPoint(),
              ),
            );
          },
          image: Image.asset(
            "assets/images/menus/quiz.png",
            height: 70,
          ),
          title: "JEU DE QUIZ",
        ),
      ],
    );
  }
}
