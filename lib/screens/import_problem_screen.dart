import 'package:flutter/material.dart';
import '../theme/candy_theme.dart';
import '../services/baekjoon_service.dart';
import '../services/database_service.dart';

class ImportProblemScreen extends StatefulWidget {
  const ImportProblemScreen({super.key});

  @override
  State<ImportProblemScreen> createState() => _ImportProblemScreenState();
}

class _ImportProblemScreenState extends State<ImportProblemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _problemIdController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _inputFormatController = TextEditingController();
  final _outputFormatController = TextEditingController();

  String _selectedDifficulty = 'Medium';
  String _selectedTopic = 'Implementation';

  final List<Map<String, TextEditingController>> _sampleCases = [];
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _addSampleCase();
  }

  @override
  void dispose() {
    _problemIdController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _inputFormatController.dispose();
    _outputFormatController.dispose();
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

  Future<void> _importProblem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isImporting = true);

    try {
      final service = BaekjoonService();

      // Prepare sample cases
      final sampleCases = _sampleCases.map((sample) {
        return {
          'input': sample['input']!.text,
          'output': sample['output']!.text,
        };
      }).toList();

      // Create problem
      final problem = service.createProblemFromManualEntry(
        problemId: _problemIdController.text,
        title: _titleController.text,
        description: _descriptionController.text,
        inputFormat: _inputFormatController.text,
        outputFormat: _outputFormatController.text,
        sampleCases: sampleCases,
        difficulty: _selectedDifficulty,
        topic: _selectedTopic,
      );

      // Save to database
      await DatabaseService().insertProblem(problem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Problem ${_problemIdController.text} imported successfully!'),
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

  void _useTemplate(ProblemTemplate template) {
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
        title: const Text('Import Baekjoon Problem'),
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
                      'Manually enter Baekjoon problem details. Visit acmicpc.net to copy the problem information.',
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
                itemCount: BaekjoonService.getCommonTemplates().length,
                itemBuilder: (context, index) {
                  final template = BaekjoonService.getCommonTemplates()[index];
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
              decoration: const InputDecoration(
                labelText: 'Problem ID',
                hintText: 'e.g., 1000',
                prefixIcon: Icon(Icons.tag),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter problem ID';
                }
                if (!BaekjoonService.isValidProblemId(value)) {
                  return 'Invalid problem ID';
                }
                return null;
              },
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _selectedDifficulty = BaekjoonService.suggestDifficulty(value);
                  });
                }
              },
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
                    items: BaekjoonService.getTopicSuggestions()
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

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Problem description...',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Input Format
            TextFormField(
              controller: _inputFormatController,
              decoration: const InputDecoration(
                labelText: 'Input Format',
                hintText: 'Describe the input format...',
                prefixIcon: Icon(Icons.input),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter input format';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Output Format
            TextFormField(
              controller: _outputFormatController,
              decoration: const InputDecoration(
                labelText: 'Output Format',
                hintText: 'Describe the output format...',
                prefixIcon: Icon(Icons.output),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter output format';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

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
              Text('1. Visit acmicpc.net and find a problem'),
              SizedBox(height: 8),
              Text('2. Copy the problem ID from the URL'),
              SizedBox(height: 8),
              Text('3. Fill in the problem details manually'),
              SizedBox(height: 8),
              Text('4. Add sample test cases'),
              SizedBox(height: 8),
              Text('5. Click Import to save'),
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
