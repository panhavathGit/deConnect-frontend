// // lib/features/chat/views/chat_list_page.dart

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../core/app_export.dart';
// // import '../../../core/providers/theme_provider.dart';
// import '../viewmodels/chat_list_viewmodel.dart';
// import '../data/repositories/chat_repository_impl.dart';
// import '../data/datasources/chat_remote_data_source.dart';
// import 'chat_room_page.dart';
// import 'select_user_page.dart';
// import 'package:intl/intl.dart';
// import './create_group_page.dart';
// import './join_group_page.dart';
// import './your_group_page.dart';

// class ChatListPage extends StatelessWidget {
//   const ChatListPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => ChatListViewModel(
//         repository: ChatRepositoryImpl(
//           remoteDataSource: ChatRemoteDataSourceImpl(),
//         ),
//       )..loadChatRooms(),
//       child: const _ChatListPageContent(),
//     );
//   }
// }

// // ============================================================
// // CHANGED: StatefulWidget so we can use 'mounted'
// // ============================================================
// class _ChatListPageContent extends StatefulWidget {
//   const _ChatListPageContent();

//   @override
//   State<_ChatListPageContent> createState() => _ChatListPageContentState();
// }

// class _ChatListPageContentState extends State<_ChatListPageContent> {
//   @override
//   Widget build(BuildContext context) {
//     // final isDark = context.watch<ThemeProvider>().isDarkMode;
//     final isDark = false;

//     return Scaffold(
//       backgroundColor: isDark ? const Color(0xFF121212) : appTheme.white_A700,
//       appBar: AppBar(
//         title: Text(
//           'Messages',
//           style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
//             fontSize: 20,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: isDark ? const Color(0xFF1E1E1E) : appTheme.blue_900,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.folder_special),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const YourGroupsPage(),
//                 ),
//               );
//             },
//             tooltip: 'Your Groups',
//           ),
//           IconButton(
//             icon: const Icon(Icons.group),
//             onPressed: () async {
//               final result = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const JoinGroupPage(),
//                 ),
//               );
              
//               // Refresh if joined successfully
//               if (result == true && mounted) {
//                 context.read<ChatListViewModel>().refresh();
//               }
//             },
//             tooltip: 'Join Group',
//           ),
//           IconButton(
//             icon: const Icon(Icons.group_add),
//             onPressed: () {
//               // Navigate to user selection
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const CreateGroupPage(),
//                 ),
//               );
//             },
//           ),
//           // IconButton(
//           //   icon: const Icon(Icons.group),
//           //   onPressed: () {
//           //     // Navigate to user selection
//           //     Navigator.push(
//           //       context,
//           //       MaterialPageRoute(
//           //         builder: (context) => const JoinGroupPage(),
//           //       ),
//           //     );
//           //   },
//           // ),
//           IconButton(
//             icon: const Icon(Icons.add_comment),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const SelectUserPage(),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Consumer<ChatListViewModel>(
//         builder: (context, viewModel, _) {
//           if (viewModel.isLoading && viewModel.chatRooms.isEmpty) {
//             return Center(
//               child: CircularProgressIndicator(color: appTheme.blue_900),
//             );
//           }

//           if (viewModel.status == ChatListStatus.error) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.error_outline, size: 48, color: Colors.red),
//                   const SizedBox(height: 16),
//                   Text(
//                     viewModel.errorMessage ?? 'Failed to load chats',
//                     style: TextStyleHelper.instance.body15MediumInter.copyWith(
//                       color: isDark ? Colors.white : null,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () => viewModel.loadChatRooms(),
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             );
//           }

//           if (viewModel.chatRooms.isEmpty) {
//             return _buildEmptyState(isDark);
//           }

