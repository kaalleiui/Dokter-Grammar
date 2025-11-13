class Answer {
  final String question;
  final String selectedAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String explanation;

  Answer({
    required this.question,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.explanation,
  });

  // Factory constructor for creating from JSON
  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      question: json['question'] as String,
      selectedAnswer: json['selectedAnswer'] as String,
      correctAnswer: json['correctAnswer'] as String,
      isCorrect: json['isCorrect'] as bool,
      explanation: json['explanation'] as String,
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'selectedAnswer': selectedAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
      'explanation': explanation,
    };
  }
}
