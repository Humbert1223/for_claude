import 'package:flutter/material.dart';
import 'package:novacole/pages/quiz/game_widgets.dart';
import 'package:novacole/pages/quiz/question.dart';
import 'package:novacole/pages/quiz/quiz_game.dart';
import 'package:novacole/pages/quiz/quiz_home_page.dart';

class QuizGameOverPage extends StatelessWidget {
  final String levelId;
  final String? serieId;
  final String disciplineId;
  final bool useTicker;
  final Score score;

  const QuizGameOverPage({
    super.key,
    required this.levelId,
    this.serieId,
    required this.disciplineId,
    this.useTicker = true,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(15.0),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/quiz_background.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: ModernScoreCard(
            score: score.value,
            total: score.total,
            rating: (score.value * 5.0) / score.total,
            onQuit: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => QuizEntryPoint()),
                  (route) => false,
            ),
            onPlayAgain: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const QuizGamePage()),
            ),
          ),
        ),
      ),
    );
  }
}
