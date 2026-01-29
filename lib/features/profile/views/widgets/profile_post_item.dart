// lib/features/profile/views/widgets/profile_post_item.dart
import 'package:flutter/material.dart';
import '../../../../core/app_export.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../../feed/data/models/feed_model.dart';

class ProfilePostItem extends StatelessWidget {
  final FeedPost post;
  final VoidCallback? onTap;

  const ProfilePostItem({
    super.key,
    required this.post,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: _buildPostContent(),
          ),
          SizedBox(width: 15),
          Expanded(
            flex: 2,
            child: _buildPostImage(),
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    return Column(
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
        _buildPostMetadata(),
      ],
    );
  }

  Widget _buildPostMetadata() {
    return Row(
      children: [
        // Show first tag or "General"
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: appTheme.blue_900.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            post.primaryTag,
            style: TextStyleHelper.instance.body12MediumRoboto.copyWith(
              color: appTheme.blue_900,
            ),
          ),
        ),
        Spacer(),
        // Removed comment count - you can add other metadata here
        Icon(
          Icons.local_offer_outlined,
          size: 14,
          color: appTheme.greyCustom,
        ),
        SizedBox(width: 4),
        Text(
          '${post.tags.length} tags',
          style: TextStyleHelper.instance.body12MediumRoboto.copyWith(
            color: appTheme.greyCustom,
          ),
        ),
      ],
    );
  }

  
  Widget _buildPostImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CustomImageView(
        imagePath: post.imageUrl ?? ImageConstant.imgPlaceholder,
        fit: BoxFit.cover,
        height: 100,
      ),
    );
  }
}