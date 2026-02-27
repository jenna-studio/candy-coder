class Submission {
  final String id;
  final String problemId;
  final String language;
  final String code;
  final String status; // 'Pending', 'Success', 'Failure', 'Wrong Answer', 'Runtime Error', 'Time Limit'
  final String? feedback;
  final int timestamp;

  // Execution details (from Piston API)
  final String? runtime; // e.g., "45ms"
  final String? stdout; // Program output
  final String? stderr; // Error messages
  final int? exitCode; // 0 for success, non-zero for errors
  final int? passedTestCases; // Number of test cases passed
  final int? totalTestCases; // Total number of test cases

  Submission({
    required this.id,
    required this.problemId,
    required this.language,
    required this.code,
    required this.status,
    this.feedback,
    required this.timestamp,
    this.runtime,
    this.stdout,
    this.stderr,
    this.exitCode,
    this.passedTestCases,
    this.totalTestCases,
  });

  factory Submission.fromMap(Map<String, dynamic> map) {
    return Submission(
      id: map['id'] as String,
      problemId: map['problemId'] as String,
      language: map['language'] as String,
      code: map['code'] as String,
      status: map['status'] as String,
      feedback: map['feedback'] as String?,
      timestamp: map['timestamp'] as int,
      runtime: map['runtime'] as String?,
      stdout: map['stdout'] as String?,
      stderr: map['stderr'] as String?,
      exitCode: map['exitCode'] as int?,
      passedTestCases: map['passedTestCases'] as int?,
      totalTestCases: map['totalTestCases'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'problemId': problemId,
      'language': language,
      'code': code,
      'status': status,
      'feedback': feedback,
      'timestamp': timestamp,
      'runtime': runtime,
      'stdout': stdout,
      'stderr': stderr,
      'exitCode': exitCode,
      'passedTestCases': passedTestCases,
      'totalTestCases': totalTestCases,
    };
  }
}
