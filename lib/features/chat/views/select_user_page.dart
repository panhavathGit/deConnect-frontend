// lib/features/chat/views/select_user_page.dart
import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import 'chat_room_page.dart';
import '../viewmodels/select_user_viewmodel.dart';
import '../../profile/data/datasources/profile_remote_data_source.dart';
import '../data/repositories/chat_repository_impl.dart';
import '../data/datasources/chat_remote_data_source.dart';

class SelectUserPage extends StatefulWidget {
  const SelectUserPage({super.key});

  @override
  State<SelectUserPage> createState() => _SelectUserPageState();
}

class _SelectUserPageState extends State<SelectUserPage> {
  late SelectUserViewModel _viewModel;
  
  // ✅ Prevent double-tap
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _viewModel = SelectUserViewModel(
      profileDataSource: ProfileRemoteDataSourceImpl(),
      chatRepository: ChatRepositoryImpl(
        remoteDataSource: ChatRemoteDataSourceImpl(),
      ),
    );
    _viewModel.loadUsers();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _startChat(String userId) async {
    // ✅ Prevent double-tap
    if (_isNavigating) {
      debugPrint('⚠️ Already navigating, ignoring tap');
      return;
    }

    setState(() {
      _isNavigating = true;
    });

    try {
      final room = await _viewModel.createChatWithUser(userId);

      if (mounted && room != null) {
        // Navigate to chat room
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomPage(
              roomId: room.id,
              roomName: room.displayName,
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create chat'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
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
        body: Stack(
          children: [
            Consumer<SelectUserViewModel>(
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
                      // ✅ Disable tap while navigating
                      onTap: _isNavigating ? null : () => _startChat(user.id),
                    );
                  },
                );
              },
            ),

            // ✅ Loading overlay
            if (_isNavigating)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: appTheme.blue_900),
                          const SizedBox(height: 16),
                          const Text('Starting chat...'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}