import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chat_viewmodel.dart';
import 'chat_room_page.dart';

class RoomListPage extends StatelessWidget {
  const RoomListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Note: For a real app, you'd want a separate "RoomListViewModel"
    // For now, we will just use a FutureBuilder directly or the generic ChatViewModel logic
    
    return Scaffold(
      appBar: AppBar(title: const Text("Messages")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TEST: Hardcode a User ID to test the RPC
          context.read<ChatViewModel>().openChatWithUser(
            'TARGET_USER_UUID_HERE', 
            (roomId) => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatRoomPage(roomId: roomId)))
          );
        },
        child: const Icon(Icons.add),
      ),
      body: const Center(child: Text("List of rooms will go here")),
    );
  }
}