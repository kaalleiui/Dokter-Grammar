import '../../../core/database/database_helper.dart';
import '../../../core/models/test_session.dart';

class TestLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> createTestSession(TestSession session) async {
    final db = await _dbHelper.database;
    
    return await db.insert(
      'test_sessions',
      {
        'user_id': session.userId,
        'session_type': session.sessionType,
        'total_questions': session.totalQuestions,
        'completed_questions': session.completedQuestions,
        'score': session.score,
        'level_before': session.levelBefore,
        'level_after': session.levelAfter,
        'started_at': session.startedAt.toIso8601String(),
        'completed_at': session.completedAt?.toIso8601String(),
        'duration_seconds': session.durationSeconds,
      },
    );
  }

  Future<void> updateTestSession(TestSession session) async {
    if (session.id == null) return;
    
    final db = await _dbHelper.database;
    
    await db.update(
      'test_sessions',
      {
        'completed_questions': session.completedQuestions,
        'score': session.score,
        'level_before': session.levelBefore,
        'level_after': session.levelAfter,
        'completed_at': session.completedAt?.toIso8601String(),
        'duration_seconds': session.durationSeconds,
      },
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<TestSession?> getTestSessionById(int sessionId) async {
    final db = await _dbHelper.database;
    
    final sessionMaps = await db.query(
      'test_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );

    if (sessionMaps.isEmpty) return null;

    final sessionMap = sessionMaps.first;
    
    // Get attempts
    final attemptMaps = await db.query(
      'test_attempts',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
    final attempts = attemptMaps.map((map) => TestAttempt.fromJson({
      'id': map['id'],
      'sessionId': map['session_id'],
      'questionId': map['question_id'],
      'userAnswer': map['user_answer'],
      'isCorrect': map['is_correct'],
      'timeSpentSeconds': map['time_spent_seconds'],
      'hintUsed': map['hint_used'],
      'answeredAt': map['answered_at'],
    })).toList();

    return TestSession(
      id: sessionMap['id'] as int,
      userId: sessionMap['user_id'] as int,
      sessionType: sessionMap['session_type'] as String,
      totalQuestions: sessionMap['total_questions'] as int,
      completedQuestions: sessionMap['completed_questions'] as int,
      score: sessionMap['score'] != null ? (sessionMap['score'] as num).toDouble() : null,
      levelBefore: sessionMap['level_before'] as String?,
      levelAfter: sessionMap['level_after'] as String?,
      startedAt: DateTime.parse(sessionMap['started_at'] as String),
      completedAt: sessionMap['completed_at'] != null
          ? DateTime.parse(sessionMap['completed_at'] as String)
          : null,
      durationSeconds: sessionMap['duration_seconds'] as int?,
      attempts: attempts,
    );
  }

  Future<int> createTestAttempt(TestAttempt attempt) async {
    final db = await _dbHelper.database;
    
    return await db.insert(
      'test_attempts',
      {
        'session_id': attempt.sessionId,
        'question_id': attempt.questionId,
        'user_answer': attempt.userAnswer,
        'is_correct': attempt.isCorrect == true ? 1 : (attempt.isCorrect == false ? 0 : null),
        'time_spent_seconds': attempt.timeSpentSeconds,
        'hint_used': attempt.hintUsed ? 1 : 0,
        'answered_at': attempt.answeredAt?.toIso8601String(),
      },
    );
  }

  Future<void> updateTestAttempt(TestAttempt attempt) async {
    if (attempt.id == null) return;
    
    final db = await _dbHelper.database;
    
    await db.update(
      'test_attempts',
      {
        'user_answer': attempt.userAnswer,
        'is_correct': attempt.isCorrect == true ? 1 : (attempt.isCorrect == false ? 0 : null),
        'time_spent_seconds': attempt.timeSpentSeconds,
        'hint_used': attempt.hintUsed ? 1 : 0,
        'answered_at': attempt.answeredAt?.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [attempt.id],
    );
  }

  Future<List<TestSession>> getUserTestSessions(int userId, {String? sessionType}) async {
    final db = await _dbHelper.database;
    
    final whereClause = 'user_id = ?';
    final whereArgs = [userId];
    
    if (sessionType != null) {
      final sessionMaps = await db.query(
        'test_sessions',
        where: '$whereClause AND session_type = ?',
        whereArgs: [...whereArgs, sessionType],
        orderBy: 'started_at DESC',
      );
      
      return sessionMaps.map((map) => _mapToTestSession(map)).toList();
    }
    
    final sessionMaps = await db.query(
      'test_sessions',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'started_at DESC',
    );
    
    return sessionMaps.map((map) => _mapToTestSession(map)).toList();
  }

  TestSession _mapToTestSession(Map<String, dynamic> map) {
    return TestSession(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      sessionType: map['session_type'] as String,
      totalQuestions: map['total_questions'] as int,
      completedQuestions: map['completed_questions'] as int,
      score: map['score']?.toDouble(),
      levelBefore: map['level_before'] as String?,
      levelAfter: map['level_after'] as String?,
      startedAt: DateTime.parse(map['started_at'] as String),
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      durationSeconds: map['duration_seconds'] as int?,
    );
  }

  Future<bool> hasUserCompletedPlacementTest(int userId) async {
    final db = await _dbHelper.database;
    
    final sessionMaps = await db.query(
      'test_sessions',
      where: 'user_id = ? AND session_type = ? AND completed_at IS NOT NULL',
      whereArgs: [userId, 'placement'],
      limit: 1,
    );
    
    return sessionMaps.isNotEmpty;
  }
}

