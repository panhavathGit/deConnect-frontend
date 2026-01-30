// lib/features/chat/views/chat_list_page.dart
import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../viewmodels/chat_list_viewmodel.dart';
import '../data/repositories/chat_repository_impl.dart';
import '../data/datasources/chat_remote_data_source.dart';
import 'chat_room_page.dart';
import 'package:timeago/timeago.dart' as timeago;
import './select_user_page.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatListViewModel(
        repository: ChatRepositoryImpl(
          remoteDataSource: ChatRemoteDataSourceImpl(),
        ),
      )..loadChatRooms(),
      child: const _ChatListPageContent(),
    );
  }
}

class _ChatListPageContent extends StatelessWidget {
  const _ChatListPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      appBar: AppBar(
        title: Text(
          'Messages',
          style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: appTheme.blue_900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment),
            onPressed: () {
              // Navigate to user selection
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SelectUserPage(),
                ),
              );
            },
          ),
        ],
        
      ),
      body: Consumer<ChatListViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: appTheme.blue_900),
            );
          }

          if (viewModel.status == ChatListStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.errorMessage ?? 'Failed to load chats',
                    style: TextStyleHelper.instance.body15MediumInter,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadChatRooms(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.chatRooms.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.refresh(),
            color: appTheme.blue_900,
            child: ListView.separated(
              itemCount: viewModel.chatRooms.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: appTheme.blue_gray_100,
              ),
              itemBuilder: (context, index) {
                final room = viewModel.chatRooms[index];
                return _buildChatItem(context, room);
              },
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
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: appTheme.greyCustom,
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyleHelper.instance.title18BoldSourceSerifPro,
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation!',
            style: TextStyleHelper.instance.body15MediumInter.copyWith(
              color: appTheme.greyCustom,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, room) {
    final hasUnread = room.unreadCount > 0;
    final timeAgo = room.lastMessageTime != null
        ? timeago.format(room.lastMessageTime!)
        : '';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: appTheme.blue_gray_100,
            child: room.displayAvatar.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      room.displayAvatar,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.person, size: 32, color: appTheme.greyCustom);
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Icon(Icons.person, size: 32, color: appTheme.greyCustom);
                      },
                    ),
                  )
                : Icon(Icons.person, size: 32, color: appTheme.greyCustom),
          ),
          if (hasUnread)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              room.displayName,
              style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
                fontSize: 16,
                fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (timeAgo.isNotEmpty)
            Text(
              timeAgo,
              style: TextStyleHelper.instance.body12MediumRoboto.copyWith(
                color: hasUnread ? appTheme.blue_900 : appTheme.greyCustom,
                fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              room.lastMessage ?? 'No messages yet',
              style: TextStyleHelper.instance.body15MediumInter.copyWith(
                color: appTheme.greyCustom,
                fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasUnread)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: appTheme.blue_900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${room.unreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomPage(
              roomId: room.id,
              roomName: room.displayName,
            ),
          ),
        );
      },
    );
  }
}