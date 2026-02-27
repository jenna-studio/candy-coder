import '../models/problem.dart';

/// Service for importing problems from LeetCode
///
/// Note: LeetCode has bot protection, so automated scraping is not possible.
/// This service provides:
/// 1. Manual problem entry with structured forms
/// 2. Problem templates for common LeetCode problem types
/// 3. Helper methods to format problems correctly
/// 4. Support for both English and Korean descriptions
class LeetCodeService {
  /// Creates a problem from manual entry data
  ///
  /// This method helps structure manually entered LeetCode problems
  /// into the app's Problem model format.
  Problem createProblemFromManualEntry({
    required String problemId,
    required String title,
    required String description,
    String? descriptionKo,
    String? constraints,
    required List<Map<String, String>> sampleCases,
    String difficulty = 'Medium',
    String topic = 'Algorithm',
  }) {
    // Combine description with constraints
    final fullDescriptionEn = '''
$description

${constraints != null ? '## Constraints\n$constraints\n' : ''}
## Examples
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
      id: 'leetcode_$problemId',
      title: title,
      topic: topic,
      difficulty: difficulty,
      description: fullDescriptionEn,
      descriptionKo: descriptionKo,
      templates: templates,
      testCases: testCases,
    );
  }

  /// Formats sample cases for display
  String _formatSampleCases(List<Map<String, String>> cases) {
    final buffer = StringBuffer();
    for (int i = 0; i < cases.length; i++) {
      buffer.writeln('### Example ${i + 1}');
      buffer.writeln('**Input:**');
      buffer.writeln('```');
      buffer.writeln(cases[i]['input'] ?? '');
      buffer.writeln('```');
      buffer.writeln('**Output:**');
      buffer.writeln('```');
      buffer.writeln(cases[i]['output'] ?? '');
      buffer.writeln('```');
      if (cases[i]['explanation'] != null) {
        buffer.writeln('**Explanation:** ${cases[i]['explanation']}');
      }
      buffer.writeln();
    }
    return buffer.toString();
  }

  /// Generates code templates for different languages
  Map<String, String> _generateTemplates(String problemId, String title) {
    // Convert problem title to function name (e.g., "Two Sum" -> "twoSum")
    final functionName = _titleToFunctionName(title);

    return {
      'JavaScript': '''/**
 * LeetCode Problem: $title
 * @param {any} input
 * @return {any}
 */
function $functionName(input) {
  // Write your code here

}

// Test
console.log($functionName());''',
      'Python': '''# LeetCode Problem: $title

class Solution:
    def $functionName(self, input):
        """
        :type input: any
        :rtype: any
        """
        # Write your code here
        pass

# Test
solution = Solution()
print(solution.$functionName())''',
      'C++': '''// LeetCode Problem: $title
#include <iostream>
#include <vector>
#include <string>
using namespace std;

class Solution {
public:
    auto $functionName(auto input) {
        // Write your code here

    }
};

int main() {
    Solution solution;
    // Test your solution
    return 0;
}''',
      'Java': '''// LeetCode Problem: $title
import java.util.*;

class Solution {
    public Object $functionName(Object input) {
        // Write your code here
        return null;
    }

    public static void main(String[] args) {
        Solution solution = new Solution();
        // Test your solution
    }
}''',
    };
  }

  /// Convert title to function name (e.g., "Two Sum" -> "twoSum")
  String _titleToFunctionName(String title) {
    final words = title.split(' ');
    if (words.isEmpty) return 'solution';

    return words[0].toLowerCase() +
           words.skip(1).map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase()).join('');
  }

  /// Get problem templates for common LeetCode problem types
  static List<ProblemTemplate> getCommonTemplates() {
    return [
      ProblemTemplate(
        name: 'Array',
        description: 'Array manipulation problems',
        difficulty: 'Easy',
        topic: 'Array',
        sampleTitle: 'Two Sum',
        sampleDescription: 'Given an array of integers nums and an integer target, return indices of the two numbers that add up to target.',
        sampleInput: 'nums = [2,7,11,15], target = 9',
        sampleOutput: '[0,1]',
      ),
      ProblemTemplate(
        name: 'String',
        description: 'String processing problems',
        difficulty: 'Easy',
        topic: 'String',
        sampleTitle: 'Valid Palindrome',
        sampleDescription: 'Given a string s, determine if it is a palindrome.',
        sampleInput: 's = "A man, a plan, a canal: Panama"',
        sampleOutput: 'true',
      ),
      ProblemTemplate(
        name: 'Linked List',
        description: 'Linked list manipulation',
        difficulty: 'Medium',
        topic: 'Linked List',
        sampleTitle: 'Reverse Linked List',
        sampleDescription: 'Given the head of a singly linked list, reverse the list.',
        sampleInput: 'head = [1,2,3,4,5]',
        sampleOutput: '[5,4,3,2,1]',
      ),
      ProblemTemplate(
        name: 'Tree',
        description: 'Binary tree problems',
        difficulty: 'Medium',
        topic: 'Tree',
        sampleTitle: 'Maximum Depth',
        sampleDescription: 'Find the maximum depth of a binary tree.',
        sampleInput: 'root = [3,9,20,null,null,15,7]',
        sampleOutput: '3',
      ),
      ProblemTemplate(
        name: 'Dynamic Programming',
        description: 'DP optimization problems',
        difficulty: 'Hard',
        topic: 'DP',
        sampleTitle: 'Longest Increasing Subsequence',
        sampleDescription: 'Find the length of the longest strictly increasing subsequence.',
        sampleInput: 'nums = [10,9,2,5,3,7,101,18]',
        sampleOutput: '4',
      ),
    ];
  }

  /// Validates if a problem ID is in correct LeetCode format
  static bool isValidProblemId(String id) {
    // LeetCode uses kebab-case slugs (e.g., "two-sum")
    return RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$').hasMatch(id);
  }

  /// Get difficulty suggestion based on problem patterns
  static String suggestDifficulty(String title) {
    final lowerTitle = title.toLowerCase();

    // Keywords that suggest difficulty
    if (lowerTitle.contains('basic') || lowerTitle.contains('simple')) return 'Easy';
    if (lowerTitle.contains('hard') || lowerTitle.contains('complex')) return 'Hard';
    if (lowerTitle.contains('advanced') || lowerTitle.contains('optimal')) return 'Hard';

    return 'Medium';
  }

  /// Get topic suggestions based on common LeetCode categories
  static List<String> getTopicSuggestions() {
    return [
      'Array',
      'String',
      'Hash Table',
      'Dynamic Programming',
      'Math',
      'Sorting',
      'Greedy',
      'Tree',
      'Graph',
      'Binary Search',
      'Two Pointers',
      'Stack',
      'Queue',
      'Linked List',
      'Backtracking',
      'Heap',
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
