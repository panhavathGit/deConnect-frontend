// lib/features/profile/views/widgets/profile_post_item.dart
import 'package:flutter/material.dart';
import '../../../../core/app_export.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../../feed/data/models/feed_model.dart';

class ProfilePostItem extends StatelessWidget {
  final FeedPost post;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProfilePostItem({
    super.key,
    required this.post,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: _buildPostContent()),
          SizedBox(width: 15),
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                _buildPostImage(),
                // Edit/Delete menu button
                if (onEdit != null || onDelete != null)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: PopupMenuButton<String>(
                      icon: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: appTheme.black_900.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.more_vert,
                          color: appTheme.white_A700,
                          size: 20,
                        ),
                      ),
                      onSelected: (value) {
                        if (value == 'edit' && onEdit != null) {
                          onEdit!();
                        } else if (value == 'delete' && onDelete != null) {
                          onDelete!();
                        }
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: appTheme.blue_900,
                                ),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
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
        Icon(Icons.local_offer_outlined, size: 14, color: appTheme.greyCustom),
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

  // Widget _buildPostImage() {
  //   return ClipRRect(
  //     borderRadius: BorderRadius.circular(12),
  //     child: CustomImageView(
  //       imagePath: post.imageUrl ?? ImageConstant.imgPlaceholder,
  //       fit: BoxFit.cover,
  //       height: 100,
  //     ),
  //   );
  // }

  Widget _buildPostImage() {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: appTheme.blue_gray_100,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CustomImageView(
          imagePath: post.imageUrl ?? ImageConstant.imgPlaceholder,
          fit: BoxFit.cover,
          height: 100,
          width: double.infinity,
        ),
      ),
    );
  }
}
