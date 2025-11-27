-- ============================================
-- USER PROFILE & AUTHENTICATION
-- ============================================

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
);

CREATE TABLE user_interests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    interest TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE(user_id, interest)
);

-- ============================================
-- QUESTION BANK
-- ============================================

CREATE TABLE topics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    difficulty_base INTEGER NOT NULL DEFAULT 3,
    description TEXT
);

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
);

CREATE TABLE question_choices (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    question_id TEXT NOT NULL,
    choice_id TEXT NOT NULL,
    text TEXT NOT NULL,
    is_correct INTEGER DEFAULT 0,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
);

CREATE TABLE question_tags (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    question_id TEXT NOT NULL,
    tag_type TEXT NOT NULL,
    tag_value TEXT NOT NULL,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    UNIQUE(question_id, tag_type, tag_value)
);

-- ============================================
-- TEST SESSIONS & ATTEMPTS
-- ============================================

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
);

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
);

-- ============================================
-- USER PERFORMANCE TRACKING
-- ============================================

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
);

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
);

-- ============================================
-- EXPLANATIONS & FEEDBACK
-- ============================================

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
);

-- ============================================
-- GAMIFICATION
-- ============================================

CREATE TABLE badges (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    badge_type TEXT NOT NULL,
    badge_name TEXT NOT NULL,
    earned_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE(user_id, badge_type)
);

CREATE TABLE daily_activities (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    activity_date TEXT NOT NULL,
    tests_completed INTEGER DEFAULT 0,
    questions_answered INTEGER DEFAULT 0,
    time_spent_seconds INTEGER DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE(user_id, activity_date)
);

-- ============================================
-- SETTINGS & CONFIGURATION
-- ============================================

CREATE TABLE app_settings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    setting_key TEXT NOT NULL,
    setting_value TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE(user_id, setting_key)
);

CREATE TABLE notification_preferences (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    notification_type TEXT NOT NULL,
    enabled INTEGER DEFAULT 1,
    time_hour INTEGER,
    time_minute INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE(user_id, notification_type)
);

-- ============================================
-- BACKUP & SYNC
-- ============================================

CREATE TABLE backup_metadata (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    backup_file_path TEXT NOT NULL,
    backup_size_bytes INTEGER,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    version TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

CREATE INDEX idx_questions_topic ON questions(topic_id);
CREATE INDEX idx_questions_difficulty ON questions(difficulty);
CREATE INDEX idx_question_tags_question ON question_tags(question_id);
CREATE INDEX idx_question_tags_value ON question_tags(tag_value);
CREATE INDEX idx_test_sessions_user ON test_sessions(user_id);
CREATE INDEX idx_test_sessions_type ON test_sessions(session_type);
CREATE INDEX idx_test_attempts_session ON test_attempts(session_id);
CREATE INDEX idx_test_attempts_question ON test_attempts(question_id);
CREATE INDEX idx_user_topic_performance_user ON user_topic_performance(user_id);
CREATE INDEX idx_user_topic_performance_topic ON user_topic_performance(topic_id);
CREATE INDEX idx_user_question_history_user ON user_question_history(user_id);
CREATE INDEX idx_daily_activities_user_date ON daily_activities(user_id, activity_date);

