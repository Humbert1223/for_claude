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
    return GridView.count(
      crossAxisCount: 3,
      primary: false,
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(vertical: 40.0),
      children: [
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
      ],
    );
  }
}
