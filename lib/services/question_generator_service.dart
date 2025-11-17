import '../models/grammar_template.dart';
import 'template_storage_service.dart';

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
  // =============================================================================
  // PROPERTIES
  // =============================================================================

  // Service untuk mengelola templates dan vocabulary
  final TemplateStorageService _templateService = TemplateStorageService();

  // Cache untuk generated questions
  final Map<String, Question> _questionCache = {};

  // =============================================================================
  // INITIALIZATION
  // =============================================================================

  // Method untuk inisialisasi service
  Future<void> initialize() async {
    await _templateService.initialize();
  }

  // =============================================================================
  // QUESTION GENERATION METHODS
  // =============================================================================

  // Method utama untuk generate questions berdasarkan weaknesses user
  Future<List<Question>> generateQuestions({
    List<String>? weaknesses,
    int count = 10,
    String? difficulty,
    List<String>? targetCategories,
  }) async {
    final questions = <Question>[];

    // Jika ada weaknesses, prioritaskan kategori tersebut
    if (weaknesses != null && weaknesses.isNotEmpty) {
      final weaknessQuestions = await _generateQuestionsForWeaknesses(weaknesses, count ~/ 2);
      questions.addAll(weaknessQuestions);
    }

    // Generate questions sisanya dari kategori umum atau target categories
    final remainingCount = count - questions.length;
    if (remainingCount > 0) {
      final generalQuestions = await _generateGeneralQuestions(
        remainingCount,
        difficulty: difficulty,
        categories: targetCategories,
      );
      questions.addAll(generalQuestions);
    }

    // Shuffle untuk variasi
    questions.shuffle();
    return questions.take(count).toList();
  }

  // Generate questions spesifik untuk weaknesses
  Future<List<Question>> _generateQuestionsForWeaknesses(List<String> weaknesses, int count) async {
    final List<Question> questions = [];

    // Cari templates yang match dengan weaknesses
    final relevantTemplates = _templateService.getTemplatesByTags(weaknesses);

    if (relevantTemplates.isEmpty) {
      // Fallback ke templates dengan kategori yang mirip
      final categoryTemplates = weaknesses.expand((weakness) =>
          _templateService.getTemplatesByCategory(weakness)
      ).toList();
      final generatedQuestions = await _generateFromTemplates(categoryTemplates, count);
      questions.addAll(generatedQuestions);
    } else {
      final generatedQuestions = await _generateFromTemplates(relevantTemplates, count);
      questions.addAll(generatedQuestions);
    }

    return questions;
  }

  // Generate questions umum
  Future<List<Question>> _generateGeneralQuestions(
    int count, {
    String? difficulty,
    List<String>? categories,
  }) async {
    List<GrammarTemplate> templates;

    if (categories != null && categories.isNotEmpty) {
      // Filter berdasarkan kategori yang diminta
      templates = categories.expand((category) =>
          _templateService.getTemplatesByCategory(category)
      ).toList();
    } else if (difficulty != null) {
      // Filter berdasarkan difficulty
      templates = _templateService.getTemplatesByDifficulty(difficulty);
    } else {
      // Ambil semua templates
      templates = _templateService.getAllTemplates();
    }

    return _generateFromTemplates(templates, count);
  }

  // Core method untuk generate questions dari templates
  Future<List<Question>> _generateFromTemplates(List<GrammarTemplate> templates, int count) async {
    final questions = <Question>[];

    if (templates.isEmpty) {
      // Fallback ke mock questions jika tidak ada templates
      return _generateMockQuestions(count);
    }

    // Shuffle templates untuk variasi
    final shuffledTemplates = List<GrammarTemplate>.from(templates)..shuffle();

    for (var i = 0; i < count && i < shuffledTemplates.length; i++) {
      final template = shuffledTemplates[i];
      final question = await _generateQuestionFromTemplate(template);

      if (question != null) {
        questions.add(question);
      }
    }

    // Jika masih kurang, generate mock questions
    while (questions.length < count) {
      questions.addAll(await _generateMockQuestions(count - questions.length));
    }

    return questions.take(count).toList();
  }

  // =============================================================================
  // MISSING METHOD IMPLEMENTATIONS
  // =============================================================================

  // Generate question dari template
  Future<Question?> _generateQuestionFromTemplate(GrammarTemplate template) async {
    try {
      // Generate placeholder replacements
      final replacements = await _generatePlaceholderReplacements(template);

      // Replace placeholders in question template
      final questionText = _replacePlaceholders(template.questionTemplate, replacements);

      // Replace placeholders in correct answer template
      final correctAnswer = _replacePlaceholders(template.correctAnswerTemplate, replacements);

      // Replace placeholders in explanation template
      final explanation = _replacePlaceholders(template.explanationTemplate, replacements);

      // Generate distractor options
      final distractors = template.distractorTemplates
          .map((distractor) => _replacePlaceholders(distractor, replacements))
          .toList();

      // Create options list with correct answer and distractors
      final options = [correctAnswer, ...distractors];
      options.shuffle(); // Randomize order

      return Question(
        questionText: questionText,
        options: options,
        correctAnswer: correctAnswer,
        explanation: explanation,
      );
    } catch (e) {
      print('Error generating question from template ${template.id}: $e');
      return null;
    }
  }

  // Generate placeholder replacements for a template
  Future<Map<String, String>> _generatePlaceholderReplacements(GrammarTemplate template) async {
    final replacements = <String, String>{};
    final placeholders = template.getPlaceholders();

    for (final placeholder in placeholders) {
      replacements[placeholder] = await _getReplacementForPlaceholder(placeholder, template);
    }

    return replacements;
  }

  // Get replacement value for a specific placeholder
  Future<String> _getReplacementForPlaceholder(String placeholder, GrammarTemplate template) async {
    switch (placeholder) {
      case 'subject':
        return _templateService.getRandomWord('subjects', difficulty: template.difficulty);
      case 'verb':
        return _templateService.getRandomWord('verbs', difficulty: template.difficulty);
      case 'verb_base':
        return _templateService.getRandomWord('verbs', difficulty: template.difficulty);
      case 'verb_s':
        final verb = _templateService.getRandomWord('verbs', difficulty: template.difficulty);
        return _conjugateVerbThirdPerson(verb);
      case 'verb_ing':
        final verb = _templateService.getRandomWord('verbs', difficulty: template.difficulty);
        return _conjugateVerbIng(verb);
      case 'verb_past':
        final verb = _templateService.getRandomWord('verbs', difficulty: template.difficulty);
        return _conjugateVerbPast(verb);
      case 'noun':
        return _templateService.getRandomWord('nouns', difficulty: template.difficulty);
      case 'article':
        final noun = _templateService.getRandomWord('nouns', difficulty: template.difficulty);
        return _getArticleForNoun(noun);
      case 'article_reason':
        final noun = _templateService.getRandomWord('nouns', difficulty: template.difficulty);
        return _getArticleReason(noun);
      default:
        // Fallback to random word from any category
        return _templateService.getRandomWord('nouns', difficulty: template.difficulty);
    }
  }

  // Replace placeholders in text using replacement map
  String _replacePlaceholders(String text, Map<String, String> replacements) {
    String result = text;
    replacements.forEach((placeholder, replacement) {
      result = result.replaceAll('[$placeholder]', replacement);
    });
    return result;
  }

  // Generate distractor options for multiple choice questions
  Future<List<String>> _generateDistractors(GrammarTemplate template, String correctAnswer, Map<String, String> replacements) async {
    final distractors = <String>[];

    // Use the template's distractor templates if available
    if (template.distractorTemplates.isNotEmpty) {
      for (final distractorTemplate in template.distractorTemplates) {
        final distractor = _replacePlaceholders(distractorTemplate, replacements);
        if (distractor != correctAnswer && !distractors.contains(distractor)) {
          distractors.add(distractor);
        }
      }
    }

    // If we don't have enough distractors from templates, generate generic ones
    while (distractors.length < 3) {
      String distractor;
      do {
        distractor = await _generateGenericDistractor(template, replacements);
      } while (distractor == correctAnswer || distractors.contains(distractor));

      distractors.add(distractor);
    }

    return distractors.take(3).toList();
  }

  // Generate a generic distractor based on template category
  Future<String> _generateGenericDistractor(GrammarTemplate template, Map<String, String> replacements) async {
    switch (template.category) {
      case 'tenses':
        if (template.subcategory == 'present_simple') {
          // Generate wrong verb forms
          final subject = replacements['subject'] ?? 'he';
          final verb = replacements['verb'] ?? 'run';
          final wrongForms = [
            '$subject ${verb}ing', // continuous form
            '$subject ${verb}ed',  // past form
            '$subject $verb',      // base form (might be correct)
          ];
          return wrongForms[DateTime.now().millisecond % wrongForms.length];
        }
        break;
      case 'articles':
        // Generate wrong articles
        final noun = replacements['noun'] ?? 'book';
        final wrongArticles = ['a', 'an', 'the'];
        final correctArticle = replacements['article'] ?? 'a';
        wrongArticles.remove(correctArticle);
        return '${wrongArticles[DateTime.now().millisecond % wrongArticles.length]} $noun';
      default:
        // Generic fallback
        return 'Wrong answer ${DateTime.now().millisecond % 100}';
    }

    // Ultimate fallback
    return 'Wrong answer ${DateTime.now().millisecond % 100}';
  }

  // =============================================================================
  // GRAMMAR HELPER METHODS
  // =============================================================================

  // Conjugate verb to third person singular (he/she/it form)
  String _conjugateVerbThirdPerson(String verb) {
    final lowerVerb = verb.toLowerCase();
    if (lowerVerb.endsWith('y') && !lowerVerb.endsWith('ay') && !lowerVerb.endsWith('ey') && !lowerVerb.endsWith('iy') && !lowerVerb.endsWith('oy') && !lowerVerb.endsWith('uy')) {
      return lowerVerb.substring(0, lowerVerb.length - 1) + 'ies';
    } else if (lowerVerb.endsWith('s') || lowerVerb.endsWith('sh') || lowerVerb.endsWith('ch') || lowerVerb.endsWith('x') || lowerVerb.endsWith('z') || lowerVerb.endsWith('o')) {
      return lowerVerb + 'es';
    } else {
      return lowerVerb + 's';
    }
  }

  // Conjugate verb to -ing form
  String _conjugateVerbIng(String verb) {
    final lowerVerb = verb.toLowerCase();
    if (lowerVerb.endsWith('e') && !lowerVerb.endsWith('ee')) {
      return lowerVerb.substring(0, lowerVerb.length - 1) + 'ing';
    } else if (lowerVerb.endsWith('ie')) {
      return lowerVerb.substring(0, lowerVerb.length - 2) + 'ying';
    } else {
      return lowerVerb + 'ing';
    }
  }

  // Conjugate verb to past tense (simple implementation)
  String _conjugateVerbPast(String verb) {
    final lowerVerb = verb.toLowerCase();
    // This is a simplified implementation - in a real app you'd use a proper verb conjugation library
    if (lowerVerb.endsWith('e')) {
      return lowerVerb + 'd';
    } else {
      return lowerVerb + 'ed';
    }
  }

  // Get appropriate article for a noun
  String _getArticleForNoun(String noun) {
    final lowerNoun = noun.toLowerCase();
    if (lowerNoun.startsWith('a') || lowerNoun.startsWith('e') || lowerNoun.startsWith('i') || lowerNoun.startsWith('o') || lowerNoun.startsWith('u')) {
      return 'an';
    } else {
      return 'a';
    }
  }

  // Get reason for article choice
  String _getArticleReason(String noun) {
    final lowerNoun = noun.toLowerCase();
    if (lowerNoun.startsWith('a') || lowerNoun.startsWith('e') || lowerNoun.startsWith('i') || lowerNoun.startsWith('o') || lowerNoun.startsWith('u')) {
      return 'is a vowel sound';
    } else {
      return 'is a consonant sound';
    }
  }

  // Generate mock questions for fallback
  Future<List<Question>> _generateMockQuestions(int count) async {
    final mockQuestions = <Question>[];
    
    for (int i = 0; i < count; i++) {
      mockQuestions.add(Question(
        questionText: 'Mock Question ${i + 1}?',
        options: ['Option A', 'Option B', 'Option C', 'Option D'],
        correctAnswer: 'Option A',
        explanation: 'This is a mock explanation for question ${i + 1}.',
      ));
    }
    
    return mockQuestions;
  }
}