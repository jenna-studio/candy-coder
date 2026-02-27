class Submission {
  final String id;
  final String problemId;
  final String language;
  final String code;
  final String status; // 'Pending', 'Success', 'Failure'
  final String? feedback;
  final int timestamp;

  Submission({
    required this.id,
    required this.problemId,
    required this.language,
    required this.code,
    required this.status,
    this.feedback,
    required this.timestamp,
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
    };
  }
}
