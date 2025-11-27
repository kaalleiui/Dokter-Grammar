import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/user_profile.dart';

class UserLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> createUser(UserProfile user) async {
    final db = await _dbHelper.database;
    
    // Insert user
    final userId = await db.insert(
      'users',
      {
        'nickname': user.nickname,
        'goal': user.goal,
        'current_level': user.currentLevel,
        'overall_score': user.overallScore,
        'streak_days': user.streakDays,
        'last_activity_date': user.lastActivityDate?.toIso8601String(),
        'created_at': user.createdAt.toIso8601String(),
        'updated_at': user.updatedAt.toIso8601String(),
      },
    );

    // Insert interests
    for (final interest in user.interests) {
      await db.insert(
        'user_interests',
        {
          'user_id': userId,
          'interest': interest,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    return userId;
  }

  Future<UserProfile?> getUserById(int id) async {
    final db = await _dbHelper.database;
    
    final userMaps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (userMaps.isEmpty) return null;

    final userMap = userMaps.first;
    
    // Get interests
    final interestMaps = await db.query(
      'user_interests',
      where: 'user_id = ?',
      whereArgs: [id],
    );
    final interests = interestMaps.map((map) => map['interest'] as String).toList();

    return UserProfile(
      id: userMap['id'] as int,
      nickname: userMap['nickname'] as String,
      goal: userMap['goal'] as String,
      currentLevel: userMap['current_level'] as String,
      overallScore: (userMap['overall_score'] as num).toDouble(),
      streakDays: userMap['streak_days'] as int,
      lastActivityDate: userMap['last_activity_date'] != null
          ? DateTime.parse(userMap['last_activity_date'] as String)
          : null,
      interests: interests,
      createdAt: DateTime.parse(userMap['created_at'] as String),
      updatedAt: DateTime.parse(userMap['updated_at'] as String),
    );
  }

  Future<UserProfile?> getCurrentUser() async {
    final db = await _dbHelper.database;
    
    final userMaps = await db.query(
      'users',
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (userMaps.isEmpty) return null;

    final userMap = userMaps.first;
    final userId = userMap['id'] as int;
    
    // Get interests
    final interestMaps = await db.query(
      'user_interests',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    final interests = interestMaps.map((map) => map['interest'] as String).toList();

    return UserProfile(
      id: userMap['id'] as int,
      nickname: userMap['nickname'] as String,
      goal: userMap['goal'] as String,
      currentLevel: userMap['current_level'] as String,
      overallScore: (userMap['overall_score'] as num).toDouble(),
      streakDays: userMap['streak_days'] as int,
      lastActivityDate: userMap['last_activity_date'] != null
          ? DateTime.parse(userMap['last_activity_date'] as String)
          : null,
      interests: interests,
      createdAt: DateTime.parse(userMap['created_at'] as String),
      updatedAt: DateTime.parse(userMap['updated_at'] as String),
    );
  }

  Future<void> updateUser(UserProfile user) async {
    if (user.id == null) return;
    
    final db = await _dbHelper.database;
    
    await db.update(
      'users',
      {
        'nickname': user.nickname,
        'goal': user.goal,
        'current_level': user.currentLevel,
        'overall_score': user.overallScore,
        'streak_days': user.streakDays,
        'last_activity_date': user.lastActivityDate?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [user.id],
    );

    // Update interests
    await db.delete('user_interests', where: 'user_id = ?', whereArgs: [user.id]);
    for (final interest in user.interests) {
      await db.insert(
        'user_interests',
        {
          'user_id': user.id,
          'interest': interest,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }
}

