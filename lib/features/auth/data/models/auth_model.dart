// lib/features/auth/data/models/auth_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'auth_model.g.dart';

@JsonSerializable()
class AuthModel {
  final String email;
  final String password;
  final String username;
  
  @JsonKey(name: 'is_logged_in', defaultValue: false)
  final bool isLoggedIn;

  const AuthModel({
    this.email = '',
    this.password = '',
    this.username = '',
    this.isLoggedIn = false,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) => 
      _$AuthModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthModelToJson(this);
}