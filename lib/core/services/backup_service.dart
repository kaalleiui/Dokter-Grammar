import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../../data/repositories/user_repository.dart';

class BackupService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final UserRepository _userRepo = UserRepository();

  /// Export all user data to a JSON file
  Future<String> exportBackup() async {
    try {
      final user = await _userRepo.getCurrentUser();
      if (user == null) {
        throw Exception('No user found');
      }

      final db = await _dbHelper.database;
      final backupData = <String, dynamic>{};

      // Export user data
      backupData['user'] = {
        'id': user.id,
        'nickname': user.nickname,
        'goal': user.goal,
        'currentLevel': user.currentLevel,
        'overallScore': user.overallScore,
        'streakDays': user.streakDays,
        'lastActivityDate': user.lastActivityDate?.toIso8601String(),
        'interests': user.interests,
        'createdAt': user.createdAt.toIso8601String(),
        'updatedAt': user.updatedAt.toIso8601String(),
      };

      // Export test sessions
      final sessions = await db.query('test_sessions', where: 'user_id = ?', whereArgs: [user.id]);
      backupData['test_sessions'] = sessions;

      // Export test attempts
      final sessionIds = sessions.map((s) => s['id'] as int).toList();
      if (sessionIds.isNotEmpty) {
        final placeholders = sessionIds.map((_) => '?').join(',');
        final attempts = await db.query(
          'test_attempts',
          where: 'session_id IN ($placeholders)',
          whereArgs: sessionIds,
        );
        backupData['test_attempts'] = attempts;
      } else {
        backupData['test_attempts'] = [];
      }

      // Export topic performance
      final performances = await db.query(
        'user_topic_performance',
        where: 'user_id = ?',
        whereArgs: [user.id],
      );
      backupData['topic_performances'] = performances;

      // Export badges
      final badges = await db.query(
        'badges',
        where: 'user_id = ?',
        whereArgs: [user.id],
      );
      backupData['badges'] = badges;

      // Export daily activities
      final activities = await db.query(
        'daily_activities',
        where: 'user_id = ?',
        whereArgs: [user.id],
      );
      backupData['daily_activities'] = activities;

      // Create backup file
      final jsonString = jsonEncode(backupData);
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final fileName = 'dokter_grammar_backup_$timestamp.json';

      // Get documents directory
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      throw Exception('Failed to export backup: $e');
    }
  }

  /// Import backup from JSON file
  Future<void> importBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Backup file not found');
      }

      final jsonString = await file.readAsString();
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      final db = await _dbHelper.database;

      // Start transaction
      await db.transaction((txn) async {
        // Import user data
        final userData = backupData['user'] as Map<String, dynamic>;
        final userId = userData['id'] as int?;

        if (userId != null) {
          // Update existing user or create new
          await txn.insert(
            'users',
            {
              'id': userId,
              'nickname': userData['nickname'],
              'goal': userData['goal'],
              'current_level': userData['currentLevel'],
              'overall_score': userData['overallScore'],
              'streak_days': userData['streakDays'],
              'last_activity_date': userData['lastActivityDate'],
              'created_at': userData['createdAt'],
              'updated_at': userData['updatedAt'],
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          // Import interests
          final interests = (userData['interests'] as List).cast<String>();
          await txn.delete('user_interests', where: 'user_id = ?', whereArgs: [userId]);
          for (final interest in interests) {
            await txn.insert(
              'user_interests',
              {'user_id': userId, 'interest': interest},
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }

          // Import test sessions
          final sessions = backupData['test_sessions'] as List;
          for (final session in sessions) {
            await txn.insert(
              'test_sessions',
              {
                'id': session['id'],
                'user_id': userId,
                'session_type': session['session_type'],
                'total_questions': session['total_questions'],
                'completed_questions': session['completed_questions'],
                'score': session['score'],
                'level_before': session['level_before'],
                'level_after': session['level_after'],
                'started_at': session['started_at'],
                'completed_at': session['completed_at'],
                'duration_seconds': session['duration_seconds'],
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }

          // Import test attempts
          final attempts = backupData['test_attempts'] as List;
          for (final attempt in attempts) {
            await txn.insert(
              'test_attempts',
              {
                'id': attempt['id'],
                'session_id': attempt['session_id'],
                'question_id': attempt['question_id'],
                'user_answer': attempt['user_answer'],
                'is_correct': attempt['is_correct'],
                'time_spent_seconds': attempt['time_spent_seconds'],
                'hint_used': attempt['hint_used'],
                'answered_at': attempt['answered_at'],
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }

          // Import topic performances
          final performances = backupData['topic_performances'] as List;
          for (final perf in performances) {
            await txn.insert(
              'user_topic_performance',
              {
                'id': perf['id'],
                'user_id': userId,
                'topic_id': perf['topic_id'],
                'attempts': perf['attempts'],
                'correct': perf['correct'],
                'total_time_seconds': perf['total_time_seconds'],
                'last_attempted_at': perf['last_attempted_at'],
                'mastery_percentage': perf['mastery_percentage'],
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }

          // Import badges
          final badges = backupData['badges'] as List;
          for (final badge in badges) {
            await txn.insert(
              'badges',
              {
                'id': badge['id'],
                'user_id': userId,
                'badge_type': badge['badge_type'],
                'badge_name': badge['badge_name'],
                'earned_at': badge['earned_at'],
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }

          // Import daily activities
          final activities = backupData['daily_activities'] as List;
          for (final activity in activities) {
            await txn.insert(
              'daily_activities',
              {
                'id': activity['id'],
                'user_id': userId,
                'activity_date': activity['activity_date'],
                'tests_completed': activity['tests_completed'],
                'questions_answered': activity['questions_answered'],
                'time_spent_seconds': activity['time_spent_seconds'],
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      });
    } catch (e) {
      throw Exception('Failed to import backup: $e');
    }
  }

  /// Get list of backup files
  Future<List<FileSystemEntity>> getBackupFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync()
          .where((entity) => entity is File && entity.path.endsWith('.json'))
          .where((entity) => (entity as File).path.contains('dokter_grammar_backup'))
          .toList();
      
      // Sort by modification date (newest first)
      files.sort((a, b) {
        final aStat = (a as File).statSync();
        final bStat = (b as File).statSync();
        return bStat.modified.compareTo(aStat.modified);
      });
      
      return files;
    } catch (e) {
      return [];
    }
  }

  /// Delete backup file
  Future<void> deleteBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete backup: $e');
    }
  }

  /// Get backup file size in MB
  Future<double> getBackupSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final size = await file.length();
        return size / (1024 * 1024); // Convert to MB
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}

