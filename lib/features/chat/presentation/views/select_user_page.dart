// lib/features/chat/views/select_user_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_export.dart';
// import '../../../core/providers/theme_provider.dart';
import 'chat_room_page.dart';
import '../viewmodels/select_user_viewmodel.dart';
import '../../../profile/data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/datasources/chat_remote_data_source.dart';

class SelectUserPage extends StatefulWidget {
  const SelectUserPage({super.key});

  @override
  State<SelectUserPage> createState() => _SelectUserPageState();
}

class _SelectUserPageState extends State<SelectUserPage> {
  late SelectUserViewModel _viewModel;
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
    // final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isDark = false;
    
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : appTheme.white_A700,
        appBar: AppBar(
          title: Text(
            'Select User',
            style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : appTheme.blue_900,
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
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          viewModel.errorMessage ?? 'Failed to load users',
                          style: TextStyleHelper.instance.body15MediumInter.copyWith(
                            color: isDark ? Colors.white : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => viewModel.loadUsers(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appTheme.blue_900,
                          ),
                          child: const Text('Retry', style: TextStyle(color: Colors.white)),
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
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: isDark ? Colors.grey[400] : appTheme.greyCustom,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No users found',
                          style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
                            color: isDark ? Colors.white : null,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: viewModel.users.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: isDark ? Colors.grey[800] : appTheme.blue_gray_100,
                  ),
                  itemBuilder: (context, index) {
                    final user = viewModel.users[index];
                    return ListTile(
                      tileColor: isDark ? const Color(0xFF121212) : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: isDark ? Colors.grey[800] : appTheme.blue_gray_100,
                        child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  user.avatarUrl!,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      size: 32,
                                      color: isDark ? Colors.grey[400] : appTheme.greyCustom,
                                    );
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Icon(
                                      Icons.person,
                                      size: 32,
                                      color: isDark ? Colors.grey[400] : appTheme.greyCustom,
                                    );
                                  },
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 32,
                                color: isDark ? Colors.grey[400] : appTheme.greyCustom,
                              ),
                      ),
                      title: Text(
                        user.name,
                        style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
                          fontSize: 16,
                          color: isDark ? Colors.white : null,
                        ),
                      ),
                      subtitle: user.bio != null
                          ? Text(
                              user.bio!,
                              style: TextStyleHelper.instance.body15MediumInter.copyWith(
                                color: isDark ? Colors.grey[400] : appTheme.greyCustom,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      onTap: _isNavigating ? null : () => _startChat(user.id),
                    );
                  },
                );
              },
            ),

            // Loading overlay
            if (_isNavigating)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Card(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: appTheme.blue_900),
                          const SizedBox(height: 16),
                          Text(
                            'Starting chat...',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
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
