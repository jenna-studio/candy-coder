class Problem {
  final String id;
  final String title;
  final String topic;
  final String difficulty;
  final String description;
  final String? descriptionKo;
  final Map<String, String> templates;
  final List<TestCase> testCases;

  Problem({
    required this.id,
    required this.title,
    required this.topic,
    required this.difficulty,
    required this.description,
    this.descriptionKo,
    required this.templates,
    required this.testCases,
  });

  factory Problem.fromMap(Map<String, dynamic> map) {
    return Problem(
      id: map['id'] as String,
      title: map['title'] as String,
      topic: map['topic'] as String,
      difficulty: map['difficulty'] as String,
      description: map['description'] as String,
      descriptionKo: map['description_ko'] as String?,
      templates: Map<String, String>.from(map['templates'] as Map),
      testCases: (map['testCases'] as List)
          .map((tc) => TestCase.fromMap(tc))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'topic': topic,
      'difficulty': difficulty,
      'description': description,
      'description_ko': descriptionKo,
      'templates': templates,
      'testCases': testCases.map((tc) => tc.toMap()).toList(),
    };
  }
}

class TestCase {
  final String input;
  final String expectedOutput;

  TestCase({
    required this.input,
    required this.expectedOutput,
  });

  factory TestCase.fromMap(Map<String, dynamic> map) {
    return TestCase(
      input: map['input'] as String,
      expectedOutput: map['expectedOutput'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'input': input,
      'expectedOutput': expectedOutput,
    };
  }
}
