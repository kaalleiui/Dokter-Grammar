import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static bool _initialized = false;

  DatabaseHelper._init();

  /// Initialize database factory for desktop platforms
  static Future<void> initializeDatabaseFactory() async {
    if (_initialized) return;
    
    // Check if running on desktop (Windows, macOS, Linux)
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      // Initialize FFI for desktop platforms
      databaseFactory = databaseFactoryFfi;
    }
    
    _initialized = true;
  }

  Future<Database> get database async {
    // Ensure database factory is initialized
    await initializeDatabaseFactory();
    
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    // Ensure database factory is initialized before opening database
    await initializeDatabaseFactory();
    
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Execute schema
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nickname TEXT NOT NULL,
        goal TEXT NOT NULL,
        current_level TEXT NOT NULL DEFAULT 'beginner',
        overall_score REAL DEFAULT 0.0,
        streak_days INTEGER DEFAULT 0,
        last_activity_date TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE user_interests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        interest TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(user_id, interest)
      )
    ''');

    await db.execute('''
      CREATE TABLE topics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        display_name TEXT NOT NULL,
        difficulty_base INTEGER NOT NULL DEFAULT 3,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE questions (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        difficulty INTEGER NOT NULL,
        topic_id INTEGER NOT NULL,
        prompt TEXT NOT NULL,
        answer TEXT NOT NULL,
        explanation_template TEXT,
        example_sentence TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (topic_id) REFERENCES topics(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE question_choices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question_id TEXT NOT NULL,
        choice_id TEXT NOT NULL,
        text TEXT NOT NULL,
        is_correct INTEGER DEFAULT 0,
        FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE question_tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question_id TEXT NOT NULL,
        tag_type TEXT NOT NULL,
        tag_value TEXT NOT NULL,
        FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
        UNIQUE(question_id, tag_type, tag_value)
      )
    ''');

    await db.execute('''
      CREATE TABLE test_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        session_type TEXT NOT NULL,
        total_questions INTEGER NOT NULL,
        completed_questions INTEGER DEFAULT 0,
        score REAL,
        level_before TEXT,
        level_after TEXT,
        started_at TEXT NOT NULL DEFAULT (datetime('now')),
        completed_at TEXT,
        duration_seconds INTEGER,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE test_attempts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        question_id TEXT NOT NULL,
        user_answer TEXT,
        is_correct INTEGER,
        time_spent_seconds INTEGER,
        hint_used INTEGER DEFAULT 0,
        answered_at TEXT,
        FOREIGN KEY (session_id) REFERENCES test_sessions(id) ON DELETE CASCADE,
        FOREIGN KEY (question_id) REFERENCES questions(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE user_topic_performance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        topic_id INTEGER NOT NULL,
        attempts INTEGER DEFAULT 0,
        correct INTEGER DEFAULT 0,
        total_time_seconds INTEGER DEFAULT 0,
        last_attempted_at TEXT,
        mastery_percentage REAL DEFAULT 0.0,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (topic_id) REFERENCES topics(id),
        UNIQUE(user_id, topic_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE user_question_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        question_id TEXT NOT NULL,
        times_attempted INTEGER DEFAULT 0,
        times_correct INTEGER DEFAULT 0,
        last_attempted_at TEXT,
        marked_for_review INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (question_id) REFERENCES questions(id),
        UNIQUE(user_id, question_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE explanations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        attempt_id INTEGER NOT NULL,
        explanation_text TEXT NOT NULL,
        explanation_type TEXT NOT NULL,
        clarity_rating INTEGER,
        marked_unclear INTEGER DEFAULT 0,
        follow_up_question TEXT,
        follow_up_answer TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (attempt_id) REFERENCES test_attempts(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE badges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        badge_type TEXT NOT NULL,
        badge_name TEXT NOT NULL,
        earned_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(user_id, badge_type)
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        activity_date TEXT NOT NULL,
        tests_completed INTEGER DEFAULT 0,
        questions_answered INTEGER DEFAULT 0,
        time_spent_seconds INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(user_id, activity_date)
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        setting_key TEXT NOT NULL,
        setting_value TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(user_id, setting_key)
      )
    ''');

    await db.execute('''
      CREATE TABLE notification_preferences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        notification_type TEXT NOT NULL,
        enabled INTEGER DEFAULT 1,
        time_hour INTEGER,
        time_minute INTEGER,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(user_id, notification_type)
      )
    ''');

    await db.execute('''
      CREATE TABLE backup_metadata (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        backup_file_path TEXT NOT NULL,
        backup_size_bytes INTEGER,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        version TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_questions_topic ON questions(topic_id)');
    await db.execute('CREATE INDEX idx_questions_difficulty ON questions(difficulty)');
    await db.execute('CREATE INDEX idx_question_tags_question ON question_tags(question_id)');
    await db.execute('CREATE INDEX idx_question_tags_value ON question_tags(tag_value)');
    await db.execute('CREATE INDEX idx_test_sessions_user ON test_sessions(user_id)');
    await db.execute('CREATE INDEX idx_test_sessions_type ON test_sessions(session_type)');
    await db.execute('CREATE INDEX idx_test_attempts_session ON test_attempts(session_id)');
    await db.execute('CREATE INDEX idx_test_attempts_question ON test_attempts(question_id)');
    await db.execute('CREATE INDEX idx_user_topic_performance_user ON user_topic_performance(user_id)');
    await db.execute('CREATE INDEX idx_user_topic_performance_topic ON user_topic_performance(topic_id)');
    await db.execute('CREATE INDEX idx_user_question_history_user ON user_question_history(user_id)');
    await db.execute('CREATE INDEX idx_daily_activities_user_date ON daily_activities(user_id, activity_date)');

    // Insert default topics
    await _insertDefaultTopics(db);
  }

  Future<void> _insertDefaultTopics(Database db) async {
    final topics = [
      {'name': 'tenses', 'display_name': 'Tenses', 'difficulty_base': 2, 'description': 'Simple, continuous, perfect, and perfect continuous tenses'},
      {'name': 'modals_auxiliaries', 'display_name': 'Modals & Auxiliaries', 'difficulty_base': 3, 'description': 'Modal verbs and auxiliary verbs'},
      {'name': 'conditionals', 'display_name': 'Conditionals', 'difficulty_base': 4, 'description': 'Zero, first, second, third, and mixed conditionals'},
      {'name': 'complex_sentences', 'display_name': 'Complex Sentences', 'difficulty_base': 4, 'description': 'Subordination, relative clauses, and complex structures'},
      {'name': 'sentence_combining', 'display_name': 'Sentence Combining & Punctuation', 'difficulty_base': 3, 'description': 'Combining sentences and punctuation rules'},
      {'name': 'articles_determiners', 'display_name': 'Articles & Determiners', 'difficulty_base': 2, 'description': 'A, an, the, and other determiners'},
      {'name': 'subject_verb_agreement', 'display_name': 'Subject-Verb Agreement', 'difficulty_base': 3, 'description': 'Agreement between subject and verb'},
      {'name': 'passive_voice', 'display_name': 'Passive Voice', 'difficulty_base': 3, 'description': 'Active and passive voice transformations'},
      {'name': 'reported_speech', 'display_name': 'Reported Speech', 'difficulty_base': 4, 'description': 'Direct and indirect speech'},
      {'name': 'prepositions', 'display_name': 'Prepositions', 'difficulty_base': 2, 'description': 'Prepositions of time, place, and movement'},
      {'name': 'adjective_clauses', 'display_name': 'Adjective Clauses', 'difficulty_base': 4, 'description': 'Relative clauses and adjective clauses'},
      {'name': 'pronouns_reference', 'display_name': 'Pronouns & Reference', 'difficulty_base': 2, 'description': 'Pronouns and reference clarity'},
    ];

    for (final topic in topics) {
      await db.insert(
        'topics',
        topic,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    // For now, we'll just recreate if version changes
    if (oldVersion < newVersion) {
      // Add migration logic here
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

