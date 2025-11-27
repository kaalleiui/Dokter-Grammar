import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/topic_performance.dart';

class PerformanceLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> updateTopicPerformance(TopicPerformance performance) async {
    final db = await _dbHelper.database;
    
    await db.insert(
      'user_topic_performance',
      {
        'user_id': performance.userId,
        'topic_id': performance.topicId,
        'attempts': performance.attempts,
        'correct': performance.correct,
        'total_time_seconds': performance.totalTimeSeconds,
        'last_attempted_at': performance.lastAttemptedAt?.toIso8601String(),
        'mastery_percentage': performance.masteryPercentage,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<TopicPerformance?> getTopicPerformance(int userId, int topicId) async {
    final db = await _dbHelper.database;
    
    final maps = await db.query(
      'user_topic_performance',
      where: 'user_id = ? AND topic_id = ?',
      whereArgs: [userId, topicId],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    return TopicPerformance(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      topicId: map['topic_id'] as int,
      attempts: map['attempts'] as int,
      correct: map['correct'] as int,
      totalTimeSeconds: map['total_time_seconds'] as int,
      lastAttemptedAt: map['last_attempted_at'] != null
          ? DateTime.parse(map['last_attempted_at'] as String)
          : null,
      masteryPercentage: (map['mastery_percentage'] as num).toDouble(),
    );
  }

  Future<Map<int, TopicPerformance>> getUserTopicPerformances(int userId) async {
    final db = await _dbHelper.database;
    
    final maps = await db.query(
      'user_topic_performance',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    final performances = <int, TopicPerformance>{};
    
    for (final map in maps) {
      final topicId = map['topic_id'] as int;
      performances[topicId] = TopicPerformance(
        id: map['id'] as int?,
        userId: map['user_id'] as int,
        topicId: topicId,
        attempts: map['attempts'] as int,
        correct: map['correct'] as int,
        totalTimeSeconds: map['total_time_seconds'] as int,
        lastAttemptedAt: map['last_attempted_at'] != null
            ? DateTime.parse(map['last_attempted_at'] as String)
            : null,
        masteryPercentage: (map['mastery_percentage'] as num).toDouble(),
      );
    }

    return performances;
  }

  Future<void> recordAttempt({
    required int userId,
    required int topicId,
    required bool isCorrect,
    required int timeSpentSeconds,
  }) async {
    // Get existing performance or create new
    final existing = await getTopicPerformance(userId, topicId);
    
    final performance = existing ?? TopicPerformance(
      userId: userId,
      topicId: topicId,
      attempts: 0,
      correct: 0,
      totalTimeSeconds: 0,
      masteryPercentage: 0.0,
    );

    // Update performance
    final updated = performance.copyWith(
      attempts: performance.attempts + 1,
      correct: performance.correct + (isCorrect ? 1 : 0),
      totalTimeSeconds: performance.totalTimeSeconds + timeSpentSeconds,
      lastAttemptedAt: DateTime.now(),
      masteryPercentage: (performance.correct + (isCorrect ? 1 : 0)) / 
                         (performance.attempts + 1),
    );

    await updateTopicPerformance(updated);
  }
}

