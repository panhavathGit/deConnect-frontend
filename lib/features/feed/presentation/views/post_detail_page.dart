// lib/features/feed/presentation/views/post_detail_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/app_export.dart';
import '../../../../core/widgets/custom_image_view.dart';
import '../../data/models/feed_model.dart';
import '../../../../core/routes/app_routes.dart';

class PostDetailPage extends StatefulWidget {
  final FeedPost post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      body: CustomScrollView(
        slivers: [
          // App Bar with back button and image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: appTheme.white_A700,
            leading: Padding(
              padding: EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color: appTheme.black_900.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: appTheme.white_A700),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: widget.post.imageUrl != null
                  ? CustomImageView(
                      imagePath: widget.post.imageUrl!,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: appTheme.blue_gray_100,
                      child: Icon(
                        Icons.image,
                        size: 100,
                        color: appTheme.greyCustom,
                      ),
                    ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.post.title,
                    style: TextStyleHelper.instance.display40RegularSourceSerifPro.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Author Info & Stats
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: appTheme.blue_gray_100,
                        ),
                        // child: Icon(Icons.person, size: 24, color: appTheme.greyCustom),
                        child: ClipOval(
                          child: widget.post.authorAvatar != null && widget.post.authorAvatar!.isNotEmpty
                              ? CustomImageView(
                                  imagePath: widget.post.authorAvatar,
                                  fit: BoxFit.cover,
                                )
                              : Icon(Icons.person, size: 24, color: appTheme.greyCustom),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post.authorName,
                              style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _formatDate(widget.post.createdAt),
                              style: TextStyleHelper.instance.body12MediumRoboto.copyWith(
                                color: appTheme.greyCustom,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.access_time, size: 16, color: appTheme.greyCustom),
                      SizedBox(width: 4),
                      Text(
                        _formatDate(widget.post.createdAt),
                        style: TextStyleHelper.instance.body12MediumRoboto.copyWith(
                          color: appTheme.greyCustom,
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.chat_bubble_outline, size: 16, color: appTheme.greyCustom),
                      
                    ],
                  ),
                  SizedBox(height: 24),

                  // Full Content
                  Text(
                    widget.post.content,
                    style: TextStyleHelper.instance.body15MediumInter.copyWith(
                      height: 1.6,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 32),

                  // View Comments Button
                  GestureDetector(
                    onTap: () {
                      context.pushNamed(
                        AppRoutes.comments,
                        pathParameters: {'id': widget.post.id},
                        extra: widget.post,
                      );
                    },
                    child: Row(
                      children: [
                        Icon(Icons.comment, size: 20, color: appTheme.blue_900),
                        SizedBox(width: 8),
                        Text(
                          'View Comments',
                          style: TextStyleHelper.instance.body15MediumInter.copyWith(
                            color: appTheme.blue_900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios, size: 16, color: appTheme.blue_900),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Comment Input Section
                  // Text(
                  //   'Add a comment',
                  //   style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
                  //     fontSize: 16,
                  //   ),
                  // ),
                  // SizedBox(height: 12),
                  // _buildCommentInput(),
                  // SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      decoration: BoxDecoration(
        color: appTheme.grey100,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: appTheme.blue_gray_100),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Write your comment...',
                hintStyle: TextStyleHelper.instance.body15MediumInter.copyWith(
                  color: appTheme.greyCustom,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              maxLines: null,
              style: TextStyleHelper.instance.body15MediumInter,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () {
                // TODO: Implement add comment functionality
                if (_commentController.text.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Comment added!'),
                      backgroundColor: appTheme.green_700,
                    ),
                  );
                  _commentController.clear();
                }
              },
              icon: Icon(Icons.send, color: appTheme.blue_900),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}