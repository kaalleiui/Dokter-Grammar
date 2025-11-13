import 'package:flutter/material.dart';

class ExplanationBox extends StatelessWidget {
  final bool isCorrect;
  final String explanation;
  final VoidCallback onContinue;
  final bool isLastQuestion;

  const ExplanationBox({
    super.key,
    required this.isCorrect,
    required this.explanation,
    required this.onContinue,
    this.isLastQuestion = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Result icon
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? Colors.green : Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              isCorrect ? 'Correct!' : 'Incorrect',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isCorrect ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              explanation,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF4E4E4E),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA726),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                _getButtonText(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getButtonText() {
    return isLastQuestion ? 'Finish' : 'Continue';
  }
}
