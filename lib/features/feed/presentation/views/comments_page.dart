// lib/features/feed/presentation/views/comments_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/app_export.dart';
import '../../data/models/feed_model.dart';

class CommentsPage extends StatefulWidget {
  final FeedPost post;

  const CommentsPage({super.key, required this.post});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _commentController = TextEditingController();

  // Mock comments data
  final List<Map<String, dynamic>> _comments = [
    {
      'author': 'John Doe',
      'comment': 'Great post! I visited Phnom Penh last year and it was amazing.',
      'time': '2 hours ago',
    },
    {
      'author': 'Sarah Smith',
      'comment': 'Thanks for sharing this. Very informative!',
      'time': '5 hours ago',
    },
    {
      'author': 'Mike Johnson',
      'comment': 'I agree! The city has so much to offer. Can\'t wait to go back.',
      'time': '1 day ago',
    },
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
      body: Column(
        children: [
          // Comments List
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: _comments.length,
              separatorBuilder: (context, index) => Divider(
                height: 32,
                color: appTheme.blue_gray_100,
              ),
              itemBuilder: (context, index) {
                return _buildCommentItem(_comments[index]);
              },
            ),
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
              child: _buildCommentInput(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: appTheme.blue_gray_100,
          ),
          child: Icon(Icons.person, size: 24, color: appTheme.greyCustom),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    comment['author'],
                    style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    comment['time'],
                    style: TextStyleHelper.instance.body12MediumRoboto.copyWith(
                      color: appTheme.greyCustom,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(
                comment['comment'],
                style: TextStyleHelper.instance.body15MediumInter.copyWith(
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
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
                hintText: 'Add a comment...',
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
                if (_commentController.text.isNotEmpty) {
                  setState(() {
                    _comments.insert(0, {
                      'author': 'You',
                      'comment': _commentController.text,
                      'time': 'Just now',
                    });
                  });
                  _commentController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Comment added!'),
                      backgroundColor: appTheme.green_700,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              icon: Icon(Icons.send, color: appTheme.blue_900),
            ),
          ),
        ],
      ),
    );
  }
}