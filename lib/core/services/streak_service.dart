import '../../data/repositories/user_repository.dart';

class StreakService {
  final UserRepository _userRepo = UserRepository();

  /// Update user streak based on activity
  Future<void> updateStreak(int userId) async {
    final user = await _userRepo.getUserById(userId);
    if (user == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    DateTime? lastActivityDate;
    if (user.lastActivityDate != null) {
      lastActivityDate = DateTime(
        user.lastActivityDate!.year,
        user.lastActivityDate!.month,
        user.lastActivityDate!.day,
      );
    }

    int newStreak = user.streakDays;

    if (lastActivityDate == null) {
      // First activity
      newStreak = 1;
    } else {
      final daysDifference = today.difference(lastActivityDate).inDays;
      
      if (daysDifference == 0) {
        // Same day, no change
        return;
      } else if (daysDifference == 1) {
        // Consecutive day, increment streak
        newStreak = user.streakDays + 1;
      } else {
        // Streak broken, reset to 1
        newStreak = 1;
      }
    }

    // Update user
    await _userRepo.updateUser(user.copyWith(
      streakDays: newStreak,
      lastActivityDate: now,
    ));
  }

  /// Check if user has activity today
  Future<bool> hasActivityToday(int userId) async {
    final user = await _userRepo.getUserById(userId);
    if (user == null || user.lastActivityDate == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActivity = DateTime(
      user.lastActivityDate!.year,
      user.lastActivityDate!.month,
      user.lastActivityDate!.day,
    );

    return today == lastActivity;
  }

  /// Get streak status message
  String getStreakMessage(int streakDays) {
    if (streakDays == 0) {
      return 'Mulai streak Anda hari ini!';
    } else if (streakDays == 1) {
      return 'Streak 1 hari! Lanjutkan!';
    } else if (streakDays < 7) {
      return 'Streak $streakDays hari! Pertahankan!';
    } else if (streakDays < 30) {
      return 'Streak $streakDays hari! Luar biasa!';
    } else {
      return 'Streak $streakDays hari! Fantastis!';
    }
  }
}

