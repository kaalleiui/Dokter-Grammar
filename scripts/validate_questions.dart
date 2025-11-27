import 'dart:convert';
import 'dart:io';

/// Question validation script
/// Validates question bank integrity and reports all issues
/// 
/// Usage: dart run scripts/validate_questions.dart

class QuestionValidator {
  final List<String> errors = [];
  final List<String> warnings = [];
  int totalQuestions = 0;
  int validQuestions = 0;
  int invalidQuestions = 0;

  Future<void> validateQuestionBank(String filePath) async {
    print('\n📋 Validating: $filePath');
    print('─' * 60);

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        errors.add('File not found: $filePath');
        return;
      }

      final jsonString = await file.readAsString();
      final List<dynamic> jsonData = json.decode(jsonString);

      for (int i = 0; i < jsonData.length; i++) {
        final questionJson = jsonData[i] as Map<String, dynamic>;
        totalQuestions++;
        validateQuestion(questionJson, i + 1);
      }
    } catch (e) {
      errors.add('Error reading $filePath: $e');
    }
  }

  void validateQuestion(Map<String, dynamic> question, int index) {
    final questionId = question['id'] as String? ?? 'unknown';
    bool isValid = true;

    // Check required fields
    if (question['id'] == null) {
      errors.add('Question #$index: Missing required field "id"');
      isValid = false;
    }
    if (question['type'] == null) {
      errors.add('Question #$index ($questionId): Missing required field "type"');
      isValid = false;
    }
    if (question['answer'] == null) {
      errors.add('Question #$index ($questionId): Missing required field "answer"');
      isValid = false;
    }
    if (question['choices'] == null && question['type'] != 'short_answer') {
      errors.add('Question #$index ($questionId): Missing required field "choices"');
      isValid = false;
    }

    // Validate answer matches isCorrect flag
    if (question['choices'] != null && question['answer'] != null) {
      final choices = question['choices'] as List<dynamic>;
      final answer = question['answer'] as String;
      final questionType = question['type'] as String;

      // Find choices with isCorrect: true
      final correctChoices = choices.where((c) {
        final choice = c as Map<String, dynamic>;
        return choice['isCorrect'] == true;
      }).toList();

      // Find choice with matching choiceId
      final matchingChoice = choices.firstWhere(
        (c) {
          final choice = c as Map<String, dynamic>;
          return choice['choiceId'] == answer;
        },
        orElse: () => null,
      );

      if (correctChoices.isEmpty) {
        errors.add(
          'Question #$index ($questionId): No choice has isCorrect: true',
        );
        isValid = false;
      } else if (correctChoices.length > 1) {
        errors.add(
          'Question #$index ($questionId): Multiple choices have isCorrect: true (${correctChoices.length} found)',
        );
        isValid = false;
      } else {
        // Check if answer field matches the correct choice
        final correctChoice = correctChoices.first as Map<String, dynamic>;
        final correctChoiceId = correctChoice['choiceId'] as String;

        if (questionType == 'gap_fill') {
          // For gap_fill, answer might be text or choiceId
          final correctChoiceText = correctChoice['text'] as String? ?? '';
          if (answer != correctChoiceId && answer != correctChoiceText) {
            warnings.add(
              'Question #$index ($questionId): Gap fill answer "$answer" doesn\'t match correct choiceId "$correctChoiceId" or text "$correctChoiceText"',
            );
          }
        } else {
          // For other types, answer should match choiceId
          if (answer != correctChoiceId) {
            errors.add(
              'Question #$index ($questionId): Answer field "$answer" doesn\'t match correct choiceId "$correctChoiceId"',
            );
            isValid = false;
          }
        }
      }

      // Check if matching choice exists
      if (matchingChoice == null && questionType != 'gap_fill') {
        warnings.add(
          'Question #$index ($questionId): Answer "$answer" doesn\'t match any choiceId',
        );
      }
    }

    // Validate explanation template
    if (question['explanationTemplate'] != null) {
      final template = question['explanationTemplate'] as String;
      if (template.trim().isEmpty) {
        warnings.add('Question #$index ($questionId): Empty explanation template');
      }
    }

    // Validate example sentence
    if (question['exampleSentence'] != null) {
      final example = question['exampleSentence'] as String;
      if (example.trim().isEmpty) {
        warnings.add('Question #$index ($questionId): Empty example sentence');
      }
    }

    if (isValid) {
      validQuestions++;
    } else {
      invalidQuestions++;
    }
  }

  void printReport() {
    print('\n' + '=' * 60);
    print('📊 VALIDATION REPORT');
    print('=' * 60);
    print('Total Questions: $totalQuestions');
    print('✅ Valid Questions: $validQuestions');
    print('❌ Invalid Questions: $invalidQuestions');
    print('⚠️  Warnings: ${warnings.length}');
    print('🔴 Errors: ${errors.length}');
    print('=' * 60);

    if (warnings.isNotEmpty) {
      print('\n⚠️  WARNINGS (${warnings.length}):');
      print('─' * 60);
      for (final warning in warnings) {
        print('  • $warning');
      }
    }

    if (errors.isNotEmpty) {
      print('\n🔴 ERRORS (${errors.length}):');
      print('─' * 60);
      for (final error in errors) {
        print('  • $error');
      }
    }

    if (errors.isEmpty && warnings.isEmpty) {
      print('\n✅ All questions are valid!');
    } else if (errors.isEmpty) {
      print('\n✅ No critical errors found, but please review warnings.');
    } else {
      print('\n❌ CRITICAL ERRORS FOUND - Please fix before presentation!');
    }
  }
}

Future<void> main() async {
  print('🔍 Question Bank Validator');
  print('=' * 60);

  final validator = QuestionValidator();

  // Validate all question bank files
  final questionBanks = [
    'assets/data/question_bank.json',
    'assets/data/question_bank1.json',
    'assets/data/question_bank2.json',
    'assets/data/question_bank3.json',
  ];

  for (final bank in questionBanks) {
    await validator.validateQuestionBank(bank);
  }

  // Print final report
  validator.printReport();

  // Exit with error code if critical errors found
  if (validator.errors.isNotEmpty) {
    exit(1);
  }
}

