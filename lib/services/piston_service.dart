import 'dart:convert';
import 'package:http/http.dart' as http;

/// Free code execution service using Piston API (emkc.org)
/// Zero-cost solution for running code in multiple languages
class PistonService {
  static const String _baseUrl = 'https://emkc.org/api/v2/piston';

  /// Language mappings for Piston API
  /// Format: 'language': {'language': 'piston_name', 'version': 'version_string'}
  static const Map<String, Map<String, String>> _languageMap = {
    'javascript': {'language': 'javascript', 'version': '18.15.0'},
    'python': {'language': 'python', 'version': '3.10.0'},
    'cpp': {'language': 'c++', 'version': '10.2.0'},
    'java': {'language': 'java', 'version': '15.0.2'},
  };

  /// Execute code and return execution result
  ///
  /// Parameters:
  /// - [code]: Source code to execute
  /// - [language]: Language identifier (javascript, python, cpp, java)
  /// - [stdin]: Standard input for the program (optional)
  /// - [timeout]: Execution timeout in milliseconds (default: 3000ms)
  ///
  /// Returns a map with execution results:
  /// - success: bool
  /// - stdout: string (program output)
  /// - stderr: string (error messages)
  /// - exitCode: int (0 = success)
  /// - runtime: string (execution time)
  /// - error: string (API/network errors)
  static Future<Map<String, dynamic>> executeCode({
    required String code,
    required String language,
    String stdin = '',
    int timeout = 3000,
  }) async {
    try {
      // Validate language
      if (!_languageMap.containsKey(language.toLowerCase())) {
        return {
          'success': false,
          'error': 'Unsupported language: $language',
          'stdout': '',
          'stderr': 'Language not supported',
          'exitCode': -1,
          'runtime': '0ms',
        };
      }

      final langConfig = _languageMap[language.toLowerCase()]!;

      // Prepare request body
      final requestBody = {
        'language': langConfig['language'],
        'version': langConfig['version'],
        'files': [
          {'content': code}
        ],
        'stdin': stdin,
        'args': [],
        'compile_timeout': timeout,
        'run_timeout': timeout,
      };

      // Make API request
      final response = await http
          .post(
            Uri.parse('$_baseUrl/execute'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(Duration(milliseconds: timeout + 2000));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final run = result['run'] as Map<String, dynamic>;

        return {
          'success': (run['code'] as int) == 0 && (run['stderr'] as String).isEmpty,
          'stdout': run['stdout'] as String? ?? '',
          'stderr': run['stderr'] as String? ?? '',
          'exitCode': run['code'] as int? ?? -1,
          'runtime': '${result['run']?['output']?.length ?? 0}ms', // Approximate
          'error': '',
        };
      } else {
        return {
          'success': false,
          'error': 'Piston API error: ${response.statusCode}',
          'stdout': '',
          'stderr': response.body,
          'exitCode': -1,
          'runtime': '0ms',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Execution failed: $e',
        'stdout': '',
        'stderr': e.toString(),
        'exitCode': -1,
        'runtime': '0ms',
      };
    }
  }

  /// Run code against multiple test cases
  ///
  /// Parameters:
  /// - [code]: Source code to execute
  /// - [language]: Language identifier
  /// - [testCases]: List of test cases, each with 'input' and 'expectedOutput'
  ///
  /// Returns:
  /// - passedCount: Number of test cases passed
  /// - totalCount: Total number of test cases
  /// - results: List of individual test case results
  /// - overallSuccess: True if all test cases passed
  static Future<Map<String, dynamic>> runTestCases({
    required String code,
    required String language,
    required List<Map<String, String>> testCases,
  }) async {
    final List<Map<String, dynamic>> results = [];
    int passedCount = 0;

    for (int i = 0; i < testCases.length; i++) {
      final testCase = testCases[i];
      final input = testCase['input'] ?? '';
      final expectedOutput = (testCase['expectedOutput'] ?? '').trim();

      final execution = await executeCode(
        code: code,
        language: language,
        stdin: input,
      );

      final actualOutput = (execution['stdout'] as String).trim();
      final passed = execution['success'] && actualOutput == expectedOutput;

      if (passed) passedCount++;

      results.add({
        'testCaseNumber': i + 1,
        'input': input,
        'expectedOutput': expectedOutput,
        'actualOutput': actualOutput,
        'passed': passed,
        'error': execution['stderr'],
        'runtime': execution['runtime'],
      });
    }

    return {
      'passedCount': passedCount,
      'totalCount': testCases.length,
      'results': results,
      'overallSuccess': passedCount == testCases.length,
    };
  }

  /// Get available languages
  static List<String> getAvailableLanguages() {
    return _languageMap.keys.toList();
  }

  /// Get language display name
  static String getLanguageDisplayName(String language) {
    final displayNames = {
      'javascript': 'JavaScript (Node.js 18.15.0)',
      'python': 'Python 3.10.0',
      'cpp': 'C++ (GCC 10.2.0)',
      'java': 'Java 15.0.2',
    };
    return displayNames[language.toLowerCase()] ?? language;
  }
}
