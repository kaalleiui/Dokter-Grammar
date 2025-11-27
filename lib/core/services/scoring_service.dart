import '../constants/app_constants.dart';
import '../models/test_session.dart';
import '../models/question.dart';

class ScoringService {
  /// Calculate overall score from test attempts
  static double calculateScore(List<TestAttempt> attempts) {
    if (attempts.isEmpty) return 0.0;
    
    final correctCount = attempts.where((a) => a.isCorrect == true).length;
    return correctCount / attempts.length;
  }

  /// Determine level from score
  static String determineLevel(double score) {
    if (score <= AppConstants.beginnerMax) {
      return AppConstants.levels[0]; // beginner
    } else if (score <= AppConstants.elementaryMax) {
      return AppConstants.levels[1]; // elementary
    } else if (score <= AppConstants.intermediateMax) {
      return AppConstants.levels[2]; // intermediate
    } else if (score <= AppConstants.upperIntermediateMax) {
      return AppConstants.levels[3]; // upper_intermediate
    } else {
      return AppConstants.levels[4]; // advanced
    }
  }

  /// Check if answer is correct
  /// Validates answer-isCorrect consistency and handles all question types correctly
  static bool isAnswerCorrect(Question question, String? userAnswer) {
    if (userAnswer == null || userAnswer.isEmpty) return false;
    
    switch (question.type) {
      case 'multiple_choice':
        // For multiple_choice, answer should be choiceId
        // User answer is also choiceId
        return question.answer.toLowerCase().trim() == userAnswer.toLowerCase().trim();
        
      case 'gap_fill':
        // For gap_fill, answer might be text or choiceId
        // User answer might be choiceId (if selecting from choices) or text
        if (question.choices.isNotEmpty) {
          // Check if userAnswer is a choiceId
          final userChoice = question.choices.firstWhere(
            (c) => c.choiceId.toLowerCase() == userAnswer.toLowerCase(),
            orElse: () => QuestionChoice(choiceId: '', text: ''),
          );
          
          if (userChoice.choiceId.isNotEmpty) {
            // User selected a choice (choiceId)
            // Check if answer field is choiceId or text
            final answerIsChoiceId = question.choices.any(
              (c) => c.choiceId.toLowerCase() == question.answer.toLowerCase().trim(),
            );
            
            if (answerIsChoiceId) {
              // Answer is choiceId, compare choiceIds
              return question.answer.toLowerCase().trim() == userAnswer.toLowerCase().trim();
            } else {
              // Answer is text, get correct choice by isCorrect flag and compare text
              final correctChoice = question.choices.firstWhere(
                (c) => c.isCorrect,
                orElse: () => QuestionChoice(choiceId: '', text: ''),
              );
              
              if (correctChoice.choiceId.isNotEmpty) {
                // Compare user's choice text with correct choice text
                return userChoice.text.toLowerCase().trim() == correctChoice.text.toLowerCase().trim();
              } else {
                // No isCorrect flag, fallback to comparing answer text with user choice text
                return question.answer.toLowerCase().trim() == userChoice.text.toLowerCase().trim();
              }
            }
          } else {
            // UserAnswer is not a choiceId, treat as text
            // Compare directly with answer field
            return question.answer.toLowerCase().trim() == userAnswer.toLowerCase().trim();
          }
        } else {
          // No choices, treat as direct text comparison
          return question.answer.toLowerCase().trim() == userAnswer.toLowerCase().trim();
        }
        
      case 'short_answer':
        // Direct text comparison
        return question.answer.toLowerCase().trim() == userAnswer.toLowerCase().trim();
        
      case 'reorder':
        // For reorder, answer is typically a sequence string
        return question.answer.toLowerCase().trim() == userAnswer.toLowerCase().trim();
        
      default:
        // Default: direct comparison
        return question.answer.toLowerCase().trim() == userAnswer.toLowerCase().trim();
    }
  }

  /// Calculate topic performance breakdown
  static Map<int, Map<String, dynamic>> calculateTopicBreakdown(
    List<TestAttempt> attempts,
    Map<String, Question> questionMap,
  ) {
    final topicStats = <int, Map<String, dynamic>>{};
    
    for (final attempt in attempts) {
      final question = questionMap[attempt.questionId];
      if (question == null) continue;
      
      final topicId = question.topicId;
      if (!topicStats.containsKey(topicId)) {
        topicStats[topicId] = {
          'attempts': 0,
          'correct': 0,
          'total': 0,
        };
      }
      
      final stats = topicStats[topicId]!;
      stats['attempts'] = (stats['attempts'] as int) + 1;
      stats['total'] = (stats['total'] as int) + 1;
      
      if (attempt.isCorrect == true) {
        stats['correct'] = (stats['correct'] as int) + 1;
      }
    }
    
    // Calculate percentages
    for (final topicId in topicStats.keys) {
      final stats = topicStats[topicId]!;
      final attempts = stats['attempts'] as int;
      final correct = stats['correct'] as int;
      stats['percentage'] = attempts > 0 ? (correct / attempts) : 0.0;
    }
    
    return topicStats;
  }
}

