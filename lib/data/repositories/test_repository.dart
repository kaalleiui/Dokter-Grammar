import '../datasources/local/test_local_datasource.dart';
import '../../core/models/test_session.dart';

class TestRepository {
  final TestLocalDataSource _dataSource = TestLocalDataSource();

  Future<int> createTestSession(TestSession session) async {
    return await _dataSource.createTestSession(session);
  }

  Future<void> updateTestSession(TestSession session) async {
    await _dataSource.updateTestSession(session);
  }

  Future<TestSession?> getTestSessionById(int sessionId) async {
    return await _dataSource.getTestSessionById(sessionId);
  }

  Future<int> createTestAttempt(TestAttempt attempt) async {
    return await _dataSource.createTestAttempt(attempt);
  }

  Future<void> updateTestAttempt(TestAttempt attempt) async {
    await _dataSource.updateTestAttempt(attempt);
  }

  Future<List<TestSession>> getUserTestSessions(int userId, {String? sessionType}) async {
    return await _dataSource.getUserTestSessions(userId, sessionType: sessionType);
  }

  Future<bool> hasUserCompletedPlacementTest(int userId) async {
    return await _dataSource.hasUserCompletedPlacementTest(userId);
  }
}

