import '../datasources/local/question_local_datasource.dart';
import '../../core/models/question.dart';

class QuestionRepository {
  final QuestionLocalDataSource _dataSource = QuestionLocalDataSource();

  Future<void> insertQuestion(Question question) async {
    await _dataSource.insertQuestion(question);
  }

  Future<void> insertQuestions(List<Question> questions) async {
    await _dataSource.insertQuestions(questions);
  }

  Future<Question?> getQuestionById(String questionId) async {
    return await _dataSource.getQuestionById(questionId);
  }

  Future<List<Question>> getQuestionsByTopic(int topicId, {int? limit}) async {
    return await _dataSource.getQuestionsByTopic(topicId, limit: limit);
  }

  Future<List<Question>> getQuestionsForPlacement({
    required List<String> userInterests,
    int totalQuestions = 50,
  }) async {
    return await _dataSource.getQuestionsForPlacement(
      userInterests: userInterests,
      totalQuestions: totalQuestions,
    );
  }

  Future<int> getQuestionCount() async {
    return await _dataSource.getQuestionCount();
  }
}

