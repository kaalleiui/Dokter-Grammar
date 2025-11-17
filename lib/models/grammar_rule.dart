// =============================================================================
// GRAMMAR RULE MODEL - PRODUCTION RULES FOR SENTENCE CONSTRUCTION
// Model ini mendefinisikan aturan produksi grammar untuk membangun kalimat
// =============================================================================

class GrammarRule {
  // =============================================================================
  // PROPERTIES
  // =============================================================================

  // ID unik untuk rule
  final String id;

  // Kategori grammar yang diujikan (tenses, prepositions, articles, dll)
  final String category;

  // Sub-kategori dalam kategori utama
  final String subcategory;

  // Tingkat kesulitan (beginner, intermediate, advanced)
  final String difficulty;

  // Non-terminal symbol (S, NP, VP, dll)
  final String nonTerminal;

  // List produksi yang mungkin (contoh: ["NP VP", "NP VP PP"])
  final List<String> productions;

  // Tag grammar yang terkait dengan rule ini
  final List<String> grammarTags;

  // Bobot probabilitas untuk selection (default 1.0)
  final double weight;

  // =============================================================================
  // CONSTRUCTOR
  // =============================================================================

  GrammarRule({
    required this.id,
    required this.category,
    required this.subcategory,
    required this.difficulty,
    required this.nonTerminal,
    required this.productions,
    required this.grammarTags,
    this.weight = 1.0,
  });

  // =============================================================================
  // FACTORY METHODS
  // =============================================================================

  // Factory untuk membuat dari JSON
  factory GrammarRule.fromJson(Map<String, dynamic> json) {
    return GrammarRule(
      id: json['id'] as String,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String,
      difficulty: json['difficulty'] as String,
      nonTerminal: json['nonTerminal'] as String,
      productions: List<String>.from(json['productions'] as List),
      grammarTags: List<String>.from(json['grammarTags'] as List),
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
    );
  }

  // Convert ke JSON untuk penyimpanan
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'subcategory': subcategory,
      'difficulty': difficulty,
      'nonTerminal': nonTerminal,
      'productions': productions,
      'grammarTags': grammarTags,
      'weight': weight,
    };
  }

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  // Method untuk mendapatkan produksi acak berdasarkan bobot
  String getRandomProduction() {
    if (productions.isEmpty) return '';

    // Jika hanya satu produksi, return langsung
    if (productions.length == 1) return productions.first;

    // Hitung total bobot
    final totalWeight = productions.length * weight;

    // Pilih berdasarkan bobot
    final random = DateTime.now().millisecondsSinceEpoch % totalWeight.toInt();
    final index = (random / weight).floor();

    return productions[index.clamp(0, productions.length - 1)];
  }

  // Method untuk cek apakah rule valid
  bool isValid() {
    return id.isNotEmpty &&
           category.isNotEmpty &&
           nonTerminal.isNotEmpty &&
           productions.isNotEmpty &&
           productions.every((prod) => prod.trim().isNotEmpty);
  }

  // Method untuk mendapatkan semua terminal symbols dari productions
  Set<String> getTerminalSymbols() {
    final terminals = <String>{};
    for (final production in productions) {
      final symbols = production.split(' ');
      for (final symbol in symbols) {
        // Terminal symbols biasanya lowercase atau dalam kurung siku
        if (symbol.toLowerCase() == symbol || symbol.startsWith('[')) {
          terminals.add(symbol);
        }
      }
    }
    return terminals;
  }

  // Method untuk mendapatkan semua non-terminal symbols dari productions
  Set<String> getNonTerminalSymbols() {
    final nonTerminals = <String>{};
    for (final production in productions) {
      final symbols = production.split(' ');
      for (final symbol in symbols) {
        // Non-terminal symbols biasanya uppercase
        if (symbol.toUpperCase() == symbol && !symbol.startsWith('[')) {
          nonTerminals.add(symbol);
        }
      }
    }
    return nonTerminals;
  }
}

// =============================================================================
// GRAMMAR RULE SET - KUMPULAN RULES UNTUK KATEGORI TERTENTU
// =============================================================================

class GrammarRuleSet {
  // =============================================================================
  // PROPERTIES
  // =============================================================================

  // ID untuk rule set
  final String id;

  // Nama rule set
  final String name;

  // Deskripsi rule set
  final String description;

  // List grammar rules dalam set ini
  final List<GrammarRule> rules;

  // Start symbol untuk grammar ini (default 'S')
  final String startSymbol;

  // =============================================================================
  // CONSTRUCTOR
  // =============================================================================

  GrammarRuleSet({
    required this.id,
    required this.name,
    required this.description,
    required this.rules,
    this.startSymbol = 'S',
  });

  // =============================================================================
  // FACTORY METHODS
  // =============================================================================

  // Factory untuk membuat dari JSON
  factory GrammarRuleSet.fromJson(Map<String, dynamic> json) {
    final rulesJson = json['rules'] as List<dynamic>;
    final rules = rulesJson.map((ruleJson) => GrammarRule.fromJson(ruleJson)).toList();

    return GrammarRuleSet(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      rules: rules,
      startSymbol: json['startSymbol'] as String? ?? 'S',
    );
  }

  // Convert ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'rules': rules.map((rule) => rule.toJson()).toList(),
      'startSymbol': startSymbol,
    };
  }

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  // Method untuk mendapatkan rule berdasarkan non-terminal
  List<GrammarRule> getRulesForNonTerminal(String nonTerminal) {
    return rules.where((rule) => rule.nonTerminal == nonTerminal).toList();
  }

  // Method untuk mendapatkan rule berdasarkan kategori
  List<GrammarRule> getRulesByCategory(String category) {
    return rules.where((rule) => rule.category == category).toList();
  }

  // Method untuk mendapatkan rule berdasarkan difficulty
  List<GrammarRule> getRulesByDifficulty(String difficulty) {
    return rules.where((rule) => rule.difficulty == difficulty).toList();
  }

  // Method untuk validasi seluruh rule set
  bool isValid() {
    if (rules.isEmpty) return false;

    // Pastikan ada rule untuk start symbol
    final hasStartRule = rules.any((rule) => rule.nonTerminal == startSymbol);
    if (!hasStartRule) return false;

    // Validasi setiap rule
    return rules.every((rule) => rule.isValid());
  }

  // Method untuk mendapatkan statistik
  Map<String, int> getStatistics() {
    final categories = <String, int>{};
    final difficulties = <String, int>{};

    for (final rule in rules) {
      categories[rule.category] = (categories[rule.category] ?? 0) + 1;
      difficulties[rule.difficulty] = (difficulties[rule.difficulty] ?? 0) + 1;
    }

    return {
      'total_rules': rules.length,
      'categories': categories.length,
      'difficulties': difficulties.length,
      ...categories.map((k, v) => MapEntry('category_$k', v)),
      ...difficulties.map((k, v) => MapEntry('difficulty_$k', v)),
    };
  }
}
