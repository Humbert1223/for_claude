import 'package:flutter/material.dart';
import 'package:novacole/pages/admin/actors/student_list_page.dart';
import 'package:novacole/pages/admin/reports/report_classe_filter.dart';
import 'package:novacole/pages/announces/announces_pages.dart';
import 'package:novacole/pages/classe_page.dart';
import 'package:novacole/pages/components/home/home_menu_widget.dart';
import 'package:novacole/pages/components/teacher_details/documents/teacher_classe_report_download_page.dart';
import 'package:novacole/pages/components/teacher_details/submenus/mark_submenu.dart';
import 'package:novacole/pages/components/teacher_details/teacher_assessment_tracking_list.dart';
import 'package:novacole/pages/event_page.dart';
import 'package:novacole/pages/leave_page.dart';
import 'package:novacole/pages/library_list_page.dart';
import 'package:novacole/pages/presence_page.dart';
import 'package:novacole/pages/quiz/quiz_home_page.dart';
import 'package:novacole/pages/suggestion_page.dart';

class HomePageTeacherMenu extends StatelessWidget {
  const HomePageTeacherMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> menuItems =  [
      HomeMenuWidget(
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
      HomeMenuWidget(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PresencePage()),
          );
        },
        title: "Présence",
        image: Image.asset(
          "assets/images/menus/presence.png",
          height: 70,
        ),
      ),
      HomeMenuWidget(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TeacherMarkSubMenuPage()),
          );
        },
        image: Image.asset(
          "assets/images/menus/mark.png",
          height: 70,
        ),
        title: "Notes",
      ),
      HomeMenuWidget(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StudentListPage()),
          );
        },
        image: Image.asset(
          "assets/images/menus/students.png",
          height: 70,
        ),
        title: "Élèves",
      ),
      HomeMenuWidget(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LeavePage()),
          );
        },
        image: Image.asset(
          "assets/images/menus/leave.png",
          height: 70,
        ),
        title: "Départ",
      ),
      HomeMenuWidget(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AnnouncesPage()),
          );
        },
        image: Image.asset(
          "assets/images/menus/notification.png",
          height: 70,
        ),
        title: "Annonces",
      ),
      HomeMenuWidget(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EventPage(),
            ),
          );
        },
        image: Image.asset(
          "assets/images/menus/event.png",
          height: 70,
        ),
        title: "Évenements",
      ),
      HomeMenuWidget(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return const TeacherAssessmentTrackingList();
              },
            ),
          );
        },
        image: Image.asset(
          "assets/images/menus/dashboard.png",
          height: 70,
        ),
        title: "Suivi des notes",
      ),
      HomeMenuWidget(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ReportClasseFilterSelector(
                degree: null,
                onSelect: (filters, classe) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return TeacherClasseReportDownloadPage(
                          classe: classe,
                          filters: filters,
                        );
                      },
                    ),
                  );
                },
              ),
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
    ];
    return buildModernMenuGrid(context, menuItems);
  }

  Widget buildModernMenuGrid(BuildContext context, List<Widget> menuItems) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
            theme.colorScheme.surface,
            theme.colorScheme.surface.withValues(alpha: 0.95),
          ]
              : [
            Colors.grey.shade50,
            Colors.white,
          ],
        ),
      ),
      child: GridView.count(
        primary: false,
        shrinkWrap: true,
        crossAxisCount: 3,
        padding: const EdgeInsets.fromLTRB(12, 40, 12, 40),
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
        children: menuItems,
      ),
    );
  }
}
