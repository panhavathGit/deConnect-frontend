// lib/features/profile/views/profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/supabase_service.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/datasources/profile_mock_data_source.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import 'widgets/profile_card.dart';
import 'widgets/profile_post_item.dart';
import 'widgets/profile_loading_state.dart';
import 'widgets/profile_error_state.dart';
import 'package:go_router/go_router.dart';
import 'edit_profile_page.dart';
import '../../../feed/data/models/feed_model.dart';
import 'edit_post_page.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current logged-in user ID from Supabase
    final currentUserId = SupabaseService.client.auth.currentUser?.id ?? 'user1';
    
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(
        repository: ProfileRepositoryImpl(
          remoteDataSource: ProfileRemoteDataSourceImpl(),
          mockDataSource: ProfileMockDataSourceImpl(),
          useMockData: false, // Set to false to use real Supabase data
        ),
        userId: currentUserId,
      )..loadProfile(),
      child: const _ProfilePageContent(),
    );
  }
}

class _ProfilePageContent extends StatelessWidget {
  const _ProfilePageContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.onPrimary,
      body: SafeArea(
        child: Consumer<ProfileViewModel>(
          builder: (context, viewModel, _) {
            // Loading state
            if (viewModel.isLoading) {
              return const ProfileLoadingState();
            }

            // Error state
            if (viewModel.status == ProfileStatus.error) {
              return ProfileErrorState(
                errorMessage: viewModel.errorMessage,
                onRetry: () => viewModel.loadProfile(),
              );
            }

            // Success state
            final user = viewModel.user;
            final stats = viewModel.stats;
            if (user == null || stats == null) return SizedBox();

            return RefreshIndicator(
              onRefresh: () => viewModel.refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    _buildHeader(context),
                    SizedBox(height: 20),
                    ProfileCard(
                      user: user,
                      stats: stats,
                      onEditProfile: () => _handleEditProfile(context),
                      onSettings: () => _handleSettings(context),
                      onLogout: () => _handleLogout(context),
                    ),
                    SizedBox(height: 30),
                    _buildPostsHeader(context,viewModel.userPosts.length),
                    SizedBox(height: 20),
                    ..._buildPostsList(context, viewModel.userPosts),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      'Profile',
      style: theme.textTheme.displayLarge?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildPostsHeader(BuildContext context ,int postCount) {
    final theme = Theme.of(context);
    return Text(
      'Your Posts ($postCount)',
      style: theme.textTheme.titleSmall?.copyWith(
        fontSize: 20,
        color: theme.colorScheme.secondary,
      ),
    );
  }

  List<Widget> _buildPostsList(BuildContext context, List<dynamic> posts) {
    return posts.map((post) => Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: ProfilePostItem(
        post: post,
        onTap: () => context.pushNamed(
          AppRoutes.postDetail,
          pathParameters: {'id': post.id},
          extra: post,
        ),
        onEdit: () => _handleEditPost(context, post),
        onDelete: () => _handleDeletePost(context, post),
      ),
    )).toList();
  }

  void _handleEditPost(BuildContext context, FeedPost post) {
    final viewModel = context.read<ProfileViewModel>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPostPage(
          post: post,
          viewModel: viewModel,
        ),
      ),
    );
  }

  void _handleDeletePost(BuildContext context, FeedPost post) async {
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Post'),
        content: Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final viewModel = context.read<ProfileViewModel>();
      final success = await viewModel.deletePost(post.id);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Post deleted successfully' : 'Failed to delete post'),
            backgroundColor: success ? theme.colorScheme.tertiary : Colors.red,
          ),
        );
      }
    }
  }

  void _handleEditProfile(BuildContext context) {
    final viewModel = context.read<ProfileViewModel>();
    if (viewModel.user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfilePage(
            user: viewModel.user!,
            viewModel: viewModel,
          ),
        ),
      );
    }
  }

  void _handleSettings(BuildContext context) {
    // TODO: Navigate to settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Settings - Coming Soon')),
    );
  }

  void _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await AuthRepository().logout();
        if (context.mounted) {
          context.go(AppPaths.login);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout failed: $e')),
          );
        }
      }
    }
  }
}