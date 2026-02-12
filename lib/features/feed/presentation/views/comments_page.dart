// lib/features/feed/presentation/views/comments_page.dart
import 'package:onboarding_project/core/app_export.dart';
import '../../feed.dart';

class CommentsPage extends StatefulWidget {
  final FeedPost post;

  const CommentsPage({super.key, required this.post});

  static Widget builder(BuildContext context, FeedPost post) {
    return ChangeNotifierProvider(
      create: (_) => CommentViewModel(
        repository: CommentRepositoryImpl(
          remoteDataSource: CommentRemoteDataSourceImpl(),
          mockDataSource: CommentMockDataSourceImpl(),
          useMockData: false, // Set to true for testing
        ),
        postId: post.id,
      )..loadComments(),
      child: CommentsPage(post: post),
    );
  }

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final viewModel = context.read<CommentViewModel>();
    final success = await viewModel.addComment(_commentController.text.trim());

    if (mounted) {
      if (success) {
        _commentController.clear();
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Comment added!'),
            backgroundColor: theme.colorScheme.tertiary,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage ?? 'Failed to add comment'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showDeleteDialog(CommentModel comment, CommentViewModel viewModel) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete Comment'),
        content: Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              
              // Use the viewModel passed as parameter, not context.read
              final success = await viewModel.deleteComment(comment.id);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Comment deleted!' : 'Failed to delete comment'),
                    backgroundColor: success ? theme.colorScheme.tertiary : Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.onPrimary,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Comments',
          style: theme.textTheme.titleSmall?.copyWith(
            fontSize: 20,
            color: theme.colorScheme.primary
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: theme.colorScheme.surface),
        ),
      ),
      body: Consumer<CommentViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              // Comments List
              Expanded(
                child: _buildCommentsList(context,viewModel),
              ),

              // Comment Input at Bottom
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: SafeArea(
                  child: _buildCommentInput(context,viewModel),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCommentsList(BuildContext context ,CommentViewModel viewModel) {
    final theme = Theme.of(context);

    if (viewModel.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.surface),
      );
    }

    if (viewModel.status == CommentStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              viewModel.errorMessage ?? 'Failed to load comments',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () => viewModel.loadComments(),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (viewModel.comments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.comment_outlined, size: 64, color: theme.colorScheme.surface),
            SizedBox(height: 16),
            Text(
              'No comments yet',
              style: theme.textTheme.titleSmall!,
            ),
            SizedBox(height: 8),
            Text(
              'Be the first to comment!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.surface,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.loadComments(),
      color: theme.colorScheme.surface,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: viewModel.comments.length,
        separatorBuilder: (context, index) => Divider(
          height: 32,
          color: theme.colorScheme.surface,
        ),
        itemBuilder: (context, index) {
          return _buildCommentItem(context,viewModel.comments[index], viewModel);
        },
      ),
    );
  }

  Widget _buildCommentItem(BuildContext context ,CommentModel comment, CommentViewModel viewModel) {
    // Get current user ID from Supabase
    final currentUserId = SupabaseService.client.auth.currentUser?.id ?? '';
    final isOwn = comment.isOwnComment(currentUserId);

    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.surface,
          ),
          child: comment.authorAvatar != null
              ? ClipOval(
                  child: Image.network(
                    comment.authorAvatar!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.person,
                      size: 24,
                      color: theme.colorScheme.surface,
                    ),
                  ),
                )
              : Icon(Icons.person, size: 24, color: theme.colorScheme.surface),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            comment.authorName ?? 'Unknown',
                            style: theme.textTheme.titleSmall!
                                .copyWith(fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          comment.getTimeAgo(),
                          style: theme.textTheme.bodySmall!
                              .copyWith(color: theme.colorScheme.onTertiary),
                        ),
                      ],
                    ),
                  ),
                  // Delete button for own comments
                  if (isOwn)
                    IconButton(
                      icon: Icon(Icons.delete_outline, size: 20),
                      color: Colors.red,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () => _showDeleteDialog(comment,viewModel),
                    ),
                ],
              ),
              SizedBox(height: 6),
              Text(
                comment.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                ),
              ),
              if (comment.updatedAt != null) ...[
                SizedBox(height: 4),
                // Text(
                //   '(edited)',
                //   style: theme.textTheme.bodySmall!.copyWith(
                //     color: theme.colorScheme.surface,
                //     fontStyle: FontStyle.italic,
                //   ),
                // ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentInput(BuildContext context,CommentViewModel viewModel) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.colorScheme.surface),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onTertiary,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              maxLines: null,
              maxLength: 1000,
              buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                if (isFocused && currentLength > 0) {
                  return Padding(
                    padding: EdgeInsets.only(left: 20, top: 4),
                    child: Text(
                      '$currentLength/$maxLength',
                      style: TextStyle(fontSize: 11, color: theme.colorScheme.surface),
                    ),
                  );
                }
                return null;
              },
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: viewModel.isSubmitting
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.surface,
                    ),
                  )
                : IconButton(
                    onPressed: _addComment,
                    icon: Icon(Icons.send, color: theme.colorScheme.primary),
                  ),
          ),
        ],
      ),
    );
  }
}