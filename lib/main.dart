import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'theme/candy_theme.dart';
import 'services/database_service.dart';
import 'services/piston_service.dart';
import 'models/user.dart';
import 'models/problem.dart';
import 'models/submission.dart';
import 'models/mock_test.dart';
import 'screens/dashboard_screen.dart';
import 'screens/import_problem_screen.dart';
import 'screens/mock_test_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/learning_paths_screen.dart';
import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await DatabaseService().database;

  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: const CandyCoderApp(),
    ),
  );
}

class CandyCoderApp extends StatelessWidget {
  const CandyCoderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          title: 'Candy Coder',
          theme: CandyTheme.lightTheme,
          home: const MainScreen(),
          debugShowCheckedModeBanner: false,
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('ko', ''),
          ],
        );
      },
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
        return const LearningPathsScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPracticeView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pick a Challenge',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            ElevatedButton.icon(
              onPressed: _openImportScreen,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Import'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CandyColors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ..._problems.map((problem) => _ProblemCard(
              problem: problem,
              onTap: () => _openProblem(problem),
            )),
      ],
    );
  }

  Future<void> _openImportScreen() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ImportProblemScreen(),
      ),
    );

    if (result == true) {
      // Reload data if a problem was imported
      await _loadData();
    }
  }

  Widget _buildMockTestView() {
    final hasEnoughProblems = _problems.length >= 3;

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
            if (!hasEnoughProblems) ...[
              Text(
                'You need at least 3 problems to start a mock test.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: CandyColors.error,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Current problems: ${_problems.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _openImportScreen,
                icon: const Icon(Icons.add),
                label: const Text('Import More Problems'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CandyColors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _startMockTest,
                child: const Text('Start Mock Test'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _startMockTest() async {
    // Select 3 random problems
    final random = Random();
    final availableProblems = List<Problem>.from(_problems);
    final selectedProblems = <Problem>[];

    for (int i = 0; i < 3; i++) {
      final index = random.nextInt(availableProblems.length);
      selectedProblems.add(availableProblems.removeAt(index));
    }

    // Create mock test
    final mockTest = MockTest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      problems: selectedProblems,
      startTime: DateTime.now(),
      durationMinutes: 90,
    );

    // Navigate to mock test screen
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MockTestScreen(
          mockTest: mockTest,
          onSubmit: _handleSubmission,
        ),
      ),
    );

    // Reload data after returning from mock test
    await _loadData();
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
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Running your code...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    // Get the problem to access test cases
    final problem = _problems.firstWhere((p) => p.id == problemId);

    // Convert test cases to the format expected by PistonService
    final testCases = problem.testCases
        .map((tc) => {
              'input': tc.input,
              'expectedOutput': tc.expectedOutput,
            })
        .toList();

    // Map language names to Piston format
    final languageMap = {
      'JavaScript': 'javascript',
      'Python': 'python',
      'C++': 'cpp',
      'Java': 'java',
    };

    final pistonLanguage = languageMap[language] ?? 'javascript';

    // Run code against test cases
    final result = await PistonService.runTestCases(
      code: code,
      language: pistonLanguage,
      testCases: testCases,
    );

    // Determine status based on results
    String status;
    String feedback;

    if (result['overallSuccess']) {
      status = 'Success';
      feedback = 'All test cases passed! (${result['passedCount']}/${result['totalCount']})';
    } else {
      // Check for runtime errors
      final hasRuntimeError = (result['results'] as List).any((r) => r['error'].toString().isNotEmpty);

      if (hasRuntimeError) {
        status = 'Runtime Error';
        final firstError = (result['results'] as List).firstWhere((r) => r['error'].toString().isNotEmpty);
        feedback = 'Runtime error: ${firstError['error']}';
      } else {
        status = 'Wrong Answer';
        feedback = 'Passed ${result['passedCount']} out of ${result['totalCount']} test cases.';

        // Add details about failed test case
        final failedTest = (result['results'] as List).firstWhere((r) => !r['passed']);
        feedback += '\n\nFailed test case #${failedTest['testCaseNumber']}:';
        feedback += '\nInput: ${failedTest['input']}';
        feedback += '\nExpected: ${failedTest['expectedOutput']}';
        feedback += '\nGot: ${failedTest['actualOutput']}';
      }
    }

    // Get execution time from first test case (as sample)
    final firstResult = (result['results'] as List).first;
    final runtime = firstResult['runtime'] ?? '0ms';

    // Create submission with execution details
    final submission = Submission(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      problemId: problemId,
      language: language,
      code: code,
      status: status,
      feedback: feedback,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      runtime: runtime,
      stdout: firstResult['actualOutput'] ?? '',
      stderr: firstResult['error'] ?? '',
      exitCode: result['overallSuccess'] ? 0 : 1,
      passedTestCases: result['passedCount'],
      totalTestCases: result['totalCount'],
    );

    await DatabaseService().insertSubmission(submission);
    await _loadData();

    // Hide loading indicator and show result
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Show success/failure message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == 'Success'
              ? '✓ All tests passed!'
              : '✗ $status - Check submission details',
        ),
        backgroundColor: status == 'Success' ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showLeaderboard() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LeaderboardScreen(
          currentUser: _user,
        ),
      ),
    );
  }

  void _showProfile() {
    if (_user == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          user: _user!,
        ),
      ),
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
          // Language switcher
          Consumer<LocaleProvider>(
            builder: (context, localeProvider, child) {
              return IconButton(
                icon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: CandyColors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CandyColors.blue.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    localeProvider.locale.languageCode.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: CandyColors.blue,
                    ),
                  ),
                ),
                onPressed: () {
                  localeProvider.toggleLocale();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        localeProvider.locale.languageCode == 'ko'
                            ? '언어가 한국어로 변경되었습니다'
                            : 'Language changed to English',
                      ),
                      duration: const Duration(seconds: 1),
                      backgroundColor: CandyColors.blue,
                    ),
                  );
                },
              );
            },
          ),
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

