import 'package:flutter/material.dart';
import '../models/learning_path.dart';
import '../models/problem.dart';
import '../models/submission.dart';
import '../theme/candy_theme.dart';
import '../main.dart';

class LearningPathDetailScreen extends StatelessWidget {
  final LearningPath path;
  final List<Problem> problems;
  final List<Submission> submissions;

  const LearningPathDetailScreen({
    super.key,
    required this.path,
    required this.problems,
    required this.submissions,
  });

  bool _isModuleCompleted(Module module) {
    if (module.problemIds.isEmpty) return false;

    final solvedProblemIds = submissions
        .where((s) => s.status == 'Success')
        .map((s) => s.problemId)
        .toSet();

    return module.problemIds.every((id) => solvedProblemIds.contains(id));
  }

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
    final completedModules = path.modules.where(_isModuleCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(path.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  path.icon,
                  style: const TextStyle(fontSize: 64),
                ),
                const SizedBox(height: 16),
                Text(
                  path.title,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: color,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  path.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: color, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '$completedModules/${path.modules.length} Modules Completed',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: color,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Modules
          Text(
            'Modules',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),

          ...path.modules.map((module) {
            final isCompleted = _isModuleCompleted(module);
            final moduleProblems = problems
                .where((p) => module.problemIds.contains(p.id))
                .toList();

            return _ModuleCard(
              module: module,
              isCompleted: isCompleted,
              color: color,
              problems: moduleProblems,
            );
          }),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final Module module;
  final bool isCompleted;
  final Color color;
  final List<Problem> problems;

  const _ModuleCard({
    required this.module,
    required this.isCompleted,
    required this.color,
    required this.problems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: CandyTheme.cardDecoration.copyWith(
        border: isCompleted
            ? Border.all(
                color: color,
                width: 2,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Order number
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? color
                      : color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 24,
                        )
                      : Text(
                          '${module.order}',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),

              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: isCompleted ? color : null,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      module.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'DONE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Topics
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: module.topics.map((topic) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  topic,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),

          // Problems
          if (problems.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Practice Problems',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            ...problems.map((problem) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      // Navigate to problem detail
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProblemDetailScreen(
                            problem: problem,
                            onSubmit: (problemId, language, code) async {
                              // This would need to be passed from the parent
                              // For now, just show a message
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Solution submitted!'),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.code,
                          size: 16,
                          color: color,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            problem.title,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: color,
                                ),
                          ),
                        ),
                        CandyTheme.difficultyBadge(problem.difficulty),
                      ],
                    ),
                  ),
                )),
          ] else ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CandyColors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: CandyColors.blue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Practice problems coming soon! Import problems to start learning.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: CandyColors.blue,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
