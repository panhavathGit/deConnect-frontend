// lib/features/chat/viewmodels/group_info_viewmodel.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/services/supabase_service.dart';
import '../../data/models/group_member_model.dart';

class GroupInfoViewModel extends ChangeNotifier {
  final String roomId;
  final bool isAdmin;
  
  String _groupName;
  String? _avatarUrl;
  List<GroupMember> _members = [];
  bool _isLoading = false;
  String? _errorMessage;

  GroupInfoViewModel({
    required this.roomId,
    required String initialName,
    String? initialAvatarUrl,
    required this.isAdmin,
  })  : _groupName = initialName,
        _avatarUrl = initialAvatarUrl;

  String get groupName => _groupName;
  String? get avatarUrl => _avatarUrl;
  List<GroupMember> get members => _members;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentUserId => SupabaseService.client.auth.currentUser?.id ?? '';

  bool isCurrentUser(String userId) => userId == currentUserId;

  Future<void> loadMembers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await SupabaseService.client
          .from('room_members')
          .select('''
            user_id,
            joined_at,
            is_admin,
            profiles:user_id (
              username,
              avatar_url
            )
          ''')
          .eq('room_id', roomId)
          .order('is_admin', ascending: false)
          .order('joined_at', ascending: true);

      _members = (response as List).map((json) {
        final profile = json['profiles'];
        return GroupMember(
          userId: json['user_id'],
          username: profile?['username'] ?? 'Unknown',
          avatarUrl: profile?['avatar_url'],
          isAdmin: json['is_admin'] ?? false,
          joinedAt: DateTime.parse(json['joined_at']),
        );
      }).toList();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Error loading members: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateGroupName(String newName) async {
    try {
      await SupabaseService.client
          .from('chat_rooms')
          .update({'name': newName})
          .eq('id', roomId);

      _groupName = newName;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Error updating group name: $e');
      return false;
    }
  }

  Future<bool> updateGroupPhoto(File imageFile) async {
    try {
      final userId = currentUserId;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${roomId}_$timestamp.jpg';
      final filePath = 'group-avatars/$fileName';

      await SupabaseService.client.storage
          .from('avatars')
          .upload(filePath, imageFile);

      final imageUrl = SupabaseService.client.storage
          .from('avatars')
          .getPublicUrl(filePath);

      await SupabaseService.client
          .from('chat_rooms')
          .update({'avatar_url': imageUrl})
          .eq('id', roomId);

      _avatarUrl = imageUrl;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Error updating group photo: $e');
      return false;
    }
  }

  Future<bool> leaveGroup() async {
    try {
      await SupabaseService.client
          .from('room_members')
          .delete()
          .eq('room_id', roomId)
          .eq('user_id', currentUserId);

      return true;
    } catch (e) {
      debugPrint('❌ Error leaving group: $e');
      return false;
    }
  }
}