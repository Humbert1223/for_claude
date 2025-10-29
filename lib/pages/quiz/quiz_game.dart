import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:novacole/components/empty_page.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/pages/quiz/models/quiz_user_model.dart';
import 'package:novacole/pages/quiz/question.dart';
import 'package:novacole/pages/quiz/quiz_game_over_page.dart';
import 'package:novacole/pages/quiz/quiz_setting_page.dart';
import 'package:novacole/pages/quiz/services/quiz_user_service.dart';

class QuizGamePage extends StatefulWidget {
  const QuizGamePage({super.key});

  @override
  QuizGamePageState createState() => QuizGamePageState();
}

class QuizGamePageState extends State<QuizGamePage> {
  final CountDownController _countDownController = CountDownController();
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  bool _showAnswer = false;
  int _selectedAnswerIndex = -1;
  int _score = 0;
  int _duration = 30;
  bool isLoading = true;
  bool _isVolumeOn = false;
  bool _isTimerEnabled = false;

  Map<String, dynamic> selectedLevel = {};
  Map<String, dynamic>? selectedSeries = {};
  Map<String, dynamic> selectedDiscipline = {};
  List<Map<String, dynamic>> selectedChapters = [];
  QuizUser? currentUser;

  void _loadPreferences() {
    currentUser = QuizUserService.getCurrentUser();
    if (currentUser == null) return;

    setState(() {
      if (currentUser!.preferences?[PreferenceKeys.level] != null) {
        selectedLevel = Map<String, dynamic>.from(
          currentUser!.preferences![PreferenceKeys.level],
        );
      }
      if (currentUser!.preferences?[PreferenceKeys.series] != null) {
        selectedSeries = Map<String, dynamic>.from(
          currentUser!.preferences![PreferenceKeys.series],
        );
      }
      if (currentUser!.preferences?[PreferenceKeys.discipline] != null) {
        selectedDiscipline = Map<String, dynamic>.from(
          currentUser!.preferences![PreferenceKeys.discipline],
        );
      }
      if (currentUser!.preferences?[PreferenceKeys.chapters] != null) {
        selectedChapters = List<Map<String, dynamic>>.from(
          currentUser!.preferences![PreferenceKeys.chapters],
        );
      }
      _isTimerEnabled =
          currentUser!.preferences?[PreferenceKeys.isTimerEnabled] ?? false;
      _isVolumeOn =
          currentUser!.preferences?[PreferenceKeys.isSoundEnabled] ?? false;
    });
  }

  void _initializeGame() {
    _loadPreferences();
    setState(() {
      _questions = [];
      _currentQuestionIndex = 0;
      _score = 0;
      _duration = 30;
      _showAnswer = false;
      _selectedAnswerIndex = -1;
    });
    _fetchQuestions().then((_) {
      if (_questions.isNotEmpty && _isTimerEnabled) {
        Future.delayed(const Duration(seconds: 1), () {
          if (_isVolumeOn) {
            FlameAudio.bgm.play('quiz_ticks.mp3', volume: 0.5);
          }
          _countDownController.start();
        });
      }
    });
  }

  @override
  void initState() {
    _initializeGame();
    super.initState();
  }

  @override
  void dispose() {
    FlameAudio.bgm.stop();
    super.dispose();
  }

  void _checkAnswer(String selectedAnswer, int index) {
    if (_showAnswer) {
      return;
    }
    FlameAudio.bgm.stop();
    _countDownController.pause();
    _selectedAnswerIndex = index;
    String correctAnswer = _questions[_currentQuestionIndex].correctAnswer
        .toLowerCase();
    if (selectedAnswer.toLowerCase().trim() == correctAnswer.trim()) {
      if (_isVolumeOn) {
        FlameAudio.play("quiz_correct_answer.mp3");
      }
      setState(() => _score++);
    } else if (index >= 0) {
      if (_isVolumeOn) {
        FlameAudio.play("quiz_wrong_answer.mp3");
      }
    }
    setState(() => _showAnswer = true);
    if (_currentQuestionIndex == _questions.length - 1 &&
        _isTimerEnabled &&
        _countDownController.isStarted.value) {
      _countDownController.reset();
      Future.delayed(const Duration(seconds: 3), _showGameOverDialog);
    } else {
      Future.delayed(const Duration(seconds: 3), _moveToNextQuestion);
    }
  }

