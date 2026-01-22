import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../viewmodels/chat_viewmodel.dart';
import '../../../core/mock/mock_data.dart';
import 'chat_room_page.dart';

class RoomListPage extends StatefulWidget {
  const RoomListPage({super.key});

  @override
  State<RoomListPage> createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatViewModel>().loadRooms();
    });
  }

  void _showNewChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Chat'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: MockData.users.length,
            itemBuilder: (context, index) {
              final user = MockData.users[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(user.username[0].toUpperCase()),
                ),
                title: Text(user.username),
                subtitle: Text(user.email),
                onTap: () {
                  Navigator.pop(context);
                  context.read<ChatViewModel>().openChatWithUser(
                    user.id,
                    (roomId) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatRoomPage(
                          roomId: roomId,
                          roomName: user.username,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChatViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Messages")),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewChatDialog,
        child: const Icon(Icons.add),
      ),
      body: viewModel.isLoadingRooms
          ? const Center(child: CircularProgressIndicator())
          : viewModel.rooms.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No conversations yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap + to start a new chat',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: viewModel.rooms.length,
                  itemBuilder: (context, index) {
                    final room = viewModel.rooms[index];
                    DateTime? lastMessageTime;
                    try {
                      lastMessageTime = room['last_message_time'] != null
                          ? DateTime.parse(room['last_message_time'])
                          : null;
                    } catch (_) {}

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          (room['name'] ?? 'U')[0].toUpperCase(),
                        ),
                      ),
                      title: Text(
                        room['name'] ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        room['last_message'] ?? 'No messages yet',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: lastMessageTime != null
                          ? Text(
                              timeago.format(lastMessageTime),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            )
                          : null,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatRoomPage(
                            roomId: room['id'],
                            roomName: room['name'] ?? 'Conversation',
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}