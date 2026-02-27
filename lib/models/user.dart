class User {
  final String id;
  final String name;
  final String avatar;
  final int points;
  final int streak;
  final String lastSubmissionDate;

  User({
    required this.id,
    required this.name,
    required this.avatar,
    required this.points,
    required this.streak,
    required this.lastSubmissionDate,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      avatar: map['avatar'] as String,
      points: map['points'] as int,
      streak: map['streak'] as int,
      lastSubmissionDate: map['last_submission_date'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'points': points,
      'streak': streak,
      'last_submission_date': lastSubmissionDate,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? avatar,
    int? points,
    int? streak,
    String? lastSubmissionDate,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      points: points ?? this.points,
      streak: streak ?? this.streak,
      lastSubmissionDate: lastSubmissionDate ?? this.lastSubmissionDate,
    );
  }
}
