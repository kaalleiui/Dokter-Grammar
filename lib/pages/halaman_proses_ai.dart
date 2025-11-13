import 'package:flutter/material.dart';

class HalamanProsesAI extends StatelessWidget {
  final Map<int, String> answers;
  const HalamanProsesAI({super.key, required this.answers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7C2),
        title: const Text('Processing AI Analysis',
            style: TextStyle(color: Color(0xFF4E4E4E))),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFFFFCA28),
              ),
              const SizedBox(height: 20),
              const Text(
                'Analyzing your grammar performance...',
                style: TextStyle(fontSize: 16, color: Color(0xFF4E4E4E)),
              ),
              const SizedBox(height: 20),
              // 🧠 Mock tampilan hasil untuk backend nanti
              Text(
                'Total answers: ${50}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF8C6C00)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
