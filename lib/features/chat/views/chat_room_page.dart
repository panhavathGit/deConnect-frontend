// lib/features/chat/views/chat_room_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../../../core/app_export.dart';
import '../viewmodels/chat_room_viewmodel.dart';
import '../data/repositories/chat_repository_impl.dart';
import '../data/datasources/chat_remote_data_source.dart';

class ChatRoomPage extends StatelessWidget {
  final String roomId;
  final String roomName;

  const ChatRoomPage({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatRoomViewModel(
        repository: ChatRepositoryImpl(
          remoteDataSource: ChatRemoteDataSourceImpl(),
        ),
        roomId: roomId,
      )..loadMessages(),
      child: _ChatRoomPageContent(roomName: roomName),
    );
  }
}

class _ChatRoomPageContent extends StatelessWidget {
  final String roomName;

  const _ChatRoomPageContent({required this.roomName});

  void _handleSendPressed(BuildContext context, types.PartialText message) async {
    final viewModel = context.read<ChatRoomViewModel>();
    await viewModel.sendMessage(message.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          roomName,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF053CC7),
        foregroundColor: Colors.white,
      ),
      body: Consumer<ChatRoomViewModel>(
        builder: (context, viewModel, _) {
          // Debug print
          debugPrint('🔍 ChatRoom Status: ${viewModel.status}, Loading: ${viewModel.isLoading}, Messages: ${viewModel.messages.length}');
          
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF053CC7),
              ),
            );
          }

          if (viewModel.status == ChatRoomStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      viewModel.errorMessage ?? 'Failed to load messages',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadMessages(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Convert ChatMessage to flutter_chat_types Message
          final chatMessages = viewModel.messages.map((msg) {
            final isCurrentUser = msg.senderId == viewModel.currentUserId;
            
            return types.TextMessage(
              author: types.User(
                id: msg.senderId,
                firstName: msg.senderName ?? 'User',
                imageUrl: msg.senderAvatar,
              ),
              createdAt: msg.createdAt.millisecondsSinceEpoch,
              id: msg.id,
              text: msg.content,
              status: isCurrentUser ? types.Status.sent : null,
            );
          }).toList();

          return Chat(
            messages: chatMessages,
            onSendPressed: (message) => _handleSendPressed(context, message),
            user: types.User(
              id: viewModel.currentUserId,
              firstName: 'You',
            ),
            theme: DefaultChatTheme(
              backgroundColor: Colors.white,
              primaryColor: const Color(0xFF053CC7),
              secondaryColor: const Color(0xFFF5F5F5),
              inputBackgroundColor: const Color(0xFFF5F5F5),
              inputTextColor: Colors.black,
              inputBorderRadius: BorderRadius.circular(24),
              messageBorderRadius: 20,
              sentMessageBodyTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              receivedMessageBodyTextStyle: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
            showUserAvatars: true,
            showUserNames: true,
            emptyState: const Center(
              child: Text(
                'No messages here yet',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
}