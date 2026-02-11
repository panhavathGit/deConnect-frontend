// lib/features/profile/data/models/profile_status.dart
import 'package:json_annotation/json_annotation.dart';

part 'profile_status.g.dart';

@JsonSerializable()
class ProfileStats {
  @JsonKey(name: 'posts_count', defaultValue: 0)
  final int postsCount;

  const ProfileStats({
    required this.postsCount,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) => 
      _$ProfileStatsFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileStatsToJson(this);
}