import 'dart:async';
import 'package:flutter/material.dart';
import '../models/mock_test.dart';
import '../theme/candy_theme.dart';
import '../main.dart';

class MockTestScreen extends StatefulWidget {
  final MockTest mockTest;
  final Function(String problemId, String language, String code) onSubmit;

  const MockTestScreen({
    super.key,
    required this.mockTest,
    required this.onSubmit,
  });

  @override
  State<MockTestScreen> createState() => _MockTestScreenState();
}

class _MockTestScreenState extends State<MockTestScreen> {
  late MockTest _currentTest;
  Timer? _timer;
  int _remainingSeconds = 0;
  int _selectedProblemIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentTest = widget.mockTest;
    _remainingSeconds = _currentTest.remainingSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingSeconds = _currentTest.remainingSeconds;
          if (_remainingSeconds <= 0) {
            _endTest();
          }
        });
      }
    });
  }

  void _endTest() {
    _timer?.cancel();
    setState(() {
      _currentTest = _currentTest.copyWith(
        isCompleted: true,
        endTime: DateTime.now(),
      );
    });
    _showResultsDialog();
  }

  void _showResultsDialog() {
    final solved = _currentTest.completedProblems;
    final total = _currentTest.problems.length;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Mock Test Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              solved == total ? Icons.emoji_events : Icons.timer_off,
              size: 64,
              color: solved == total ? CandyColors.yellow : CandyColors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              'You solved $solved out of $total problems',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _remainingSeconds > 0
                  ? 'Great job finishing early!'
                  : 'Time\'s up!',
              style: const TextStyle(color: CandyColors.textLight),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to main screen
            },
            child: const Text('Exit Mock Test'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  Color _getTimerColor() {
    if (_remainingSeconds > 1800) return CandyColors.success; // > 30 min
    if (_remainingSeconds > 600) return CandyColors.yellow; // > 10 min
    return CandyColors.error; // < 10 min
  }

  bool _isProblemSolved(String problemId) {
    return _currentTest.submissions.any(
      (s) => s.problemId == problemId && s.status == 'Success',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentTest.isCompleted && _remainingSeconds <= 0) {
      // Test ended, show results
      return _buildResultsView();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock Test'),
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getTimerColor().withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getTimerColor(), width: 2),
            ),
            child: Row(
              children: [
                Icon(Icons.timer, color: _getTimerColor(), size: 20),
                const SizedBox(width: 8),
                Text(
                  _formatTime(_remainingSeconds),
                  style: TextStyle(
                    color: _getTimerColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _showExitConfirmation();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProblemTabs(),
          Expanded(
            child: _buildProblemView(),
          ),
        ],
      ),
    );
  }

  Widget _buildProblemTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          _currentTest.problems.length,
          (index) {
            final problem = _currentTest.problems[index];
            final isSolved = _isProblemSolved(problem.id);
            final isSelected = index == _selectedProblemIndex;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedProblemIndex = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? CandyColors.pink
                      : (isSolved ? CandyColors.success.withValues(alpha: 0.2) : Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    if (isSolved)
                      Icon(Icons.check_circle, color: CandyColors.success, size: 18)
                    else
                      Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : CandyColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      'Problem ${index + 1}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : CandyColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProblemView() {
    final problem = _currentTest.problems[_selectedProblemIndex];

    return ProblemDetailScreen(
      problem: problem,
      onSubmit: (problemId, language, code) async {
        await widget.onSubmit(problemId, language, code);
        // Refresh to show updated submission status
        setState(() {});
      },
    );
  }

  Widget _buildResultsView() {
    final solved = _currentTest.completedProblems;
    final total = _currentTest.problems.length;
    final percentage = (solved / total * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock Test Results'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: CandyTheme.cardDecoration,
            child: Column(
              children: [
                Icon(
                  percentage >= 66 ? Icons.emoji_events : Icons.description,
                  size: 80,
                  color: percentage >= 66 ? CandyColors.yellow : CandyColors.blue,
                ),
                const SizedBox(height: 16),
                Text(
                  'Mock Test Complete!',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 24),
                _buildStatRow('Problems Solved', '$solved / $total'),
                const SizedBox(height: 12),
                _buildStatRow('Success Rate', '$percentage%'),
                const SizedBox(height: 12),
                _buildStatRow(
                  'Time Used',
                  _formatTime(_currentTest.durationMinutes * 60 - _remainingSeconds),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Problem Breakdown',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          ..._currentTest.problems.asMap().entries.map((entry) {
            final index = entry.key;
            final problem = entry.value;
            final isSolved = _isProblemSolved(problem.id);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: CandyTheme.cardDecoration,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSolved ? CandyColors.success : CandyColors.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        isSolved ? Icons.check : Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Problem ${index + 1}',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Text(
                          problem.title,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  CandyTheme.difficultyBadge(problem.difficulty),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Return to Dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: CandyColors.textLight,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CandyColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Mock Test?'),
        content: const Text(
          'Are you sure you want to exit? Your progress will be saved but the timer will keep running.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Exit mock test
            },
            child: const Text(
              'Exit',
              style: TextStyle(color: CandyColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
