// =============================================================================
// HALAMAN LATIHAN CUSTOM - QUIZ INTERAKTIF
// File ini berisi halaman quiz kustom dengan 10 pertanyaan grammar
// =============================================================================

// Import library yang dibutuhkan
import 'package:flutter/material.dart'; // Framework UI Flutter
import '../services/question_generator_service.dart'; // Service untuk generate soal
import '../services/hive_storage_service.dart'; // Service untuk penyimpanan data
import '../models/answer.dart'; // Model data jawaban user
import '../models/analysis_result.dart'; // Model data hasil analisis
import '../widgets/question_card.dart'; // Widget untuk tampilkan soal
import '../widgets/explanation_box.dart'; // Widget untuk tampilkan penjelasan
import 'halaman_penjelasan_ai.dart'; // Halaman hasil analisis AI

// =============================================================================
// KELAS UTAMA HALAMAN LATIHAN CUSTOM
// Widget stateful untuk mengelola state quiz (pertanyaan, skor, dll)
// =============================================================================
class HalamanLatihanCustom extends StatefulWidget {
  const HalamanLatihanCustom({super.key});

  @override
  State<HalamanLatihanCustom> createState() => _HalamanLatihanCustomState();
}

// =============================================================================
// STATE CLASS UNTUK MENGELOLA LOGIKA QUIZ
// Mengatur state pertanyaan, skor, loading, dll
// =============================================================================
class _HalamanLatihanCustomState extends State<HalamanLatihanCustom> {
  // Variabel state untuk quiz
  List<Question> _questions = []; // List semua pertanyaan yang didapat dari service
  int _currentQuestionIndex = 0; // Index pertanyaan yang sedang ditampilkan
  int _score = 0; // Jumlah jawaban benar
  final List<Answer> _answers = []; // List semua jawaban user untuk analisis
  bool _isLoading = true; // Status loading saat generate pertanyaan
  bool _showExplanation = false; // Apakah tampilkan penjelasan jawaban
  bool _isCorrect = false; // Status jawaban benar/salah
  String _explanation = ''; // Teks penjelasan jawaban

  // =============================================================================
  // LIFECYCLE METHODS
  // =============================================================================

  @override
  void initState() {
    super.initState();
    _initializeQuiz(); // Panggil fungsi untuk setup quiz saat widget pertama kali dibuat
  }

  // Fungsi untuk inisialisasi quiz - generate 10 pertanyaan grammar
  // Dipanggil saat initState untuk mempersiapkan quiz sebelum ditampilkan
  Future<void> _initializeQuiz() async {
    final questionService = QuestionGeneratorService(); // Buat instance service
    await questionService.initialize(); // Inisialisasi template service
    final questions = await questionService.generateQuestions(count: 10); // Generate 10 soal
    setState(() {
      _questions = questions; // Simpan pertanyaan ke state
      _isLoading = false; // Matikan loading, siap tampilkan quiz
    });
  }

  // =============================================================================
  // EVENT HANDLERS - FUNGSI YANG DIPANGGIL SAAT USER INTERAKSI
  // =============================================================================

  // Fungsi yang dipanggil saat user memilih jawaban
  // Mengecek apakah jawaban benar, update skor, dan simpan jawaban untuk analisis
  void _onAnswerSelected(String answer) {
    setState(() {
      _isCorrect = answer == _questions[_currentQuestionIndex].correctAnswer; // Cek jawaban benar/salah
      _explanation = _questions[_currentQuestionIndex].explanation; // Ambil penjelasan dari soal
      _showExplanation = true; // Tampilkan box penjelasan

      if (_isCorrect) {
        _score++; // Tambah skor jika benar
      }

      // Simpan jawaban ke list untuk analisis nanti
      final answerModel = Answer(
        question: _questions[_currentQuestionIndex].questionText,
        selectedAnswer: answer,
        correctAnswer: _questions[_currentQuestionIndex].correctAnswer,
        isCorrect: _isCorrect,
        explanation: _explanation,
      );
      _answers.add(answerModel); // Tambahkan ke list jawaban
    });
  }

