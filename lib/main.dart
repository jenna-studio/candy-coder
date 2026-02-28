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
import 'screens/settings_screen.dart';
import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'dart:math';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/re_highlight.dart';
import 'package:re_highlight/languages/javascript.dart';
import 'package:re_highlight/languages/python.dart';
import 'package:re_highlight/languages/cpp.dart';
import 'package:re_highlight/languages/java.dart';

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

    Widget currentView;
    switch (_currentIndex) {
      case 0:
        currentView = DashboardScreen(
          user: _user,
          recentSubmissions: _submissions,
          solvedCount: _solvedCount,
          onPracticePressed: () => _onNavTap(1),
          onMockPressed: () => _onNavTap(2),
          onLearnPressed: () => _onNavTap(3),
          onLeaderboardPressed: () => _showLeaderboard(),
          onProfilePressed: () => _showProfile(),
        );
        break;
      case 1:
        currentView = _buildPracticeView();
        break;
      case 2:
        currentView = _buildMockTestView();
        break;
      case 3:
        currentView = const LearningPathsScreen();
        break;
      default:
        currentView = const SizedBox.shrink();
    }

    return SafeArea(
      child: currentView,
    );
  }

  Widget _buildPracticeView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Pick a Challenge',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 48, // Touch-friendly button size
              child: ElevatedButton.icon(
                onPressed: _openImportScreen,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Import'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CandyColors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (_problems.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: CandyColors.textLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No problems yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Import some problems to get started!',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
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
              SizedBox(
                width: double.infinity,
                height: 56, // Extra large touch target for important action
                child: ElevatedButton(
                  onPressed: _startMockTest,
                  child: const Text('Start Mock Test'),
                ),
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

    if (!mounted) return;

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
          Container(
            margin: const EdgeInsets.only(right: 8),
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
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(user: _user),
                ),
              );

              // Reload data if profile was updated
              if (result == true) {
                await _loadData();
              }
            },
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20), // Larger padding for touch
          constraints: const BoxConstraints(
            minHeight: 100, // Minimum touch-friendly height
          ),
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
                  SizedBox(width: 4),
                  Text(
                    'Tap to solve',
                    style: TextStyle(
                      color: CandyColors.textLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
  late CodeLineEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = CodeLineEditingController.fromText(widget.controller.text);

    // Sync changes from CodeLineEditingController back to TextEditingController
    _codeController.addListener(() {
      if (widget.controller.text != _codeController.text) {
        widget.controller.text = _codeController.text;
      }
    });

    // Sync changes from TextEditingController to CodeLineEditingController
    widget.controller.addListener(() {
      if (_codeController.text != widget.controller.text) {
        _codeController.text = widget.controller.text;
      }
    });
  }

  @override
  void didUpdateWidget(_CodeEditorWithLineNumbers oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_codeController.text != widget.controller.text) {
        _codeController.text = widget.controller.text;
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  String _getLanguageMode(String language) {
    switch (language) {
      case 'javascript':
        return 'javascript';
      case 'python':
        return 'python';
      case 'cpp':
        return 'cpp';
      case 'java':
        return 'java';
      default:
        return 'javascript';
    }
  }

  Mode _getHighlightMode(String language) {
    switch (language) {
      case 'javascript':
        return langJavascript;
      case 'python':
        return langPython;
      case 'cpp':
        return langCpp;
      case 'java':
        return langJava;
      default:
        return langJavascript;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CodeEditor(
      controller: _codeController,
      style: CodeEditorStyle(
        fontSize: 14,
        fontFamily: 'monospace',
        fontHeight: 1.5,
        // Dracula-inspired dark theme colors
        backgroundColor: const Color(0xFF282A36),
        textColor: const Color(0xFFF8F8F2),
        cursorColor: const Color(0xFFFF79C6), // Pink cursor
        codeTheme: CodeHighlightTheme(
          languages: {
            _getLanguageMode(widget.language): CodeHighlightThemeMode(
              mode: _getHighlightMode(widget.language),
            ),
          },
          theme: _draculaTheme(),
        ),
      ),
      indicatorBuilder: (context, editingController, chunkController, notifier) {
        return DefaultCodeLineNumber(
          controller: editingController,
          notifier: notifier,
          textStyle: const TextStyle(
            color: Color(0xFF6272A4), // Comment color for line numbers
            fontSize: 14,
            fontFamily: 'monospace',
          ),
        );
      },
    );
  }

  // Official Dracula theme colors for syntax highlighting
  Map<String, TextStyle> _draculaTheme() {
    return {
      'root': const TextStyle(
        color: Color(0xFFF8F8F2),
        backgroundColor: Color(0xFF282A36),
      ),
      'keyword': const TextStyle(
        color: Color(0xFFFF79C6), // Pink
        fontWeight: FontWeight.bold,
      ),
      'built_in': const TextStyle(color: Color(0xFF8BE9FD)), // Cyan
      'type': const TextStyle(color: Color(0xFF8BE9FD)), // Cyan
      'literal': const TextStyle(color: Color(0xFFBD93F9)), // Purple
      'number': const TextStyle(color: Color(0xFFBD93F9)), // Purple
      'regexp': const TextStyle(color: Color(0xFFF1FA8C)), // Yellow
      'string': const TextStyle(color: Color(0xFFF1FA8C)), // Yellow
      'subst': const TextStyle(color: Color(0xFFF8F8F2)), // Foreground
      'symbol': const TextStyle(color: Color(0xFFF1FA8C)), // Yellow
      'class': const TextStyle(color: Color(0xFF8BE9FD)), // Cyan
      'function': const TextStyle(color: Color(0xFF50FA7B)), // Green
      'title': const TextStyle(color: Color(0xFF50FA7B)), // Green
      'params': const TextStyle(color: Color(0xFFFFB86C)), // Orange
      'comment': const TextStyle(
        color: Color(0xFF6272A4), // Comment
        fontStyle: FontStyle.italic,
      ),
      'doctag': const TextStyle(color: Color(0xFF8BE9FD)), // Cyan
      'meta': const TextStyle(color: Color(0xFFFF79C6)), // Pink
      'meta-keyword': const TextStyle(color: Color(0xFFFF79C6)), // Pink
      'meta-string': const TextStyle(color: Color(0xFFF1FA8C)), // Yellow
      'section': const TextStyle(color: Color(0xFF8BE9FD)), // Cyan
      'tag': const TextStyle(color: Color(0xFFFF79C6)), // Pink
      'name': const TextStyle(color: Color(0xFF8BE9FD)), // Cyan
      'builtin-name': const TextStyle(color: Color(0xFF8BE9FD)), // Cyan
      'attr': const TextStyle(color: Color(0xFF50FA7B)), // Green
      'attribute': const TextStyle(color: Color(0xFF50FA7B)), // Green
      'variable': const TextStyle(color: Color(0xFFF8F8F2)), // Foreground
      'bullet': const TextStyle(color: Color(0xFF8BE9FD)), // Cyan
      'code': const TextStyle(color: Color(0xFF50FA7B)), // Green
      'emphasis': const TextStyle(
        color: Color(0xFFF1FA8C), // Yellow
        fontStyle: FontStyle.italic,
      ),
      'strong': const TextStyle(
        color: Color(0xFFFFB86C), // Orange
        fontWeight: FontWeight.bold,
      ),
      'formula': const TextStyle(color: Color(0xFF50FA7B)), // Green
      'link': const TextStyle(color: Color(0xFF8BE9FD)), // Cyan
      'quote': const TextStyle(
        color: Color(0xFFF1FA8C), // Yellow
        fontStyle: FontStyle.italic,
      ),
      'selector-tag': const TextStyle(color: Color(0xFFFF79C6)), // Pink
      'selector-id': const TextStyle(color: Color(0xFF50FA7B)), // Green
      'selector-class': const TextStyle(color: Color(0xFF8BE9FD)), // Cyan
      'selector-attr': const TextStyle(color: Color(0xFF50FA7B)), // Green
      'selector-pseudo': const TextStyle(color: Color(0xFF8BE9FD)), // Cyan
      'template-tag': const TextStyle(color: Color(0xFFF8F8F2)), // Foreground
      'template-variable': const TextStyle(color: Color(0xFFF8F8F2)), // Foreground
      'addition': TextStyle(
        color: const Color(0xFF50FA7B), // Green
        backgroundColor: const Color(0xFF50FA7B).withValues(alpha: 0.1),
      ),
      'deletion': TextStyle(
        color: const Color(0xFFFF5555), // Red
        backgroundColor: const Color(0xFFFF5555).withValues(alpha: 0.1),
      ),
    };
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
  String _descriptionLanguage = 'en'; // 'en' or 'ko' for problem description
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

  Future<void> _runCode() async {
    if (_codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write some code first!'),
          backgroundColor: CandyColors.error,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Running your code...'),
              ],
            ),
          ),
        ),
      ),
    );

    // Convert test cases to the format expected by PistonService
    final testCases = widget.problem.testCases
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

    final pistonLanguage = languageMap[_language] ?? 'javascript';

    // Run code against test cases
    final result = await PistonService.runTestCases(
      code: _codeController.text,
      language: pistonLanguage,
      testCases: testCases,
    );

    // Close loading dialog
    if (mounted) Navigator.of(context).pop();

    // Show results dialog
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                result['overallSuccess'] ? Icons.check_circle : Icons.error,
                color: result['overallSuccess'] ? CandyColors.green : CandyColors.error,
              ),
              const SizedBox(width: 8),
              Text(result['overallSuccess'] ? 'All Tests Passed!' : 'Tests Failed'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Passed: ${result['passedCount']}/${result['totalCount']} test cases',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Test Results:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...((result['results'] as List).map((testResult) {
                  final passed = testResult['passed'] as bool;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: passed
                          ? CandyColors.green.withValues(alpha: 0.1)
                          : CandyColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: passed ? CandyColors.green : CandyColors.error,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              passed ? Icons.check : Icons.close,
                              size: 16,
                              color: passed ? CandyColors.green : CandyColors.error,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Test Case ${testResult['testCaseNumber']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        if (!passed) ...[
                          const SizedBox(height: 8),
                          Text('Input: ${testResult['input']}'),
                          Text('Expected: ${testResult['expectedOutput']}'),
                          Text('Got: ${testResult['actualOutput']}'),
                          if (testResult['error'].toString().isNotEmpty)
                            Text(
                              'Error: ${testResult['error']}',
                              style: const TextStyle(color: CandyColors.error),
                            ),
                        ],
                      ],
                    ),
                  );
                })),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.problem.title),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: keyboardHeight > 0 ? keyboardHeight + 16 : 16,
          ),
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
                      // Problem description language switcher
                      if (widget.problem.descriptionKo != null)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: CandyColors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: CandyColors.blue.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _LanguageButton(
                                label: 'EN',
                                isSelected: _descriptionLanguage == 'en',
                                onTap: () {
                                  setState(() => _descriptionLanguage = 'en');
                                },
                              ),
                              _LanguageButton(
                                label: 'KO',
                                isSelected: _descriptionLanguage == 'ko',
                                onTap: () {
                                  setState(() => _descriptionLanguage = 'ko');
                                },
                              ),
                            ],
                          ),
                        ),
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
                    _descriptionLanguage == 'ko' && widget.problem.descriptionKo != null
                        ? widget.problem.descriptionKo!
                        : widget.problem.description,
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
            // Mobile-optimized code editor
            Container(
              height: screenHeight * 0.4, // 40% of screen height
              decoration: BoxDecoration(
                color: const Color(0xFF282A36),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _CodeEditorWithLineNumbers(
                controller: _codeController,
                language: _getHighlightLanguage(_language),
                placeholder: _getPlaceholderCode(_language),
              ),
            ),
            const SizedBox(height: 24),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        await _runCode();
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Run Code'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CandyColors.blue,
                        side: const BorderSide(color: CandyColors.blue),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        FocusScope.of(context).unfocus();

                        await widget.onSubmit(
                          widget.problem.id,
                          _language,
                          _codeController.text,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Solution submitted successfully!'),
                            ),
                          );
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Submit'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 100), // Extra space for scrolling past keyboard
          ],
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? CandyColors.blue
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: isSelected ? Colors.white : CandyColors.blue,
          ),
        ),
      ),
    );
  }
}
