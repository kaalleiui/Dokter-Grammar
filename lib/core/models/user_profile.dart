class UserProfile {
  final int? id;
  final String nickname;
  final String goal;
  final String currentLevel; // 'beginner', 'elementary', etc.
  final double overallScore; // 0.0 to 1.0
  final int streakDays;
  final DateTime? lastActivityDate;
  final List<String> interests;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    this.id,
    required this.nickname,
    required this.goal,
    this.currentLevel = 'beginner',
    this.overallScore = 0.0,
    this.streakDays = 0,
    this.lastActivityDate,
    required this.interests,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nickname': nickname,
    'goal': goal,
    'currentLevel': currentLevel,
    'overallScore': overallScore,
    'streakDays': streakDays,
    'lastActivityDate': lastActivityDate?.toIso8601String(),
    'interests': interests,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'],
    nickname: json['nickname'],
    goal: json['goal'],
    currentLevel: json['currentLevel'] ?? 'beginner',
    overallScore: json['overallScore']?.toDouble() ?? 0.0,
    streakDays: json['streakDays'] ?? 0,
    lastActivityDate: json['lastActivityDate'] != null 
        ? DateTime.parse(json['lastActivityDate']) 
        : null,
    interests: List<String>.from(json['interests'] ?? []),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );

  UserProfile copyWith({
    int? id,
    String? nickname,
    String? goal,
    String? currentLevel,
    double? overallScore,
    int? streakDays,
    DateTime? lastActivityDate,
    List<String>? interests,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      goal: goal ?? this.goal,
      currentLevel: currentLevel ?? this.currentLevel,
      overallScore: overallScore ?? this.overallScore,
      streakDays: streakDays ?? this.streakDays,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      interests: interests ?? this.interests,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

