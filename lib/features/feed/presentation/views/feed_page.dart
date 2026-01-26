// lib/features/feed/views/feed_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_export.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../viewmodels/feed_viewmodel.dart';
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FeedViewModel>();

    return Scaffold(
      backgroundColor: appTheme.white_A700,
      appBar: CustomAppBar(
        title: "DeConnect",
        actionIconPath: ImageConstant.imgMessageCircle,
        actionBackgroundColor: Color(0x33868686),
        onActionPressed: () {
          // Navigate to messages/notifications
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
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: viewModel.posts.length,
                    itemBuilder: (context, index) {
                      return _buildFeedCard(viewModel.posts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileSection() {
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
            child: ClipOval(
              child: Image.asset(
                ImageConstant.imgPlaceholder,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.person, size: 32, color: appTheme.greyCustom);
                },
              ),
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
                Text(
                  'Panhavath',
                  style: TextStyleHelper.instance.title18BoldSourceSerifPro,
                ),
              ],
            ),
          ),

          // Gallery Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: appTheme.blue_gray_100),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.image_outlined,
              color: appTheme.blue_900,
              size: 24,
            ),
          ),
        ],
      ),
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
                  'The best place to visit in Phnom Penh',
                  style: TextStyleHelper.instance.title18BoldSourceSerifPro,
                ),
                SizedBox(height: 8),
                Text(
                  'Phnom Penh, Cambodia\'s busy capital, sits at the junction of the Mekong and Tonlé Sap rivers. It was a hub for both the Khmer Empire and French colonialists.',
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
                        child: Image.asset(
                          ImageConstant.imgPlaceholder,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.person, size: 16, color: appTheme.greyCustom);
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Alice Jane',
                      style: TextStyleHelper.instance.body12MediumRoboto,
                    ),
                    Spacer(),
                    Icon(Icons.chat_bubble_outline, size: 16, color: appTheme.greyCustom),
                    SizedBox(width: 4),
                    Text(
                      '1.2K',
                      style: TextStyleHelper.instance.body12MediumRoboto.copyWith(
                        color: appTheme.greyCustom,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Image Section
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: CustomImageView(
              imagePath: ImageConstant.imgPlaceholder,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
      )
    );
  }
}