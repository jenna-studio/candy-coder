import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/database_service.dart';
import '../theme/candy_theme.dart';

class LeaderboardScreen extends StatefulWidget {
  final User? currentUser;

  const LeaderboardScreen({
    super.key,
    this.currentUser,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<User> _leaderboard = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);

    try {
      final leaderboard = await DatabaseService().getLeaderboard();

      setState(() {
        _leaderboard = leaderboard;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return CandyColors.textLight;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.emoji_events_outlined;
      case 3:
        return Icons.workspace_premium;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadLeaderboard,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          CandyColors.purple,
                          CandyColors.pink,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Global Rankings',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Compete with coders worldwide',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Top 3 Podium
                  if (_leaderboard.length >= 3) ...[
                    _buildPodium(),
                    const SizedBox(height: 32),
                  ],

                  // Rest of the rankings
                  Text(
                    'All Rankings',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),

                  ..._leaderboard.asMap().entries.map((entry) {
                    final rank = entry.key + 1;
                    final user = entry.value;
                    final isCurrentUser = widget.currentUser?.id == user.id;

                    return _LeaderboardCard(
                      rank: rank,
                      user: user,
                      isCurrentUser: isCurrentUser,
                      rankColor: _getRankColor(rank),
                      rankIcon: _getRankIcon(rank),
                    );
                  }),
                ],
              ),
            ),
    );
  }

  Widget _buildPodium() {
    final first = _leaderboard.length > 0 ? _leaderboard[0] : null;
    final second = _leaderboard.length > 1 ? _leaderboard[1] : null;
    final third = _leaderboard.length > 2 ? _leaderboard[2] : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Second place
        if (second != null)
          Expanded(
            child: _PodiumPlace(
              rank: 2,
              user: second,
              height: 100,
              color: const Color(0xFFC0C0C0),
            ),
          ),

        const SizedBox(width: 8),

        // First place
        if (first != null)
          Expanded(
            child: _PodiumPlace(
              rank: 1,
              user: first,
              height: 140,
              color: const Color(0xFFFFD700),
            ),
          ),

        const SizedBox(width: 8),

        // Third place
        if (third != null)
          Expanded(
            child: _PodiumPlace(
              rank: 3,
              user: third,
              height: 80,
              color: const Color(0xFFCD7F32),
            ),
          ),
      ],
    );
  }
}

class _PodiumPlace extends StatelessWidget {
  final int rank;
  final User user;
  final double height;
  final Color color;

  const _PodiumPlace({
    required this.rank,
    required this.user,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar
        Container(
          width: rank == 1 ? 80 : 64,
          height: rank == 1 ? 80 : 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: 3,
            ),
            image: DecorationImage(
              image: NetworkImage(user.avatar),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Name
        Text(
          user.name,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        // Points
        Text(
          '${user.points} pts',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: CandyColors.textLight,
              ),
        ),

        const SizedBox(height: 8),

        // Podium block
        Container(
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            border: Border.all(
              color: color,
              width: 2,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events,
                  color: color,
                  size: rank == 1 ? 40 : 32,
                ),
                const SizedBox(height: 4),
                Text(
                  '#$rank',
                  style: TextStyle(
                    fontSize: rank == 1 ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  final int rank;
  final User user;
  final bool isCurrentUser;
  final Color rankColor;
  final IconData rankIcon;

  const _LeaderboardCard({
    required this.rank,
    required this.user,
    required this.isCurrentUser,
    required this.rankColor,
    required this.rankIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: CandyTheme.cardDecoration.copyWith(
        border: isCurrentUser
            ? Border.all(
                color: CandyColors.pink,
                width: 2,
              )
            : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: Row(
              children: [
                Icon(
                  rankIcon,
                  color: rankColor,
                  size: rank <= 3 ? 24 : 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '#$rank',
                  style: TextStyle(
                    fontSize: rank <= 3 ? 18 : 16,
                    fontWeight: rank <= 3 ? FontWeight.bold : FontWeight.normal,
                    color: rankColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isCurrentUser ? CandyColors.pink : Colors.transparent,
                width: 2,
              ),
              image: DecorationImage(
                image: NetworkImage(user.avatar),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Name and streak
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: isCurrentUser ? CandyColors.pink : null,
                          ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: CandyColors.pink,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      size: 14,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${user.streak} day streak',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${user.points}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: CandyColors.purple,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'points',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
