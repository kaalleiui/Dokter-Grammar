import '../models/question.dart';
import 'explanation_service.dart';

/// AI Service for on-device model inference
/// Currently uses rule-based fallback (as per spec: "If on-device heavy model not feasible, fallback to templated explanations")
class AIService {
  static bool _modelAvailable = false;
  static Map<String, dynamic>? _modelConfig;

  /// Initialize AI service (load model config)
  static Future<void> initialize() async {
    try {
      // Try to load model config
      // In a real implementation, this would load the ONNX model
      // For now, we use rule-based fallback as specified
      _modelAvailable = false; // Model not available, use fallback
      _modelConfig = {
        'model_name': 'grammar_explainer_v1',
        'model_type': 'lightweight_generative',
        'fallback_to_template': true,
      };
    } catch (e) {
      _modelAvailable = false;
      _modelConfig = {'fallback_to_template': true};
    }
  }

  /// Generate explanation using AI model (or fallback to rule-based)
  static Future<Map<String, dynamic>> generateExplanation({
    required Question question,
    required String? userAnswer,
    required bool? isCorrect,
    required List<String> userInterests,
    Map<String, dynamic>? context,
  }) async {
    // If model not available, use rule-based fallback
    if (!_modelAvailable || _modelConfig?['fallback_to_template'] == true) {
      return _generateRuleBasedExplanation(
        question: question,
        userAnswer: userAnswer,
        isCorrect: isCorrect,
      );
    }

    // TODO: In future, implement actual ONNX model inference here
    // For now, always use rule-based
    return _generateRuleBasedExplanation(
      question: question,
      userAnswer: userAnswer,
      isCorrect: isCorrect,
    );
  }

  /// Generate rule-based explanation (fallback)
  static Map<String, dynamic> _generateRuleBasedExplanation({
    required Question question,
    required String? userAnswer,
    required bool? isCorrect,
  }) {
    final explanationService = ExplanationService();
    final explanation = explanationService.generateExplanation(
      question: question,
      userAnswer: userAnswer,
      isCorrect: isCorrect,
    );

    return {
      'text': explanation,
      'type': 'rule_based',
      'confidence': 1.0,
      'rule_applied': _getRuleIdFromQuestion(question),
      'example': question.exampleSentence,
      'follow_up_available': false,
      'related_topics': _getRelatedTopics(question),
      'generation_time_ms': 0,
    };
  }

  /// Get rule ID from question tags
  static String? _getRuleIdFromQuestion(Question question) {
    final grammarPointTag = question.tags.firstWhere(
      (tag) => tag.tagType == 'grammar_point',
      orElse: () => QuestionTag(tagType: '', tagValue: ''),
    );
    return grammarPointTag.tagValue.isNotEmpty ? grammarPointTag.tagValue : null;
  }

  /// Get related topics from question tags
  static List<String> _getRelatedTopics(Question question) {
    return question.tags
        .where((tag) => tag.tagType == 'grammar_point' || tag.tagType == 'topic')
        .map((tag) => tag.tagValue)
        .toList();
  }

  /// Check if AI model is available
  static bool get isModelAvailable => _modelAvailable;

  /// Get model configuration
  static Map<String, dynamic>? get modelConfig => _modelConfig;
}

