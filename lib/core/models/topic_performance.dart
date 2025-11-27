class TopicPerformance {
  final int? id;
  final int userId;
  final int topicId;
  final int attempts;
  final int correct;
  final int totalTimeSeconds;
  final DateTime? lastAttemptedAt;
  final double masteryPercentage; // 0.0 to 1.0

  TopicPerformance({
    this.id,
    required this.userId,
    required this.topicId,
    this.attempts = 0,
    this.correct = 0,
    this.totalTimeSeconds = 0,
    this.lastAttemptedAt,
    this.masteryPercentage = 0.0,
  });

  double get accuracy => attempts > 0 ? correct / attempts : 0.0;
  double get averageTimeSeconds => attempts > 0 ? totalTimeSeconds / attempts : 0.0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'topicId': topicId,
    'attempts': attempts,
    'correct': correct,
    'totalTimeSeconds': totalTimeSeconds,
    'lastAttemptedAt': lastAttemptedAt?.toIso8601String(),
    'masteryPercentage': masteryPercentage,
  };

  factory TopicPerformance.fromJson(Map<String, dynamic> json) => TopicPerformance(
    id: json['id'],
    userId: json['userId'],
    topicId: json['topicId'],
    attempts: json['attempts'] ?? 0,
    correct: json['correct'] ?? 0,
    totalTimeSeconds: json['totalTimeSeconds'] ?? 0,
    lastAttemptedAt: json['lastAttemptedAt'] != null 
        ? DateTime.parse(json['lastAttemptedAt']) 
        : null,
    masteryPercentage: json['masteryPercentage']?.toDouble() ?? 0.0,
  );

  TopicPerformance copyWith({
    int? id,
    int? userId,
    int? topicId,
    int? attempts,
    int? correct,
    int? totalTimeSeconds,
    DateTime? lastAttemptedAt,
    double? masteryPercentage,
  }) {
    return TopicPerformance(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      topicId: topicId ?? this.topicId,
      attempts: attempts ?? this.attempts,
      correct: correct ?? this.correct,
      totalTimeSeconds: totalTimeSeconds ?? this.totalTimeSeconds,
      lastAttemptedAt: lastAttemptedAt ?? this.lastAttemptedAt,
      masteryPercentage: masteryPercentage ?? this.masteryPercentage,
    );
  }
}

