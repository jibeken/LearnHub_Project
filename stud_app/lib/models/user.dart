class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? avatarUrl;
  final String? bio;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.bio,
  });

  bool get isTeacher => role == 'teacher';
  bool get isStudent => role == 'student';

  factory User.fromJson(Map<String, dynamic> json) {
    String displayName = json['name']?.toString() ?? '';
    if (displayName.isEmpty) {
      displayName = json['username']?.toString() ?? '';
    }
    if (displayName.isEmpty) {
      final email = json['email']?.toString() ?? '';
      displayName = email.contains('@')
          ? email.split('@')[0]
          : 'User ${json['id'] ?? 0}';
    }

    return User(
      id: json['id'] ?? 0,
      name: displayName,
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'student',
      avatarUrl: json['avatar_url']?.toString(),
      bio: json['bio']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'avatar_url': avatarUrl,
    'bio': bio,
  };
}
