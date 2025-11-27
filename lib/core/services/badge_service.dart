import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/performance_repository.dart';
import '../../data/repositories/test_repository.dart';
import '../database/database_helper.dart';

class BadgeService {
  final UserRepository _userRepo = UserRepository();
  final PerformanceRepository _performanceRepo = PerformanceRepository();
  final TestRepository _testRepo = TestRepository();

  /// Check and award badges for user
  Future<List<String>> checkAndAwardBadges(int userId) async {
    final user = await _userRepo.getUserById(userId);
    if (user == null) return [];

    final newBadges = <String>[];

    // Streak badges
    if (user.streakDays >= 7 && !await _hasBadge(userId, 'streak_7')) {
      await _awardBadge(userId, 'streak_7', 'Streak 7 Hari');
      newBadges.add('streak_7');
    }
    if (user.streakDays >= 30 && !await _hasBadge(userId, 'streak_30')) {
      await _awardBadge(userId, 'streak_30', 'Streak 30 Hari');
      newBadges.add('streak_30');
    }
    if (user.streakDays >= 100 && !await _hasBadge(userId, 'streak_100')) {
      await _awardBadge(userId, 'streak_100', 'Streak 100 Hari');
      newBadges.add('streak_100');
    }

    // Level badges
    if (user.currentLevel == 'intermediate' && !await _hasBadge(userId, 'level_intermediate')) {
      await _awardBadge(userId, 'level_intermediate', 'Level Intermediate');
      newBadges.add('level_intermediate');
    }
    if (user.currentLevel == 'advanced' && !await _hasBadge(userId, 'level_advanced')) {
      await _awardBadge(userId, 'level_advanced', 'Level Advanced');
      newBadges.add('level_advanced');
    }

    // Test completion badges
    final sessions = await _testRepo.getUserTestSessions(userId);
    final completedCount = sessions.where((s) => s.isCompleted).length;
    
    if (completedCount >= 10 && !await _hasBadge(userId, 'tests_10')) {
      await _awardBadge(userId, 'tests_10', '10 Test Selesai');
      newBadges.add('tests_10');
    }
    if (completedCount >= 50 && !await _hasBadge(userId, 'tests_50')) {
      await _awardBadge(userId, 'tests_50', '50 Test Selesai');
      newBadges.add('tests_50');
    }

    // Topic mastery badges
    final performances = await _performanceRepo.getUserTopicPerformances(userId);
    final masteredTopics = performances.values.where((p) => p.masteryPercentage >= 0.8).length;
    
    if (masteredTopics >= 3 && !await _hasBadge(userId, 'master_3_topics')) {
      await _awardBadge(userId, 'master_3_topics', 'Master 3 Topik');
      newBadges.add('master_3_topics');
    }
    if (masteredTopics >= 5 && !await _hasBadge(userId, 'master_5_topics')) {
      await _awardBadge(userId, 'master_5_topics', 'Master 5 Topik');
      newBadges.add('master_5_topics');
    }

    return newBadges;
  }

  /// Get all badges for user
  Future<List<Map<String, dynamic>>> getUserBadges(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final badgeMaps = await db.query(
      'badges',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'earned_at DESC',
    );

    return badgeMaps.map((map) => {
      'badge_type': map['badge_type'] as String,
      'badge_name': map['badge_name'] as String,
      'earned_at': DateTime.parse(map['earned_at'] as String),
    }).toList();
  }

  Future<bool> _hasBadge(int userId, String badgeType) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'badges',
      where: 'user_id = ? AND badge_type = ?',
      whereArgs: [userId, badgeType],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<void> _awardBadge(int userId, String badgeType, String badgeName) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'badges',
      {
        'user_id': userId,
        'badge_type': badgeType,
        'badge_name': badgeName,
        'earned_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Get badge display name
  String getBadgeDisplayName(String badgeType) {
    switch (badgeType) {
      case 'streak_7':
        return 'Streak 7 Hari';
      case 'streak_30':
        return 'Streak 30 Hari';
      case 'streak_100':
        return 'Streak 100 Hari';
      case 'level_intermediate':
        return 'Level Intermediate';
      case 'level_advanced':
        return 'Level Advanced';
      case 'tests_10':
        return '10 Test Selesai';
      case 'tests_50':
        return '50 Test Selesai';
      case 'master_3_topics':
        return 'Master 3 Topik';
      case 'master_5_topics':
        return 'Master 5 Topik';
      default:
        return badgeType;
    }
  }

  /// Get badge icon
  IconData getBadgeIcon(String badgeType) {
    if (badgeType.startsWith('streak')) {
      return Icons.local_fire_department;
    } else if (badgeType.startsWith('level')) {
      return Icons.stars;
    } else if (badgeType.startsWith('tests')) {
      return Icons.quiz;
    } else if (badgeType.startsWith('master')) {
      return Icons.emoji_events;
    }
    return Icons.workspace_premium;
  }
}

