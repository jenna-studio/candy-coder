import 'package:flutter/material.dart';
import '../theme/candy_theme.dart';
import '../services/leetcode_service.dart';
import '../services/database_service.dart';

class LeetCodeImportScreen extends StatefulWidget {
  const LeetCodeImportScreen({super.key});

  @override
  State<LeetCodeImportScreen> createState() => _LeetCodeImportScreenState();
}

class _LeetCodeImportScreenState extends State<LeetCodeImportScreen> {
  String? _selectedDifficulty;
  int _problemCount = 10;
  bool _isImporting = false;
  double _progress = 0.0;
  String _statusMessage = '';
  final List<String> _importedProblems = [];
  int _successCount = 0;
  int _failCount = 0;

  Future<void> _startImport() async {
    if (_isImporting) return;

    setState(() {
      _isImporting = true;
      _progress = 0.0;
      _statusMessage = 'Fetching problems from LeetCode...';
      _importedProblems.clear();
      _successCount = 0;
      _failCount = 0;
    });

    try {
      // Fetch problems from LeetCode
      final problems = await LeetCodeService.fetchProblems(
        limit: _problemCount,
        difficulty: _selectedDifficulty,
      );

      if (problems.isEmpty) {
        setState(() {
          _statusMessage = 'No problems found. Try different filters.';
          _isImporting = false;
        });
        return;
      }

      setState(() {
        _statusMessage = 'Importing ${problems.length} problems...';
      });

      // Import each problem to database
      final db = DatabaseService();
      for (int i = 0; i < problems.length; i++) {
        try {
          await db.insertProblem(problems[i]);
          _successCount++;
          _importedProblems.add('✓ ${problems[i].title}');
        } catch (e) {
          _failCount++;
          _importedProblems.add('✗ ${problems[i].title} - Error: $e');
        }

        setState(() {
          _progress = (i + 1) / problems.length;
          _statusMessage = 'Imported ${i + 1}/${problems.length} problems...';
        });
      }

      setState(() {
        _statusMessage = 'Import complete! Success: $_successCount, Failed: $_failCount';
        _isImporting = false;
      });

      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: CandyColors.green),
                SizedBox(width: 8),
                Text('Import Complete'),
              ],
            ),
            content: Text(
              'Successfully imported $_successCount problems!\n${_failCount > 0 ? 'Failed: $_failCount' : ''}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(true); // Return to previous screen
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _isImporting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: CandyColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from LeetCode'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [CandyColors.purple, CandyColors.pink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.cloud_download, size: 48, color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Bulk Import Problems',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Import problems directly from LeetCode',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Filters
            Container(
              padding: const EdgeInsets.all(20),
              decoration: CandyTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Import Settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Difficulty selector
                  const Text(
                    'Difficulty',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _selectedDifficulty == null,
                        onSelected: (selected) {
                          setState(() => _selectedDifficulty = null);
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Easy'),
                        selected: _selectedDifficulty == 'EASY',
                        selectedColor: CandyColors.green,
                        onSelected: (selected) {
                          setState(() => _selectedDifficulty = 'EASY');
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Medium'),
                        selected: _selectedDifficulty == 'MEDIUM',
                        selectedColor: CandyColors.yellow,
                        onSelected: (selected) {
                          setState(() => _selectedDifficulty = 'MEDIUM');
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Hard'),
                        selected: _selectedDifficulty == 'HARD',
                        selectedColor: CandyColors.error,
                        onSelected: (selected) {
                          setState(() => _selectedDifficulty = 'HARD');
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Number of problems
                  Text(
                    'Number of Problems: $_problemCount',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _problemCount.toDouble(),
                    min: 5,
                    max: 50,
                    divisions: 9,
                    label: '$_problemCount',
                    onChanged: _isImporting
                        ? null
                        : (value) {
                            setState(() => _problemCount = value.toInt());
                          },
                  ),
                  const Text(
                    'Note: Each problem requires an individual API call, so larger imports may take several minutes.',
                    style: TextStyle(
                      fontSize: 12,
                      color: CandyColors.textLight,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Import button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isImporting ? null : _startImport,
                icon: _isImporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.download),
                label: Text(_isImporting ? 'Importing...' : 'Start Import'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CandyColors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            if (_isImporting || _importedProblems.isNotEmpty) ...[
              const SizedBox(height: 24),

              // Progress indicator
              if (_isImporting)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: CandyTheme.cardDecoration,
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: CandyColors.textLight.withValues(alpha: 0.2),
                        color: CandyColors.blue,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _statusMessage,
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

              // Import results
              if (_importedProblems.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: CandyTheme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Import Results',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '$_successCount/${ _successCount + _failCount}',
                            style: const TextStyle(
                              color: CandyColors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _importedProblems.length,
                          itemBuilder: (context, index) {
                            final item = _importedProblems[index];
                            final isSuccess = item.startsWith('✓');
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSuccess ? CandyColors.green : CandyColors.error,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
