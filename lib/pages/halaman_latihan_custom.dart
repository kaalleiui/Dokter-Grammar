import 'package:flutter/material.dart';
import '../services/question_generator_service.dart';
import '../services/hive_storage_service.dart';
import '../models/answer.dart';
import '../models/analysis_result.dart';
import '../widgets/question_card.dart';
import '../widgets/explanation_box.dart';
import 'halaman_penjelasan_ai.dart';

class HalamanLatihanCustom extends StatefulWidget {
  const HalamanLatihanCustom({super.key});

  @override
  State<HalamanLatihanCustom> createState() => _HalamanLatihanCustomState();
}

class _HalamanLatihanCustomState extends State<HalamanLatihanCustom> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  final List<Answer> _answers = [];
  bool _isLoading = true;
  bool _showExplanation = false;
  bool _isCorrect = false;
  String _explanation = '';

  @override
  void initState() {
    super.initState();
    _initializeQuiz();
  }

  Future<void> _initializeQuiz() async {
    final questionService = QuestionGeneratorService();
    final questions = await questionService.generateQuestions(count: 10);
    setState(() {
      _questions = questions;
      _isLoading = false;
    });
  }

  void _onAnswerSelected(String answer) {
    setState(() {
      _isCorrect = answer == _questions[_currentQuestionIndex].correctAnswer;
      _explanation = _questions[_currentQuestionIndex].explanation;
      _showExplanation = true;

      if (_isCorrect) {
        _score++;
      }

      // Record the answer
      final answerModel = Answer(
        question: _questions[_currentQuestionIndex].questionText,
        selectedAnswer: answer,
        correctAnswer: _questions[_currentQuestionIndex].correctAnswer,
        isCorrect: _isCorrect,
        explanation: _explanation,
      );
      _answers.add(answerModel);
    });
  }

  void _onContinue() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _showExplanation = false;
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() async {
    // Calculate final score as percentage
    final percentage = ((_score / _questions.length) * 100).round();

    // Create analysis result
    final analysisResult = AnalysisResult(
      totalQuestions: _questions.length,
      correctAnswers: _score,
      score: percentage,
      strengths: _getStrengths(),
      weaknesses: _getWeaknesses(),
      overallFeedback: _getOverallFeedback(percentage),
    );

    // Update user progress (assuming userId is 'default' for now)
    final storageService = HiveStorageService();
    await storageService.updateUserProgress('default', percentage, 'custom');

    // Navigate to halaman_penjelasan_ai with results
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HalamanPenjelasanAi(
            analysisResult: analysisResult,
            answers: _answers,
          ),
        ),
      );
    }
  }

  List<String> _getStrengths() {
    // Simple logic: if score > 70%, consider it a strength
    return _score > (_questions.length * 0.7) ? ['Good understanding of grammar concepts'] : [];
  }

  List<String> _getWeaknesses() {
    // Simple logic: if score < 70%, consider it a weakness
    return _score < (_questions.length * 0.7) ? ['Need more practice on grammar rules'] : [];
  }

  String _getOverallFeedback(int percentage) {
    if (percentage >= 90) {
      return 'Excellent! You have a strong grasp of English grammar.';
    } else if (percentage >= 70) {
      return 'Good job! Keep practicing to improve further.';
    } else if (percentage >= 50) {
      return 'Not bad, but you need more practice on grammar concepts.';
    } else {
      return 'You need significant improvement. Focus on basic grammar rules.';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFFAEE),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFA726)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAEE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFCF2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4E4E4E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Custom Practice',
          style: TextStyle(
            color: Color(0xFF4E4E4E),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _showExplanation
            ? ExplanationBox(
                isCorrect: _isCorrect,
                explanation: _explanation,
                onContinue: _onContinue,
                isLastQuestion: _currentQuestionIndex == _questions.length - 1,
              )
            : QuestionCard(
                question: _questions[_currentQuestionIndex],
                questionNumber: _currentQuestionIndex + 1,
                totalQuestions: _questions.length,
                onAnswerSelected: _onAnswerSelected,
              ),
      ),
    );
  }
}
