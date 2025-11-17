// =============================================================================
// GRAMMAR TEMPLATE MODEL - TEMPLATE UNTUK GENERATE PERTANYAAN AI
// Model ini mendefinisikan struktur template grammar dengan placeholder
// =============================================================================

class GrammarTemplate {
  // =============================================================================
  // PROPERTIES
  // =============================================================================

  // ID unik untuk template
  final String id;

  // Kategori grammar (tenses, prepositions, articles, dll)
  final String category;

  // Sub-kategori dalam kategori utama
  final String subcategory;

  // Tingkat kesulitan (beginner, intermediate, advanced)
  final String difficulty;

  // Template teks pertanyaan dengan placeholder seperti [subject], [verb], [object]
  final String questionTemplate;

  // Template untuk jawaban benar
  final String correctAnswerTemplate;

  // Template untuk penjelasan jawaban
  final String explanationTemplate;

  // List template untuk opsi jawaban salah (distractors)
  final List<String> distractorTemplates;

  // Tag untuk tracking kategori grammar yang diujikan
  final List<String> grammarTags;

  // =============================================================================
  // CONSTRUCTOR
  // =============================================================================

  GrammarTemplate({
    required this.id,
    required this.category,
    required this.subcategory,
    required this.difficulty,
    required this.questionTemplate,
    required this.correctAnswerTemplate,
    required this.explanationTemplate,
    required this.distractorTemplates,
    required this.grammarTags,
  });

  // =============================================================================
  // FACTORY METHODS
  // =============================================================================

  // Factory untuk membuat template dari JSON (untuk penyimpanan)
  factory GrammarTemplate.fromJson(Map<String, dynamic> json) {
    return GrammarTemplate(
      id: json['id'] as String,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String,
      difficulty: json['difficulty'] as String,
      questionTemplate: json['questionTemplate'] as String,
      correctAnswerTemplate: json['correctAnswerTemplate'] as String,
      explanationTemplate: json['explanationTemplate'] as String,
      distractorTemplates: List<String>.from(json['distractorTemplates'] as List),
      grammarTags: List<String>.from(json['grammarTags'] as List),
    );
  }

  // Method untuk convert ke JSON (untuk penyimpanan)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'subcategory': subcategory,
      'difficulty': difficulty,
      'questionTemplate': questionTemplate,
      'correctAnswerTemplate': correctAnswerTemplate,
      'explanationTemplate': explanationTemplate,
      'distractorTemplates': distractorTemplates,
      'grammarTags': grammarTags,
    };
  }

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  // Method untuk mendapatkan semua placeholder yang ada di template
  List<String> getPlaceholders() {
    final RegExp placeholderRegex = RegExp(r'\[([^\]]+)\]');
    final matches = placeholderRegex.allMatches(questionTemplate);
    return matches.map((match) => match.group(1)!).toSet().toList();
  }

  // Method untuk validasi template - memastikan semua placeholder terdefinisi
  bool isValid() {
    final questionPlaceholders = getPlaceholders();
    final correctPlaceholders = RegExp(r'\[([^\]]+)\]').allMatches(correctAnswerTemplate)
        .map((match) => match.group(1)!).toSet();
    final explanationPlaceholders = RegExp(r'\[([^\]]+)\]').allMatches(explanationTemplate)
        .map((match) => match.group(1)!).toSet();

    // Pastikan semua placeholder di template utama ada di correct dan explanation
    return questionPlaceholders.every((placeholder) =>
        correctPlaceholders.contains(placeholder) &&
        explanationPlaceholders.contains(placeholder));
  }
}
