// lib/features/profile/views/widgets/profile_post_item.dart
import 'package:flutter/material.dart';
import '../../../../../core/widgets/custom_image_view.dart';
import '../../../../feed/data/models/feed_model.dart';
import '../../../../../core/constants/image_constant.dart';

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
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: _buildPostContent(context)),
          const SizedBox(width: 15),
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                _buildPostImage(context),
                if (onEdit != null || onDelete != null)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colors.onSurface.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.more_vert,
                          color: colors.surface,
                          size: 20,
                        ),
                      ),
                      onSelected: (value) {
                        if (value == 'edit') onEdit?.call();
                        if (value == 'delete') onDelete?.call();
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20, color: colors.primary),
                                const SizedBox(width: 8),
                                const Text('Edit'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: colors.error),
                                const SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: colors.error),
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

  Widget _buildPostContent(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          post.title,
          style: textTheme.titleSmall?.copyWith(fontSize: 16),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          post.content,
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            color: colors.onSurface.withOpacity(0.6),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        _buildPostMetadata(context),
      ],
    );
  }

  Widget _buildPostMetadata(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            post.primaryTag,
            style: textTheme.bodySmall?.copyWith(
              color: colors.primary,
            ),
          ),
        ),
        const Spacer(),
        Icon(Icons.local_offer_outlined, size: 14, color: colors.onSurface.withOpacity(0.5)),
        const SizedBox(width: 4),
        Text(
          '${post.tags.length} tags',
          style: textTheme.bodySmall?.copyWith(
            color: colors.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildPostImage(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colors.surface,
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
