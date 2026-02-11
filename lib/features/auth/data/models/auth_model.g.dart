// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthModel _$AuthModelFromJson(Map<String, dynamic> json) => AuthModel(
  email: json['email'] as String? ?? '',
  password: json['password'] as String? ?? '',
  username: json['username'] as String? ?? '',
  isLoggedIn: json['is_logged_in'] as bool? ?? false,
);

Map<String, dynamic> _$AuthModelToJson(AuthModel instance) => <String, dynamic>{
  'email': instance.email,
  'password': instance.password,
  'username': instance.username,
  'is_logged_in': instance.isLoggedIn,
};
