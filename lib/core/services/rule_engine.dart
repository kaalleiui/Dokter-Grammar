import 'dart:convert';
import 'package:flutter/services.dart';

class RuleEngine {
  static Map<String, dynamic>? _grammarRules;
  static Map<String, dynamic>? _explanationTemplates;

  /// Load grammar rules from assets
  static Future<void> loadRules() async {
    try {
      final rulesString = await rootBundle.loadString('assets/rules/grammar_rules.json');
      _grammarRules = json.decode(rulesString);
    } catch (e) {
      _grammarRules = {};
    }
  }

  /// Load explanation templates from assets
  static Future<void> loadTemplates() async {
    try {
      final templatesString = await rootBundle.loadString('assets/templates/explanations.json');
      _explanationTemplates = json.decode(templatesString);
    } catch (e) {
      _explanationTemplates = {};
    }
  }

  /// Get grammar rule for a specific grammar point
  static Map<String, dynamic>? getRuleForGrammarPoint(String grammarPoint) {
    if (_grammarRules == null) return null;
    
    final rules = _grammarRules!['rules'] as List?;
    if (rules == null) return null;

    for (final rule in rules) {
      if (rule['rule_id'] == grammarPoint || 
          rule['topic'] == grammarPoint) {
        return rule as Map<String, dynamic>;
      }
    }
    return null;
  }

  /// Get explanation template for question type
  static String? getTemplateForQuestionType(String questionType, {String? topic, bool isCorrect = false}) {
    if (_explanationTemplates == null) return null;
    
    final templates = _explanationTemplates!['templates'] as List?;
    if (templates == null) return null;

    for (final template in templates) {
      final templateMap = template as Map<String, dynamic>;
      final templateType = templateMap['question_type'] as String?;
      final templateTopic = templateMap['topic'] as String?;
      final templateId = templateMap['template_id'] as String?;
      
      // Match by type and correctness
      if (templateType == questionType) {
        if (isCorrect && templateId?.contains('correct') == true) {
          return templateMap['template'] as String?;
        } else if (!isCorrect && templateId?.contains('incorrect') == true) {
          // Also check topic match if specified
          if (topic == null || templateTopic == null || templateTopic == topic) {
            return templateMap['template'] as String?;
          }
        }
      }
    }
    return null;
  }

  /// Get common error explanation
  static String? getCommonErrorExplanation(String grammarPoint, String errorPattern) {
    final rule = getRuleForGrammarPoint(grammarPoint);
    if (rule == null) return null;

    final commonErrors = rule['common_errors'] as List?;
    if (commonErrors == null) return null;

    for (final error in commonErrors) {
      if (error['error_pattern'] == errorPattern) {
        return error['explanation'] as String?;
      }
    }
    return null;
  }

  /// Initialize rule engine (load rules and templates)
  static Future<void> initialize() async {
    await Future.wait([
      loadRules(),
      loadTemplates(),
    ]);
  }
}

