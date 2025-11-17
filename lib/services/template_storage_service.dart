// =============================================================================
// TEMPLATE STORAGE SERVICE - SERVICE UNTUK MENYIMPAN DAN MEMUAT TEMPLATE
// Service ini mengelola penyimpanan template grammar dan vocabulary banks
// =============================================================================

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/grammar_template.dart';
import '../models/vocabulary_bank.dart';

class TemplateStorageService {
  // =============================================================================
  // PROPERTIES
  // =============================================================================

  // Instance singleton
  static final TemplateStorageService _instance = TemplateStorageService._internal();
  factory TemplateStorageService() => _instance;
  TemplateStorageService._internal();

  // Cache untuk templates dan vocabulary
  List<GrammarTemplate> _templates = [];
  VocabularyManager _vocabularyManager = VocabularyManager();

  // Status loading
  bool _isLoaded = false;

  // =============================================================================
  // INITIALIZATION METHODS
  // =============================================================================

  // Method untuk inisialisasi service - load semua data dari assets
  Future<void> initialize() async {
    if (_isLoaded) return; // Sudah di-load sebelumnya

    try {
      // Load templates dari JSON file
      await _loadTemplatesFromAssets();

      // Load vocabulary banks dari JSON file
      await _loadVocabularyFromAssets();

      _isLoaded = true;
    } catch (e) {
      print('Error initializing TemplateStorageService: $e');
      // Fallback ke data default jika gagal load
      _loadDefaultTemplates();
      _loadDefaultVocabulary();
    }
  }

  // Load templates dari assets/templates.json
  Future<void> _loadTemplatesFromAssets() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/templates.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

      _templates = jsonList.map((json) => GrammarTemplate.fromJson(json)).toList();
      print('Loaded ${_templates.length} templates from assets');
    } catch (e) {
      print('Error loading templates from assets: $e');
      throw e;
    }
  }

  // Load vocabulary dari assets/vocabulary.json
  Future<void> _loadVocabularyFromAssets() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/vocabulary.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

      _vocabularyManager.loadFromJson(jsonList.cast<Map<String, dynamic>>());
      print('Loaded ${_vocabularyManager.bankCount} vocabulary banks from assets');
    } catch (e) {
      print('Error loading vocabulary from assets: $e');
      throw e;
    }
  }

  // =============================================================================
  // DEFAULT DATA - FALLBACK JIKA ASSET TIDAK ADA
  // =============================================================================

  // Load template default sebagai fallback
  void _loadDefaultTemplates() {
    _templates = [
      GrammarTemplate(
        id: 'present_simple_1',
        category: 'tenses',
        subcategory: 'present_simple',
        difficulty: 'beginner',
        questionTemplate: 'What is the correct form of "[verb]" in present simple for "[subject]"?',
        correctAnswerTemplate: '[subject] [verb_s]',
        explanationTemplate: 'In present simple, "[subject]" takes "[verb_s]" because it is third person singular.',
        distractorTemplates: [
          '[subject] [verb_base]',
          '[subject] [verb_ing]',
          '[subject] [verb_past]'
        ],
        grammarTags: ['present_simple', 'third_person_singular'],
      ),
      GrammarTemplate(
        id: 'articles_1',
        category: 'articles',
        subcategory: 'a_an_the',
        difficulty: 'beginner',
        questionTemplate: 'Choose the correct article: "___ [noun]"',
        correctAnswerTemplate: '[article] [noun]',
        explanationTemplate: 'We use "[article]" before "[noun]" because [noun] [article_reason].',
        distractorTemplates: [
          'a [noun]',
          'an [noun]',
          'the [noun]'
        ],
        grammarTags: ['articles', 'a_an_the'],
      ),
    ];
    print('Loaded default templates');
  }

  // Load vocabulary default sebagai fallback
  void _loadDefaultVocabulary() {
    _vocabularyManager.addBank(VocabularyBank(
      id: 'nouns_beginner',
      category: 'nouns',
      difficulty: 'beginner',
      words: ['cat', 'dog', 'book', 'house', 'car'],
      examples: {
        'cat': 'The cat is sleeping.',
        'dog': 'My dog likes to play.',
      },
    ));

    _vocabularyManager.addBank(VocabularyBank(
      id: 'verbs_beginner',
      category: 'verbs',
      difficulty: 'beginner',
      words: ['run', 'eat', 'sleep', 'read', 'write'],
      examples: {
        'run': 'She runs every morning.',
        'eat': 'He eats breakfast at 7 AM.',
      },
    ));

    _vocabularyManager.addBank(VocabularyBank(
      id: 'subjects_third_person',
      category: 'subjects',
      difficulty: 'beginner',
      words: ['he', 'she', 'it', 'John', 'Mary'],
    ));

    print('Loaded default vocabulary banks');
  }

  // =============================================================================
  // TEMPLATE METHODS
  // =============================================================================

  // Method untuk mendapatkan semua templates
  List<GrammarTemplate> getAllTemplates() {
    return List.unmodifiable(_templates);
  }

  // Method untuk mendapatkan templates berdasarkan kategori
  List<GrammarTemplate> getTemplatesByCategory(String category) {
    return _templates.where((template) => template.category == category).toList();
  }

  // Method untuk mendapatkan templates berdasarkan difficulty
  List<GrammarTemplate> getTemplatesByDifficulty(String difficulty) {
    return _templates.where((template) => template.difficulty == difficulty).toList();
  }

  // Method untuk mendapatkan template berdasarkan ID
  GrammarTemplate? getTemplateById(String id) {
    return _templates.where((template) => template.id == id).firstOrNull;
  }

  // Method untuk mendapatkan templates berdasarkan grammar tags
  List<GrammarTemplate> getTemplatesByTags(List<String> tags) {
    return _templates.where((template) =>
        tags.any((tag) => template.grammarTags.contains(tag))
    ).toList();
  }

  // =============================================================================
  // VOCABULARY METHODS
  // =============================================================================

  // Method untuk mendapatkan vocabulary manager
  VocabularyManager getVocabularyManager() {
    return _vocabularyManager;
  }

  // Method untuk mendapatkan kata acak dari kategori tertentu
  String getRandomWord(String category, {String? difficulty}) {
    return _vocabularyManager.getRandomWordFromCategory(category, difficulty: difficulty);
  }

  // Method untuk mendapatkan multiple kata acak
  List<String> getRandomWords(String category, int count, {String? difficulty}) {
    return _vocabularyManager.getRandomWordsFromCategory(category, count, difficulty: difficulty);
  }

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  // Method untuk validasi semua templates
  List<String> validateTemplates() {
    final errors = <String>[];

    for (final template in _templates) {
      if (!template.isValid()) {
        errors.add('Template ${template.id} is invalid: placeholders mismatch');
      }
    }

    return errors;
  }

  // Method untuk mendapatkan statistik
  Map<String, int> getStatistics() {
    final categories = <String, int>{};
    final difficulties = <String, int>{};

    for (final template in _templates) {
      categories[template.category] = (categories[template.category] ?? 0) + 1;
      difficulties[template.difficulty] = (difficulties[template.difficulty] ?? 0) + 1;
    }

    return {
      'total_templates': _templates.length,
      'total_vocabulary_banks': _vocabularyManager.bankCount,
      ...categories.map((k, v) => MapEntry('category_$k', v)),
      ...difficulties.map((k, v) => MapEntry('difficulty_$k', v)),
    };
  }

  // Method untuk reset dan reload data
  Future<void> reload() async {
    _templates.clear();
    _vocabularyManager.clear();
    _isLoaded = false;
    await initialize();
  }
}
