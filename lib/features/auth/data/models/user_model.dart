// lib/features/auth/data/models/user_model.dart
class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? bio;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.bio,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'bio': bio,
      'created_at': createdAt.toIso8601String(),
    };
  }
}