class _CodeEditorWithLineNumbers extends StatefulWidget {
  final TextEditingController controller;
  final String language;
  final String placeholder;

  const _CodeEditorWithLineNumbers({
    required this.controller,
    required this.language,
    required this.placeholder,
  });

  @override
  State<_CodeEditorWithLineNumbers> createState() => _CodeEditorWithLineNumbersState();
}

class _CodeEditorWithLineNumbersState extends State<_CodeEditorWithLineNumbers> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _lineNumberScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_syncScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_syncScroll);
    _scrollController.dispose();
    _lineNumberScrollController.dispose();
    super.dispose();
  }

  void _syncScroll() {
    if (_lineNumberScrollController.hasClients) {
      _lineNumberScrollController.jumpTo(_scrollController.offset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lines = widget.controller.text.isEmpty
        ? widget.placeholder.split('\n')
        : widget.controller.text.split('\n');
    final lineCount = lines.length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Line numbers
        Container(
          width: 50,
          decoration: const BoxDecoration(
            color: Color(0xFF1E1F26),
            border: Border(
              right: BorderSide(
                color: Color(0xFF44475A),
                width: 1,
              ),
            ),
          ),
          child: SingleChildScrollView(
            controller: _lineNumberScrollController,
            physics: const NeverScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  lineCount > 0 ? lineCount : 1,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: Color(0xFF6272A4),
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Code editor
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: widget.controller,
              maxLines: null,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: Color(0xFFF8F8F2), // Dracula foreground
                height: 1.5,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.placeholder,
                hintStyle: const TextStyle(
                  color: Color(0xFF6272A4), // Dracula comment color
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.5,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              cursorColor: const Color(0xFFFF79C6), // Dracula pink
              onChanged: (value) {
                setState(() {}); // Refresh to update line numbers
              },
            ),
          ),
        ),
      ],
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
                // Code editor with line numbers
                Container(
                  constraints: const BoxConstraints(
                    minHeight: 300,
                    maxHeight: 500,
                  ),
                  child: _CodeEditorWithLineNumbers(
                    controller: _codeController,
                    language: _getHighlightLanguage(_language),
                    placeholder: _getPlaceholderCode(_language),
                  ),
                ),
              ],
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
