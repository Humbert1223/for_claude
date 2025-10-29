import 'package:flutter/material.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/pages/components/home/admin_welcome.dart';
import 'package:novacole/pages/auth/user_preferences_page.dart';
import 'package:novacole/pages/components/home/home_search_widget.dart';
import 'package:novacole/pages/components/home/home_slider.dart';
import 'package:novacole/pages/components/home/teacher_welcome_page.dart';
import 'package:novacole/pages/components/home/tutor_welcome_page.dart';
import 'package:novacole/pages/components/home/user_intro.dart';
import 'package:novacole/pages/global_search_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  WelcomePageState createState() => WelcomePageState();
}

class WelcomePageState extends State<WelcomePage> {
  UserModel? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await UserModel.fromLocalStorage();
    if (mounted) {
      setState(() {
        _user = user;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor.withValues(alpha:0.02),
            Colors.white,
          ],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: _loadUser,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const UserIntro(),
              const SizedBox(height: 20),
              HomeSearchWidget(
                onSearch: (term) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => GlobalSearchPage(term: term),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const HomeSlider(),
              _buildAcademicWarning(),
              const SizedBox(height: 24),
              _loading ? _buildLoadingIndicator() : _renderDashboard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _renderDashboard() {
    switch (_user?.accountType) {
      case 'admin':
      case 'staff':
        return const AdminWelcomePage();
      case 'teacher':
        return const TeacherWelcomePage();
      case 'tutor':
        return const TutorWelcomePage();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAcademicWarning() {
    if (_user == null ||
        _user?.academic != null ||
        (_user?.schools ?? []).isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 24, left: 16, right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade50,
            Colors.orange.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha:0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const SimpleDialog(
                children: [UserAcademicSelectForm()],
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 48,
                    color: Colors.amber.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Veuillez sélectionner une année scolaire",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.amber.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Appuyez pour configurer",
                  style: TextStyle(
                    color: Colors.amber.shade700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}