//           return RefreshIndicator(
//             onRefresh: () => viewModel.refresh(),
//             color: appTheme.blue_900,
//             child: ListView.separated(
//               itemCount: viewModel.chatRooms.length,
//               separatorBuilder: (context, index) => Divider(
//                 height: 1,
//                 color: isDark ? Colors.grey[800] : appTheme.blue_gray_100,
//               ),
//               itemBuilder: (context, index) {
//                 final room = viewModel.chatRooms[index];
//                 return _buildChatItem(context, room, isDark, viewModel);
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildEmptyState(bool isDark) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.chat_bubble_outline,
//             size: 64,
//             color: isDark ? Colors.grey[400] : appTheme.greyCustom,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No messages yet',
//             style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
//               color: isDark ? Colors.white : null,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Start a conversation!',
//             style: TextStyleHelper.instance.body15MediumInter.copyWith(
//               color: isDark ? Colors.grey[400] : appTheme.greyCustom,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Format time for chat list (Today: time, Yesterday, Weekday, or Date)
//   String _formatChatListTime(DateTime dateTime) {
//     final now = DateTime.now();
//     final localTime = dateTime.toLocal();
//     final today = DateTime(now.year, now.month, now.day);
//     final messageDate = DateTime(localTime.year, localTime.month, localTime.day);
//     final difference = today.difference(messageDate).inDays;

//     if (difference == 0) {
//       // Today - show time
//       return DateFormat('HH:mm').format(localTime);
//     } else if (difference == 1) {
//       // Yesterday
//       return 'Yesterday';
//     } else if (difference < 7) {
//       // This week - show day name
//       return DateFormat('EEE').format(localTime); // Mon, Tue, etc.
//     } else {
//       // Older - show date
//       return DateFormat('dd/MM/yy').format(localTime);
//     }
//   }

//   Widget _buildChatItem(BuildContext context, room, bool isDark, ChatListViewModel viewModel) {
//     final hasUnread = room.unreadCount > 0;
    
//     // Format time correctly with local timezone
//     String timeDisplay = '';
//     if (room.lastMessageTime != null) {
//       timeDisplay = _formatChatListTime(room.lastMessageTime!);
//     }

//     return ListTile(
//       tileColor: isDark ? const Color(0xFF121212) : null,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//       leading: Stack(
//         children: [
//           CircleAvatar(
//             radius: 28,
//             backgroundColor: isDark ? Colors.grey[800] : appTheme.blue_gray_100,
//             child: room.displayAvatar?.isNotEmpty == true
//                 ? ClipOval(
//                     child: Image.network(
//                       room.displayAvatar!,
//                       width: 56,
//                       height: 56,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) {
//                         return Icon(Icons.person, size: 32, color: isDark ? Colors.grey[400] : appTheme.greyCustom);
//                       },
//                       loadingBuilder: (context, child, loadingProgress) {
//                         if (loadingProgress == null) return child;
//                         return Icon(Icons.person, size: 32, color: isDark ? Colors.grey[400] : appTheme.greyCustom);
//                       },
//                     ),
//                   )
//                 : Icon(Icons.person, size: 32, color: isDark ? Colors.grey[400] : appTheme.greyCustom),
//           ),
//           // Show green dot for ONLINE users
//           if (room.otherUserIsOnline)
//             Positioned(
//               right: 0,
//               bottom: 0,
//               child: Container(
//                 width: 14,
//                 height: 14,
//                 decoration: BoxDecoration(
//                   color: Colors.green,
//                   shape: BoxShape.circle,
//                   border: Border.all(color: isDark ? const Color(0xFF121212) : Colors.white, width: 2),
//                 ),
//               ),
//             ),
//         ],
//       ),
//       title: Row(
//         children: [
//           Expanded(
//             child: Text(
//               room.displayName,
//               style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
//                 fontSize: 16,
//                 fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w400,
//                 color: isDark ? Colors.white : null,
//               ),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//           if (timeDisplay.isNotEmpty)
//             Text(
//               timeDisplay,
//               style: TextStyleHelper.instance.body12MediumRoboto.copyWith(
//                 color: hasUnread ? appTheme.blue_900 : (isDark ? Colors.grey[400] : appTheme.greyCustom),
//                 fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
//               ),
//             ),
//         ],
//       ),
//       subtitle: Row(
//         children: [
//           Expanded(
//             child: Text(
//               room.lastMessage ?? 'No messages yet',
//               style: TextStyleHelper.instance.body15MediumInter.copyWith(
//                 color: isDark ? Colors.grey[400] : appTheme.greyCustom,
//                 fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
//               ),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//           if (hasUnread)
//             Container(
//               margin: const EdgeInsets.only(left: 8),
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//               decoration: BoxDecoration(
//                 color: appTheme.blue_900,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 '${room.unreadCount}',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//         ],
//       ),
//       onTap: () async {
//         // Navigate to chat room and WAIT for it to close
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ChatRoomPage(
//               roomId: room.id,
//               roomName: room.displayName,
//               otherUserId: room.otherUserId,
//               initialLastSeenText: room.lastSeenText,
//               initialIsOnline: room.otherUserIsOnline,
//             ),
//           ),
//         );
//         // IMPORTANT: Refresh chat list when returning to update unread counts
//         // Now 'mounted' works because we're in a StatefulWidget
//         if (mounted) {
//           viewModel.refresh();
//         }
//       },
//     );
//   }
// }

// lib/features/chat/views/chat_list_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_export.dart';
import '../viewmodels/chat_list_viewmodel.dart';
import '../viewmodels/your_group_viewmodel.dart';
import '../data/repositories/chat_repository_impl.dart';
import '../data/datasources/chat_remote_data_source.dart';
import 'chat_room_page.dart';
import 'select_user_page.dart';
import 'package:intl/intl.dart';
import './create_group_page.dart';
import './join_group_page.dart';
import 'package:flutter/services.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ChatListViewModel(
            repository: ChatRepositoryImpl(
              remoteDataSource: ChatRemoteDataSourceImpl(),
            ),
          )..loadChatRooms(),
        ),
        ChangeNotifierProvider(
          create: (_) => YourGroupsViewModel(
            repository: ChatRepositoryImpl(
              remoteDataSource: ChatRemoteDataSourceImpl(),
            ),
          )..loadGroups(),
        ),
      ],
      child: const _ChatListPageContent(),
    );
  }
}

