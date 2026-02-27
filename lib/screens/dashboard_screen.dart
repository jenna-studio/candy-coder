import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/submission.dart';
import '../theme/candy_theme.dart';

class DashboardScreen extends StatelessWidget {
  final User? user;
  final List<Submission> recentSubmissions;
  final int solvedCount;
  final VoidCallback onPracticePressed;
  final VoidCallback onMockPressed;
  final VoidCallback onLearnPressed;
  final VoidCallback onLeaderboardPressed;
  final VoidCallback onProfilePressed;

  const DashboardScreen({
    super.key,
    required this.user,
    required this.recentSubmissions,
    required this.solvedCount,
    required this.onPracticePressed,
    required this.onMockPressed,
    required this.onLearnPressed,
    required this.onLeaderboardPressed,
    required this.onProfilePressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: CandyTheme.gradientCardDecoration(
              colors: [CandyColors.pink, CandyColors.purple],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Coder! 🍭',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ready to sweeten your coding skills today?',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'STREAK',
                        value: '${user?.streak ?? 0} Days',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        label: 'SOLVED',
                        value: '$solvedCount',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _ActionCard(
                icon: Icons.code,
                label: 'Practice',
                color: CandyColors.blue,
                onTap: onPracticePressed,
              ),
              _ActionCard(
                icon: Icons.timer,
                label: 'Mock Test',
                color: CandyColors.purple,
                onTap: onMockPressed,
              ),
              _ActionCard(
                icon: Icons.book,
                label: 'Learn',
                color: CandyColors.yellow,
                onTap: onLearnPressed,
              ),
              _ActionCard(
                icon: Icons.emoji_events,
                label: 'Ranking',
                color: CandyColors.blue,
                onTap: onLeaderboardPressed,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Recent Submissions
          Text(
            'Recent Submissions',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 16),
          ...recentSubmissions.take(3).map((submission) {
            final isSuccess = submission.status == 'Success';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: CandyTheme.cardDecoration,
              child: Row(
                children: [
                  Icon(
                    isSuccess ? Icons.check_circle : Icons.cancel,
                    color: isSuccess ? CandyColors.success : CandyColors.error,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Problem #${submission.problemId}',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        Text(
                          DateTime.fromMillisecondsSinceEpoch(submission.timestamp)
                              .toString()
                              .split(' ')[0],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: CandyColors.textLight),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: CandyTheme.cardDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}
