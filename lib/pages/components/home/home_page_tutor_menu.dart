import 'package:flutter/material.dart';
import 'package:novacole/pages/announces/announces_pages.dart';
import 'package:novacole/pages/components/home/home_menu_widget.dart';
import 'package:novacole/pages/components/tutors_details/payment_request_page.dart';
import 'package:novacole/pages/event_page.dart';
import 'package:novacole/pages/library_list_page.dart';
import 'package:novacole/pages/quiz/quiz_home_page.dart';
import 'package:novacole/pages/suggestion_page.dart';
import 'package:novacole/pages/tutor_student_page.dart';

class HomePageTutorMenu extends StatelessWidget {
  const HomePageTutorMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> menuItems = [
      HomeMenuWidget(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TutorStudentPage(),
            ),
          );
        },
        image: Image.asset(
          "assets/images/menus/students.png",
          height: 70,
        ),
        title: "Enfants",
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
        title: "Événements",
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
              builder: (context) => const TutorPaymentRequestPage(),
            ),
          );
        },
        image: Image.asset(
          "assets/images/menus/payment_request.png",
          height: 70,
        ),
        title: "Demandes de paiment",
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
