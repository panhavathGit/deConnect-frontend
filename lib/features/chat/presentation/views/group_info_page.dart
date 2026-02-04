// lib/features/chat/views/group_info_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/app_export.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../viewmodels/group_info_viewmodel.dart';
import '../../data/models/group_member_model.dart';
import 'package:go_router/go_router.dart';

class GroupInfoPage extends StatefulWidget {
  final String roomId;
  final String roomName;
  final String? avatarUrl;
  final bool isAdmin;

  const GroupInfoPage({
    super.key,
    required this.roomId,
    required this.roomName,
    this.avatarUrl,
    required this.isAdmin,
  });

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _changeGroupPhoto(GroupInfoViewModel viewModel) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose Photo Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null && mounted) {
        final success = await viewModel.updateGroupPhoto(File(image.path));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'Group photo updated' : 'Failed to update photo'),
              backgroundColor: success ? appTheme.greenCustom : Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _changeGroupName(GroupInfoViewModel viewModel) async {
    final controller = TextEditingController(text: viewModel.groupName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Group Name'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter new group name',
            border: OutlineInputBorder(),
          ),
          maxLength: 50,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text('Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && mounted) {
      final success = await viewModel.updateGroupName(newName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Group name updated' : 'Failed to update name'),
            backgroundColor: success ? appTheme.greenCustom : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _leaveGroup(GroupInfoViewModel viewModel) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Leave Group'),
        content: Text('Are you sure you want to leave this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Leave'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await viewModel.leaveGroup();
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Left group successfully'),
              backgroundColor: appTheme.greenCustom,
            ),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to leave group'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GroupInfoViewModel(
        roomId: widget.roomId,
        initialName: widget.roomName,
        initialAvatarUrl: widget.avatarUrl,
        isAdmin: widget.isAdmin,
      )..loadMembers(),
      child: Consumer<GroupInfoViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: appTheme.white_A700,
            appBar: AppBar(
              backgroundColor: appTheme.blue_900,
              foregroundColor: Colors.white,
              title: Text('Group Info'),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: 'Info'),
                  Tab(text: 'Members (${viewModel.members.length})'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildInfoTab(viewModel),
                _buildMembersTab(viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTab(GroupInfoViewModel viewModel) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Group Photo
          GestureDetector(
            onTap: widget.isAdmin ? () => _changeGroupPhoto(viewModel) : null,
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: appTheme.blue_900.withOpacity(0.1),
                  ),
                  child: viewModel.avatarUrl != null
                      ? ClipOval(
                          child: CustomImageView(
                            imagePath: viewModel.avatarUrl!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.group,
                          size: 60,
                          color: appTheme.blue_900,
                        ),
                ),
                if (widget.isAdmin)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: appTheme.blue_900,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Group Name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                viewModel.groupName,
                style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
                  fontSize: 24,
                ),
              ),
              if (widget.isAdmin) ...[
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.edit, color: appTheme.blue_900),
                  onPressed: () => _changeGroupName(viewModel),
                ),
              ],
            ],
          ),
          SizedBox(height: 30),

          // Action Buttons
          if (widget.isAdmin) ...[
            _buildActionButton(
              icon: Icons.people_outline,
              label: 'Manage Members',
              color: appTheme.blue_900,
              onTap: () {
                _tabController.animateTo(1);
              },
            ),
            SizedBox(height: 12),
          ],
          _buildActionButton(
            icon: Icons.exit_to_app,
            label: 'Leave Group',
            color: Colors.red,
            onTap: () => _leaveGroup(viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTab(GroupInfoViewModel viewModel) {
    if (viewModel.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: appTheme.blue_900),
      );
    }

    if (viewModel.members.isEmpty) {
      return Center(
        child: Text('No members found'),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: viewModel.members.length,
      separatorBuilder: (_, __) => Divider(),
      itemBuilder: (context, index) {
        final member = viewModel.members[index];
        return _buildMemberItem(member, viewModel);
      },
    );
  }

  Widget _buildMemberItem(GroupMember member, GroupInfoViewModel viewModel) {
    final isCurrentUser = viewModel.isCurrentUser(member.userId);
    
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: appTheme.blue_900.withOpacity(0.1),
        ),
        child: member.avatarUrl != null
            ? ClipOval(
                child: CustomImageView(
                  imagePath: member.avatarUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              )
            : Icon(Icons.person, color: appTheme.blue_900),
      ),
      title: Row(
        children: [
          Text(
            member.username,
            style: TextStyleHelper.instance.body15MediumInter.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isCurrentUser) ...[
            SizedBox(width: 8),
            Text(
              '(You)',
              style: TextStyleHelper.instance.body12MediumRoboto.copyWith(
                color: appTheme.greyCustom,
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        'Joined ${_formatJoinDate(member.joinedAt)}',
        style: TextStyleHelper.instance.body12MediumRoboto.copyWith(
          color: appTheme.greyCustom,
        ),
      ),
      trailing: member.isAdmin
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: appTheme.blue_900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            SizedBox(width: 12),
            Text(
              label,
              style: TextStyleHelper.instance.body15MediumInter.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            Spacer(),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }

  String _formatJoinDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }
}