// lib/features/feed/presentation/views/comments_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/app_export.dart';
import '../../data/models/feed_model.dart';
import '../../data/models/comment_model.dart';
import '../../data/repositories/comment_repository_impl.dart';
import '../../data/datasources/comment_remote_data_source.dart';
import '../../data/datasources/comment_mock_data_source.dart';
import '../viewmodels/comment_viewmodel.dart';
import '../../../../core/services/supabase_service.dart'; 

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
            backgroundColor: appTheme.greenCustom,
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

  // void _showDeleteDialog(CommentModel comment) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Delete Comment'),
  //       content: Text('Are you sure you want to delete this comment?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () async {
  //             Navigator.pop(context);
  //             final viewModel = context.read<CommentViewModel>();
  //             final success = await viewModel.deleteComment(comment.id);
              
  //             if (mounted) {
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(
  //                   content: Text(success ? 'Comment deleted' : 'Failed to delete comment'),
  //                   backgroundColor: success ? appTheme.greenCustom : Colors.red,
  //                 ),
  //               );
  //             }
  //           },
  //           child: Text('Delete', style: TextStyle(color: Colors.red)),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
                    backgroundColor: success ? appTheme.greenCustom : Colors.red,
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
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      appBar: AppBar(
        backgroundColor: appTheme.white_A700,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appTheme.black_900),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Comments',
          style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: appTheme.blue_gray_100),
        ),
      ),
      body: Consumer<CommentViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              // Comments List
              Expanded(
                child: _buildCommentsList(viewModel),
              ),

              // Comment Input at Bottom
              Container(
                decoration: BoxDecoration(
                  color: appTheme.white_A700,
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
                  child: _buildCommentInput(viewModel),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCommentsList(CommentViewModel viewModel) {
    if (viewModel.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: appTheme.blue_900),
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
              style: TextStyleHelper.instance.body15MediumInter,
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
            Icon(Icons.comment_outlined, size: 64, color: appTheme.greyCustom),
            SizedBox(height: 16),
            Text(
              'No comments yet',
              style: TextStyleHelper.instance.title18BoldSourceSerifPro,
            ),
            SizedBox(height: 8),
            Text(
              'Be the first to comment!',
              style: TextStyleHelper.instance.body15MediumInter.copyWith(
                color: appTheme.greyCustom,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.loadComments(),
      color: appTheme.blue_900,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: viewModel.comments.length,
        separatorBuilder: (context, index) => Divider(
          height: 32,
          color: appTheme.blue_gray_100,
        ),
        itemBuilder: (context, index) {
          return _buildCommentItem(viewModel.comments[index], viewModel);
        },
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment, CommentViewModel viewModel) {
    // Get current user ID from Supabase
    final currentUserId = SupabaseService.client.auth.currentUser?.id ?? '';
    final isOwn = comment.isOwnComment(currentUserId);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: appTheme.blue_gray_100,
          ),
          child: comment.authorAvatar != null
              ? ClipOval(
                  child: Image.network(
                    comment.authorAvatar!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.person,
                      size: 24,
                      color: appTheme.greyCustom,
                    ),
                  ),
                )
              : Icon(Icons.person, size: 24, color: appTheme.greyCustom),
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
                            style: TextStyleHelper.instance.title18BoldSourceSerifPro
                                .copyWith(fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          comment.getTimeAgo(),
                          style: TextStyleHelper.instance.body12MediumRoboto
                              .copyWith(color: appTheme.greyCustom),
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
                style: TextStyleHelper.instance.body15MediumInter.copyWith(
                  height: 1.4,
                ),
              ),
              if (comment.updatedAt != null) ...[
                SizedBox(height: 4),
                Text(
                  '(edited)',
                  style: TextStyleHelper.instance.body12MediumRoboto.copyWith(
                    color: appTheme.greyCustom,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentInput(CommentViewModel viewModel) {
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
                hintText: 'Add a comment...',
                hintStyle: TextStyleHelper.instance.body15MediumInter.copyWith(
                  color: appTheme.greyCustom,
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
                      style: TextStyle(fontSize: 11, color: appTheme.greyCustom),
                    ),
                  );
                }
                return null;
              },
              style: TextStyleHelper.instance.body15MediumInter,
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
                      color: appTheme.blue_900,
                    ),
                  )
                : IconButton(
                    onPressed: _addComment,
                    icon: Icon(Icons.send, color: appTheme.blue_900),
                  ),
          ),
        ],
      ),
    );
  }
}