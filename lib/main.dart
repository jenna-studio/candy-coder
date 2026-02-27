import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/dracula.dart';
import 'theme/candy_theme.dart';
import 'services/database_service.dart';
import 'models/user.dart';
import 'models/problem.dart';
import 'models/submission.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await DatabaseService().database;

  runApp(const CandyCoderApp());
}

class CandyCoderApp extends StatelessWidget {
  const CandyCoderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Candy Coder',
      theme: CandyTheme.lightTheme,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  User? _user;
  List<Problem> _problems = [];
  List<Submission> _submissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final db = DatabaseService();
      final user = await db.getUser('default');
      final problems = await db.getProblems();
      final submissions = await db.getSubmissions();

      setState(() {
        _user = user;
        _problems = problems;
        _submissions = submissions;
        _isLoading = false;
      });
    } catch (e) {
      // Error loading data
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

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  Widget _buildCurrentView() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    switch (_currentIndex) {
      case 0:
        return DashboardScreen(
          user: _user,
          recentSubmissions: _submissions,
          solvedCount: _solvedCount,
          onPracticePressed: () => _onNavTap(1),
          onMockPressed: () => _onNavTap(2),
          onLearnPressed: () => _onNavTap(3),
          onLeaderboardPressed: () => _showLeaderboard(),
          onProfilePressed: () => _showProfile(),
        );
      case 1:
        return _buildPracticeView();
      case 2:
        return _buildMockTestView();
      case 3:
        return _buildLearnView();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPracticeView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Pick a Challenge',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 24),
        ..._problems.map((problem) => _ProblemCard(
              problem: problem,
              onTap: () => _openProblem(problem),
            )),
      ],
    );
  }

  Widget _buildMockTestView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: CandyColors.purple,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.timer,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Mock Test Mode',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Simulate a real coding interview. 3 problems, 90 minutes. No hints allowed!',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mock test feature coming soon!'),
                  ),
                );
              },
              child: const Text('Start Mock Test'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearnView() {
    final learningPaths = [
      'Dynamic Programming',
      'Graph Theory',
      'Greedy Algorithms',
      'Data Structures'
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Learning Paths',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 24),
        ...learningPaths.map((path) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: CandyTheme.cardDecoration,
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: CandyColors.yellow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.book,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          path,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        Text(
                          'Master the fundamentals with AI guidance',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: CandyColors.textLight),
                ],
              ),
            )),
      ],
    );
  }

  void _openProblem(Problem problem) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProblemDetailScreen(
          problem: problem,
          onSubmit: _handleSubmission,
        ),
      ),
    );
  }

  Future<void> _handleSubmission(
    String problemId,
    String language,
    String code,
  ) async {
    // Store submission without AI evaluation
    final submission = Submission(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      problemId: problemId,
      language: language,
      code: code,
      status: 'Success',
      feedback: 'Code submitted successfully! Manual review recommended.',
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    await DatabaseService().insertSubmission(submission);
    await _loadData();
  }

  void _showLeaderboard() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Leaderboard feature coming soon!')),
    );
  }

  void _showProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: CandyColors.pink,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Candy Coder',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: CandyColors.pink,
                  ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: CandyColors.yellow.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: CandyColors.yellow),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '${_user?.points ?? 0}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _buildCurrentView(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: CandyColors.pink,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.code),
            label: 'Practice',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Mock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Learn',
          ),
        ],
      ),
    );
  }
}

class _ProblemCard extends StatelessWidget {
  final Problem problem;
  final VoidCallback onTap;

  const _ProblemCard({
    required this.problem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: CandyTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CandyTheme.difficultyBadge(problem.difficulty),
                Text(
                  problem.topic,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              problem.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.chevron_right, color: CandyColors.textLight),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProblemDetailScreen extends StatefulWidget {
  final Problem problem;
  final Function(String problemId, String language, String code) onSubmit;

  const ProblemDetailScreen({
    super.key,
    required this.problem,
    required this.onSubmit,
  });

  @override
  State<ProblemDetailScreen> createState() => _ProblemDetailScreenState();
}

class _ProblemDetailScreenState extends State<ProblemDetailScreen> {
  String _language = 'JavaScript';
  late TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(
      text: widget.problem.templates[_language] ?? '',
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  String _getHighlightLanguage(String language) {
    switch (language) {
      case 'JavaScript':
        return 'javascript';
      case 'Python':
        return 'python';
      case 'C++':
        return 'cpp';
      case 'Java':
        return 'java';
      default:
        return 'javascript';
    }
  }

  String _getLanguageDisplayName(String language) {
    return language;
  }

  String _getPlaceholderCode(String language) {
    switch (language) {
      case 'JavaScript':
        return '// Write your JavaScript code here...';
      case 'Python':
        return '# Write your Python code here...';
      case 'C++':
        return '// Write your C++ code here...';
      case 'Java':
        return '// Write your Java code here...';
      default:
        return '// Write your code here...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.problem.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: CandyTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CandyTheme.difficultyBadge(widget.problem.difficulty),
                    const Spacer(),
                    DropdownButton<String>(
                      value: _language,
                      items: ['JavaScript', 'Python', 'C++', 'Java']
                          .map((lang) => DropdownMenuItem(
                                value: lang,
                                child: Text(lang),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _language = value;
                            _codeController.text =
                                widget.problem.templates[value] ?? '';
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.problem.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your Solution',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Container(
            height: 400,
            decoration: BoxDecoration(
              color: const Color(0xFF282A36),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: CandyColors.blue.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                // Editor toolbar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E1F26),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.code, size: 16, color: Colors.white54),
                      const SizedBox(width: 8),
                      Text(
                        _getLanguageDisplayName(_language),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF50FA7B),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Ready',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Code editor with syntax highlighting
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: HighlightView(
                      _codeController.text.isEmpty ? _getPlaceholderCode(_language) : _codeController.text,
                      language: _getHighlightLanguage(_language),
                      theme: draculaTheme,
                      padding: EdgeInsets.zero,
                      textStyle: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Editable text field (for input)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _codeController,
              maxLines: 10,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Colors.white,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: _getPlaceholderCode(_language),
                hintStyle: const TextStyle(color: Colors.white38),
              ),
              cursorColor: CandyColors.pink,
              onChanged: (value) {
                setState(() {}); // Refresh to update highlight view
              },
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await widget.onSubmit(
                widget.problem.id,
                _language,
                _codeController.text,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Solution submitted successfully!'),
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Submit Solution'),
          ),
        ],
      ),
    );
  }
}
