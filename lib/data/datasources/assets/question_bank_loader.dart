import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../../core/models/question.dart';

class QuestionBankLoader {
  static Future<List<Question>> loadQuestionsFromAssets() async {
    final List<Question> allQuestions = [];
    final List<String> validationErrors = [];
    final List<String> validationWarnings = [];
    
    // Load from multiple question bank files
    final List<String> bankFiles = [
      'assets/data/question_bank1.json',
      'assets/data/question_bank2.json',
      'assets/data/question_bank3.json',
      // Keep old file for backward compatibility
      'assets/data/question_bank.json',
    ];
    
    for (final filePath in bankFiles) {
      try {
        final String jsonString = await rootBundle.loadString(filePath);
        final List<dynamic> jsonData = json.decode(jsonString);
        final questions = jsonData.map((json) => Question.fromJson(json)).toList();
        
        // Validate each question
        for (final question in questions) {
          final validation = _validateQuestion(question);
          if (validation.isValid) {
            allQuestions.add(question);
          } else {
            if (validation.isError) {
              validationErrors.add('${question.id}: ${validation.message}');
            } else {
              validationWarnings.add('${question.id}: ${validation.message}');
              // Add question even with warnings (non-critical)
              allQuestions.add(question);
            }
          }
        }
      } catch (e) {
        // File doesn't exist or can't be loaded, skip it
        if (kDebugMode) {
          debugPrint('Warning: Could not load $filePath: $e');
        }
        continue;
      }
    }
    
    // Log validation results
    if (kDebugMode) {
      if (validationErrors.isNotEmpty) {
        debugPrint('❌ Question validation errors (${validationErrors.length}):');
        for (final error in validationErrors) {
          debugPrint('  • $error');
        }
      }
      if (validationWarnings.isNotEmpty) {
        debugPrint('⚠️  Question validation warnings (${validationWarnings.length}):');
        for (final warning in validationWarnings) {
          debugPrint('  • $warning');
        }
      }
      if (validationErrors.isEmpty && validationWarnings.isEmpty) {
        debugPrint('✅ All questions passed validation');
      }
    }
    
    // If no questions loaded, return sample questions
    if (allQuestions.isEmpty) {
      return _getSampleQuestions();
    }
    
    return allQuestions;
  }

  /// Validate a question and return validation result
  static _ValidationResult _validateQuestion(Question question) {
    // Check required fields
    if (question.id.isEmpty) {
      return _ValidationResult(false, true, 'Missing question ID');
    }
    if (question.answer.isEmpty) {
      return _ValidationResult(false, true, 'Missing answer field');
    }
    if (question.type.isEmpty) {
      return _ValidationResult(false, true, 'Missing question type');
    }

    // For questions with choices, validate answer matches isCorrect
    if (question.choices.isNotEmpty) {
      final correctChoices = question.choices.where((c) => c.isCorrect).toList();
      
      if (correctChoices.isEmpty) {
        // Try to find by matching answer field
        final matchingByAnswer = question.choices.firstWhere(
          (c) => c.choiceId.toLowerCase() == question.answer.toLowerCase(),
          orElse: () => QuestionChoice(choiceId: '', text: ''),
        );
        
        if (matchingByAnswer.choiceId.isEmpty) {
          return _ValidationResult(false, true, 'No correct choice found and answer field does not match any choiceId');
        } else {
          // Warning: answer matches but isCorrect not set
          return _ValidationResult(true, false, 'Answer field matches choiceId but isCorrect flag not set');
        }
      } else if (correctChoices.length > 1) {
        return _ValidationResult(false, true, 'Multiple choices have isCorrect: true (${correctChoices.length} found)');
      } else {
        // Check if answer field matches the correct choice
        final correctChoice = correctChoices.first;
        final answerIsChoiceId = question.choices.any(
          (c) => c.choiceId.toLowerCase() == question.answer.toLowerCase(),
        );
        
        if (answerIsChoiceId && question.answer.toLowerCase() != correctChoice.choiceId.toLowerCase()) {
          return _ValidationResult(false, true, 'Answer field "$question.answer" does not match correct choiceId "${correctChoice.choiceId}"');
        } else if (!answerIsChoiceId && question.type == 'gap_fill') {
          // For gap_fill, answer might be text - this is acceptable
          return _ValidationResult(true, false, 'Gap fill answer is text, not choiceId (acceptable)');
        } else if (!answerIsChoiceId) {
          return _ValidationResult(false, true, 'Answer field "$question.answer" does not match any choiceId');
        }
      }
    }

    return _ValidationResult(true, false, '');
  }

  static List<Question> _getSampleQuestions() {
    // Return sample questions for testing
    return [
      Question(
        id: 'q_sample_1',
        type: 'multiple_choice',
        difficulty: 2,
        topicId: 1, // tenses
        prompt: 'Choose the correct form: "I _____ to the store yesterday."',
        answer: 'b',
        explanationTemplate: 'Use simple past tense for completed actions in the past.',
        exampleSentence: 'I went to the store yesterday.',
        choices: [
          QuestionChoice(choiceId: 'a', text: 'go', isCorrect: false),
          QuestionChoice(choiceId: 'b', text: 'went', isCorrect: true),
          QuestionChoice(choiceId: 'c', text: 'going', isCorrect: false),
          QuestionChoice(choiceId: 'd', text: 'gone', isCorrect: false),
        ],
        tags: [
          QuestionTag(tagType: 'tense', tagValue: 'past'),
          QuestionTag(tagType: 'grammar_point', tagValue: 'simple_past'),
        ],
      ),
      Question(
        id: 'q_sample_2',
        type: 'multiple_choice',
        difficulty: 3,
        topicId: 4, // complex_sentences
        prompt: 'Choose the best sentence combination: "The book was interesting. I read it last week."',
        answer: 'b',
        explanationTemplate: 'Use a relative clause to combine the sentences.',
        exampleSentence: 'The book that I read last week was interesting.',
        choices: [
          QuestionChoice(choiceId: 'a', text: 'The book was interesting, I read it last week.', isCorrect: false),
          QuestionChoice(choiceId: 'b', text: 'The book that I read last week was interesting.', isCorrect: true),
          QuestionChoice(choiceId: 'c', text: 'The book was interesting that I read last week.', isCorrect: false),
          QuestionChoice(choiceId: 'd', text: 'The book interesting I read last week.', isCorrect: false),
        ],
        tags: [
          QuestionTag(tagType: 'grammar_point', tagValue: 'relative_clause'),
        ],
      ),
    ];
  }
}

class _ValidationResult {
  final bool isValid;
  final bool isError; // true = error (skip question), false = warning (include question)
  final String message;

  _ValidationResult(this.isValid, this.isError, this.message);
}

