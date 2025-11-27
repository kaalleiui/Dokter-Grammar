import '../constants/app_constants.dart';
import '../models/question.dart';
import '../models/topic_performance.dart';
import '../../data/repositories/question_repository.dart';
import '../../data/repositories/performance_repository.dart';

class AdaptiveAlgorithm {
  final QuestionRepository _questionRepo = QuestionRepository();
  final PerformanceRepository _performanceRepo = PerformanceRepository();

  /// Get questions for custom test based on user's weak areas
  Future<List<Question>> getCustomTestQuestions({
    required int userId,
    required int totalQuestions,
    List<String>? userInterests,
  }) async {
    // Get user's topic performance
    final topicPerformances = await _getTopicPerformances(userId);
    
    // Sort topics by weakness (lowest mastery first)
    final sortedTopics = topicPerformances.entries.toList()
      ..sort((a, b) => a.value.masteryPercentage.compareTo(b.value.masteryPercentage));

    // Get weakest topics (top 3)
    final weakestTopics = sortedTopics.take(3).map((e) => e.key).toList();
    
    // Calculate question distribution
    final weakestCount = (totalQuestions * AppConstants.weakestTopicsWeight).round();
    final mediumCount = (totalQuestions * AppConstants.mediumTopicsWeight).round();
    final strongCount = totalQuestions - weakestCount - mediumCount;

    final allQuestions = <Question>[];

    // 50% from weakest topics
    final questionsPerWeakTopic = (weakestCount / weakestTopics.length).ceil();
    for (final topicId in weakestTopics) {
      final questions = await _questionRepo.getQuestionsByTopic(
        topicId,
        limit: questionsPerWeakTopic,
      );
      allQuestions.addAll(questions);
    }

    // 30% from medium topics
    final mediumTopics = sortedTopics
        .skip(3)
        .take((sortedTopics.length - 3) ~/ 2)
        .map((e) => e.key)
        .toList();
    if (mediumTopics.isNotEmpty) {
      final questionsPerMediumTopic = (mediumCount / mediumTopics.length).ceil();
      for (final topicId in mediumTopics) {
        final questions = await _questionRepo.getQuestionsByTopic(
          topicId,
          limit: questionsPerMediumTopic,
        );
        allQuestions.addAll(questions);
      }
    }

    // 20% from strong topics (for variety)
    final strongTopics = sortedTopics
        .skip(sortedTopics.length - (sortedTopics.length ~/ 3))
        .map((e) => e.key)
        .toList();
    if (strongTopics.isNotEmpty) {
      final questionsPerStrongTopic = (strongCount / strongTopics.length).ceil();
      for (final topicId in strongTopics) {
        final questions = await _questionRepo.getQuestionsByTopic(
          topicId,
          limit: questionsPerStrongTopic,
        );
        allQuestions.addAll(questions);
      }
    }

    // Filter by interests if provided
    if (userInterests != null && userInterests.isNotEmpty) {
      final filtered = allQuestions.where((q) {
        return q.tags.any((tag) =>
            tag.tagType == 'interest' && userInterests.contains(tag.tagValue));
      }).toList();
      
      // If filtered list is too small, mix with unfiltered
      if (filtered.length < totalQuestions * 0.5) {
        final mixed = <Question>[];
        mixed.addAll(filtered);
        mixed.addAll(allQuestions.where((q) => !filtered.contains(q)));
        allQuestions.clear();
        allQuestions.addAll(mixed);
      } else {
        allQuestions.clear();
        allQuestions.addAll(filtered);
      }
    }

    // Shuffle and limit to totalQuestions
    allQuestions.shuffle();
    return allQuestions.take(totalQuestions).toList();
  }

  /// Get questions for daily test (mixed, slightly biased to weak areas)
  Future<List<Question>> getDailyTestQuestions({
    required int userId,
    required int totalQuestions,
    List<String>? userInterests,
  }) async {
    final topicPerformances = await _getTopicPerformances(userId);
    
    // Sort by weakness
    final sortedTopics = topicPerformances.entries.toList()
      ..sort((a, b) => a.value.masteryPercentage.compareTo(b.value.masteryPercentage));

    // 40% from weak, 60% random
    final weakCount = (totalQuestions * 0.4).round();
    final randomCount = totalQuestions - weakCount;

    final allQuestions = <Question>[];

    // Get from weak topics
    final weakTopics = sortedTopics.take(3).map((e) => e.key).toList();
    if (weakTopics.isNotEmpty) {
      final questionsPerTopic = (weakCount / weakTopics.length).ceil();
      for (final topicId in weakTopics) {
        final questions = await _questionRepo.getQuestionsByTopic(
          topicId,
          limit: questionsPerTopic,
        );
        allQuestions.addAll(questions);
      }
    }

    // Get random from all topics
    final allTopicIds = topicPerformances.keys.toList();
    allTopicIds.shuffle();
    final randomQuestions = <Question>[];
    for (final topicId in allTopicIds) {
      if (randomQuestions.length >= randomCount) break;
      final questions = await _questionRepo.getQuestionsByTopic(
        topicId,
        limit: 2,
      );
      randomQuestions.addAll(questions);
    }
    allQuestions.addAll(randomQuestions);

    // Filter by interests if provided
    if (userInterests != null && userInterests.isNotEmpty) {
      final filtered = allQuestions.where((q) {
        return q.tags.any((tag) =>
            tag.tagType == 'interest' && userInterests.contains(tag.tagValue));
      }).toList();
      
      if (filtered.length >= totalQuestions * 0.5) {
        allQuestions.clear();
        allQuestions.addAll(filtered);
      }
    }

    allQuestions.shuffle();
    return allQuestions.take(totalQuestions).toList();
  }

  /// Get topic performances for user
  Future<Map<int, TopicPerformance>> _getTopicPerformances(int userId) async {
    return await _performanceRepo.getUserTopicPerformances(userId);
  }

  /// Get questions for reassessment (targeted or full)
  Future<List<Question>> getReassessmentQuestions({
    required int userId,
    required bool isTargeted,
    required int totalQuestions,
    List<String>? userInterests,
  }) async {
    if (isTargeted) {
      // Focus on weakest areas
      return await getCustomTestQuestions(
        userId: userId,
        totalQuestions: totalQuestions,
        userInterests: userInterests,
      );
    } else {
      // Full reassessment - similar to placement test
      return await _questionRepo.getQuestionsForPlacement(
        userInterests: userInterests ?? [],
        totalQuestions: totalQuestions,
      );
    }
  }
}

