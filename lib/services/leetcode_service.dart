import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/problem.dart';

/// Service for fetching problems from LeetCode via GraphQL API
class LeetCodeService {
  static const String _graphqlUrl = 'https://leetcode.com/graphql';

  /// Fetch a list of problems from LeetCode
  ///
  /// Parameters:
  /// - [limit]: Maximum number of problems to fetch (default: 50)
  /// - [skip]: Number of problems to skip for pagination (default: 0)
  /// - [difficulty]: Filter by difficulty ('EASY', 'MEDIUM', 'HARD', or null for all)
  ///
  /// Returns a list of Problem objects
  static Future<List<Problem>> fetchProblems({
    int limit = 50,
    int skip = 0,
    String? difficulty,
  }) async {
    try {
      // GraphQL query to fetch problem list
      final query = '''
        query problemsetQuestionList(\$categorySlug: String, \$limit: Int, \$skip: Int, \$filters: QuestionListFilterInput) {
          problemsetQuestionList: questionList(
            categorySlug: \$categorySlug
            limit: \$limit
            skip: \$skip
            filters: \$filters
          ) {
            total: totalNum
            questions: data {
              questionId
              questionFrontendId
              title
              titleSlug
              difficulty
              isPaidOnly
              topicTags {
                name
                slug
              }
              acRate
            }
          }
        }
      ''';

      final variables = {
        'categorySlug': '',
        'skip': skip,
        'limit': limit,
        'filters': difficulty != null
            ? {'difficulty': difficulty}
            : {},
      };

      final response = await http.post(
        Uri.parse(_graphqlUrl),
        headers: {
          'Content-Type': 'application/json',
          'Referer': 'https://leetcode.com',
        },
        body: jsonEncode({
          'query': query,
          'variables': variables,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['errors'] != null) {
          throw Exception('GraphQL Error: ${data['errors']}');
        }

        final questions = data['data']?['problemsetQuestionList']?['questions'] as List?;
        if (questions == null) {
          return [];
        }

        final problems = <Problem>[];
        for (var q in questions) {
          // Skip paid-only problems
          if (q['isPaidOnly'] == true) continue;

          try {
            final problem = await _convertToProblem(q);
            if (problem != null) {
              problems.add(problem);
              // Add delay to avoid rate limiting
              await Future.delayed(const Duration(milliseconds: 200));
            }
          } catch (e) {
            debugPrint('Error converting problem ${q['title']}: $e');
            continue;
          }
        }

        return problems;
      } else {
        throw Exception('Failed to fetch problems: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching LeetCode problems: $e');
    }
  }

  /// Fetch a single problem with detailed information
  static Future<Problem?> fetchProblemBySlug(String titleSlug) async {
    try {
      final query = '''
        query questionData(\$titleSlug: String!) {
          question(titleSlug: \$titleSlug) {
            questionId
            questionFrontendId
            title
            titleSlug
            content
            difficulty
            topicTags {
              name
              slug
            }
            codeSnippets {
              lang
              langSlug
              code
            }
            sampleTestCase
            exampleTestcases
          }
        }
      ''';

      final response = await http.post(
        Uri.parse(_graphqlUrl),
        headers: {
          'Content-Type': 'application/json',
          'Referer': 'https://leetcode.com',
        },
        body: jsonEncode({
          'query': query,
          'variables': {'titleSlug': titleSlug},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['errors'] != null) {
          debugPrint('GraphQL Error for $titleSlug: ${data['errors']}');
          return null;
        }

        final question = data['data']?['question'];

        if (question == null) return null;

        return _convertDetailedToProblem(question);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching problem details for $titleSlug: $e');
      return null;
    }
  }

  /// Convert LeetCode question to our Problem model (basic info)
  static Future<Problem?> _convertToProblem(Map<String, dynamic> q) async {
    try {
      final titleSlug = q['titleSlug'] as String;

      // Fetch detailed info to get description and code snippets
      final detailedProblem = await fetchProblemBySlug(titleSlug);
      return detailedProblem;
    } catch (e) {
      debugPrint('Error converting problem ${q['title']}: $e');
      return null;
    }
  }

  /// Convert detailed LeetCode question to our Problem model
  static Problem _convertDetailedToProblem(Map<String, dynamic> q) {
    final questionId = q['questionFrontendId'].toString();
    final title = q['title'] as String;
    final difficulty = q['difficulty'] as String;

    // Extract topics (use first topic as main category, or 'Array' as default)
    final topics = (q['topicTags'] as List?)
        ?.map((t) => t['name'] as String)
        .toList() ?? [];
    final mainTopic = topics.isNotEmpty ? topics.first : 'Array';

    // Clean HTML description
    String description = q['content'] as String? ?? 'No description available';
    description = _cleanHtml(description);

    // Extract code templates
    final codeSnippets = (q['codeSnippets'] as List?) ?? [];
    final templates = <String, String>{};

    for (var snippet in codeSnippets) {
      final lang = snippet['lang'] as String;
      final code = snippet['code'] as String;

      // Map LeetCode language names to our format
      if (lang == 'JavaScript' || lang == 'TypeScript') {
        templates['JavaScript'] = code;
      } else if (lang == 'Python' || lang == 'Python3') {
        templates['Python'] = code;
      } else if (lang == 'C++') {
        templates['C++'] = code;
      } else if (lang == 'Java') {
        templates['Java'] = code;
      }
    }

    // Ensure we have at least basic templates
    if (templates.isEmpty) {
      templates['JavaScript'] = '// Write your solution here';
      templates['Python'] = '# Write your solution here';
      templates['C++'] = '// Write your solution here';
      templates['Java'] = '// Write your solution here';
    }

    // Create basic test cases from sample test case
    final testCases = <TestCase>[];
    final sampleTest = q['sampleTestCase'] as String?;
    final exampleTests = q['exampleTestcases'] as String?;

    if (sampleTest != null && sampleTest.isNotEmpty) {
      testCases.add(TestCase(
        input: sampleTest,
        expectedOutput: 'See problem examples',
      ));
    }

    // If we have example test cases, try to parse them
    if (exampleTests != null && exampleTests.isNotEmpty) {
      final examples = exampleTests.split('\n');
      for (var example in examples.take(2)) {
        if (example.trim().isNotEmpty) {
          testCases.add(TestCase(
            input: example.trim(),
            expectedOutput: 'See problem examples',
          ));
        }
      }
    }

    // Ensure at least one test case exists
    if (testCases.isEmpty) {
      testCases.add(TestCase(
        input: '',
        expectedOutput: 'See problem examples',
      ));
    }

    return Problem(
      id: 'leetcode_$questionId',
      title: '$questionId. $title',
      topic: mainTopic,
      difficulty: difficulty == 'Easy' ? 'Easy' : (difficulty == 'Hard' ? 'Hard' : 'Medium'),
      description: description,
      templates: templates,
      testCases: testCases,
    );
  }

  /// Clean HTML tags from description
  static String _cleanHtml(String html) {
    // Remove HTML tags
    String cleaned = html.replaceAll(RegExp(r'<[^>]*>'), ' ');

    // Decode HTML entities
    cleaned = cleaned
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"')
        .replaceAll('&ndash;', '-')
        .replaceAll('&mdash;', '-');

    // Clean up excessive whitespace
    cleaned = cleaned
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n')
        .trim();

    return cleaned;
  }

  /// Get available difficulty levels
  static List<String> getDifficultyLevels() {
    return ['EASY', 'MEDIUM', 'HARD'];
  }

  /// Get available topic categories
  static List<String> getTopicCategories() {
    return [
      'Array',
      'String',
      'Hash Table',
      'Dynamic Programming',
      'Math',
      'Sorting',
      'Greedy',
      'Depth-First Search',
      'Binary Search',
      'Breadth-First Search',
      'Tree',
      'Two Pointers',
      'Stack',
      'Graph',
      'Linked List',
      'Backtracking',
      'Heap',
    ];
  }

  /// Alias for getTopicCategories for compatibility
  static List<String> getTopicSuggestions() {
    return getTopicCategories();
  }

  /// Suggest difficulty based on title (placeholder implementation)
  static String suggestDifficulty(String title) {
    // Simple heuristic: if title contains certain keywords, suggest difficulty
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('easy') || lowerTitle.contains('simple')) {
      return 'Easy';
    } else if (lowerTitle.contains('hard') || lowerTitle.contains('complex')) {
      return 'Hard';
    }
    return 'Medium';
  }

  /// Validate if a problem ID is valid for LeetCode (slug format)
  static bool isValidProblemId(String id) {
    // LeetCode slugs are lowercase with hyphens, no spaces
    return RegExp(r'^[a-z0-9\-]+$').hasMatch(id);
  }

  /// Get common problem templates
  static List<ProblemTemplate> getCommonTemplates() {
    return [
      ProblemTemplate(
        name: 'Two Sum',
        description: 'Array & Hash Table',
        difficulty: 'Easy',
        topic: 'Array',
        sampleTitle: 'Two Sum',
        sampleDescription: 'Given an array of integers, return indices of the two numbers that add up to a specific target.',
        sampleInput: '[2,7,11,15], target = 9',
        sampleOutput: '[0,1]',
      ),
      ProblemTemplate(
        name: 'Reverse String',
        description: 'String manipulation',
        difficulty: 'Easy',
        topic: 'String',
        sampleTitle: 'Reverse String',
        sampleDescription: 'Write a function that reverses a string.',
        sampleInput: 'hello',
        sampleOutput: 'olleh',
      ),
      ProblemTemplate(
        name: 'Max Subarray',
        description: 'Dynamic Programming',
        difficulty: 'Medium',
        topic: 'Dynamic Programming',
        sampleTitle: 'Maximum Subarray',
        sampleDescription: 'Find the contiguous subarray with the largest sum.',
        sampleInput: '[-2,1,-3,4,-1,2,1,-5,4]',
        sampleOutput: '6',
      ),
    ];
  }

  /// Create a problem from manual entry
  Problem createProblemFromManualEntry({
    required String problemId,
    required String title,
    required String description,
    String? descriptionKo,
    String? constraints,
    required List<Map<String, String>> sampleCases,
    required String difficulty,
    required String topic,
  }) {
    // Create code templates
    final templates = <String, String>{
      'JavaScript': '// Write your solution here\nfunction solution() {\n    \n}',
      'Python': '# Write your solution here\ndef solution():\n    pass',
      'C++': '// Write your solution here\nclass Solution {\npublic:\n    \n};',
      'Java': '// Write your solution here\nclass Solution {\n    \n}',
    };

    // Convert sample cases to TestCase objects
    final testCases = sampleCases.map((sample) {
      return TestCase(
        input: sample['input'] ?? '',
        expectedOutput: sample['output'] ?? '',
      );
    }).toList();

    // Append constraints to description if provided
    String fullDescription = description;
    if (constraints != null && constraints.isNotEmpty) {
      fullDescription += '\n\nConstraints:\n$constraints';
    }

    return Problem(
      id: 'leetcode_$problemId',
      title: title,
      topic: topic,
      difficulty: difficulty,
      description: fullDescription,
      descriptionKo: descriptionKo,
      templates: templates,
      testCases: testCases,
    );
  }
}

/// Template for creating new problems
class ProblemTemplate {
  final String name;
  final String description;
  final String difficulty;
  final String topic;
  final String sampleTitle;
  final String sampleDescription;
  final String sampleInput;
  final String sampleOutput;

  ProblemTemplate({
    required this.name,
    required this.description,
    required this.difficulty,
    required this.topic,
    required this.sampleTitle,
    required this.sampleDescription,
    required this.sampleInput,
    required this.sampleOutput,
  });
}