class _ChatListPageContent extends StatefulWidget {
  const _ChatListPageContent();

  @override
  State<_ChatListPageContent> createState() => _ChatListPageContentState();
}

class _ChatListPageContentState extends State<_ChatListPageContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          // Show different actions based on current tab
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, child) {
              if (_tabController.index == 0) {
                // Individual chats tab - show new chat button
                return IconButton(
                  icon: const Icon(Icons.add_comment),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SelectUserPage(),
                      ),
                    );
                  },
                  tooltip: 'New Chat',
                );
              } else {
                // Groups tab - show create and join group buttons
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.group_add),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateGroupPage(),
                          ),
                        );
                        if (result == true && mounted) {
                          context.read<YourGroupsViewModel>().loadGroups();
                        }
                      },
                      tooltip: 'Create Group',
                    ),
                    IconButton(
                      icon: const Icon(Icons.group),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const JoinGroupPage(),
                          ),
                        );
                        if (result == true && mounted) {
                          context.read<YourGroupsViewModel>().loadGroups();
                        }
                      },
                      tooltip: 'Join Group',
                    ),
                  ],
                );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyleHelper.instance.body15MediumInter.copyWith(
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Chats'),
            Tab(text: 'Groups'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Individual Chats Tab
          _buildChatsTab(isDark),
          // Groups Tab
          _buildGroupsTab(isDark),
        ],
      ),
    );
  }

  Widget _buildChatsTab(bool isDark) {
    return Consumer<ChatListViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading && viewModel.chatRooms.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: appTheme.blue_900),
          );
        }

        if (viewModel.status == ChatListStatus.error) {
          return _buildErrorState(
            isDark,
            viewModel.errorMessage ?? 'Failed to load chats',
            () => viewModel.loadChatRooms(),
          );
        }

        // Filter out group chats, show only direct messages
        final directChats = viewModel.chatRooms.where((room) => !room.isGroup).toList();

        if (directChats.isEmpty) {
          return _buildEmptyState(
            isDark,
            Icons.chat_bubble_outline,
            'No chats yet',
            'Start a conversation!',
          );
        }

        return RefreshIndicator(
          onRefresh: () => viewModel.refresh(),
          color: appTheme.blue_900,
          child: ListView.separated(
            itemCount: directChats.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: isDark ? Colors.grey[800] : appTheme.blue_gray_100,
            ),
            itemBuilder: (context, index) {
              final room = directChats[index];
              return _buildChatItem(context, room, isDark, viewModel);
            },
          ),
        );
      },
    );
  }

  Widget _buildGroupsTab(bool isDark) {
    return Consumer<YourGroupsViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: appTheme.blue_900),
          );
        }

        if (viewModel.errorMessage != null) {
          return _buildErrorState(
            isDark,
            viewModel.errorMessage!,
            () => viewModel.loadGroups(),
          );
        }

        if (viewModel.groups.isEmpty) {
          return _buildEmptyState(
            isDark,
            Icons.group_outlined,
            'No groups yet',
            'Create or join a group to get started!',
          );
        }

        return RefreshIndicator(
          onRefresh: () => viewModel.loadGroups(),
          color: appTheme.blue_900,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.groups.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final group = viewModel.groups[index];
              return _buildGroupCard(context, group, isDark);
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorState(bool isDark, String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              style: TextStyleHelper.instance.body15MediumInter.copyWith(
                color: isDark ? Colors.white : null,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: appTheme.blue_900,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: isDark ? Colors.grey[400] : appTheme.greyCustom,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
              color: isDark ? Colors.white : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyleHelper.instance.body15MediumInter.copyWith(
              color: isDark ? Colors.grey[400] : appTheme.greyCustom,
            ),
          ),
        ],
      ),
    );
  }

  String _formatChatListTime(DateTime dateTime) {
    final now = DateTime.now();
    final localTime = dateTime.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(localTime.year, localTime.month, localTime.day);
    final difference = today.difference(messageDate).inDays;

    if (difference == 0) {
      return DateFormat('HH:mm').format(localTime);
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return DateFormat('EEE').format(localTime);
    } else {
      return DateFormat('dd/MM/yy').format(localTime);
    }
  }

  Widget _buildChatItem(BuildContext context, room, bool isDark, ChatListViewModel viewModel) {
    final hasUnread = room.unreadCount > 0;
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
        if (mounted) {
          viewModel.refresh();
        }
      },
    );
  }

  Widget _buildGroupCard(BuildContext context, group, bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoomPage(
                roomId: group.roomId,
                roomName: group.roomName,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: appTheme.blue_900.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.group,
                      color: appTheme.blue_900,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.roomName,
                          style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.people, size: 14, color: appTheme.greyCustom),
                            const SizedBox(width: 4),
                            Text(
                              '${group.memberCount} member${group.memberCount != 1 ? 's' : ''}',
                              style: TextStyleHelper.instance.body12MediumRoboto.copyWith(
                                color: appTheme.greyCustom,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (group.isAdmin)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: appTheme.blue_900,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              if (group.lastMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: appTheme.grey100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 14, color: appTheme.greyCustom),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          group.lastMessage!,
                          style: TextStyleHelper.instance.body12MediumRoboto.copyWith(
                            color: appTheme.greyCustom,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (group.isAdmin && group.inviteCode.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invite Code',
                            style: TextStyleHelper.instance.body12MediumRoboto.copyWith(
                              color: appTheme.greyCustom,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: appTheme.blue_900.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: appTheme.blue_900.withOpacity(0.3)),
                            ),
                            child: Text(
                              group.inviteCode,
                              style: TextStyleHelper.instance.title18BoldSourceSerifPro.copyWith(
                                fontSize: 16,
                                color: appTheme.blue_900,
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: group.inviteCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Code copied: ${group.inviteCode}'),
                            backgroundColor: appTheme.greenCustom ?? Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      color: appTheme.blue_900,
                      tooltip: 'Copy code',
                      style: IconButton.styleFrom(
                        backgroundColor: appTheme.blue_900.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ],
              if (group.unreadCount > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${group.unreadCount} unread',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
