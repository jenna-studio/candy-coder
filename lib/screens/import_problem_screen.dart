import 'package:flutter/material.dart';
import '../theme/candy_theme.dart';
import '../services/problem_import_service.dart';
import '../services/url_parser.dart';
import '../services/database_service.dart';

class ImportProblemScreen extends StatefulWidget {
  const ImportProblemScreen({super.key});

  @override
  State<ImportProblemScreen> createState() => _ImportProblemScreenState();
}

class _ImportProblemScreenState extends State<ImportProblemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _problemIdController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionKoController = TextEditingController();
  final _inputFormatController = TextEditingController();
  final _outputFormatController = TextEditingController();
  final _constraintsController = TextEditingController();

  String _selectedDifficulty = 'Medium';
  String _selectedTopic = 'Implementation';
  String _selectedLanguage = 'EN'; // EN or KR
  ProblemPlatform? _detectedPlatform;
  String? _helpText;

  final List<Map<String, TextEditingController>> _sampleCases = [];
  bool _isImporting = false;

  final _importService = ProblemImportService();

  @override
  void initState() {
    super.initState();
    _addSampleCase();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _problemIdController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _descriptionKoController.dispose();
    _inputFormatController.dispose();
    _outputFormatController.dispose();
    _constraintsController.dispose();
    for (var sample in _sampleCases) {
      sample['input']?.dispose();
      sample['output']?.dispose();
    }
    super.dispose();
  }

  void _addSampleCase() {
    setState(() {
      _sampleCases.add({
        'input': TextEditingController(),
        'output': TextEditingController(),
      });
    });
  }

  void _removeSampleCase(int index) {
    if (_sampleCases.length > 1) {
      setState(() {
        _sampleCases[index]['input']?.dispose();
        _sampleCases[index]['output']?.dispose();
        _sampleCases.removeAt(index);
      });
    }
  }

  void _handleUrlChange(String value) {
    if (value.isEmpty) {
      setState(() {
        _detectedPlatform = null;
        _helpText = null;
      });
      return;
    }

    final suggestions = _importService.getSuggestions(value);

    setState(() {
      _detectedPlatform = suggestions.platform;
      _helpText = suggestions.helpText;
      _problemIdController.text = suggestions.problemId;
      _selectedDifficulty = suggestions.suggestedDifficulty;
    });
  }

  Future<void> _importProblem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isImporting = true);

    try {
      // Prepare sample cases
      final sampleCases = _sampleCases.map((sample) {
        return {
          'input': sample['input']!.text,
          'output': sample['output']!.text,
        };
      }).toList();

      // Create problem using unified service
      final problem = _importService.createProblemFromUrl(
        urlOrId: _urlController.text.isNotEmpty ? _urlController.text : _problemIdController.text,
        title: _titleController.text,
        description: _descriptionController.text,
        descriptionKo: _descriptionKoController.text.isNotEmpty ? _descriptionKoController.text : null,
        inputFormat: _inputFormatController.text.isNotEmpty ? _inputFormatController.text : null,
        outputFormat: _outputFormatController.text.isNotEmpty ? _outputFormatController.text : null,
        constraints: _constraintsController.text.isNotEmpty ? _constraintsController.text : null,
        sampleCases: sampleCases,
        difficulty: _selectedDifficulty,
        topic: _selectedTopic,
      );

      if (problem == null) {
        throw Exception('Failed to create problem');
      }

      // Save to database
      await DatabaseService().insertProblem(problem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Problem "${_titleController.text}" imported successfully!'),
            backgroundColor: CandyColors.blue,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing problem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  void _useTemplate(dynamic template) {
    setState(() {
      _titleController.text = template.sampleTitle;
      _descriptionController.text = template.sampleDescription;
      _selectedDifficulty = template.difficulty;
      _selectedTopic = template.topic;

      // Clear existing sample cases
      for (var sample in _sampleCases) {
        sample['input']?.dispose();
        sample['output']?.dispose();
      }
      _sampleCases.clear();

      // Add template sample
      _sampleCases.add({
        'input': TextEditingController(text: template.sampleInput),
        'output': TextEditingController(text: template.sampleOutput),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_detectedPlatform == ProblemPlatform.leetcode
            ? 'Import LeetCode Problem'
            : _detectedPlatform == ProblemPlatform.baekjoon
                ? 'Import Baekjoon Problem'
                : 'Import Problem'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog();
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // URL Input Field
            TextFormField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Problem URL or ID',
                hintText: 'https://acmicpc.net/problem/1000 or https://leetcode.com/problems/two-sum',
                prefixIcon: const Icon(Icons.link),
                suffixIcon: _detectedPlatform != null
                    ? Icon(
                        _detectedPlatform == ProblemPlatform.baekjoon
                            ? Icons.check_circle
                            : Icons.code,
                        color: CandyColors.blue,
                      )
                    : null,
              ),
              onChanged: _handleUrlChange,
            ),
            if (_helpText != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CandyColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CandyColors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: CandyColors.success, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _helpText!,
                        style: TextStyle(color: CandyColors.success, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Info banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CandyColors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CandyColors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: CandyColors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Paste a problem URL above, or manually enter details. Supports Baekjoon (acmicpc.net) and LeetCode.',
                      style: TextStyle(color: CandyColors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Templates section
            Text(
              'Quick Templates',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _importService.getTemplates(_detectedPlatform).length,
                itemBuilder: (context, index) {
                  final template = _importService.getTemplates(_detectedPlatform)[index];
                  return GestureDetector(
                    onTap: () => _useTemplate(template),
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: CandyTheme.cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            template.description,
                            style: TextStyle(
                              fontSize: 10,
                              color: CandyColors.textLight,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          CandyTheme.difficultyBadge(template.difficulty),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Problem ID
            Text(
              'Problem Details',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _problemIdController,
              decoration: InputDecoration(
                labelText: 'Problem ID',
                hintText: _detectedPlatform == ProblemPlatform.leetcode
                    ? 'e.g., two-sum'
                    : 'e.g., 1000',
                prefixIcon: const Icon(Icons.tag),
              ),
              keyboardType: _detectedPlatform == ProblemPlatform.leetcode
                  ? TextInputType.text
                  : TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter problem ID';
                }
                return null;
              },
              enabled: _urlController.text.isEmpty,
            ),
            const SizedBox(height: 16),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g., A+B',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Difficulty and Topic
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedDifficulty,
                    decoration: const InputDecoration(
                      labelText: 'Difficulty',
                      prefixIcon: Icon(Icons.speed),
                    ),
                    items: ['Easy', 'Medium', 'Hard']
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedDifficulty = value!);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedTopic,
                    decoration: const InputDecoration(
                      labelText: 'Topic',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _importService.getTopicSuggestions(_detectedPlatform)
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedTopic = value!);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description with Language Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'EN', label: Text('EN')),
                    ButtonSegment(value: 'KR', label: Text('KR')),
                  ],
                  selected: {_selectedLanguage},
                  onSelectionChanged: (Set<String> selected) {
                    setState(() {
                      _selectedLanguage = selected.first;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _selectedLanguage == 'EN' ? _descriptionController : _descriptionKoController,
              decoration: InputDecoration(
                labelText: _selectedLanguage == 'EN' ? 'Description (English)' : '설명 (한국어)',
                hintText: _selectedLanguage == 'EN' ? 'Problem description...' : '문제 설명...',
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 4,
              validator: (value) {
                if (_selectedLanguage == 'EN' && (value == null || value.isEmpty)) {
                  return 'Please enter description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Conditional fields based on platform
            if (_detectedPlatform == ProblemPlatform.baekjoon || _detectedPlatform == null) ...[
              // Input Format (Baekjoon)
              TextFormField(
                controller: _inputFormatController,
                decoration: const InputDecoration(
                  labelText: 'Input Format',
                  hintText: 'Describe the input format...',
                  prefixIcon: Icon(Icons.input),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Output Format (Baekjoon)
              TextFormField(
                controller: _outputFormatController,
                decoration: const InputDecoration(
                  labelText: 'Output Format',
                  hintText: 'Describe the output format...',
                  prefixIcon: Icon(Icons.output),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
            ],

            if (_detectedPlatform == ProblemPlatform.leetcode) ...[
              // Constraints (LeetCode)
              TextFormField(
                controller: _constraintsController,
                decoration: const InputDecoration(
                  labelText: 'Constraints',
                  hintText: 'e.g., 1 <= n <= 10^5',
                  prefixIcon: Icon(Icons.rule),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 8),

            // Sample Cases
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sample Test Cases',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: CandyColors.pink),
                  onPressed: _addSampleCase,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Sample case inputs
            ..._sampleCases.asMap().entries.map((entry) {
              final index = entry.key;
              final sample = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: CandyTheme.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sample ${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (_sampleCases.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => _removeSampleCase(index),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: sample['input'],
                      decoration: const InputDecoration(
                        labelText: 'Input',
                        hintText: 'Sample input...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      style: const TextStyle(fontFamily: 'monospace'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter sample input';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: sample['output'],
                      decoration: const InputDecoration(
                        labelText: 'Expected Output',
                        hintText: 'Expected output...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      style: const TextStyle(fontFamily: 'monospace'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter expected output';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // Import button
            ElevatedButton(
              onPressed: _isImporting ? null : _importProblem,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: _isImporting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Import Problem'),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Import'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Import from URL:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('1. Copy the problem URL from Baekjoon (acmicpc.net) or LeetCode'),
              SizedBox(height: 8),
              Text('2. Paste it in the "Problem URL or ID" field'),
              SizedBox(height: 8),
              Text('3. The app will detect the platform and pre-fill some fields'),
              SizedBox(height: 8),
              Text('4. Fill in remaining details manually'),
              SizedBox(height: 16),
              Text('Manual Import:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('1. Enter problem ID directly'),
              SizedBox(height: 8),
              Text('2. Fill in title, description, and test cases'),
              SizedBox(height: 8),
              Text('3. Toggle EN/KR for bilingual support'),
              SizedBox(height: 16),
              Text(
                'Tip: Use quick templates to get started faster!',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
