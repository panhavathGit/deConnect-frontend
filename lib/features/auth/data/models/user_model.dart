import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final String id;

  /// Username or display name (from 'username' or 'name' in DB)
  @JsonKey(name: 'username')
  final String name;

  final String email;

  @JsonKey(name: 'first_name')
  final String? firstName;

  @JsonKey(name: 'last_name')
  final String? lastName;

  final String? gender;

  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  final String? bio;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.firstName,
    this.lastName,
    this.gender,
    this.avatarUrl,
    this.bio,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}