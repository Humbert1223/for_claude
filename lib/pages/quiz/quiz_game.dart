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

class QuizGamePageState extends State<QuizGamePage>
    with TickerProviderStateMixin {
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

  // Animations
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _progressController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeGame();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );
  }

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
      if (_questions.isNotEmpty) {
        _slideController.forward();
        _scaleController.forward();
        _updateProgressAnimation();
        if (_isTimerEnabled) {
          Future.delayed(const Duration(seconds: 1), () {
            if (_isVolumeOn) {
              FlameAudio.bgm.play('quiz_ticks.mp3', volume: 0.5);
            }
            _countDownController.start();
          });
        }
      }
    });
  }

  void _updateProgressAnimation() {
    _progressController.reset();
    _progressController.animateTo(
      (_currentQuestionIndex + 1) / _questions.length,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    FlameAudio.bgm.stop();
    _slideController.dispose();
    _scaleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _checkAnswer(String selectedAnswer, int index) {
    if (_showAnswer) return;

    FlameAudio.bgm.stop();
    _countDownController.pause();
    _selectedAnswerIndex = index;

    String correctAnswer =
    _questions[_currentQuestionIndex].correctAnswer.toLowerCase();

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

      _slideController.reset();
      _scaleController.reset();
      _slideController.forward();
      _scaleController.forward();
      _updateProgressAnimation();

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
    setState(() => isLoading = true);

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
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(child: _buildWidget()),
      ),
    );
  }

  Widget _buildWidget() {
    if (isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const LoadingIndicator(),
          ),
          const SizedBox(height: 24),
          Text(
            'Chargement des questions...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Préparez-vous !',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      );
    }

    if (_questions.isEmpty) {
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

    return Column(
      children: [
        _buildHeader(),
        Expanded(child: _buildQuestionCard()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildScoreChip(),
              if (_isTimerEnabled) _buildTimer(),
              _buildProgressChip(),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _progressAnimation.value,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScoreChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade400,
            Colors.amber.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars, color: Colors.white, size: 20),
          const SizedBox(width: 6),
          Text(
            '$_score',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        '${_currentQuestionIndex + 1}/${_questions.length}',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildTimer() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircularCountDownTimer(
        duration: _duration,
        controller: _countDownController,
        width: 60,
        height: 60,
        ringColor: Colors.grey[300]!,
        fillColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Colors.white,
        strokeWidth: 6.0,
        strokeCap: StrokeCap.round,
        textStyle: TextStyle(
          fontSize: 20.0,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
        textFormat: CountdownTextFormat.S,
        isReverse: true,
        isReverseAnimation: false,
        isTimerTextShown: true,
        autoStart: false,
        onComplete: () {
          FlameAudio.bgm.stop();
          _checkAnswer('', -1);
        },
      ),
    );
  }

  Widget _buildQuestionCard() {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildQuestionContainer(),
                const SizedBox(height: 24),
                _buildOptionsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Question ${_currentQuestionIndex + 1}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _questions[_currentQuestionIndex].questionText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsList() {
    return Column(
      children: List.generate(
        _questions[_currentQuestionIndex].options.length,
            (index) => _buildOptionCard(index),
      ),
    );
  }

  Widget _buildOptionCard(int index) {
    String option = _questions[_currentQuestionIndex].options[index];
    bool isCorrectAnswer = option.toLowerCase().trim() ==
        _questions[_currentQuestionIndex].correctAnswer.toLowerCase().trim();
    bool isSelected = _selectedAnswerIndex == index;

    Color cardColor;
    if (_showAnswer && isCorrectAnswer) {
      cardColor = Colors.green;
    } else if (_showAnswer && isSelected && !isCorrectAnswer) {
      cardColor = Colors.red;
    } else {
      cardColor = Colors.white;
    }

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _showAnswer ? null : () => _checkAnswer(option, index),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _showAnswer && isCorrectAnswer
                      ? Colors.green.shade700
                      : _showAnswer && isSelected
                      ? Colors.red.shade700
                      : Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: cardColor == Colors.white
                        ? Colors.black.withValues(alpha: 0.05)
                        : cardColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _showAnswer && isCorrectAnswer
                          ? Colors.white
                          : _showAnswer && isSelected
                          ? Colors.white
                          : Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: _showAnswer && isCorrectAnswer
                          ? const Icon(Icons.check, color: Colors.green, size: 24)
                          : _showAnswer && isSelected
                          ? const Icon(Icons.close, color: Colors.red, size: 24)
                          : Text(
                        String.fromCharCode(65 + index),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: cardColor == Colors.white
                            ? Colors.black87
                            : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}