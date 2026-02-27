class LearningPath {
  final String id;
  final String title;
  final String description;
  final String icon;
  final List<Module> modules;
  final int estimatedHours;

  LearningPath({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.modules,
    required this.estimatedHours,
  });
}

class Module {
  final String id;
  final String title;
  final String description;
  final List<String> topics;
  final List<String> problemIds;
  final int order;

  Module({
    required this.id,
    required this.title,
    required this.description,
    required this.topics,
    required this.problemIds,
    required this.order,
  });
}
