class User {
  final String id;
  final String name;
  final String avatar;
  final int points;
  final int streak;
  final String lastSubmissionDate;
  final String? bio;
  final String? organization;
  final int? level;
  final String? github;
  final String? linkedin;
  final String? instagram;

  User({
    required this.id,
    required this.name,
    required this.avatar,
    required this.points,
    required this.streak,
    required this.lastSubmissionDate,
    this.bio,
    this.organization,
    this.level,
    this.github,
    this.linkedin,
    this.instagram,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      avatar: map['avatar'] as String,
      points: map['points'] as int,
      streak: map['streak'] as int,
      lastSubmissionDate: map['last_submission_date'] as String,
      bio: map['bio'] as String?,
      organization: map['organization'] as String?,
      level: map['level'] as int?,
      github: map['github'] as String?,
      linkedin: map['linkedin'] as String?,
      instagram: map['instagram'] as String?,
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
      'bio': bio,
      'organization': organization,
      'level': level,
      'github': github,
      'linkedin': linkedin,
      'instagram': instagram,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? avatar,
    int? points,
    int? streak,
    String? lastSubmissionDate,
    String? bio,
    String? organization,
    int? level,
    String? github,
    String? linkedin,
    String? instagram,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      points: points ?? this.points,
      streak: streak ?? this.streak,
      lastSubmissionDate: lastSubmissionDate ?? this.lastSubmissionDate,
      bio: bio ?? this.bio,
      organization: organization ?? this.organization,
      level: level ?? this.level,
      github: github ?? this.github,
      linkedin: linkedin ?? this.linkedin,
      instagram: instagram ?? this.instagram,
    );
  }
}