  // Fungsi yang dipanggil saat user klik "Continue" setelah melihat penjelasan
  // Pindah ke soal berikutnya atau selesai quiz jika sudah soal terakhir
  void _onContinue() {
    if (_currentQuestionIndex < _questions.length - 1) {
      // Masih ada soal berikutnya
      setState(() {
        _currentQuestionIndex++; // Pindah ke soal berikutnya
        _showExplanation = false; // Sembunyikan penjelasan untuk soal baru
      });
    } else {
      // Sudah soal terakhir, selesai quiz
      _finishQuiz();
    }
  }

  // =============================================================================
  // QUIZ COMPLETION - FUNGSI SELESAI QUIZ
  // =============================================================================

  // Fungsi yang dipanggil saat quiz selesai (setelah soal terakhir)
  // Hitung skor akhir, buat analisis hasil, simpan progress, dan navigasi ke halaman hasil
  void _finishQuiz() async {
    // Hitung skor akhir dalam persentase
    final percentage = ((_score / _questions.length) * 100).round();

    // Buat objek hasil analisis untuk ditampilkan di halaman berikutnya
    final analysisResult = AnalysisResult(
      totalQuestions: _questions.length, // Total soal yang dikerjakan
      correctAnswers: _score, // Jumlah jawaban benar
      score: percentage, // Skor dalam persentase
      strengths: _getStrengths(), // Kelebihan user berdasarkan skor
      weaknesses: _getWeaknesses(), // Kekurangan user berdasarkan skor
      overallFeedback: _getOverallFeedback(percentage), // Feedback keseluruhan
    );

    // Simpan progress user ke database lokal (Hive)
    final storageService = HiveStorageService();
    await storageService.updateUserProgress('default', percentage, 'custom');

    // Navigasi ke halaman hasil analisis AI dengan data lengkap
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HalamanPenjelasanAi(
            analysisResult: analysisResult, // Hasil analisis
            answers: _answers, // Semua jawaban user untuk ditampilkan detail
          ),
        ),
      );
    }
  }

  // =============================================================================
  // ANALYSIS HELPERS - FUNGSI PEMBANTU UNTUK ANALISIS HASIL
  // =============================================================================

  // Fungsi untuk menentukan kelebihan user berdasarkan skor
  // Logika sederhana: jika skor > 70%, dianggap memiliki pemahaman yang baik
  List<String> _getStrengths() {
    return _score > (_questions.length * 0.7) ? ['Good understanding of grammar concepts'] : [];
  }

  // Fungsi untuk menentukan kekurangan user berdasarkan skor
  // Logika sederhana: jika skor < 70%, dianggap perlu latihan lebih banyak
  List<String> _getWeaknesses() {
    return _score < (_questions.length * 0.7) ? ['Need more practice on grammar rules'] : [];
  }

  // Fungsi untuk memberikan feedback keseluruhan berdasarkan persentase skor
  // Feedback berbeda untuk setiap rentang skor
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

  // =============================================================================
  // UI BUILD METHOD - MEMBANGUN TAMPILAN HALAMAN
  // =============================================================================

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading screen saat generate pertanyaan
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFFAEE), // Background cream
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFA726)), // Orange color
          ),
        ),
      );
    }

    // Main quiz interface
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAEE), // Background cream
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFCF2), // Light cream background
        elevation: 0, // No shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4E4E4E)), // Dark gray icon
          onPressed: () => Navigator.of(context).pop(), // Back navigation
        ),
        title: const Text(
          'Custom Practice', // Page title
          style: TextStyle(
            color: Color(0xFF4E4E4E), // Dark gray text
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // Center the title
      ),
      body: SafeArea(
        child: _showExplanation
            // Tampilkan box penjelasan jika user sudah jawab
            ? ExplanationBox(
                isCorrect: _isCorrect, // Status benar/salah
                explanation: _explanation, // Teks penjelasan
                onContinue: _onContinue, // Callback untuk lanjut
                isLastQuestion: _currentQuestionIndex == _questions.length - 1, // Apakah soal terakhir
              )
            // Tampilkan kartu soal jika belum jawab
            : QuestionCard(
                question: _questions[_currentQuestionIndex], // Soal saat ini
                questionNumber: _currentQuestionIndex + 1, // Nomor soal (1-based)
                totalQuestions: _questions.length, // Total soal
                onAnswerSelected: _onAnswerSelected, // Callback saat jawab dipilih
              ),
      ),
    );
  }
}
