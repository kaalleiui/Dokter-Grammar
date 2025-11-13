class AnalysisResult {
  final int totalQuestions;
  final int correctAnswers;
  final int score; // e.g., percentage or points
  final List<String> strengths;
  final List<String> weaknesses;
  final String overallFeedback;

  AnalysisResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
    required this.strengths,
    required this.weaknesses,
    required this.overallFeedback,
  });

  // Factory constructor for creating from JSON
  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
      score: json['score'] as int,
      strengths: List<String>.from(json['strengths'] as List),
      weaknesses: List<String>.from(json['weaknesses'] as List),
      overallFeedback: json['overallFeedback'] as String,
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'score': score,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'overallFeedback': overallFeedback,
    };
  }
}
