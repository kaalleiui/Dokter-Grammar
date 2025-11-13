class Question {
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });
}

class QuestionGeneratorService {
  // Mock questions for demonstration. In a real app, this would integrate with AI.
  final List<Question> _mockQuestions = [
    Question(
      questionText: 'What is the past tense of "go"?',
      options: ['went', 'gone', 'going', 'goes'],
      correctAnswer: 'went',
      explanation: 'The past tense of "go" is "went".',
    ),
    Question(
      questionText: 'Which article is used before a vowel sound?',
      options: ['a', 'an', 'the', 'none'],
      correctAnswer: 'an',
      explanation: '"An" is used before words starting with a vowel sound.',
    ),
    Question(
      questionText: 'Choose the correct preposition: "I live ___ Paris."',
      options: ['in', 'on', 'at', 'to'],
      correctAnswer: 'in',
      explanation: '"In" is used for cities.',
    ),
    Question(
      questionText: 'What does "vocabulary" mean?',
      options: ['Words known to a person', 'Grammar rules', 'Pronunciation', 'Writing skills'],
      correctAnswer: 'Words known to a person',
      explanation: 'Vocabulary refers to the set of words used in a language.',
    ),
    // Add more questions as needed to reach 10-20
    Question(
      questionText: 'What is the present continuous of "eat"?',
      options: ['eating', 'ate', 'eaten', 'eats'],
      correctAnswer: 'eating',
      explanation: 'Present continuous is formed by "is/are + verb-ing".',
    ),
    Question(
      questionText: 'Which sentence is correct?',
      options: ['He go to school.', 'He goes to school.', 'He going to school.', 'He went to school.'],
      correctAnswer: 'He goes to school.',
      explanation: 'Third person singular uses "goes".',
    ),
    Question(
      questionText: 'What is a synonym for "happy"?',
      options: ['sad', 'joyful', 'angry', 'tired'],
      correctAnswer: 'joyful',
      explanation: 'Joyful means feeling or expressing great pleasure.',
    ),
    Question(
      questionText: 'Choose the correct form: "She ___ a book."',
      options: ['read', 'reads', 'reading', 'readed'],
      correctAnswer: 'reads',
      explanation: 'Third person singular present tense.',
    ),
    Question(
      questionText: 'What is the plural of "child"?',
      options: ['childs', 'children', 'childes', 'childrens'],
      correctAnswer: 'children',
      explanation: '"Child" has an irregular plural "children".',
    ),
    Question(
      questionText: 'Which word is a preposition?',
      options: ['run', 'quickly', 'under', 'beautiful'],
      correctAnswer: 'under',
      explanation: 'Prepositions show relationships like position.',
    ),
  ];

  // Method to generate questions based on user weaknesses (mock implementation)
  Future<List<Question>> generateQuestions({List<String>? weaknesses, int count = 10}) async {
    // In a real implementation, use AI to generate questions based on weaknesses
    // For now, return a shuffled subset of mock questions
    final shuffled = List<Question>.from(_mockQuestions)..shuffle();
    return shuffled.take(count).toList();
  }
}
