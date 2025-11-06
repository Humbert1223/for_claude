import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:novacole/pages/quiz/game_widgets.dart';
import 'package:novacole/pages/quiz/quiz_game.dart';
import 'package:novacole/pages/quiz/quiz_setting_page.dart';
import 'package:novacole/pages/quiz/quiz_scores_page.dart';
import 'package:novacole/pages/quiz/achievements_page.dart';
import 'package:novacole/pages/quiz/services/quiz_user_service.dart';
import 'package:novacole/pages/quiz/models/quiz_user_model.dart';
import 'package:novacole/pages/quiz/quiz_user_selection_page.dart';
import 'package:novacole/pages/quiz/achievement_system.dart';

class QuizEntryPoint extends StatefulWidget {
  const QuizEntryPoint({super.key});

  @override
  State<QuizEntryPoint> createState() => _QuizEntryPointState();
}

class _QuizEntryPointState extends State<QuizEntryPoint> {
  QuizUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    setState(() {
      _currentUser = QuizUserService.getCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _currentUser != null
        ? QuizHomePage()
        : QuizUserSelectionPage();
  }
}

class QuizHomePage extends StatefulWidget {
  const QuizHomePage({super.key});

  @override
  QuizHomePageState createState() => QuizHomePageState();
}

class QuizHomePageState extends State<QuizHomePage> {
  bool _isVolumeOn = true;
  QuizUser? currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    setState(() {
      currentUser = QuizUserService.getCurrentUser();
      if (currentUser != null) {
        _isVolumeOn = currentUser!.preferences?['isSoundEnabled'] ?? true;
      }
    });
  }

  Future<void> _saveVolumeState() async {
    if (currentUser != null) {
      currentUser!.preferences ??= {};
      currentUser!.preferences!['isSoundEnabled'] = _isVolumeOn;
      await QuizUserService.updateUser(currentUser!);
    }
  }

  bool _hasRequiredSettings() {
    if (currentUser == null) return false;
    return currentUser!.preferences?['level'] != null &&
        currentUser!.preferences?['discipline'] != null;
  }

  @override
  Widget build(BuildContext context) {
    final unlockedCount = currentUser != null
        ? AchievementSystem.getUnlockedCount(currentUser!)
        : 0;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/quiz_background.jpeg"),
              fit: BoxFit.cover,
              opacity: 0.3,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // User info + badges
                  if (currentUser != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: ModernUserCard(
                        userName: currentUser!.name,
                        gamesCount: currentUser!.scores?.length ?? 0,
                        achievementsCount: unlockedCount,
                      ),
                    ),
                  const SizedBox(height: 20),
                  Container(
                    height: 180,
                    width: 400,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/quiz.png'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      children: [
                        ModernGameButton(
                          child: const ListTile(
                            leading: Icon(
                              Icons.flag,
                              color: Colors.white,
                            ),
                            title: Text(
                              "DÉMARRER",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          onPressed: () {
                            if (_hasRequiredSettings()) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const QuizGamePage(),
                                ),
                              );
                            } else {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const QuizSettingPage(),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        ModernGameButton(
                          child:  ListTile(
                            leading: Icon(
                              Icons.emoji_events,
                              color: Colors.white,
                              size: 30,
                            ),
                            title: Text(
                              "SUCCÈS",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AchievementsPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        ModernGameButton(
                          child:  ListTile(
                            leading: Icon(
                              Icons.list,
                              color: Colors.white,
                              size: 30,
                            ),
                            title: Text(
                              "SCORES",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const QuizScoresPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        ModernGameButton(
                          child: const ListTile(
                            leading: Icon(
                              Icons.settings,
                              color: Colors.white,
                            ),
                            title: Text(
                              "CONFIGURATION",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const QuizSettingPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButtons(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFloatingActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ModernFloatingButton(
            color: Colors.red,
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: FontAwesomeIcons.shareFromSquare,
          ),
          ModernFloatingButton(
            onPressed: () {
              setState(() {
                _isVolumeOn = !_isVolumeOn;
                _saveVolumeState();
              });
            },
            icon: _isVolumeOn
                ? FontAwesomeIcons.volumeHigh
                : FontAwesomeIcons.volumeXmark,
          ),
        ],
      ),
    );
  }
}