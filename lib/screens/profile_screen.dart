import 'package:flutter/material.dart';
import 'dart:io';
import '../models/user.dart';
import '../models/submission.dart';
import '../models/problem.dart';
import '../services/database_service.dart';
import '../theme/candy_theme.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Submission> _submissions = [];
  List<Problem> _problems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final submissions = await DatabaseService().getSubmissions();
      final problems = await DatabaseService().getProblems();

      setState(() {
        _submissions = submissions;
        _problems = problems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  int get _solvedCount {
    final solvedProblemIds = _submissions
        .where((s) => s.status == 'Success')
        .map((s) => s.problemId)
        .toSet();
    return solvedProblemIds.length;
  }

  int get _totalSubmissions => _submissions.length;

  int get _successfulSubmissions =>
      _submissions.where((s) => s.status == 'Success').length;

  double get _successRate {
    if (_totalSubmissions == 0) return 0.0;
    return (_successfulSubmissions / _totalSubmissions) * 100;
  }

  Map<String, int> get _difficultyBreakdown {
    final solvedProblemIds = _submissions
        .where((s) => s.status == 'Success')
        .map((s) => s.problemId)
        .toSet();

    final solvedProblems =
        _problems.where((p) => solvedProblemIds.contains(p.id));

    final breakdown = <String, int>{
      'Easy': 0,
      'Medium': 0,
      'Hard': 0,
    };

    for (var problem in solvedProblems) {
      breakdown[problem.difficulty] = (breakdown[problem.difficulty] ?? 0) + 1;
    }

    return breakdown;
  }

  Map<String, int> get _topicBreakdown {
    final solvedProblemIds = _submissions
        .where((s) => s.status == 'Success')
        .map((s) => s.problemId)
        .toSet();

    final solvedProblems =
        _problems.where((p) => solvedProblemIds.contains(p.id));

    final breakdown = <String, int>{};

    for (var problem in solvedProblems) {
      breakdown[problem.topic] = (breakdown[problem.topic] ?? 0) + 1;
    }

    return breakdown;
  }

  List<String> get _achievements {
    final achievements = <String>[];

    // First submission
    if (_totalSubmissions > 0) {
      achievements.add('First Steps');
    }

    // First success
    if (_successfulSubmissions > 0) {
      achievements.add('Problem Solver');
    }

    // Solve 5 problems
    if (_solvedCount >= 5) {
      achievements.add('Rising Star');
    }

    // Solve 10 problems
    if (_solvedCount >= 10) {
      achievements.add('Code Master');
    }

    // 100% success rate with at least 5 submissions
    if (_totalSubmissions >= 5 && _successRate == 100) {
      achievements.add('Perfectionist');
    }

    // Streak achievements
    if (widget.user.streak >= 3) {
      achievements.add('Committed');
    }
    if (widget.user.streak >= 7) {
      achievements.add('Dedicated');
    }
    if (widget.user.streak >= 30) {
      achievements.add('Unstoppable');
    }

    // Point milestones
    if (widget.user.points >= 100) {
      achievements.add('Century Club');
    }
    if (widget.user.points >= 500) {
      achievements.add('Point Champion');
    }

    return achievements;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Profile Header
                  _buildProfileHeader(),
                  const SizedBox(height: 24),

                  // Statistics Grid
                  _buildStatisticsGrid(),
                  const SizedBox(height: 24),

                  // Difficulty Breakdown
                  _buildDifficultyBreakdown(),
                  const SizedBox(height: 24),

                  // Topic Breakdown
                  if (_topicBreakdown.isNotEmpty) ...[
                    _buildTopicBreakdown(),
                    const SizedBox(height: 24),
                  ],

                  // Achievements
                  _buildAchievements(),
                  const SizedBox(height: 24),

                  // Recent Activity
                  _buildRecentActivity(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CandyColors.pink,
            CandyColors.purple,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CandyColors.pink,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
            ),
            child: ClipOval(
              child: widget.user.avatar.isEmpty
                  ? Center(
                      child: Text(
                        widget.user.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : (widget.user.avatar.startsWith('http')
                      ? Image.network(
                          widget.user.avatar,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                widget.user.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        )
                      : File(widget.user.avatar).existsSync()
                          ? Image.file(
                              File(widget.user.avatar),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: Text(
                                widget.user.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            widget.user.name,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          // Points
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.user.points} Points',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Streak
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.user.streak} Day Streak',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.check_circle,
                iconColor: CandyColors.green,
                label: 'Solved',
                value: '$_solvedCount',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.code,
                iconColor: CandyColors.blue,
                label: 'Submissions',
                value: '$_totalSubmissions',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.trending_up,
                iconColor: CandyColors.purple,
                label: 'Success Rate',
                value: '${_successRate.toStringAsFixed(1)}%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.star,
                iconColor: CandyColors.yellow,
                label: 'Achievements',
                value: '${_achievements.length}',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDifficultyBreakdown() {
    final breakdown = _difficultyBreakdown;
    final total = _solvedCount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: CandyTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Problems by Difficulty',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildProgressBar(
            label: 'Easy',
            count: breakdown['Easy'] ?? 0,
            total: total,
            color: CandyColors.green,
          ),
          const SizedBox(height: 12),
          _buildProgressBar(
            label: 'Medium',
            count: breakdown['Medium'] ?? 0,
            total: total,
            color: CandyColors.yellow,
          ),
          const SizedBox(height: 12),
          _buildProgressBar(
            label: 'Hard',
            count: breakdown['Hard'] ?? 0,
            total: total,
            color: CandyColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar({
    required String label,
    required int count,
    required int total,
    required Color color,
  }) {
    final percentage = total > 0 ? (count / total) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '$count',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildTopicBreakdown() {
    final breakdown = _topicBreakdown;
    final sortedTopics = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: CandyTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Topics Mastered',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ...sortedTopics.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: CandyColors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          entry.key,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    Text(
                      '${entry.value} solved',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: CandyColors.textLight,
                          ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    final achievements = _achievements;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        if (achievements.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: CandyTheme.cardDecoration,
            child: Center(
              child: Text(
                'No achievements yet. Keep solving problems!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: CandyColors.textLight,
                    ),
              ),
            ),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: achievements
                .map((achievement) => _AchievementBadge(
                      title: achievement,
                    ))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    final recentSubmissions = _submissions.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        if (recentSubmissions.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: CandyTheme.cardDecoration,
            child: Center(
              child: Text(
                'No recent activity',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: CandyColors.textLight,
                    ),
              ),
            ),
          )
        else
          ...recentSubmissions.map((submission) {
            final problem =
                _problems.firstWhere((p) => p.id == submission.problemId);
            final timestamp =
                DateTime.fromMillisecondsSinceEpoch(submission.timestamp);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: CandyTheme.cardDecoration,
              child: Row(
                children: [
                  // Status icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: submission.status == 'Success'
                          ? CandyColors.green.withValues(alpha: 0.2)
                          : CandyColors.error.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      submission.status == 'Success'
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: submission.status == 'Success'
                          ? CandyColors.green
                          : CandyColors.error,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Problem info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          problem.title,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${submission.language} • ${_formatTimestamp(timestamp)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: submission.status == 'Success'
                          ? CandyColors.green
                          : CandyColors.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      submission.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: CandyTheme.cardDecoration,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final String title;

  const _AchievementBadge({
    required this.title,
  });

  IconData _getIcon() {
    switch (title) {
      case 'First Steps':
        return Icons.flight_takeoff;
      case 'Problem Solver':
        return Icons.lightbulb;
      case 'Rising Star':
        return Icons.star_half;
      case 'Code Master':
        return Icons.school;
      case 'Perfectionist':
        return Icons.verified;
      case 'Committed':
        return Icons.local_fire_department;
      case 'Dedicated':
        return Icons.favorite;
      case 'Unstoppable':
        return Icons.rocket_launch;
      case 'Century Club':
        return Icons.military_tech;
      case 'Point Champion':
        return Icons.emoji_events;
      default:
        return Icons.stars;
    }
  }

  Color _getColor() {
    switch (title) {
      case 'First Steps':
        return CandyColors.blue;
      case 'Problem Solver':
        return CandyColors.yellow;
      case 'Rising Star':
        return CandyColors.purple;
      case 'Code Master':
        return CandyColors.pink;
      case 'Perfectionist':
        return CandyColors.green;
      case 'Committed':
      case 'Dedicated':
      case 'Unstoppable':
        return Colors.orange;
      case 'Century Club':
      case 'Point Champion':
        return const Color(0xFFFFD700); // Gold
      default:
        return CandyColors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
