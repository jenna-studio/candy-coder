import '../models/problem.dart';

/// Service for importing problems from Baekjoon Online Judge
///
/// Note: Baekjoon has bot protection, so automated scraping is not possible.
/// This service provides:
/// 1. Manual problem entry with structured forms
/// 2. Problem templates for common Baekjoon problem types
/// 3. Helper methods to format problems correctly
class BaekjoonService {
  /// Creates a problem from manual entry data
  ///
  /// This method helps structure manually entered Baekjoon problems
  /// into the app's Problem model format.
  Problem createProblemFromManualEntry({
    required String problemId,
    required String title,
    required String description,
    required String inputFormat,
    required String outputFormat,
    required List<Map<String, String>> sampleCases,
    String difficulty = 'Medium',
    String topic = 'Algorithm',
  }) {
    // Combine description with input/output format
    final fullDescription = '''
$description

## Input Format
$inputFormat

## Output Format
$outputFormat

## Sample Cases
${_formatSampleCases(sampleCases)}
''';

    // Generate language templates
    final templates = _generateTemplates(problemId, title);

    // Convert sample cases to TestCase objects
    final testCases = sampleCases.map((sample) {
      return TestCase(
        input: sample['input'] ?? '',
        expectedOutput: sample['output'] ?? '',
      );
    }).toList();

    return Problem(
      id: 'baekjoon_$problemId',
      title: '[$problemId] $title',
      topic: topic,
      difficulty: difficulty,
      description: fullDescription,
      descriptionKo: fullDescription,
      templates: templates,
      testCases: testCases,
    );
  }

  /// Formats sample cases for display
  String _formatSampleCases(List<Map<String, String>> cases) {
    final buffer = StringBuffer();
    for (int i = 0; i < cases.length; i++) {
      buffer.writeln('### Sample ${i + 1}');
      buffer.writeln('**Input:**');
      buffer.writeln('```');
      buffer.writeln(cases[i]['input'] ?? '');
      buffer.writeln('```');
      buffer.writeln('**Output:**');
      buffer.writeln('```');
      buffer.writeln(cases[i]['output'] ?? '');
      buffer.writeln('```');
      buffer.writeln();
    }
    return buffer.toString();
  }

  /// Generates code templates for different languages
  Map<String, String> _generateTemplates(String problemId, String title) {
    return {
      'JavaScript': '''// Baekjoon $problemId: $title
const readline = require('readline');
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

let input = [];

rl.on('line', function (line) {
  input.push(line);
}).on('close', function () {
  // Your solution here
  const result = solve(input);
  console.log(result);
});

function solve(input) {
  // TODO: Implement your solution
  return '';
}''',
      'Python': '''# Baekjoon $problemId: $title
import sys
input = sys.stdin.readline

def solve():
    # TODO: Implement your solution
    pass

if __name__ == "__main__":
    solve()''',
      'C++': '''// Baekjoon $problemId: $title
#include <iostream>
#include <vector>
#include <string>
using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(NULL);

    // TODO: Implement your solution

    return 0;
}''',
      'Java': '''// Baekjoon $problemId: $title
import java.io.*;
import java.util.*;

public class Main {
    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(System.out));

        // TODO: Implement your solution

        bw.flush();
        bw.close();
        br.close();
    }
}''',
    };
  }

  /// Get problem templates for common Baekjoon problem types
  static List<ProblemTemplate> getCommonTemplates() {
    return [
      ProblemTemplate(
        name: 'Simple I/O',
        description: 'Basic input/output problem (e.g., A+B)',
        difficulty: 'Easy',
        topic: 'Implementation',
        sampleTitle: 'A+B',
        sampleDescription: 'Read two integers and output their sum.',
        sampleInput: '1 2',
        sampleOutput: '3',
      ),
      ProblemTemplate(
        name: 'Array Processing',
        description: 'Problems involving array manipulation',
        difficulty: 'Easy',
        topic: 'Array',
        sampleTitle: 'Maximum Value',
        sampleDescription: 'Find the maximum value in an array.',
        sampleInput: '5\n1 2 3 4 5',
        sampleOutput: '5',
      ),
      ProblemTemplate(
        name: 'String Processing',
        description: 'String manipulation and parsing',
        difficulty: 'Easy',
        topic: 'String',
        sampleTitle: 'Reverse String',
        sampleDescription: 'Reverse the given string.',
        sampleInput: 'hello',
        sampleOutput: 'olleh',
      ),
      ProblemTemplate(
        name: 'Dynamic Programming',
        description: 'DP optimization problems',
        difficulty: 'Hard',
        topic: 'DP',
        sampleTitle: 'Fibonacci',
        sampleDescription: 'Calculate the nth Fibonacci number.',
        sampleInput: '10',
        sampleOutput: '55',
      ),
      ProblemTemplate(
        name: 'Graph Traversal',
        description: 'BFS/DFS problems',
        difficulty: 'Medium',
        topic: 'Graph',
        sampleTitle: 'Shortest Path',
        sampleDescription: 'Find the shortest path in a graph.',
        sampleInput: '4\n1 2\n2 3\n3 4',
        sampleOutput: '3',
      ),
    ];
  }

  /// Validates if a problem ID is in correct Baekjoon format
  static bool isValidProblemId(String id) {
    final numericId = int.tryParse(id);
    return numericId != null && numericId > 0 && numericId < 100000;
  }

  /// Get difficulty suggestion based on problem ID range
  static String suggestDifficulty(String problemId) {
    final id = int.tryParse(problemId);
    if (id == null) return 'Medium';

    if (id < 1000) return 'Easy';
    if (id < 5000) return 'Easy';
    if (id < 10000) return 'Medium';
    if (id < 15000) return 'Medium';
    return 'Hard';
  }

  /// Get topic suggestions based on common Baekjoon categories
  static List<String> getTopicSuggestions() {
    return [
      'Implementation',
      'Math',
      'DP',
      'Graph',
      'Greedy',
      'String',
      'Data Structure',
      'Sorting',
      'Binary Search',
      'Two Pointer',
      'Brute Force',
      'Backtracking',
    ];
  }
}

/// Template for creating new problems quickly
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
