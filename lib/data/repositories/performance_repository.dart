import '../datasources/local/performance_local_datasource.dart';
import '../../core/models/topic_performance.dart';

class PerformanceRepository {
  final PerformanceLocalDataSource _dataSource = PerformanceLocalDataSource();

  Future<void> updateTopicPerformance(TopicPerformance performance) async {
    await _dataSource.updateTopicPerformance(performance);
  }

  Future<TopicPerformance?> getTopicPerformance(int userId, int topicId) async {
    return await _dataSource.getTopicPerformance(userId, topicId);
  }

  Future<Map<int, TopicPerformance>> getUserTopicPerformances(int userId) async {
    return await _dataSource.getUserTopicPerformances(userId);
  }

  Future<void> recordAttempt({
    required int userId,
    required int topicId,
    required bool isCorrect,
    required int timeSpentSeconds,
  }) async {
    await _dataSource.recordAttempt(
      userId: userId,
      topicId: topicId,
      isCorrect: isCorrect,
      timeSpentSeconds: timeSpentSeconds,
    );
  }
}

