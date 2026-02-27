import 'problem.dart';
import 'submission.dart';

class MockTest {
  final String id;
  final List<Problem> problems;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes;
  final List<Submission> submissions;
  final bool isCompleted;

  MockTest({
    required this.id,
    required this.problems,
    required this.startTime,
    this.endTime,
    this.durationMinutes = 90,
    this.submissions = const [],
    this.isCompleted = false,
  });

  int get remainingSeconds {
    if (isCompleted) return 0;

    final now = DateTime.now();
    final elapsed = now.difference(startTime).inSeconds;
    final total = durationMinutes * 60;
    return (total - elapsed).clamp(0, total);
  }

  int get completedProblems {
    final solvedIds = submissions
        .where((s) => s.status == 'Success')
        .map((s) => s.problemId)
        .toSet();
    return solvedIds.length;
  }

  MockTest copyWith({
    String? id,
    List<Problem>? problems,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    List<Submission>? submissions,
    bool? isCompleted,
  }) {
    return MockTest(
      id: id ?? this.id,
      problems: problems ?? this.problems,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      submissions: submissions ?? this.submissions,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'problemIds': problems.map((p) => p.id).toList(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }
}
