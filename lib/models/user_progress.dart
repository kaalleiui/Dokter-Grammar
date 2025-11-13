import 'package:hive/hive.dart';

part 'user_progress.g.dart';

@HiveType(typeId: 0)
class UserProgress {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final int totalQuizzesCompleted;

  @HiveField(2)
  final int totalScore;

  @HiveField(3)
  final Map<String, int> categoryScores; // e.g., {'tenses': 85, 'vocabulary': 90}

  @HiveField(4)
  final DateTime lastQuizDate;

  UserProgress({
    required this.userId,
    required this.totalQuizzesCompleted,
    required this.totalScore,
    required this.categoryScores,
    required this.lastQuizDate,
  });

  // Factory constructor for creating from JSON (for Hive storage)
  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      userId: json['userId'] as String,
      totalQuizzesCompleted: json['totalQuizzesCompleted'] as int,
      totalScore: json['totalScore'] as int,
      categoryScores: Map<String, int>.from(json['categoryScores'] as Map),
      lastQuizDate: DateTime.parse(json['lastQuizDate'] as String),
    );
  }

  // Method to convert to JSON (for Hive storage)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalQuizzesCompleted': totalQuizzesCompleted,
      'totalScore': totalScore,
      'categoryScores': categoryScores,
      'lastQuizDate': lastQuizDate.toIso8601String(),
    };
  }

  // Method to update progress after a quiz
  UserProgress updateAfterQuiz(int score, String category) {
    final newTotalScore = totalScore + score;
    final newCategoryScores = Map<String, int>.from(categoryScores);
    newCategoryScores[category] = (newCategoryScores[category] ?? 0) + score;

    return UserProgress(
      userId: userId,
      totalQuizzesCompleted: totalQuizzesCompleted + 1,
      totalScore: newTotalScore,
      categoryScores: newCategoryScores,
      lastQuizDate: DateTime.now(),
    );
  }
}
