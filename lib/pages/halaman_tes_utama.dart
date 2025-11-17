import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/question_generator_service.dart';
import '../models/answer.dart';
import '../models/analysis_result.dart';
import '../services/hive_storage_service.dart';
import 'halaman_penjelasan_ai.dart';

class HalamanTesUtama extends StatefulWidget {
  const HalamanTesUtama({super.key});

  @override
  State<HalamanTesUtama> createState() => _HalamanTesUtamaState();
}

class _HalamanTesUtamaState extends State<HalamanTesUtama>
    with SingleTickerProviderStateMixin {
  bool started = false;
  int currentQuestion = 0;
  bool _isLoading = true;

  // 🧩 Generated questions from QuestionGeneratorService
  List<Question> _questions = [];

  // 🗂️ Cache jawaban user (selected answer text)
  Map<int, String> userAnswers = {};

  // Services
  late QuestionGeneratorService _questionGenerator;
  late HiveStorageService _hiveStorage;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _slideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-1.2, 0)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Initialize services and generate questions
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _questionGenerator = QuestionGeneratorService();
    _hiveStorage = HiveStorageService();

    await _questionGenerator.initialize();

    // Generate 50 questions for the main test
    _questions = await _questionGenerator.generateQuestions(
      count: 50,
    );

    setState(() {
      _isLoading = false;
    });
  }

  // 🟢 Start test
  void _startTest() => setState(() => started = true);

  // 🔴 Exit test (konfirmasi)
  void _exitTest() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Exit Test?"),
        content: const Text("Your progress won’t be saved."),
        actions: [
         TextButton(
  style: TextButton.styleFrom(
    foregroundColor: Colors.black, // Mengatur warna teks menjadi hitam
  ),
  onPressed: () => Navigator.pop(context),
  child: const Text(
    "Cancel",
    style: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 14,
      fontWeight: FontWeight.normal, // Menggunakan normal, Anda bisa ubah ke w500/w600 jika perlu
    ),
  ),
),
TextButton(
  style: TextButton.styleFrom(
    foregroundColor: Colors.black, // Mengatur warna teks menjadi hitam
  ),
  onPressed: () {
    Navigator.pop(context);
    Navigator.pop(context);
  },
  child: const Text(
    "Exit",
    style: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
  ),
),
        ],
      ),
    );
  }

  // ⏭️ Next question animation
  void _nextQuestion() async {
    if (currentQuestion < _questions.length - 1) {
      await _controller.forward();
      setState(() => currentQuestion++);
      _controller.reset();
    } else {
      // ✅ Semua soal selesai → calculate results and navigate to analysis
      await _finishTest();
    }
  }

  Future<void> _finishTest() async {
    // Calculate score and create analysis
    int correctAnswers = 0;
    List<Answer> answers = [];
    List<String> strengths = [];
    List<String> weaknesses = [];

    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final userAnswer = userAnswers[i];
      final isCorrect = userAnswer == question.correctAnswer;

      if (isCorrect) correctAnswers++;

      answers.add(Answer(
        question: question.questionText,
        selectedAnswer: userAnswer ?? '',
        correctAnswer: question.correctAnswer,
        isCorrect: isCorrect,
        explanation: question.explanation,
      ));

      // Track strengths and weaknesses by category
      // Note: Question class doesn't have category field, using generic tracking
      if (isCorrect) {
        if (!strengths.contains('general')) {
          strengths.add('general');
        }
      } else {
        if (!weaknesses.contains('general')) {
          weaknesses.add('general');
        }
      }
    }

    final score = ((correctAnswers / _questions.length) * 100).round();

    // Create analysis result
    final analysisResult = AnalysisResult(
      totalQuestions: _questions.length,
      correctAnswers: correctAnswers,
      score: score,
      strengths: strengths,
      weaknesses: weaknesses,
      overallFeedback: _generateFeedback(score, strengths, weaknesses),
    );

    // Save progress to Hive
    await _hiveStorage.updateUserProgress('user1', score, 'main_test');

    // Navigate to analysis page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HalamanPenjelasanAi(
          analysisResult: analysisResult,
          answers: answers,
        ),
      ),
    );
  }

  String _generateFeedback(int score, List<String> strengths, List<String> weaknesses) {
    if (score >= 80) {
      return "Excellent performance! You have a strong grasp of English grammar.";
    } else if (score >= 60) {
      return "Good job! You have solid grammar knowledge with room for improvement.";
    } else {
      return "Keep practicing! Focus on the areas where you need more work.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (currentQuestion + 1) / _questions.length;
    final question = _questions[currentQuestion];

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: started
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 🔹 Header bar: Exit + Progress + Counter
                    Row(
                      children: [
                        IconButton(
                          onPressed: _exitTest,
                          icon: const Icon(Icons.close_rounded,
                              color: Color(0xFF4E4E4E)),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: LinearProgressIndicator(
                              value: progress,
                              color: const Color(0xFFFFCA28),
                              backgroundColor: Colors.yellow.shade100,
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "${currentQuestion + 1}/50",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 🧠 Container Pertanyaan (Card Atas)
                    Expanded(
                      flex: 4,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildQuestionCard(question),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 🗳️ Container Jawaban (Card Bawah)
                    Expanded(
                      flex: 5,
                      child: _buildAnswerCard(question),
                    ),

                    const SizedBox(height: 16),

                    // 🔘 Tombol Next
                    ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFE88B),
                        foregroundColor: Colors.black,
                        elevation: 6,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        currentQuestion < _questions.length - 1
                            ? "Next"
                            : "Finish",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                )
              : _buildStartPopup(),
        ),
      ),
    );
  }

  /// 🟡 POPUP awal sebelum mulai tes
  Widget _buildStartPopup() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.yellow.shade200.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.quiz_rounded,
                size: 60, color: Colors.yellow.shade700.withOpacity(0.9)),
            const SizedBox(height: 20),
            Text(
              "Ready to Start the Test?",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4E4E4E),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "You’ll answer 50 grammar questions.\nYou can pause anytime.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _startTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFE88B),
                foregroundColor: Colors.black,
                elevation: 6,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                "Start Test",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// 🧠 Container Pertanyaan
  Widget _buildQuestionCard(Question q) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.shade200.withOpacity(0.6),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          q.questionText,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4E4E4E),
          ),
        ),
      ),
    );
  }

  /// 🗳️ Container Jawaban
  Widget _buildAnswerCard(Question q) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF4),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.shade100.withOpacity(0.6),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListView.builder(
        itemCount: q.options.length,
        itemBuilder: (context, index) {
          final optionText = q.options[index];
          final selected = userAnswers[currentQuestion] == optionText;
          return GestureDetector(
            onTap: () {
              setState(() {
                userAnswers[currentQuestion] = optionText;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFFFF7C2) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? const Color(0xFFFFCA28)
                      : Colors.yellow.shade100,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.shade100.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                optionText,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4E4E4E),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ✅ Halaman hasil tes mock (TODO: ambil hasil dari backend)
class HalamanHasilTes extends StatelessWidget {
  const HalamanHasilTes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(28),
          margin: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.yellow.shade200.withOpacity(0.6),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tombol Exit (taruh di bagian bawah Column hasil tes)
            ElevatedButton(
              onPressed: () {
                // Kembali ke halaman awal / home
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                elevation: 3,
              ),
              child: const Text(
                'Exit',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),

              Icon(Icons.emoji_events_rounded,
                  size: 70, color: Colors.yellow.shade700),
              const SizedBox(height: 20),
              Text(
                "Your Level: B2",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4E4E4E),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Upper Intermediate Grammar Mastery",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // TODO: Navigate ke halaman_proses_ai.dart
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFE88B),
                  foregroundColor: Colors.black,
                  elevation: 6,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  "Go to Analysis",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
