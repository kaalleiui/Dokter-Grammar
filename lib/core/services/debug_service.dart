import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/question.dart';
import '../models/test_session.dart';
import '../models/user_profile.dart';

class DebugService {
  static DebugService? _instance;
  static DebugService get instance => _instance ??= DebugService._();
  
  DebugService._();

  Map<String, dynamic>? _config;
  List<Map<String, dynamic>> _logEntries = [];
  bool _enabled = false;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      final String jsonString = await rootBundle.loadString('assets/config/debug_config.json');
      _config = json.decode(jsonString);
      _enabled = _config?['enabled'] ?? false;
      _initialized = true;
      
      if (_enabled) {
        _log('debug_service', 'initialized', {
          'config': _config,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      // Config file not found, debug disabled
      _enabled = false;
      _initialized = true;
    }
  }

  bool get isEnabled => _enabled && _initialized;
  bool isCallbackEnabled(String callbackName) {
    if (!isEnabled) return false;
    return _config?['callbacks']?[callbackName] ?? false;
  }

  void _log(String event, String action, Map<String, dynamic> data) {
    if (!isEnabled) return;

    final entry = {
      'event': event,
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
      'data': data,
    };

    _logEntries.add(entry);

    // Limit log entries
    final maxEntries = _config?['maxLogEntries'] ?? 1000;
    if (_logEntries.length > maxEntries) {
      _logEntries.removeAt(0);
    }

    // Log to console if enabled
    if (_config?['logToConsole'] ?? false) {
      print('[DEBUG] $event.$action: ${json.encode(entry)}');
    }
  }

  // Test lifecycle callbacks
  void onTestStart({
    required String sessionType,
    required int totalQuestions,
    UserProfile? user,
    Map<String, dynamic>? metadata,
  }) {
    if (!isCallbackEnabled('onTestStart')) return;

    _log('test', 'start', {
      'sessionType': sessionType,
      'totalQuestions': totalQuestions,
      'userId': user?.id,
      'userLevel': user?.currentLevel,
      'userScore': user?.overallScore,
      'metadata': metadata ?? {},
    });
  }

  void onQuestionLoad({
    required List<Question> questions,
    required String source,
    Map<String, dynamic>? metadata,
  }) {
    if (!isCallbackEnabled('onQuestionLoad')) return;

    _log('question', 'load', {
      'source': source,
      'count': questions.length,
      'questionIds': questions.map((q) => q.id).toList(),
      'topics': questions.map((q) => q.topicId).toSet().toList(),
      'difficulties': questions.map((q) => q.difficulty).toList(),
      'metadata': metadata ?? {},
    });
  }

  void onQuestionDisplay({
    required Question question,
    required int questionIndex,
    required int totalQuestions,
    Map<String, dynamic>? metadata,
  }) {
    if (!isCallbackEnabled('onQuestionDisplay')) return;

    final questionData = _config?['includeQuestionData'] == true
        ? {
            'id': question.id,
            'type': question.type,
            'difficulty': question.difficulty,
            'topicId': question.topicId,
            'prompt': question.prompt,
            'choicesCount': question.choices.length,
            'tags': question.tags.map((t) => '${t.tagType}:${t.tagValue}').toList(),
          }
        : {
            'id': question.id,
            'type': question.type,
            'difficulty': question.difficulty,
            'topicId': question.topicId,
          };

    _log('question', 'display', {
      'questionIndex': questionIndex,
      'totalQuestions': totalQuestions,
      'progress': (questionIndex + 1) / totalQuestions,
      'question': questionData,
      'metadata': metadata ?? {},
    });
  }

  void onAnswerSelect({
    required Question question,
    required String? selectedAnswer,
    required int questionIndex,
    Map<String, dynamic>? metadata,
  }) {
    if (!isCallbackEnabled('onAnswerSelect')) return;

    _log('answer', 'select', {
      'questionId': question.id,
      'questionIndex': questionIndex,
      'selectedAnswer': selectedAnswer,
      'correctAnswer': question.answer,
      'isCorrect': selectedAnswer == question.answer,
      'metadata': metadata ?? {},
    });
  }

  void onAnswerSubmit({
    required Question question,
    required String answer,
    required bool isCorrect,
    required int timeSpentSeconds,
    required int questionIndex,
    Map<String, dynamic>? metadata,
  }) {
    if (!isCallbackEnabled('onAnswerSubmit')) return;

    _log('answer', 'submit', {
      'questionId': question.id,
      'questionIndex': questionIndex,
      'userAnswer': answer,
      'correctAnswer': question.answer,
      'isCorrect': isCorrect,
      'timeSpentSeconds': timeSpentSeconds,
      'metadata': metadata ?? {},
    });
  }

  void onQuestionChange({
    required int fromIndex,
    required int toIndex,
    required int totalQuestions,
    Map<String, dynamic>? metadata,
  }) {
    if (!isCallbackEnabled('onQuestionChange')) return;

    _log('navigation', 'question_change', {
      'fromIndex': fromIndex,
      'toIndex': toIndex,
      'direction': toIndex > fromIndex ? 'next' : 'previous',
      'totalQuestions': totalQuestions,
      'metadata': metadata ?? {},
    });
  }

  void onTestComplete({
    required TestSession session,
    required double score,
    required String level,
    required int totalQuestions,
    required int correctAnswers,
    Map<String, dynamic>? metadata,
  }) {
    if (!isCallbackEnabled('onTestComplete')) return;

    final performanceData = _config?['includePerformanceMetrics'] == true
        ? {
            'totalTimeSeconds': session.durationSeconds,
            'averageTimePerQuestion': session.durationSeconds != null
                ? (session.durationSeconds! / totalQuestions)
                : null,
            'correctAnswers': correctAnswers,
            'totalQuestions': totalQuestions,
            'accuracy': score,
          }
        : {
            'score': score,
            'level': level,
          };

    _log('test', 'complete', {
      'sessionId': session.id,
      'sessionType': session.sessionType,
      'score': score,
      'level': level,
      'levelBefore': session.levelBefore,
      'levelAfter': session.levelAfter,
      'performance': performanceData,
      'metadata': metadata ?? {},
    });
  }

  void onScoreCalculate({
    required List<Map<String, dynamic>> attempts,
    required double score,
    Map<String, dynamic>? metadata,
  }) {
    if (!isCallbackEnabled('onScoreCalculate')) return;

    _log('scoring', 'calculate', {
      'attemptsCount': attempts.length,
      'correctCount': attempts.where((a) => a['isCorrect'] == true).length,
      'score': score,
      'level': _determineLevel(score),
      'metadata': metadata ?? {},
    });
  }

  void onLevelUpdate({
    required String oldLevel,
    required String newLevel,
    required double score,
    Map<String, dynamic>? metadata,
  }) {
    if (!isCallbackEnabled('onLevelUpdate')) return;

    _log('user', 'level_update', {
      'oldLevel': oldLevel,
      'newLevel': newLevel,
      'score': score,
      'levelChanged': oldLevel != newLevel,
      'metadata': metadata ?? {},
    });
  }

  void onPerformanceUpdate({
    required int topicId,
    required int attempts,
    required int correct,
    required double masteryPercentage,
    Map<String, dynamic>? metadata,
  }) {
    if (!isCallbackEnabled('onPerformanceUpdate')) return;

    _log('performance', 'update', {
      'topicId': topicId,
      'attempts': attempts,
      'correct': correct,
      'masteryPercentage': masteryPercentage,
      'accuracy': attempts > 0 ? (correct / attempts) : 0.0,
      'metadata': metadata ?? {},
    });
  }

  // Utility methods
  String _determineLevel(double score) {
    if (score >= 0.85) return 'advanced';
    if (score >= 0.70) return 'upper_intermediate';
    if (score >= 0.55) return 'intermediate';
    if (score >= 0.40) return 'elementary';
    return 'beginner';
  }

  // Export logs
  Future<String> exportLogs({bool formatted = true}) async {
    final logs = {
      'exportedAt': DateTime.now().toIso8601String(),
      'totalEntries': _logEntries.length,
      'config': _config,
      'logs': _logEntries,
    };

    if (formatted) {
      return const JsonEncoder.withIndent('  ').convert(logs);
    }
    return json.encode(logs);
  }

  // Save logs to file
  Future<File?> saveLogsToFile({String? filename}) async {
    if (!isEnabled || _config?['logToFile'] != true) return null;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${filename ?? 'debug_log_${DateTime.now().millisecondsSinceEpoch}.json'}');
      final logsJson = await exportLogs();
      await file.writeAsString(logsJson);
      return file;
    } catch (e) {
      print('Error saving debug logs: $e');
      return null;
    }
  }

  // Get logs as list
  List<Map<String, dynamic>> getLogs() {
    return List.unmodifiable(_logEntries);
  }

  // Clear logs
  void clearLogs() {
    _logEntries.clear();
  }

  // Get summary
  Map<String, dynamic> getSummary() {
    if (_logEntries.isEmpty) {
      return {'totalEntries': 0};
    }

    final events = _logEntries.map((e) => e['event'] as String).toList();
    final eventCounts = <String, int>{};
    for (final event in events) {
      eventCounts[event] = (eventCounts[event] ?? 0) + 1;
    }

    return {
      'totalEntries': _logEntries.length,
      'firstEntry': _logEntries.first['timestamp'],
      'lastEntry': _logEntries.last['timestamp'],
      'eventCounts': eventCounts,
      'enabled': isEnabled,
    };
  }
}

