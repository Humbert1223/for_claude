
class Question {
  final String questionText;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswer,
  });
}

class Score {
  final int total;
  final int value;

  Score({required this.total, required this.value});
}
