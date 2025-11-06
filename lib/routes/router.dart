import 'package:flutter/material.dart';
import 'package:novacole/pages/admin/activities/registration_page.dart';
import 'package:novacole/pages/admin/actors/student_list_page.dart';
import 'package:novacole/pages/admin/actors/teacher_list_page.dart';
import 'package:novacole/pages/admin/actors/tutor_list_page.dart';
import 'package:novacole/pages/auth/login_page.dart';
import 'package:novacole/pages/auth/profile_page.dart';
import 'package:novacole/pages/auth/register_page.dart';
import 'package:novacole/pages/classe_page.dart';
import 'package:novacole/pages/home_page.dart';
import 'package:novacole/pages/leave_page.dart';
import 'package:novacole/pages/marks_page.dart';
import 'package:novacole/pages/notification_details.dart';
import 'package:novacole/pages/notification_page.dart';
import 'package:novacole/pages/planing_page.dart';
import 'package:novacole/pages/presence_page.dart';
import 'package:novacole/pages/splash_screen.dart';

Map<String, Widget Function(BuildContext)> routes = {
  '/': (context) => const SplashScreen(),
  '/home': (context) => const HomeScreen(),
  '/login': (context) =>  const LoginPage(),
  '/register': (context) =>  const RegisterPage(),
  '/profile': (context) =>  const ProfilePage(),
  '/presence': (context) =>  const PresencePage(),
  '/notes': (context) =>  const MarksPage(),
  '/planing': (context) =>  const PlaningPage(),
  '/leave': (context) =>  const LeavePage(),
  '/students': (context) =>  const StudentListPage(),
  '/registrations': (context) =>  const RegistrationPage(),
  '/teachers': (context) =>  const TeacherListPage(),
  '/classes': (context) =>  const ClasseListPage(),
  '/tutors': (context) =>  const TutorListPage(),
  '/notification': (context) =>  const NotificationDetails(),
  '/notifications': (context) =>  const NotificationPage(),
};
