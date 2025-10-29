import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor:
                                Theme.of(context).colorScheme.primary,
                                child: Text(
                                  currentUser!.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentUser!.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${currentUser!.scores?.length ?? 0} parties',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (unlockedCount > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.amber,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.emoji_events,
                                        color: Colors.amber,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$unlockedCount',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
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
                        QuizGameButton(
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
                        QuizGameButton(
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
                        QuizGameButton(
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
                        QuizGameButton(
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
          FloatingActionButton(
            heroTag: "backBtn",
            onPressed: () {
              Navigator.pop(context);
            },
            child: const RotatedBox(
              quarterTurns: 2,
              child: Icon(
                FontAwesomeIcons.shareFromSquare,
                color: Colors.red,
              ),
            ),
          ),
          FloatingActionButton(
            heroTag: 'volumeBtn',
            onPressed: () {
              setState(() {
                _isVolumeOn = !_isVolumeOn;
                _saveVolumeState();
              });
            },
            child: Icon(
              _isVolumeOn
                  ? FontAwesomeIcons.volumeHigh
                  : FontAwesomeIcons.volumeXmark,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class QuizGameButton extends StatelessWidget {
  final Widget? child;
  final VoidCallback onPressed;
  final Widget? icon;

  const QuizGameButton({
    super.key,
    this.child,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade600,
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: Colors.grey.shade300,
              offset: const Offset(-5, 0),
            ),
            BoxShadow(
              color: Colors.grey.shade300,
              offset: const Offset(5, 0),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: child,
        ),
      ),
    );
  }
}