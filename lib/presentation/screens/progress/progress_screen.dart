import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/color_scheme.dart';
import '../../../core/constants/strings.dart';
import '../../../core/database/database_helper.dart';
import '../../../data/repositories/performance_repository.dart';
import '../../../data/repositories/test_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/models/topic_performance.dart';
import '../../widgets/common/modern_header.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  UserProfile? _user;
  Map<int, TopicPerformance> _topicPerformances = {};
  List<Map<String, dynamic>> _recentSessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    try {
      final userRepo = UserRepository();
      final user = await userRepo.getCurrentUser();
      
      if (user != null) {
        if (user.id == null) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: User ID tidak valid'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }

        final performanceRepo = PerformanceRepository();
        final performances = await performanceRepo.getUserTopicPerformances(user.id!);
        
        final testRepo = TestRepository();
        final sessions = await testRepo.getUserTestSessions(user.id!);
        
        // Get topic names
        final db = await DatabaseHelper.instance.database;
        final topicMaps = await db.query('topics');
        final topicNames = <int, String>{};
        for (final map in topicMaps) {
          final id = map['id'];
          final displayName = map['display_name'];
          if (id != null && displayName != null) {
            topicNames[id as int] = displayName as String;
          }
        }
        
        setState(() {
          _user = user;
          _topicPerformances = performances;
          _recentSessions = sessions.take(5).map((session) {
            return {
              'type': session.sessionType,
              'score': session.score,
              'date': session.completedAt ?? session.startedAt,
              'total': session.totalQuestions,
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final sortedTopics = _topicPerformances.entries.toList()
      ..sort((a, b) => a.value.masteryPercentage.compareTo(b.value.masteryPercentage));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            ModernHeader(
              title: AppStrings.progress,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Overall Stats Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(AppColors.radius),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.lemonMedium.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Statistik Keseluruhan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                context,
                                'Level',
                                _user?.currentLevel.toUpperCase() ?? 'N/A',
                                AppColors.textPrimary,
                              ),
                              _buildStatItem(
                                context,
                                'Skor',
                                _user != null ? '${(_user!.overallScore * 100).toInt()}%' : '0%',
                                AppColors.success,
                              ),
                              _buildStatItem(
                                context,
                                'Streak',
                                '${_user?.streakDays ?? 0} hari',
                                AppColors.warning,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Topic Performance Chart
                    if (sortedTopics.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppColors.lemonCardGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.lemonMedium.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Performa per Topik',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: _buildTopicChart(sortedTopics),
                        ),
                      ],
                    ),
                  ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Topic Performance List
                    if (sortedTopics.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppColors.lemonCardGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.lemonMedium.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Detail Topik',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...sortedTopics.map((entry) {
                              final performance = entry.value;
                              return _buildTopicItem(context, entry.key, performance);
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Recent Test Sessions
                    if (_recentSessions.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppColors.lemonCardGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.lemonMedium.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Test Terakhir',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ..._recentSessions.map((session) {
                              return _buildSessionItem(context, session);
                            }),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildTopicChart(List<MapEntry<int, TopicPerformance>> topics) {
    final topTopics = topics.take(6).toList();
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= topTopics.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'T${value.toInt() + 1}',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}%', style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        barGroups: topTopics.asMap().entries.map((entry) {
          final index = entry.key;
          final performance = entry.value.value;
          final percentage = (performance.masteryPercentage * 100).toInt();
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: percentage.toDouble(),
                color: _getPerformanceColor(performance.masteryPercentage),
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopicItem(BuildContext context, int topicId, TopicPerformance performance) {
    final percentage = (performance.masteryPercentage * 100).toInt();
    final accuracy = performance.attempts > 0
        ? (performance.correct / performance.attempts * 100).toInt()
        : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FutureBuilder<Map<int, String>>(
                future: _getTopicNames(),
                builder: (context, snapshot) {
                  final topicName = snapshot.data?[topicId] ?? 'Topik $topicId';
                  return Expanded(
                    child: Text(
                      topicName,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  );
                },
              ),
              Text(
                '$percentage%',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: _getPerformanceColor(performance.masteryPercentage),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: performance.masteryPercentage,
            backgroundColor: AppColors.lemonSoft,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getPerformanceColor(performance.masteryPercentage),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Akurasi: $accuracy%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '${performance.attempts} percobaan',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionItem(BuildContext context, Map<String, dynamic> session) {
    final score = session['score'] as double?;
    final scorePercent = score != null ? (score * 100).toInt() : 0;
    final date = session['date'] as DateTime;
    final type = session['type'] as String;
    final total = session['total'] as int;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getSessionTypeName(type),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$scorePercent%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _getScoreColor(score ?? 0),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$total soal',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPerformanceColor(double percentage) {
    if (percentage >= 0.8) return AppColors.success;
    if (percentage >= 0.6) return AppColors.warning;
    return AppColors.error;
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) return AppColors.success;
    if (score >= 0.6) return AppColors.warning;
    return AppColors.error;
  }

  String _getSessionTypeName(String type) {
    switch (type) {
      case 'placement':
        return 'Placement Test';
      case 'custom':
        return 'Custom Test';
      case 'daily':
        return 'Daily Test';
      case 'reassessment':
        return 'Reassessment';
      default:
        return type;
    }
  }

  Future<Map<int, String>> _getTopicNames() async {
    final db = await DatabaseHelper.instance.database;
    final topicMaps = await db.query('topics');
    final topicNames = <int, String>{};
    for (final map in topicMaps) {
      final id = map['id'];
      final displayName = map['display_name'];
      if (id != null && displayName != null) {
        topicNames[id as int] = displayName as String;
      }
    }
    return topicNames;
  }
}

