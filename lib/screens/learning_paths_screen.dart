import 'package:flutter/material.dart';
import '../models/learning_path.dart';
import '../models/problem.dart';
import '../models/submission.dart';
import '../services/database_service.dart';
import '../theme/candy_theme.dart';
import 'learning_path_detail_screen.dart';

class LearningPathsScreen extends StatefulWidget {
  const LearningPathsScreen({super.key});

  @override
  State<LearningPathsScreen> createState() => _LearningPathsScreenState();
}

class _LearningPathsScreenState extends State<LearningPathsScreen> {
  List<Problem> _problems = [];
  List<Submission> _submissions = [];
  bool _isLoading = true;

  final List<LearningPath> _learningPaths = [
    LearningPath(
      id: 'dp',
      title: 'Dynamic Programming',
      description: 'Master the art of solving complex problems by breaking them into simpler subproblems',
      icon: '🧮',
      estimatedHours: 20,
      modules: [
        Module(
          id: 'dp-1',
          title: 'Introduction to DP',
          description: 'Understanding memoization and tabulation',
          topics: ['Fibonacci', 'Climbing Stairs', 'Min Cost Climbing Stairs'],
          problemIds: ['2'], // Climbing Stairs
          order: 1,
        ),
        Module(
          id: 'dp-2',
          title: 'Classic DP Problems',
          description: 'House Robber, Coin Change, Longest Increasing Subsequence',
          topics: ['House Robber', 'Coin Change', 'LIS'],
          problemIds: ['4'], // House Robber
          order: 2,
        ),
        Module(
          id: 'dp-3',
          title: 'Advanced DP',
          description: 'Knapsack, Edit Distance, Matrix Chain Multiplication',
          topics: ['0/1 Knapsack', 'Edit Distance'],
          problemIds: [],
          order: 3,
        ),
      ],
    ),
    LearningPath(
      id: 'graph',
      title: 'Graph Theory',
      description: 'Explore graphs, trees, and graph algorithms like BFS, DFS, and Dijkstra',
      icon: '🕸️',
      estimatedHours: 25,
      modules: [
        Module(
          id: 'graph-1',
          title: 'Graph Basics',
          description: 'Graph representation and traversal',
          topics: ['Adjacency List', 'BFS', 'DFS'],
          problemIds: [],
          order: 1,
        ),
        Module(
          id: 'graph-2',
          title: 'Shortest Paths',
          description: 'Dijkstra, Bellman-Ford, Floyd-Warshall',
          topics: ['Dijkstra', 'Bellman-Ford'],
          problemIds: [],
          order: 2,
        ),
        Module(
          id: 'graph-3',
          title: 'Advanced Graph',
          description: 'Minimum Spanning Tree, Topological Sort, Strongly Connected Components',
          topics: ['MST', 'Topological Sort', 'SCC'],
          problemIds: [],
          order: 3,
        ),
      ],
    ),
    LearningPath(
      id: 'greedy',
      title: 'Greedy Algorithms',
      description: 'Learn to make locally optimal choices to find global solutions',
      icon: '🎯',
      estimatedHours: 15,
      modules: [
        Module(
          id: 'greedy-1',
          title: 'Greedy Fundamentals',
          description: 'Activity Selection, Fractional Knapsack',
          topics: ['Activity Selection', 'Fractional Knapsack'],
          problemIds: [],
          order: 1,
        ),
        Module(
          id: 'greedy-2',
          title: 'Interval Problems',
          description: 'Merge Intervals, Meeting Rooms',
          topics: ['Merge Intervals', 'Non-overlapping Intervals'],
          problemIds: [],
          order: 2,
        ),
        Module(
          id: 'greedy-3',
          title: 'Advanced Greedy',
          description: 'Huffman Coding, Job Sequencing',
          topics: ['Huffman Coding', 'Job Sequencing'],
          problemIds: [],
          order: 3,
        ),
      ],
    ),
    LearningPath(
      id: 'ds',
      title: 'Data Structures',
      description: 'Master fundamental and advanced data structures',
      icon: '📚',
      estimatedHours: 30,
      modules: [
        Module(
          id: 'ds-1',
          title: 'Linear Data Structures',
          description: 'Arrays, Linked Lists, Stacks, Queues',
          topics: ['Array', 'Linked List', 'Stack', 'Queue'],
          problemIds: ['1', '3'], // Two Sum, Valid Parentheses
          order: 1,
        ),
        Module(
          id: 'ds-2',
          title: 'Trees and Heaps',
          description: 'Binary Trees, BST, Heap, Priority Queue',
          topics: ['Binary Tree', 'BST', 'Heap'],
          problemIds: [],
          order: 2,
        ),
        Module(
          id: 'ds-3',
          title: 'Advanced Structures',
          description: 'Trie, Segment Tree, Fenwick Tree, Disjoint Set',
          topics: ['Trie', 'Segment Tree', 'Union Find'],
          problemIds: [],
          order: 3,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final problems = await DatabaseService().getProblems();
      final submissions = await DatabaseService().getSubmissions();

      setState(() {
        _problems = problems;
        _submissions = submissions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  int _getCompletedModulesCount(LearningPath path) {
    int completed = 0;

    final solvedProblemIds = _submissions
        .where((s) => s.status == 'Success')
        .map((s) => s.problemId)
        .toSet();

    for (var module in path.modules) {
      if (module.problemIds.isEmpty) continue;

      // Check if all problems in the module are solved
      final allSolved = module.problemIds.every((id) => solvedProblemIds.contains(id));
      if (allSolved) completed++;
    }

    return completed;
  }

  double _getProgress(LearningPath path) {
    if (path.modules.isEmpty) return 0.0;

    final completed = _getCompletedModulesCount(path);
    return completed / path.modules.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Paths'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
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
                          CandyColors.yellow,
                          CandyColors.pink,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '📖',
                          style: TextStyle(fontSize: 48),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Structured Learning',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Master algorithms step by step',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Learning paths
                  Text(
                    'Choose Your Path',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),

                  ..._learningPaths.map((path) {
                    final progress = _getProgress(path);
                    final completedModules = _getCompletedModulesCount(path);

                    return _LearningPathCard(
                      path: path,
                      progress: progress,
                      completedModules: completedModules,
                      onTap: () => _openLearningPath(path),
                    );
                  }),
                ],
              ),
            ),
    );
  }

  void _openLearningPath(LearningPath path) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LearningPathDetailScreen(
          path: path,
          problems: _problems,
          submissions: _submissions,
        ),
      ),
    );
  }
}

class _LearningPathCard extends StatelessWidget {
  final LearningPath path;
  final double progress;
  final int completedModules;
  final VoidCallback onTap;

  const _LearningPathCard({
    required this.path,
    required this.progress,
    required this.completedModules,
    required this.onTap,
  });

  Color _getPathColor() {
    switch (path.id) {
      case 'dp':
        return CandyColors.purple;
      case 'graph':
        return CandyColors.blue;
      case 'greedy':
        return CandyColors.green;
      case 'ds':
        return CandyColors.yellow;
      default:
        return CandyColors.pink;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getPathColor();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: CandyTheme.cardDecoration.copyWith(
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      path.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Title and description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        path.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: color,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        path.description,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const Icon(Icons.chevron_right, color: CandyColors.textLight),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),

            // Stats
            Row(
              children: [
                _buildStat(
                  context,
                  Icons.check_circle_outline,
                  '$completedModules/${path.modules.length} modules',
                  color,
                ),
                const SizedBox(width: 16),
                _buildStat(
                  context,
                  Icons.access_time,
                  '~${path.estimatedHours}h',
                  color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: CandyColors.textLight,
              ),
        ),
      ],
    );
  }
}
