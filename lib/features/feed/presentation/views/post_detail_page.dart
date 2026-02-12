// lib/features/feed/presentation/views/post_detail_page.dart
import 'package:onboarding_project/core/app_export.dart';
import '../../feed.dart';

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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.onPrimary,
      body: CustomScrollView(
        slivers: [
          // App Bar with back button and image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: theme.colorScheme.onPrimary,
            leading: Padding(
              padding: EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
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
                      color: theme.colorScheme.surface,
                      child: Icon(
                        Icons.image,
                        size: 100,
                        color: theme.colorScheme.onTertiary,
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
                    style: theme.textTheme.displayLarge?.copyWith(
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
                          color: theme.colorScheme.surface,
                        ),
                        // child: Icon(Icons.person, size: 24, color: theme.colorScheme.onTertiary),
                        child: ClipOval(
                          child: widget.post.authorAvatar != null && widget.post.authorAvatar!.isNotEmpty
                              ? CustomImageView(
                                  imagePath: widget.post.authorAvatar,
                                  fit: BoxFit.cover,
                                )
                              : Icon(Icons.person, size: 24, color: theme.colorScheme.onTertiary),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post.authorName!,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _formatDate(widget.post.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.access_time, size: 16, color: theme.colorScheme.onTertiary),
                      SizedBox(width: 4),
                      Text(
                        _formatDate(widget.post.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onTertiary,
                        ),
                      ),
                      // SizedBox(width: 16),
                      // Icon(Icons.chat_bubble_outline, size: 16, color: theme.colorScheme.onTertiary),
                      
                    ],
                  ),
                  SizedBox(height: 24),

                  // Full Content
                  Text(
                    widget.post.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
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
                        Icon(Icons.comment, size: 20, color: theme.colorScheme.primary),
                        SizedBox(width: 8),
                        Text(
                          'View Comments',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.primary),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  // This use to have comment input 

                ],
              ),
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