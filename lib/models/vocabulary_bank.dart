// =============================================================================
// VOCABULARY BANK MODEL - DATABASE KATA-KATA UNTUK TEMPLATE
// Model ini menyimpan koleksi kata-kata terorganisir berdasarkan kategori
// =============================================================================

class VocabularyBank {
  // =============================================================================
  // PROPERTIES
  // =============================================================================

  // ID unik untuk vocabulary bank
  final String id;

  // Nama kategori vocabulary (nouns, verbs, adjectives, dll)
  final String category;

  // Tingkat kesulitan (beginner, intermediate, advanced)
  final String difficulty;

  // List kata-kata dalam kategori ini
  final List<String> words;

  // Contoh penggunaan untuk setiap kata (optional)
  final Map<String, String> examples;

  // =============================================================================
  // CONSTRUCTOR
  // =============================================================================

  VocabularyBank({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.words,
    this.examples = const {},
  });

  // =============================================================================
  // FACTORY METHODS
  // =============================================================================

  // Factory untuk membuat dari JSON
  factory VocabularyBank.fromJson(Map<String, dynamic> json) {
    return VocabularyBank(
      id: json['id'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      words: List<String>.from(json['words'] as List),
      examples: Map<String, String>.from(json['examples'] as Map? ?? {}),
    );
  }

  // Convert ke JSON untuk penyimpanan
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'difficulty': difficulty,
      'words': words,
      'examples': examples,
    };
  }

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  // Method untuk mendapatkan kata acak dari bank
  String getRandomWord() {
    if (words.isEmpty) return '';
    return words[DateTime.now().millisecondsSinceEpoch % words.length];
  }

  // Method untuk mendapatkan beberapa kata acak
  List<String> getRandomWords(int count) {
    if (words.isEmpty) return [];
    final shuffled = List<String>.from(words)..shuffle();
    return shuffled.take(count).toList();
  }

  // Method untuk cek apakah kata ada di bank
  bool containsWord(String word) {
    return words.contains(word.toLowerCase());
  }

  // Method untuk filter kata berdasarkan kriteria
  List<String> filterWords(bool Function(String) predicate) {
    return words.where(predicate).toList();
  }
}

// =============================================================================
// VOCABULARY MANAGER - MANAGER UNTUK MENGELOLA MULTIPLE VOCABULARY BANKS
// =============================================================================

class VocabularyManager {
  // =============================================================================
  // PROPERTIES
  // =============================================================================

  // Map untuk menyimpan semua vocabulary banks berdasarkan ID
  final Map<String, VocabularyBank> _banks = {};

  // =============================================================================
  // METHODS
  // =============================================================================

  // Method untuk menambah vocabulary bank
  void addBank(VocabularyBank bank) {
    _banks[bank.id] = bank;
  }

  // Method untuk mendapatkan bank berdasarkan ID
  VocabularyBank? getBank(String id) {
    return _banks[id];
  }

  // Method untuk mendapatkan semua banks dalam kategori tertentu
  List<VocabularyBank> getBanksByCategory(String category) {
    return _banks.values.where((bank) => bank.category == category).toList();
  }

  // Method untuk mendapatkan semua banks dengan difficulty tertentu
  List<VocabularyBank> getBanksByDifficulty(String difficulty) {
    return _banks.values.where((bank) => bank.difficulty == difficulty).toList();
  }

  // Method untuk mendapatkan kata acak dari kategori tertentu
  String getRandomWordFromCategory(String category, {String? difficulty}) {
    final banks = difficulty != null
        ? getBanksByCategory(category).where((bank) => bank.difficulty == difficulty).toList()
        : getBanksByCategory(category);

    if (banks.isEmpty) return '';

    final randomBank = banks[DateTime.now().millisecondsSinceEpoch % banks.length];
    return randomBank.getRandomWord();
  }

  // Method untuk mendapatkan multiple kata acak dari kategori
  List<String> getRandomWordsFromCategory(String category, int count, {String? difficulty}) {
    final banks = difficulty != null
        ? getBanksByCategory(category).where((bank) => bank.difficulty == difficulty).toList()
        : getBanksByCategory(category);

    if (banks.isEmpty) return [];

    final allWords = banks.expand((bank) => bank.words).toList();
    if (allWords.isEmpty) return [];

    final shuffled = List<String>.from(allWords)..shuffle();
    return shuffled.take(count).toList();
  }

  // Method untuk load vocabulary dari JSON
  void loadFromJson(List<Map<String, dynamic>> jsonList) {
    for (final json in jsonList) {
      final bank = VocabularyBank.fromJson(json);
      addBank(bank);
    }
  }

  // Method untuk export semua banks ke JSON
  List<Map<String, dynamic>> exportToJson() {
    return _banks.values.map((bank) => bank.toJson()).toList();
  }

  // Method untuk clear semua banks
  void clear() {
    _banks.clear();
  }

  // Getter untuk jumlah banks
  int get bankCount => _banks.length;

  // Getter untuk list semua banks
  List<VocabularyBank> get allBanks => _banks.values.toList();
}