  void _moveToNextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _showAnswer = false;
        _selectedAnswerIndex = -1;
        _currentQuestionIndex++;
        _duration = 30;
      });
      if (_isTimerEnabled == true) {
        if (_isVolumeOn) {
          FlameAudio.bgm.play('quiz_ticks.mp3', volume: 0.5);
        }
        _countDownController.isStarted.value
            ? _countDownController.restart()
            : _countDownController.start();
      }
    } else {
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() {
    if (_isTimerEnabled == true) {
      _countDownController.reset();
      if (_isVolumeOn) {
        FlameAudio.play('quiz_level_complete.mp3');
      }
    }

    // Sauvegarder le score dans Hive
    if (currentUser != null) {
      final quizScore = QuizScore(
        levelId: selectedLevel['id'],
        serieId: selectedSeries?['id'],
        disciplineId: selectedDiscipline['id'],
        score: _score,
        totalQuestions: _questions.length,
        usedTimer: _isTimerEnabled,
        playedAt: DateTime.now(),
      );
      currentUser!.addScore(quizScore);
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return QuizGameOverPage(
            disciplineId: selectedDiscipline['id'],
            levelId: selectedLevel['id'],
            useTicker: _isTimerEnabled,
            serieId: selectedSeries?['id'],
            score: Score(total: _questions.length, value: _score),
          );
        },
      ),
    );
  }

  Future<void> _fetchQuestions() async {
    setState(() {
      isLoading = true;
    });
    List<Map<String, dynamic>> filters = [
      {'field': 'level_id', 'value': selectedLevel['id']},
      {'field': 'discipline_id', 'value': selectedDiscipline['id']},
      if (selectedChapters.isNotEmpty)
        {
          'field': 'chapter_id',
          'operator': 'in',
          'value': selectedChapters.map((e) => e['id']).toList(),
        },
      if (selectedSeries != null && selectedSeries?['id'] != null)
        {'field': 'serie_id', 'value': selectedSeries?['id']},
    ];
    try {
      final fetchedQuestions = await MasterCrudModel('qcm').search(
        paginate: '0',
        perPage: 20,
        query: {'randomize': 1},
        filters: filters,
      );
      setState(() {
        _questions.addAll(
          List.from(fetchedQuestions).map((el) {
            var options = List<String>.from(el['options']);
            options.shuffle();
            return Question(
              questionText: el['name'],
              options: options,
              correctAnswer: el['correct_answer'],
            );
          }).toList(),
        );
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildWidget() {
    if (isLoading) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingIndicator(),
          Text('Chargement des question...', textAlign: TextAlign.center),
        ],
      );
    } else {
      if (_questions.isNotEmpty) {
        return SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/quiz_background.jpeg'),
                  opacity: 0.1,
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_isTimerEnabled == true)
                    CircularCountDownTimer(
                      duration: _duration,
                      controller: _countDownController,
                      width: 70,
                      height: 70,
                      ringColor: Colors.grey[300]!,
                      ringGradient: null,
                      fillColor: const Color(0x4079a106),
                      fillGradient: null,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      backgroundGradient: null,
                      strokeWidth: 15.0,
                      strokeCap: StrokeCap.round,
                      textStyle: const TextStyle(
                        fontSize: 25.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textFormat: CountdownTextFormat.S,
                      isReverse: true,
                      isReverseAnimation: false,
                      isTimerTextShown: true,
                      autoStart: false,
                      onStart: () {},
                      onComplete: () {
                        FlameAudio.bgm.stop();
                        _checkAnswer('', -1);
                      },
                      onChange: (String timeStamp) {},
                      timeFormatterFunction:
                          (defaultFormatterFunction, duration) {
                            if (duration.inSeconds == 0) {
                              return "0";
                            } else {
                              return Function.apply(defaultFormatterFunction, [
                                duration,
                              ]);
                            }
                          },
                    ),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      _questions[_currentQuestionIndex].questionText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount:
                          _questions[_currentQuestionIndex].options.length,
                      itemBuilder: (context, index) {
                        String option =
                            _questions[_currentQuestionIndex].options[index];
                        bool isCorrectAnswer =
                            option.toLowerCase().trim() ==
                            _questions[_currentQuestionIndex].correctAnswer
                                .toLowerCase()
                                .trim();
                        return InkWell(
                          onTap: () => _checkAnswer(option, index),
                          child: AnimatedContainer(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.only(
                              left: 30,
                              top: 10,
                              bottom: 10,
                            ),
                            width: MediaQuery.of(context).size.width - 20,
                            decoration: BoxDecoration(
                              color: _showAnswer && isCorrectAnswer
                                  ? Colors.green.withValues(alpha: 0.5)
                                  : _showAnswer && _selectedAnswerIndex == index
                                  ? Colors.red.withValues(alpha: 0.5)
                                  : const Color(0x907E7E7E),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeInOut,
                            child: Text(
                              option,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        return const EmptyPage(
          icon: Icon(Icons.quiz_outlined, size: 70),
          sub: Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              "Aucune question pour l'instant",
              style: TextStyle(fontSize: 35),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/quiz_background.jpeg'),
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
        ),
        child: _buildWidget(),
      ),
    );
  }
}
