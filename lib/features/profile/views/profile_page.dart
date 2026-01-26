// lib/features/profile/views/profile_page.dart
import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../../../core/widgets/custom_image_view.dart';
import '../../feed/data/models/feed_model.dart';
import '../../auth/data/models/user_model.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../data/datasources/profile_mock_data_source.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(
        repository: ProfileRepositoryImpl(
          mockDataSource: ProfileMockDataSourceImpl(),
          useMockData: true,
        ),
        userId: 'user1',
      )..loadProfile(),
      child: const _ProfilePageContent(),
    );
  }
}

class _ProfilePageContent extends StatelessWidget {
  const _ProfilePageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      body: SafeArea(
        child: Consumer<ProfileViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: appTheme.blue_900,
                ),
              );
            }

            if (viewModel.status == ProfileStatus.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: appTheme.colorFFFF00),
                    SizedBox(height: 16),
                    Text(
                      viewModel.errorMessage ?? 'Something went wrong',
                      style: TextStyleHelper.instance.body15MediumInter,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => viewModel.loadProfile(),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final user = viewModel.user;
            final stats = viewModel.stats;
            if (user == null || stats == null) return SizedBox();

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Profile',
                    style: TextStyleHelper.instance.display40RegularSourceSerifPro.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: appTheme.blue_900,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildProfileCard(context, user, stats),
                  SizedBox(height: 30),
                  Text(
                    'Your Posts (${viewModel.userPosts.length})',
                    style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
                      fontSize: 20,
                      color: appTheme.blue_light,
                    ),
                  ),
                  SizedBox(height: 20),
                  ...viewModel.userPosts.map((post) => Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: _buildPostItem(context, post),
                  )),
                  SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, User user, dynamic stats) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appTheme.white_A700,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: appTheme.greyCustom.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: appTheme.blue_gray_100,
                ),
                child: user.avatarUrl != null
                    ? ClipOval(
                        child: CustomImageView(
                          imagePath: user.avatarUrl,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 40,
                        color: appTheme.greyCustom,
                      ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyleHelper.instance.title18BoldSourceSerifPro,
                    ),
                    SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyleHelper.instance.body15MediumInter.copyWith(
                        color: appTheme.greyCustom,
                      ),
                    ),
                    if (user.bio != null) ...[
                      SizedBox(height: 8),
                      Text(
                        user.bio!,
                        style: TextStyleHelper.instance.body12MediumRoboto,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 40, color: appTheme.blue_gray_100),
          _buildMenuTile(Icons.person_outline, 'Edit Profile'),
          _buildMenuTile(Icons.settings_outlined, 'Settings'),
          _buildMenuTile(Icons.logout, 'Log Out', isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, {bool isDestructive = false}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: isDestructive ? appTheme.colorFFFF00 : appTheme.gray_900,
      ),
      title: Text(
        title,
        style: TextStyleHelper.instance.body15MediumInter.copyWith(
          color: isDestructive ? appTheme.colorFFFF00 : appTheme.gray_900,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: appTheme.greyCustom,
      ),
      onTap: () {},
    );
  }

  Widget _buildPostItem(BuildContext context, FeedPost post) {
    return GestureDetector(
      onTap: () {
        context.push('/main/post/${post.id}');
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Text(
                  post.content,
                  style: TextStyleHelper.instance.body15MediumInter.copyWith(
                    fontSize: 13,
                    color: appTheme.greyCustom,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: appTheme.blue_900.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        post.category,
                        style: TextStyleHelper.instance.body12MediumRoboto.copyWith(
                          color: appTheme.blue_900,
                        ),
                      ),
                    ),
                    Spacer(),
                    Text(
                      '${post.commentCount}',
                      style: TextStyleHelper.instance.body12MediumRoboto.copyWith(
                        color: appTheme.greyCustom,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 14,
                      color: appTheme.greyCustom,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomImageView(
                imagePath: post.imageUrl ?? ImageConstant.imgPlaceholder,
                fit: BoxFit.cover,
                height: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }
}