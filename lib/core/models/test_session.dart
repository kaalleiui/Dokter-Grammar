class TestSession {
  final int? id;
  final int userId;
  final String sessionType; // 'placement', 'custom', 'daily', 'reassessment'
  final int totalQuestions;
  final int completedQuestions;
  final double? score; // NULL until completed
  final String? levelBefore;
  final String? levelAfter;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? durationSeconds;
  final List<TestAttempt> attempts;

  TestSession({
    this.id,
    required this.userId,
    required this.sessionType,
    required this.totalQuestions,
    this.completedQuestions = 0,
    this.score,
    this.levelBefore,
    this.levelAfter,
    required this.startedAt,
    this.completedAt,
    this.durationSeconds,
    this.attempts = const [],
  });

  bool get isCompleted => completedAt != null;
  double get progress => totalQuestions > 0 ? completedQuestions / totalQuestions : 0.0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'sessionType': sessionType,
    'totalQuestions': totalQuestions,
    'completedQuestions': completedQuestions,
    'score': score,
    'levelBefore': levelBefore,
    'levelAfter': levelAfter,
    'startedAt': startedAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'durationSeconds': durationSeconds,
    'attempts': attempts.map((a) => a.toJson()).toList(),
  };

  factory TestSession.fromJson(Map<String, dynamic> json) => TestSession(
    id: json['id'],
    userId: json['userId'],
    sessionType: json['sessionType'],
    totalQuestions: json['totalQuestions'],
    completedQuestions: json['completedQuestions'] ?? 0,
    score: json['score']?.toDouble(),
    levelBefore: json['levelBefore'],
    levelAfter: json['levelAfter'],
    startedAt: DateTime.parse(json['startedAt']),
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    durationSeconds: json['durationSeconds'],
    attempts: (json['attempts'] as List?)
        ?.map((a) => TestAttempt.fromJson(a))
        .toList() ?? [],
  );

  TestSession copyWith({
    int? id,
    int? userId,
    String? sessionType,
    int? totalQuestions,
    int? completedQuestions,
    double? score,
    String? levelBefore,
    String? levelAfter,
    DateTime? startedAt,
    DateTime? completedAt,
    int? durationSeconds,
    List<TestAttempt>? attempts,
  }) {
    return TestSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionType: sessionType ?? this.sessionType,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      completedQuestions: completedQuestions ?? this.completedQuestions,
      score: score ?? this.score,
      levelBefore: levelBefore ?? this.levelBefore,
      levelAfter: levelAfter ?? this.levelAfter,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      attempts: attempts ?? this.attempts,
    );
  }
}

class TestAttempt {
  final int? id;
  final int sessionId;
  final String questionId;
  final String? userAnswer;
  final bool? isCorrect;
  final int? timeSpentSeconds;
  final bool hintUsed;
  final DateTime? answeredAt;

  TestAttempt({
    this.id,
    required this.sessionId,
    required this.questionId,
    this.userAnswer,
    this.isCorrect,
    this.timeSpentSeconds,
    this.hintUsed = false,
    this.answeredAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'sessionId': sessionId,
    'questionId': questionId,
    'userAnswer': userAnswer,
    'isCorrect': isCorrect == true ? 1 : (isCorrect == false ? 0 : null),
    'timeSpentSeconds': timeSpentSeconds,
    'hintUsed': hintUsed ? 1 : 0,
    'answeredAt': answeredAt?.toIso8601String(),
  };

  factory TestAttempt.fromJson(Map<String, dynamic> json) => TestAttempt(
    id: json['id'],
    sessionId: json['sessionId'],
    questionId: json['questionId'],
    userAnswer: json['userAnswer'],
    isCorrect: json['isCorrect'] == null ? null : (json['isCorrect'] == 1),
    timeSpentSeconds: json['timeSpentSeconds'],
    hintUsed: json['hintUsed'] == 1,
    answeredAt: json['answeredAt'] != null ? DateTime.parse(json['answeredAt']) : null,
  );
}

