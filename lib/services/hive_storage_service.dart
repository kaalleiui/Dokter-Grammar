import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_progress.dart';

class HiveStorageService {
  static const String _userProgressBoxName = 'userProgress';

  // Initialize Hive (call this in main.dart)
  static Future<void> init() async {
    await Hive.initFlutter();
    // Register adapters if needed
    Hive.registerAdapter(UserProgressAdapter());
  }

  // Save user progress
  Future<void> saveUserProgress(UserProgress progress) async {
    final box = await Hive.openBox<UserProgress>(_userProgressBoxName);
    await box.put(progress.userId, progress);
  }

  // Load user progress
  Future<UserProgress?> loadUserProgress(String userId) async {
    final box = await Hive.openBox<UserProgress>(_userProgressBoxName);
    return box.get(userId);
  }

  // Update user progress after quiz
  Future<void> updateUserProgress(String userId, int score, String category) async {
    final currentProgress = await loadUserProgress(userId);
    if (currentProgress != null) {
      final updatedProgress = currentProgress.updateAfterQuiz(score, category);
      await saveUserProgress(updatedProgress);
    } else {
      // Create new progress if none exists
      final newProgress = UserProgress(
        userId: userId,
        totalQuizzesCompleted: 1,
        totalScore: score,
        categoryScores: {category: score},
        lastQuizDate: DateTime.now(),
      );
      await saveUserProgress(newProgress);
    }
  }
}
