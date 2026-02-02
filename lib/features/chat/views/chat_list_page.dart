// lib/features/chat/views/chat_list_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_export.dart';
// import '../../../core/providers/theme_provider.dart';
import '../viewmodels/chat_list_viewmodel.dart';
import '../data/repositories/chat_repository_impl.dart';
import '../data/datasources/chat_remote_data_source.dart';
import 'chat_room_page.dart';
import 'select_user_page.dart';
import 'package:intl/intl.dart';
import './create_group_page.dart';
import './join_group_page.dart';

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

// ============================================================
// CHANGED: StatefulWidget so we can use 'mounted'
// ============================================================
class _ChatListPageContent extends StatefulWidget {
  const _ChatListPageContent();

  @override
  State<_ChatListPageContent> createState() => _ChatListPageContentState();
}

class _ChatListPageContentState extends State<_ChatListPageContent> {
  @override
  Widget build(BuildContext context) {
    // final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isDark = false;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : appTheme.white_A700,
      appBar: AppBar(
        title: Text(
          'Messages',
          style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : appTheme.blue_900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () {
              // Navigate to user selection
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateGroupPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: () {
              // Navigate to user selection
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const JoinGroupPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_comment),
            onPressed: () {
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
          if (viewModel.isLoading && viewModel.chatRooms.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: appTheme.blue_900),
            );
          }

          if (viewModel.status == ChatListStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.errorMessage ?? 'Failed to load chats',
                    style: TextStyleHelper.instance.body15MediumInter.copyWith(
                      color: isDark ? Colors.white : null,
                    ),
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
            return _buildEmptyState(isDark);
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.refresh(),
            color: appTheme.blue_900,
            child: ListView.separated(
              itemCount: viewModel.chatRooms.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: isDark ? Colors.grey[800] : appTheme.blue_gray_100,
              ),
              itemBuilder: (context, index) {
                final room = viewModel.chatRooms[index];
                return _buildChatItem(context, room, isDark, viewModel);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: isDark ? Colors.grey[400] : appTheme.greyCustom,
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
              color: isDark ? Colors.white : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation!',
            style: TextStyleHelper.instance.body15MediumInter.copyWith(
              color: isDark ? Colors.grey[400] : appTheme.greyCustom,
            ),
          ),
        ],
      ),
    );
  }

  // Format time for chat list (Today: time, Yesterday, Weekday, or Date)
  String _formatChatListTime(DateTime dateTime) {
    final now = DateTime.now();
    final localTime = dateTime.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(localTime.year, localTime.month, localTime.day);
    final difference = today.difference(messageDate).inDays;

    if (difference == 0) {
      // Today - show time
      return DateFormat('HH:mm').format(localTime);
    } else if (difference == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference < 7) {
      // This week - show day name
      return DateFormat('EEE').format(localTime); // Mon, Tue, etc.
    } else {
      // Older - show date
      return DateFormat('dd/MM/yy').format(localTime);
    }
  }

  Widget _buildChatItem(BuildContext context, room, bool isDark, ChatListViewModel viewModel) {
    final hasUnread = room.unreadCount > 0;
    
    // Format time correctly with local timezone
    String timeDisplay = '';
    if (room.lastMessageTime != null) {
      timeDisplay = _formatChatListTime(room.lastMessageTime!);
    }

    return ListTile(
      tileColor: isDark ? const Color(0xFF121212) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: isDark ? Colors.grey[800] : appTheme.blue_gray_100,
            child: room.displayAvatar?.isNotEmpty == true
                ? ClipOval(
                    child: Image.network(
                      room.displayAvatar!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.person, size: 32, color: isDark ? Colors.grey[400] : appTheme.greyCustom);
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Icon(Icons.person, size: 32, color: isDark ? Colors.grey[400] : appTheme.greyCustom);
                      },
                    ),
                  )
                : Icon(Icons.person, size: 32, color: isDark ? Colors.grey[400] : appTheme.greyCustom),
          ),
          // Show green dot for ONLINE users
          if (room.otherUserIsOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: isDark ? const Color(0xFF121212) : Colors.white, width: 2),
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
                color: isDark ? Colors.white : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (timeDisplay.isNotEmpty)
            Text(
              timeDisplay,
              style: TextStyleHelper.instance.body12MediumRoboto.copyWith(
                color: hasUnread ? appTheme.blue_900 : (isDark ? Colors.grey[400] : appTheme.greyCustom),
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
                color: isDark ? Colors.grey[400] : appTheme.greyCustom,
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
      onTap: () async {
        // Navigate to chat room and WAIT for it to close
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomPage(
              roomId: room.id,
              roomName: room.displayName,
              otherUserId: room.otherUserId,
              initialLastSeenText: room.lastSeenText,
              initialIsOnline: room.otherUserIsOnline,
            ),
          ),
        );
        // IMPORTANT: Refresh chat list when returning to update unread counts
        // Now 'mounted' works because we're in a StatefulWidget
        if (mounted) {
          viewModel.refresh();
        }
      },
    );
  }
}
