// lib/features/auth/data/models/user_model.dart
class User {
  final String id;
  final String name;
  final String email;
  final String? firstName;      // Add
  final String? lastName;       // Add
  final String? gender;         // Add
  final String? avatarUrl;
  final String? bio;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.firstName,               // Add
    this.lastName,                // Add
    this.gender,                  // Add
    this.avatarUrl,
    this.bio,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? json['username'] ?? 'Unknown',
      email: json['email'],
      firstName: json['first_name'],     // Add
      lastName: json['last_name'],       // Add
      gender: json['gender'],            // Add
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
      'first_name': firstName,         // Add
      'last_name': lastName,           // Add
      'gender': gender,                // Add
      'avatar_url': avatarUrl,
      'bio': bio,
      'created_at': createdAt.toIso8601String(),
    };
  }
}