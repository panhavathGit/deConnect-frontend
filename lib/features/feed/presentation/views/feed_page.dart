// lib/features/feed/presentation/views/feed_page.dart
import 'package:flutter/material.dart';
import '../../../../core/app_export.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../viewmodels/feed_viewmodel.dart';
import '../viewmodels/user_info_viewmodel.dart';
import '../../data/models/feed_model.dart';
import 'package:go_router/go_router.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['All', 'Politics', 'Technologies', 'Business'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedViewModel>().loadPosts();
      context.read<UserInfoViewModel>().loadUserInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final feedViewModel = context.watch<FeedViewModel>();

    return Scaffold(
      backgroundColor: appTheme.white_A700,
      appBar: CustomAppBar(
        title: "DeConnect",
        actionIconPath: ImageConstant.imgMessageCircle,
        actionBackgroundColor: Color(0x33868686),
        onActionPressed: () {
          // Navigate to messages/notifications
          context.go('/chat');
        },
      ),
      body: Column(
        children: [
          // User Profile Section
          _buildUserProfileSection(),

          // Category Filter Tabs
          _buildCategoryTabs(),

          // Feed List
          Expanded(
            child: feedViewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : feedViewModel.posts.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        itemCount: feedViewModel.posts.length,
                        itemBuilder: (context, index) {
                          return _buildFeedCard(feedViewModel.posts[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileSection() {
    return Consumer<UserInfoViewModel>(
      builder: (context, userViewModel, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: appTheme.blue_gray_100,
                ),
                child: userViewModel.isLoading
                    ? Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: appTheme.blue_900,
                          ),
                        ),
                      )
                    : ClipOval(
                        child: userViewModel.avatarUrl != null
                            ? CustomImageView(
                                imagePath: userViewModel.avatarUrl,
                                fit: BoxFit.cover,
                              )
                            : Icon(Icons.person, size: 32, color: appTheme.greyCustom),
                      ),
              ),
              SizedBox(width: 12),
              
              // Welcome Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back 👋',
                      style: TextStyleHelper.instance.body15MediumInter.copyWith(
                        color: appTheme.greyCustom,
                      ),
                    ),
                    SizedBox(height: 2),
                    userViewModel.isLoading
                        ? Container(
                            width: 100,
                            height: 18,
                            decoration: BoxDecoration(
                              color: appTheme.blue_gray_100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )
                        : Text(
                            userViewModel.userName,
                            style: TextStyleHelper.instance.title18BoldSourceSerifPro,
                          ),
                  ],
                ),
              ),

              // Create Post Icon
              GestureDetector(
                onTap: () {
                  context.push('/create-post');
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: appTheme.blue_gray_100),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    color: appTheme.blue_900,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
              context.read<FeedViewModel>().filterByCategory(_categories[index]);
            },
            child: Container(
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? appTheme.blue_900 : appTheme.grey100,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  _categories[index],
                  style: TextStyleHelper.instance.body15MediumInter.copyWith(
                    color: isSelected ? appTheme.white_A700 : appTheme.black_900,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.feed_outlined, size: 64, color: appTheme.greyCustom),
          SizedBox(height: 16),
          Text(
            'No posts yet',
            style: TextStyleHelper.instance.title18BoldSourceSerifPro,
          ),
          SizedBox(height: 8),
          Text(
            'Be the first to create a post!',
            style: TextStyleHelper.instance.body15MediumInter.copyWith(
              color: appTheme.greyCustom,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedCard(FeedPost post) {
    return GestureDetector(
      onTap: () {
        context.push('/main/post/${post.id}', extra: post);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: appTheme.white_A700,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content Section
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: TextStyleHelper.instance.title18BoldSourceSerifPro,
                  ),
                  SizedBox(height: 8),
                  Text(
                    post.content,
                    style: TextStyleHelper.instance.body15MediumInter.copyWith(
                      color: appTheme.greyCustom,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      // Author Avatar
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: appTheme.blue_gray_100,
                        ),
                        child: ClipOval(
                          child: post.authorAvatar != null
                              ? CustomImageView(
                                  imagePath: post.authorAvatar,
                                  fit: BoxFit.cover,
                                )
                              : Icon(Icons.person, size: 16, color: appTheme.greyCustom),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        post.authorName,
                        style: TextStyleHelper.instance.body12MediumRoboto,
                      ),
                      Spacer(),
                      Icon(Icons.chat_bubble_outline, size: 16, color: appTheme.greyCustom),
                      
                    ],
                  ),
                ],
              ),
            ),

            // Image Section
            if (post.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: CustomImageView(
                  imagePath: post.imageUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ),
    );
  }
}