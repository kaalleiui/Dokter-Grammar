import 'package:flutter/material.dart';
import '../models/analysis_result.dart';
import '../models/answer.dart';

class HalamanPenjelasanAi extends StatelessWidget {
  final AnalysisResult analysisResult;
  final List<Answer> answers;

  const HalamanPenjelasanAi({
    super.key,
    required this.analysisResult,
    required this.answers,
  });

  @override
  Widget build(BuildContext context) {
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
          'AI Analysis',
          style: TextStyle(
            color: Color(0xFF4E4E4E),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Score Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your Score',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4E4E4E),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${analysisResult.score}%',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFA726),
                      ),
                    ),
                    Text(
                      '${analysisResult.correctAnswers}/${analysisResult.totalQuestions} correct',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4E4E4E),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Feedback
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Feedback',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4E4E4E),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      analysisResult.overallFeedback,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4E4E4E),
                        height: 1.5,
                      ),
                    ),
                    if (analysisResult.strengths.isNotEmpty) ...[
                      const SizedBox(height: 15),
                      const Text(
                        'Strengths:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      ...analysisResult.strengths.map((strength) => Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              '• $strength',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4E4E4E),
                              ),
                            ),
                          )),
                    ],
                    if (analysisResult.weaknesses.isNotEmpty) ...[
                      const SizedBox(height: 15),
                      const Text(
                        'Areas for Improvement:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      ...analysisResult.weaknesses.map((weakness) => Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              '• $weakness',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4E4E4E),
                              ),
                            ),
                          )),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Review Answers Button
              Center(
                child: ElevatedButton(
                  onPressed: () => _showAnswerReview(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA726),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Review Answers',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAnswerReview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFFFFFAEE),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: const Text(
                'Answer Review',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4E4E4E),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: answers.length,
                itemBuilder: (context, index) {
                  final answer = answers[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              answer.isCorrect ? Icons.check_circle : Icons.cancel,
                              color: answer.isCorrect ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Question ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4E4E4E),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          answer.question,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4E4E4E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your answer: ${answer.selectedAnswer}',
                          style: TextStyle(
                            fontSize: 12,
                            color: answer.isCorrect ? Colors.green : Colors.red,
                          ),
                        ),
                        if (!answer.isCorrect) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Correct answer: ${answer.correctAnswer}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          answer.explanation,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4E4E4E),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
