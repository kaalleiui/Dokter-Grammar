import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HalamanTesUtama extends StatefulWidget {
  const HalamanTesUtama({super.key});

  @override
  State<HalamanTesUtama> createState() => _HalamanTesUtamaState();
}

class _HalamanTesUtamaState extends State<HalamanTesUtama>
    with SingleTickerProviderStateMixin {
  bool started = false;
  int currentQuestion = 0;

  // 🧩 Mock data pertanyaan (ganti nanti dari backend)
  final List<Map<String, dynamic>> _questions = List.generate(50, (i) {
    return {
      "question": "Question ${i + 1}: Choose the correct grammar form.",
      "options": ["A. He go", "B. He goes", "C. He gone", "D. He going"],
      "answer": 1,
    };
  });

  // 🗂️ Cache jawaban user (TODO: simpan ke Hive/local)
  Map<int, int> userAnswers = {};

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
      // ✅ Semua soal selesai → ke hasil tes
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HalamanHasilTes()),
      );
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
  Widget _buildQuestionCard(Map<String, dynamic> q) {
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
          q["question"],
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
  Widget _buildAnswerCard(Map<String, dynamic> q) {
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
        itemCount: q["options"].length,
        itemBuilder: (context, index) {
          final selected = userAnswers[currentQuestion] == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                userAnswers[currentQuestion] = index;
                // TODO: simpan jawaban ke cache Hive di sini
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
                q["options"][index],
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
