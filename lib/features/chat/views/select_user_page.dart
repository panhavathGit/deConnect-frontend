// lib/features/chat/views/select_user_page.dart
import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import 'chat_room_page.dart';
import '../viewmodels/select_user_viewmodel.dart';
import '../../profile/data/datasources/profile_remote_data_source.dart';
import '../data/repositories/chat_repository_impl.dart';
import '../data/datasources/chat_remote_data_source.dart';

class SelectUserPage extends StatelessWidget {
  const SelectUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SelectUserViewModel(
        profileDataSource: ProfileRemoteDataSourceImpl(),
        chatRepository: ChatRepositoryImpl(
          remoteDataSource: ChatRemoteDataSourceImpl(),
        ),
      )..loadUsers(),
      child: const _SelectUserPageContent(),
    );
  }
}

class _SelectUserPageContent extends StatelessWidget {
  const _SelectUserPageContent();

  Future<void> _startChat(BuildContext context, String userId) async {
    final viewModel = context.read<SelectUserViewModel>();
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(color: appTheme.blue_900),
      ),
    );

    try {
      final room = await viewModel.createChatWithUser(userId);

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        if (room != null) {
          // Navigate to chat room
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoomPage(
                roomId: room.id,
                roomName: room.displayName,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create chat'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e, this is where it error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      appBar: AppBar(
        title: Text(
          'Select User',
          style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: appTheme.blue_900,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SelectUserViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: appTheme.blue_900),
            );
          }

          if (viewModel.status == SelectUserStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.errorMessage ?? 'Failed to load users',
                    style: TextStyleHelper.instance.body15MediumInter,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadUsers(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: appTheme.greyCustom),
                  const SizedBox(height: 16),
                  Text(
                    'No users found',
                    style: TextStyleHelper.instance.title18BoldSourceSerifPro,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: viewModel.users.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: appTheme.blue_gray_100,
            ),
            itemBuilder: (context, index) {
              final user = viewModel.users[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: appTheme.blue_gray_100,
                  child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            user.avatarUrl!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.person, size: 32, color: appTheme.greyCustom);
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Icon(Icons.person, size: 32, color: appTheme.greyCustom);
                            },
                          ),
                        )
                      : Icon(Icons.person, size: 32, color: appTheme.greyCustom),
                ),
                title: Text(
                  user.name,
                  style: TextStyleHelper.instance.title18BoldSourceSerifPro
                      .copyWith(fontSize: 16),
                ),
                subtitle: user.bio != null
                    ? Text(
                        user.bio!,
                        style: TextStyleHelper.instance.body15MediumInter
                            .copyWith(color: appTheme.greyCustom),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                onTap: () => _startChat(context, user.id),
              );
            },
          );
        },
      ),
    );
  }
}